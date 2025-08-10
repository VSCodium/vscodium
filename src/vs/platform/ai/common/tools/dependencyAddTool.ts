/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import { IAgentTool, IAgentToolExecuteArg, IAgentToolExecuteResult } from 'vs/platform/ai/common/aiTypes';
import { IFileService } from 'vs/platform/files/common/files';
import { ILogService } from 'vs/platform/log/common/log';
import { URI } from 'vs/base/common/uri';
import { VSBuffer } from 'vs/base/common/buffer';

interface IAddDependencyArgs {
	package_name: string;
	version?: string;
}

const REQUIREMENTS_FILE_NAME = 'requirements.txt';

export class DependencyAddTool implements IAgentTool {
	readonly name = 'dependency.add';
	readonly description = 'Adds a Python package to the requirements.txt file and installs all requirements.';

	constructor(
		@ILogService private readonly logService: ILogService,
		@IFileService private readonly fileService: IFileService,
	) { }

	readonly inputSchema = {
		type: 'object',
		properties: {
			package_name: {
				type: 'string',
				description: 'The name of the Python package to add (e.g., "requests").',
				required: true
			},
			version: {
				type: 'string',
				description: 'Optional. The specific version of the package (e.g., "2.28.1").',
				required: false
			}
		},
	};

	async execute(args: IAddDependencyArgs, context: IAgentToolExecuteArg): Promise<IAgentToolExecuteResult> {
		if (!args.package_name) {
			return {
				result: 'Error: package_name argument is missing.',
				isError: true,
			};
		}

		if (!context.projectRoot) {
			return {
				result: 'Error: No project root is available in the current context.',
				isError: true,
			};
		}

		const requirementsUri = URI.joinPath(context.projectRoot, REQUIREMENTS_FILE_NAME);
		const requirementString = args.version ? `${args.package_name}==${args.version}\n` : `${args.package_name}\n`;

		try {
			// Step 1: Append the dependency to requirements.txt
			const content = VSBuffer.fromString(requirementString);
			if (await this.fileService.exists(requirementsUri)) {
				await this.fileService.append(requirementsUri, content);
			} else {
				await this.fileService.createFile(requirementsUri, content, { overwrite: false });
			}
			this.logService.info(`[DependencyAddTool] Appended '${requirementString.trim()}' to ${requirementsUri.toString()}`);

			// Step 2: Install dependencies using pip
			this.logService.info(`[DependencyAddTool] Running pip install...`);
			const installCommand = 'python';
			const installArgs = ['-m', 'pip', 'install', '-r', requirementsUri.fsPath];
			const installResult = await context.executeTerminalCommand(installCommand, installArgs, context.projectRoot);

			if (installResult.exitCode !== 0) {
				const errorMessage = `Failed to install dependencies. Exit code: ${installResult.exitCode}. Stderr: ${installResult.stderr}`;
				this.logService.error(`[DependencyAddTool] ${errorMessage}`);
				return {
					result: errorMessage,
					isError: true,
				};
			}

			const successMessage = `Successfully added '${args.package_name}' and installed dependencies.`;
			this.logService.info(`[DependencyAddTool] ${successMessage}`);
			return {
				result: successMessage,
			};

		} catch (e: any) {
			this.logService.error(`[DependencyAddTool] Error adding dependency:`, e);
			return {
				result: `Error adding dependency: ${e.message}`,
				isError: true,
			};
		}
	}
}
