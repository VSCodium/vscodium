/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import { IAgentTool, IAgentToolExecuteArg, IAgentToolExecuteResult } from 'vs/platform/ai/common/aiTypes';
import { IFileService } from 'vs/platform/files/common/files';
import { ILogService } from 'vs/platform/log/common/log';
import { URI } from 'vs/base/common/uri';
import { VSBuffer } from 'vs/base/common/buffer';

interface IUpdateTaskStatusArgs {
	task_id: string;
	status: 'todo' | 'in_progress' | 'in_testing' | 'done' | 'failed';
}

// Assuming ITask is defined elsewhere, but for clarity:
interface ITask {
	id: string;
	title: string;
	description: string;
	status: string;
	epic_id?: string;
}

const TASKS_FILE_NAME = 'PROJECT_TASKS.json';

export class PMUpdateTaskStatusTool implements IAgentTool {
	readonly name = 'pm.updateTaskStatus';
	readonly description = 'Updates the status of a single task in the PROJECT_TASKS.json file.';

	constructor(
		@ILogService private readonly logService: ILogService,
		@IFileService private readonly fileService: IFileService,
	) { }

	readonly inputSchema = {
		type: 'object',
		properties: {
			task_id: {
				type: 'string',
				description: 'The unique identifier of the task to update.',
				required: true
			},
			status: {
				type: 'string',
				description: 'The new status for the task.',
				enum: ['todo', 'in_progress', 'in_testing', 'done', 'failed'],
				required: true
			}
		},
	};

	async execute(args: IUpdateTaskStatusArgs, context: IAgentToolExecuteArg): Promise<IAgentToolExecuteResult> {
		if (!args.task_id || !args.status) {
			return {
				result: 'Error: task_id and status arguments are required.',
				isError: true,
			};
		}

		if (!context.projectRoot) {
			return {
				result: 'Error: No project root is available in the current context.',
				isError: true,
			};
		}

		const tasksJsonUri = URI.joinPath(context.projectRoot, TASKS_FILE_NAME);
		let tasks: ITask[] = [];

		try {
			if (await this.fileService.exists(tasksJsonUri)) {
				const content = await this.fileService.readFile(tasksJsonUri);
				tasks = JSON.parse(content.toString());
			} else {
				return {
					result: `Error: The task file ${TASKS_FILE_NAME} does not exist.`,
					isError: true,
				};
			}

			const taskIndex = tasks.findIndex(t => t.id === args.task_id);
			if (taskIndex === -1) {
				return {
					result: `Error: Task with ID '${args.task_id}' not found.`,
					isError: true,
				};
			}

			tasks[taskIndex].status = args.status;

			const updatedContent = VSBuffer.fromString(JSON.stringify(tasks, null, 2));
			await this.fileService.writeFile(tasksJsonUri, updatedContent);

			this.logService.info(`[PMUpdateTaskStatusTool] Successfully updated task '${args.task_id}' to status '${args.status}'.`);
			return {
				result: `Successfully updated task '${args.task_id}' to status '${args.status}'.`,
			};

		} catch (e: any) {
			this.logService.error(`[PMUpdateTaskStatusTool] Error updating task status:`, e);
			return {
				result: `Error processing task file: ${e.message}`,
				isError: true,
			};
		}
	}
}
