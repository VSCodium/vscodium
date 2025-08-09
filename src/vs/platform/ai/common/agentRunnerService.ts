/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import { Emitter, Event } from 'vs/base/common/event';
import { IAgentDefinition, IAgentRequest, IAgentTask, IAgentRunnerService, IAgentTool, IAgentToolsService, LlmActionResponse, AgentTaskStatus, IAgentActivity } from 'vs/platform/ai/common/aiTypes';
import { IInstantiationService } from 'vs/platform/instantiation/common/instantiation';
import { ILogService } from 'vs/platform/log/common/log';
import { IAgentDefinitionService } from 'vs/platform/ai/common/agentDefinitionService';
import { IAgentTaskStoreService } from 'vs/platform/ai/common/agentTaskStoreService';
import { ILlmCommsService } from 'vs/platform/ai/common/llmCommsService';
import { IWorkspaceContextService } from 'vs/platform/workspace/common/workspace';
import { URI } from 'vs/base/common/uri';
import { AgentPerformanceMonitorService, IAgentPerformanceMonitorService } from 'vs/platform/ai/common/agentPerformanceMonitorService';
import { IAgentTaskMetrics } from 'vs/platform/ai/common/agentMetrics';
import { IFileService } from 'vs/platform/files/common/files';
import { UserRequestInputTool } from 'vs/platform/ai/common/tools/userRequestInputTool';

interface IWaitingForUserInputState {
	task: IAgentTask;
	agent: IAgentDefinition;
	request: IAgentRequest;
	resolve: (result: any) => void;
	reject: (reason?: any) => void;
}

// TODO: an actual implementation of this
const vscode_executeTerminalCommand_SANDBOXED = (command: string, args: string[], cwd: URI, onOutput: (output: string) => void, onExit: (error?: any) => void) => {
	onOutput(`> ${command} ${args.join(' ')}\n`);
	// mock implementations
	onExit();
};

export class AgentRunnerService implements IAgentRunnerService {
	_serviceBrand: undefined;

	private readonly _onAgentActivity = new Emitter<IAgentActivity>();
	readonly onAgentActivity: Event<IAgentActivity> = this._onAgentActivity.event;

	private readonly _waitingForUserInput = new Map<string, IWaitingForUserInputState>();

	private readonly performanceMonitorService: IAgentPerformanceMonitorService;

	constructor(
		@IInstantiationService private readonly instantiationService: IInstantiationService,
		@ILogService private readonly logService: ILogService,
		@IAgentDefinitionService private readonly agentDefinitionService: IAgentDefinitionService,
		@IAgentToolsService private readonly agentToolsService: IAgentToolsService,
		@IAgentTaskStoreService private readonly agentTaskStoreService: IAgentTaskStoreService,
		@ILlmCommsService private readonly llmCommsService: ILlmCommsService,
		@IWorkspaceContextService private readonly workspaceContextService: IWorkspaceContextService,
		@IFileService private readonly fileService: IFileService,
	) {
		// Workaround for not being able to find the service registration file
		this.performanceMonitorService = new AgentPerformanceMonitorService(this.logService, this.fileService, this.workspaceContextService);
	}

	private async _executeAgentTask(taskId: string, agent: IAgentDefinition, request: IAgentRequest): Promise<any> {
		this.logService.info(`[AgentRunnerService] Executing agent task ${taskId} for agent ${agent.name}`);
		const workspaceFolders = this.workspaceContextService.getWorkspace().folders;
		const projectRoot: URI | undefined = workspaceFolders.length > 0 ? workspaceFolders[0].uri : undefined;

		let llmCalls = 0;
		let toolCalls = 0;
		let errorCount = 0;

		try {
			const MAX_ITERATIONS = 20;
			let iteration = 0;
			let prompt = `${agent.initial_prompt_template}\n\n## Current Task\nUser provided input: ${request.message}\n\n`;

			while (iteration < MAX_ITERATIONS) {
				iteration++;
				this.logService.info(`[AgentRunnerService] Iteration ${iteration} for task ${taskId}`);

				const tools = agent.tools.map(toolName => this.agentToolsService.getTool(toolName)).filter(t => !!t) as IAgentTool[];
				const toolDefinitions = tools.map(t => `### ${t.name}\n${t.description}\nInput schema: ${JSON.stringify(t.inputSchema, null, 2)}`).join('\n\n');
				const fullPrompt = `${prompt}\n\n## Available Tools\n${toolDefinitions}\n\nRespond with a single JSON object matching the LlmActionResponse schema.`;

				llmCalls++;
				const response = await this.llmCommsService.sendMessage(taskId, {
					prompt: fullPrompt,
					model: agent.model,
				});

				let action: LlmActionResponse;
				try {
					action = JSON.parse(response.content) as LlmActionResponse;
				} catch (e) {
					this.logService.error(`[AgentRunnerService] Failed to parse LLM response for task ${taskId}: ${response.content}`);
					prompt += `\n\nYour last response was not valid JSON. Please correct it. The error was: ${e}.`;
					errorCount++;
					continue;
				}

				if (action.tool) {
					if (action.tool === UserRequestInputTool.toolName) {
						this.logService.info(`[AgentRunnerService] Task ${taskId} is waiting for user input.`);
						const task = await this.agentTaskStoreService.getTask(taskId);
						if (task) {
							task.status = 'waiting';
							await this.agentTaskStoreService.updateTask(task);
						}

						this._onAgentActivity.fire({ type: 'waitingForUserInput', taskId, message: action.args.message });

						const userInput = await new Promise((resolve, reject) => {
							this._waitingForUserInput.set(taskId, { task: task!, agent, request, resolve, reject });
						});

						prompt += `\n\nI have used the tool '${action.tool}' and the user responded with: ${JSON.stringify(userInput)}`;
						continue;
					}

					const tool = this.agentToolsService.getTool(action.tool);
					if (tool) {
						this.logService.info(`[AgentRunnerService] Task ${taskId} is using tool ${tool.name}`);
						toolCalls++;
						const toolResult = await tool.execute(action.args, {
							projectRoot,
							executeTerminalCommand: (command, args, cwd) => new Promise((resolve, reject) => vscode_executeTerminalCommand_SANDBOXED(command, args, cwd, (output) => this.logService.info(output), (error) => error ? reject(error) : resolve('Command executed successfully')))
						});
						prompt += `\n\nI have used the tool '${tool.name}' with arguments ${JSON.stringify(action.args)}. The result was: ${toolResult}`;
					} else {
						prompt += `\n\nI tried to use a tool named '${action.tool}' but it is not available.`;
						errorCount++;
					}
				} else if (action.delegate) {
					this.logService.info(`[AgentRunnerService] Task ${taskId} is delegating to agent ${action.delegate}`);
					const delegateAgent = this.agentDefinitionService.getAgent(action.delegate);
					if (delegateAgent) {
						const subtaskRequest: IAgentRequest = { message: action.args.message, };
						const subtaskId = await this.runAgent(action.delegate, subtaskRequest, taskId);
						const subtaskResult = await this.agentTaskStoreService.getTask(subtaskId);
						prompt += `\n\nI have delegated a subtask to '${action.delegate}'. The result was: ${subtaskResult?.output}`;
					} else {
						prompt += `\n\nI tried to delegate to an agent named '${action.delegate}' but it is not available.`;
						errorCount++;
					}
				} else if (action.result) {
					this.logService.info(`[AgentRunnerService] Task ${taskId} produced a result.`);
					const task = await this.agentTaskStoreService.getTask(taskId);
					if (task) {
						task.output = action.result;
						task.status = 'completed';
						await this.agentTaskStoreService.updateTask(task);
					}
					return action.result;
				}
			}
			throw new Error(`Agent ${agent.name} exceeded max iterations.`);
		} finally {
			const task = await this.agentTaskStoreService.getTask(taskId);
			if (task && (task.status === 'completed' || task.status === 'failed')) {
				const metrics: IAgentTaskMetrics = {
					taskId: task.id,
					agentName: task.agentName,
					status: task.status,
					startTime: task.startTime || Date.now(),
					endTime: Date.now(),
					durationMs: Date.now() - (task.startTime || Date.now()),
					llmCalls,
					toolCalls,
					errorCount: task.status === 'failed' ? errorCount + 1 : errorCount,
				};
				this.performanceMonitorService.recordTaskMetrics(metrics);
			}
		}
	}

	public async runAgent(agentName: string, request: IAgentRequest, parentTaskId?: string | undefined): Promise<string> {
		this.logService.info(`[AgentRunnerService] Received request to run agent ${agentName}`);
		const agent = this.agentDefinitionService.getAgent(agentName);
		if (!agent) {
			throw new Error(`Agent ${agentName} not found.`);
		}

		const task: IAgentTask = {
			id: `${agentName}_${Date.now()}`,
			agentName: agentName,
			request: request,
			status: 'pending',
			startTime: Date.now(),
			parentTaskId: parentTaskId,
			history: [],
		};
		await this.agentTaskStoreService.addTask(task);

		this._executeAgentTask(task.id, agent, request).catch(e => {
			this.logService.error(`[AgentRunnerService] Error executing agent task ${task.id}: ${e}`);
			task.status = 'failed';
			task.output = e.message;
			this.agentTaskStoreService.updateTask(task);
		});

		return task.id;
	}

	public async resolveUserInput(taskId: string, userInput: any): Promise<void> {
		const waitingTask = this._waitingForUserInput.get(taskId);
		if (!waitingTask) {
			this.logService.warn(`[AgentRunnerService] No task found waiting for user input with id ${taskId}`);
			return;
		}

		this.logService.info(`[AgentRunnerService] Received user input for task ${taskId}`);
		this._waitingForUserInput.delete(taskId);

		const task = await this.agentTaskStoreService.getTask(taskId);
		if (task) {
			task.status = 'running';
			await this.agentTaskStoreService.updateTask(task);
		}

		waitingTask.resolve({ userInput });
	}
}
