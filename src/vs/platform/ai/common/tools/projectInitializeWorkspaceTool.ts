import { AgentTool, IAgentToolExecutionContext } from "src/vs/platform/ai/common/tools/agentToolsService";
import { ProjectScaffoldDirectoryTool } from "src/vs/platform/ai/common/tools/projectScaffoldDirectoryTool";
import { GitInitTool } from "src/vs/platform/ai/common/tools/gitInitTool";
import *import * as fs from 'fs'; // In a real VS Code extension, use workspace.fs or similar
import * as path from 'path';


// Helper to simulate getting a tool's execute function - in reality, this would come from AgentToolsService
const getToolExecute = (toolInstance: AgentTool) => {
    return toolInstance.execute;
};

export class ProjectInitializeWorkspaceTool extends AgentTool {
    constructor() {
        super(
            "project.initializeWorkspace",
            "Initializes a new project workspace: creates a directory for the project, scaffolds a basic structure, and initializes a Git repository.",
            [
                { name: "project_name", type: "string", description: "The name of the project. A directory with this name will be created.", required: true },
                { name: "base_target_directory", type: "string", description: "The base directory where the project directory will be created (e.g., '/workspace'). This base directory must exist.", required: true },
                { name: "project_type", type: "string", description: "Optional: Type of project (e.g., 'web', 'python', 'generic') to guide scaffolding. Defaults to 'generic'.", required: false }
            ],
            async (context: IAgentToolExecutionContext, args: { project_name: string; base_target_directory: string; project_type?: string }) => {
                const { project_name, base_target_directory, project_type = 'generic' } = args;

                if (!project_name || !base_target_directory) {
                    throw new Error("project_name and base_target_directory parameters are required.");
                }

                const projectPath = path.join(base_target_directory, project_name);
                context.sendProgress(`Initializing project workspace for '${project_name}' in '${projectPath}'...`);

                try {
                    // 1. Create the project directory
                    if (fs.existsSync(projectPath)) {
                        const message = `Project directory ${projectPath} already exists. Skipping creation.`;
                        context.sendProgress(message);
                        // Optionally, could be an error or a configurable behavior (overwrite/use existing)
                        // For now, we'll proceed, assuming we can scaffold/init within it if needed, or tools handle it.
                    } else {
                        fs.mkdirSync(projectPath, { recursive: true });
                        context.sendProgress(`Created project directory: ${projectPath}`);
                    }

                    // 2. Scaffold the directory structure
                    // In a real system, we'd get these tools from the AgentToolService via context
                    const scaffoldTool = new ProjectScaffoldDirectoryTool();
                    const scaffoldExecute = getToolExecute(scaffoldTool);

                    context.sendProgress(`Scaffolding directory structure in ${projectPath}...`);
                    await scaffoldExecute(context, { target_directory: projectPath, project_type });
                    context.sendProgress("Directory structure scaffolded.");

                    // 3. Initialize Git repository
                    const gitInitTool = new GitInitTool();
                    const gitInitExecute = getToolExecute(gitInitTool);

                    context.sendProgress(`Initializing Git repository in ${projectPath}...`);
                    await gitInitExecute(context, { directory_path: projectPath });
                    context.sendProgress("Git repository initialized.");

                    const successMessage = `Project workspace '${project_name}' initialized successfully at ${projectPath}.`;
                    context.sendProgress(successMessage);
                    return {
                        success: true,
                        message: successMessage,
                        project_path: projectPath
                    };

                } catch (error: any) {
                    const errorMessage = `Failed to initialize project workspace '${project_name}': ${error.message}`;
                    console.error(errorMessage, error);
                    context.sendProgress(errorMessage);
                    throw new Error(errorMessage);
                }
            }
        );
    }
}
