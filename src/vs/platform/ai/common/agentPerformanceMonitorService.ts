/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import { createDecorator } from 'vs/platform/instantiation/common/instantiation';
import { IAgentTaskMetrics } from 'vs/platform/ai/common/agentMetrics';
import { ILogService } from 'vs/platform/log/common/log';
import { IFileService } from 'vs/platform/files/common/files';
import { IWorkspaceContextService } from 'vs/platform/workspace/common/workspace';
import { URI } from 'vs/base/common/uri';
import { VSBuffer } from 'vs/base/common/buffer';

export const IAgentPerformanceMonitorService = createDecorator<IAgentPerformanceMonitorService>('agentPerformanceMonitorService');

export interface IAgentPerformanceMonitorService {
	readonly _serviceBrand: undefined;

	/**
	 * Records the performance metrics for a completed agent task.
	 * @param metrics The performance metrics to record.
	 */
	recordTaskMetrics(metrics: IAgentTaskMetrics): void;
}

export class AgentPerformanceMonitorService implements IAgentPerformanceMonitorService {
	readonly _serviceBrand: undefined;

	private static readonly LOG_FILE_NAME = '.weezy/performance_log.jsonl';

	constructor(
		@ILogService private readonly logService: ILogService,
		@IFileService private readonly fileService: IFileService,
		@IWorkspaceContextService private readonly workspaceContextService: IWorkspaceContextService,
	) { }

	async recordTaskMetrics(metrics: IAgentTaskMetrics): Promise<void> {
		// Log to console
		this.logService.info(`[AgentPerformanceMonitorService] Recording task metrics for ${metrics.taskId}:`, JSON.stringify(metrics, null, 2));

		// Log to file
		const workspaceFolders = this.workspaceContextService.getWorkspace().folders;
		if (workspaceFolders.length === 0) {
			this.logService.warn('[AgentPerformanceMonitorService] No workspace folder found. Cannot write performance log.');
			return;
		}
		const projectRoot = workspaceFolders[0].uri;
		const logFileUri = URI.joinPath(projectRoot, AgentPerformanceMonitorService.LOG_FILE_NAME);

		const logLine = JSON.stringify(metrics) + '\n';
		const content = VSBuffer.fromString(logLine);

		try {
			// Ensure directory exists
			await this.fileService.createFolder(URI.joinPath(projectRoot, '.weezy'));

			// Append to file
			if (await this.fileService.exists(logFileUri)) {
				await this.fileService.append(logFileUri, content);
			} else {
				await this.fileService.createFile(logFileUri, content, { overwrite: false });
			}
			this.logService.info(`[AgentPerformanceMonitorService] Successfully wrote metrics for task ${metrics.taskId} to ${logFileUri.toString()}`);
		} catch (error) {
			this.logService.error(`[AgentPerformanceMonitorService] Failed to write performance log to ${logFileUri.toString()}:`, error);
		}
	}
}
