/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import { IAgentTool, IAgentToolsService } from 'vs/platform/ai/common/aiTypes';
import { IInstantiationService } from 'vs/platform/instantiation/common/instantiation';
import { ILogService } from 'vs/platform/log/common/log';
import { GitInitTool } from 'vs/platform/ai/common/tools/gitInitTool';
import { ProjectInitializeWorkspaceTool } from 'vs/platform/ai/common/tools/projectInitializeWorkspaceTool';
import { ProjectScaffoldDirectoryTool } from 'vs/platform/ai/common/tools/projectScaffoldDirectoryTool';
import { FileWriteTool } from 'vs/platform/ai/common/tools/fileWriteTool';
import { FileReadTool } from 'vs/platform/ai/common/tools/fileReadTool';
import { PMUpsertTaskTool } from 'vs/platform/ai/common/tools/pmUpsertTaskTool';
import { UserRequestInputTool } from 'vs/platform/ai/common/tools/userRequestInputTool';
import { SecurityScanFileTool } from 'vs/platform/ai/common/tools/securityScanFileTool';
import { PMUpdateTaskStatusTool } from 'vs/platform/ai/common/tools/pmUpdateTaskStatusTool';
import { DependencyAddTool } from 'vs/platform/ai/common/tools/dependencyAddTool';

export class AgentToolsService implements IAgentToolsService {
	_serviceBrand: undefined;

	private readonly _tools: Map<string, IAgentTool> = new Map();

	constructor(
		@IInstantiationService private readonly instantiationService: IInstantiationService,
		@ILogService private readonly logService: ILogService,
	) {
		this.registerTool(this.instantiationService.createInstance(GitInitTool));
		this.registerTool(this.instantiationService.createInstance(ProjectInitializeWorkspaceTool));
		this.registerTool(this.instantiationService.createInstance(ProjectScaffoldDirectoryTool));
		this.registerTool(this.instantiationService.createInstance(FileWriteTool));
		this.registerTool(this.instantiationService.createInstance(FileReadTool));
		this.registerTool(this.instantiationService.createInstance(PMUpsertTaskTool));
		this.registerTool(this.instantiationService.createInstance(UserRequestInputTool));
		this.registerTool(this.instantiationService.createInstance(SecurityScanFileTool));
		this.registerTool(this.instantiationService.createInstance(PMUpdateTaskStatusTool));
		this.registerTool(this.instantiationService.createInstance(DependencyAddTool));
	}

	private registerTool(tool: IAgentTool): void {
		if (this._tools.has(tool.name)) {
			this.logService.warn(`[AgentToolsService] Tool with name ${tool.name} already registered.`);
			return;
		}
		this._tools.set(tool.name, tool);
	}

	getTool(name: string): IAgentTool | undefined {
		return this._tools.get(name);
	}

	getTools(): IAgentTool[] {
		return Array.from(this._tools.values());
	}
}
