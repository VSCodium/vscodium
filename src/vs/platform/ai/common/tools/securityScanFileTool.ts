/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import { IAgentTool, IAgentToolExecuteArg, IAgentToolExecuteResult } from 'vs/platform/ai/common/aiTypes';
import { ILogService } from 'vs/platform/log/common/log';

interface ISecurityScanFileArgs {
	file_path: string;
}

interface IBanditIssue {
	filename: string;
	issue_severity: 'LOW' | 'MEDIUM' | 'HIGH';
	issue_confidence: 'LOW' | 'MEDIUM' | 'HIGH';
	issue_text: string;
	line_number: number;
	test_id: string;
}

interface IBanditResults {
	results: IBanditIssue[];
}

export class SecurityScanFileTool implements IAgentTool {
	readonly name = 'security.scanFile';
	readonly description = 'Scans a single Python file for common security vulnerabilities using the "bandit" tool.';

	constructor(
		@ILogService private readonly logService: ILogService,
	) { }

	readonly inputSchema = {
		type: 'object',
		properties: {
			file_path: {
				type: 'string',
				description: 'The path to the Python file to scan.',
				required: true
			}
		},
	};

	async execute(args: ISecurityScanFileArgs, context: IAgentToolExecuteArg): Promise<IAgentToolExecuteResult> {
		if (!args.file_path) {
			return {
				result: 'Error: file_path argument is missing.',
				isError: true,
			};
		}

		const command = 'bandit';
		const commandArgs = ['-f', 'json', '-q', args.file_path];

		try {
			const termResult = await context.executeTerminalCommand(command, commandArgs, context.projectRoot);
			this.logService.info(`[SecurityScanFileTool] bandit command stdout for ${args.file_path}:\n${termResult.stdout}`);

			// Bandit exits with a non-zero code if issues are found, but this is not a tool error.
			// We rely on parsing the JSON output.
			if (termResult.stdout) {
				try {
					const banditOutput: IBanditResults = JSON.parse(termResult.stdout);
					return {
						result: banditOutput.results || [], // Return the array of issues
					};
				} catch (e) {
					this.logService.error(`[SecurityScanFileTool] Failed to parse bandit JSON output for ${args.file_path}. Error: ${e}. Raw output: ${termResult.stdout}`);
					return {
						result: `Error: Failed to parse bandit JSON output. Raw output: ${termResult.stdout}`,
						isError: true,
					};
				}
			}

			// If stdout is empty, it might mean no issues were found or an error occurred that didn't go to stdout.
			if (termResult.stderr) {
				this.logService.warn(`[SecurityScanFileTool] bandit command stderr for ${args.file_path}:\n${termResult.stderr}`);
			}
			return {
				result: [], // No issues found
			};

		} catch (e: any) {
			this.logService.error(`[SecurityScanFileTool] Error executing bandit command for ${args.file_path}:`, e);
			return {
				result: `Error executing bandit command: ${e.message || e}`,
				isError: true,
			};
		}
	}
}
