import * as path from 'path';
import * as fs from 'fs'; // In a real VS Code extension, use workspace.fs or similar
import { AgentTool, IAgentToolExecutionContext } from "src/vs/platform/ai/common/tools/agentToolsService";

export class ProjectScaffoldDirectoryTool extends AgentTool {
    constructor() {
        super(
            "project.scaffoldDirectory",
            "Creates a basic directory structure for a new software project within a given target directory.",
            [
                { name: "target_directory", type: "string", description: "The absolute path to the directory where the project structure should be created. This directory should already exist and be the root of the new project.", required: true },
                { name: "project_type", type: "string", description: "Optional: Type of project (e.g., 'web', 'python', 'generic'). Affects scaffolded structure. Defaults to 'generic'.", required: false }
            ],
            async (context: IAgentToolExecutionContext, args: { target_directory: string; project_type?: string }) => {
                const { target_directory, project_type = 'generic' } = args;

                if (!target_directory) {
                    throw new Error("target_directory parameter is required.");
                }

                // In a real VS Code extension, ensure target_directory is within a safe, user-approved workspace.
                // For now, we assume it's a safe path provided by the SupervisorAgent (which itself gets it from config or a safe default).

                context.sendProgress(`Scaffolding project in ${target_directory} with type ${project_type}`);

                const commonDirs = ["docs", "tests"];
                let projectSpecificDirs: string[] = [];
                let filesToCreate: { filePath: string; content: string }[] = [];

                if (project_type === 'web') {
                    projectSpecificDirs = ["src/js", "src/css", "src/assets", "public"];
                    filesToCreate.push({ filePath: path.join(target_directory, 'src', 'index.html'), content: '<!DOCTYPE html><html><head><title>New Web Project</title></head><body><h1>Hello, World!</h1><script src="js/app.js"></script></body></html>' });
                    filesToCreate.push({ filePath: path.join(target_directory, 'src', 'js', 'app.js'), content: '// Main application JavaScript' });
                    filesToCreate.push({ filePath: path.join(target_directory, 'src', 'css', 'style.css'), content: '/* Main application styles */' });
                } else if (project_type === 'python') {
                    projectSpecificDirs = [args.target_directory.split(path.sep).pop() || 'main_module', "scripts"]; // project name as main module
                    filesToCreate.push({ filePath: path.join(target_directory, projectSpecificDirs[0], '__init__.py'), content: '# Init file for module' });
                    filesToCreate.push({ filePath: path.join(target_directory, 'requirements.txt'), content: '# Project dependencies' });
                } else { // generic
                    projectSpecificDirs = ["src"];
                     filesToCreate.push({ filePath: path.join(target_directory, 'src', 'main.txt'), content: 'Start your project here.' });
                }

                const allDirs = [...commonDirs, ...projectSpecificDirs];

                try {
                    // Create root directory if it doesn't exist (should be created by initializeWorkspace)
                    // For scaffold, we assume target_directory is the project root and exists.
                    if (!fs.existsSync(target_directory)) {
                         // fs.mkdirSync(target_directory, { recursive: true }); // This should be done by the caller like initializeWorkspace
                         throw new Error(`Target directory ${target_directory} does not exist. It should be created before scaffolding.`);
                    }

                    for (const dir of allDirs) {
                        const fullPath = path.join(target_directory, dir);
                        if (!fs.existsSync(fullPath)) {
                            fs.mkdirSync(fullPath, { recursive: true });
                            context.sendProgress(`Created directory: ${fullPath}`);
                        }
                    }

                    filesToCreate.push({ filePath: path.join(target_directory, '.gitignore'), content: '# Common .gitignore\nnode_modules/\n.DS_Store\n*.log\n*.tmp\n*.swp' });
                    filesToCreate.push({ filePath: path.join(target_directory, 'README.md'), content: `# ${path.basename(target_directory)}\n\nA new project.\n` });

                    for (const file of filesToCreate) {
                        if (!fs.existsSync(file.filePath)) {
                            fs.writeFileSync(file.filePath, file.content);
                            context.sendProgress(`Created file: ${file.filePath}`);
                        }
                    }

                    context.sendProgress("Project scaffolding completed successfully.");
                    return { success: true, message: `Project structure scaffolded in ${target_directory}` };

                } catch (error: any) {
                    console.error("Error scaffolding project:", error);
                    context.sendProgress(`Error scaffolding project: ${error.message}`);
                    throw new Error(`Failed to scaffold project in ${target_directory}: ${error.message}`);
                }
            }
        );
    }
}
