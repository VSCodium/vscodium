import { IAgentTool, IAgentToolExecutionContext, IAgentToolService } from "src/vs/platform/ai/common/aiActionService";

export class AgentTool implements IAgentTool {
    constructor(
        public readonly name: string,
        public readonly description: string,
        public readonly parameters: { name: string; type: string; description: string; required?: boolean }[],
        public readonly execute: (context: IAgentToolExecutionContext, args: any) => Promise<any>
    ) {}
}

import { FileReadTool } from "src/vs/platform/ai/common/tools/fileReadTool";
import { FileWriteTool } from "src/vs/platform/ai/common/tools/fileWriteTool";
import { GitInitTool } from "src/vs/platform/ai/common/tools/gitInitTool";
import { ProjectInitializeWorkspaceTool } from "src/vs/platform/ai/common/tools/projectInitializeWorkspaceTool";
import { ProjectScaffoldDirectoryTool } from "src/vs/platform/ai/common/tools/projectScaffoldDirectoryTool";
import { PMUpsertTaskTool } from "src/vs/platform/ai/common/tools/pmUpsertTaskTool"; // Changed

export class AgentToolsService implements IAgentToolService {
    private tools: Map<string, IAgentTool> = new Map();

    constructor() {
        this.registerPredefinedTools();
    }

    private registerPredefinedTools(): void {
        this.registerTool(new ProjectScaffoldDirectoryTool());
        this.registerTool(new GitInitTool());
        this.registerTool(new ProjectInitializeWorkspaceTool());
        this.registerTool(new FileWriteTool());
        this.registerTool(new FileReadTool());
        this.registerTool(new PMUpsertTaskTool()); // Changed
        // Register other tools here as they are defined
    }

    registerTool(tool: IAgentTool): void {
        if (this.tools.has(tool.name)) {
            console.warn(`Tool with name ${tool.name} already registered. Overwriting.`);
        }
        this.tools.set(tool.name, tool);
    }

    getTool(name: string): IAgentTool | undefined {
        return this.tools.get(name);
    }

    getAvailableTools(agentId?: string): IAgentTool[] {
        // Later, filter by agentId based on agent definitions
        return Array.from(this.tools.values());
    }
}

// Basic interfaces (can be moved to a central types file later)
export interface IAgentTool {
    readonly name: string;
    readonly description: string;
    readonly parameters: { name: string; type: string; description: string; required?: boolean }[];
    execute(context: IAgentToolExecutionContext, args: any): Promise<any>;
}

export interface IAgentToolExecutionContext {
    // The root path of the current project/workspace the agent is operating on.
    // Tools like file.write, file.read should be restricted to this path.
    projectRootPath?: string;

    // Function to execute a terminal command in a sandboxed environment.
    // Should return stdout, stderr, and exit code.
    executeTerminalCommand: (command: string, args?: string[], options?: { cwd?: string }) => Promise<{ stdout: string; stderr: string; exitCode: number }>;

    // Function to make HTTP requests (e.g., for LLM calls by tools themselves, if ever needed, or for other APIs)
    // Should be sandboxed and restricted.
    makeHttpRequest: (config: any) => Promise<any>;

    // Function to send progress updates or logs back to the UI or a logging service.
    sendProgress: (message: string, details?: any) => void;

    // Access to other services if needed, e.g., workspace service, file service
    // For now, keeping it simple.
}

export interface IAgentToolService {
    _serviceBrand: undefined;
    registerTool(tool: IAgentTool): void;
    getTool(name: string): IAgentTool | undefined;
    getAvailableTools(agentId?: string): IAgentTool[];
}
