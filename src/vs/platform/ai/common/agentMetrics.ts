/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import { AgentTaskStatus } from 'vs/platform/ai/common/aiTypes';

/**
 * Interface for storing performance metrics of a completed agent task.
 */
export interface IAgentTaskMetrics {
	/**
	 * The unique identifier for the task.
	 */
	readonly taskId: string;

	/**
	 * The name of the agent that executed the task.
	 */
	readonly agentName: string;

	/**
	 * The terminal status of the task.
	 */
	readonly status: AgentTaskStatus;

	/**
	 * The Unix timestamp (ms) when the task started processing.
	 */
	readonly startTime: number;

	/**
	 * The Unix timestamp (ms) when the task reached a terminal state.
	 */
	readonly endTime: number;

	/**
	 * The total duration of the task in milliseconds.
	 */
	readonly durationMs: number;

	/**
	 * The number of calls made to the Language Model (LLM) during the task.
	 */
	readonly llmCalls: number;

	/**
	 * The number of tools executed during the task.
	 */
	readonly toolCalls: number;

	/**
	 * A count of errors encountered during the task.
	 */
	readonly errorCount: number;
}
