<div id="cortex-code-logo" align="center">
    <br />
    <!-- Placeholder for a new logo -->
    <h1>Cortex-Code</h1>
    <h3>An AI-native, mood-adaptive, web-based IDE.</h3>
</div>

## About This Project

Welcome to the official repository for **Cortex-Code**. This project aims to create a next-generation, web-based IDE that seamlessly integrates with AI to act as a true coding partner. This repository is currently based on the excellent open-source work of [VSCodium](https://github.com/VSCodium/vscodium), providing a solid foundation as we build out the future of coding.

## The Vision: Your AI Coding Partner

Cortex-Code is a web-based IDE that takes the best of VS Code, Windsurf, and Cursor, but pushes it further with real-time AI integration and mood-adaptive features. The core is the Monaco editor running in the browser, backed by Firebase for identity, data, presence, and storage. We are building for multi-tab editing, live collaboration (multi-cursor, typing presence), and a plugin-like system of AI agents.

### Key Features of the Vision:

*   **Choose Your AI Engine**: Users can pick which AI engine they want—OpenAI, Anthropic, or Gemini—and Cortex routes requests accordingly.
*   **Powerful AI Agents**: Our agents are designed to handle a variety of tasks:
    *   **Explain-My-Code**: Understand complex code blocks instantly.
    *   **Safe Refactors**: AI-powered refactoring, always delivered as a diff, never a direct overwrite.
    *   **Test Generation**: Automatically create unit tests for your code.
    *   **Documentation Drafting**: Generate documentation on the fly.
    *   **PR Preparation**: Get help with writing pull requests.
*   **Mood-Adaptive UX (Opt-In)**: Cortex watches the user’s flow. By analyzing webcam and typing cadence, our AI assistant, "Cody the Coder," can detect when a developer is getting stuck or frustrated.
    *   **Proactive Assistance**: Cody checks in, offers help, or even suggests solutions to keep you moving.
    *   **Adaptive Interface**: Fonts, colors, themes, and even background music adapt live via Firebase Remote Config based on the user’s state to create the optimal coding environment.

### The Tech Stack Vision:

*   **Frontend**: Monaco Editor (in-browser)
*   **Backend**: Fastify service with Firebase Admin
*   **Cloud Services**:
    *   **Firebase Auth**: For user identity.
    *   **Firestore**: For session and project state.
    *   **Realtime Database**: For live presence and collaboration.
    *   **Cloud Storage**: For generated artifacts and walkthroughs.
    *   **Cloud Functions**: For AI agent orchestration and policy.
    *   **Remote Config**: For the adaptive UX.

## Current Status & Roadmap

This project is in its early stages. The current codebase is a fork of VSCodium, which provides the build scripts to create a "clean" build of VS Code from source.

Our high-level roadmap is as follows:
1.  **Phase 1: Foundation & Firebase Integration**
    *   Integrate Firebase for authentication, and Firestore for basic project state.
    *   Set up the core Fastify backend service.
2.  **Phase 2: Core AI Agent System**
    *   Develop the AI agent routing system for multiple providers (OpenAI, Anthropic, Gemini).
    *   Implement the first AI agent features (e.g., "Explain-My-Code").
3.  **Phase 3: Collaboration & Adaptive UX**
    *   Build out real-time collaboration features using Realtime Database.
    *   Develop the opt-in mood/intent model and integrate it with Remote Config for the adaptive UX.

## Getting Started (Development)

As we are in the initial phase, the build process is inherited from VSCodium. To get started with development, you'll need to build the application from source.

### Dependencies:

*   node 20.18
*   jq
*   git
*   python3 3.11
*   rustup
*   Platform-specific dependencies (see `docs/howto-build.md` for details).

### Build for Development:

A helper script is available for development builds:

*   **Linux / macOS**: `./dev/build.sh`
*   **Windows**: `powershell -ExecutionPolicy ByPass -File .\dev\build.ps1`

For more detailed build instructions, please refer to the [How to Build document](./docs/howto-build.md).

## Contributing

We are actively looking for contributors who are excited about the future of software development. If the vision for Cortex-Code resonates with you, we'd love your help.

Please read our [Contributing Guidelines](CONTRIBUTING.md) and our [Code of Conduct](CODE_OF_CONDUCT.md).

## Special Thanks

We extend our gratitude to the original creators and maintainers of VSCodium, as well as the sponsors who made that project possible. Their work provides the foundation upon which Cortex-Code is built.

<table>
  <tr>
    <td><a href="https://github.com/jaredreich" target="_blank">@jaredreich</a></td>
    <td>for the VSCodium logo</td>
  </tr>
  <tr>
    <td><a href="https://github.com/PalinuroSec" target="_blank">@PalinuroSec</a></td>
    <td>for CDN and domain name for VSCodium</td>
  </tr>
  <tr>
    <td><a href="https://www.macstadium.com" target="_blank"><img src="https://images.prismic.io/macstadium/66fbce64-707e-41f3-b547-241908884716_MacStadium_Logo.png?w=128&q=75" width="128" height="49" alt="MacStadium logo" /></a></td>
    <td>for providing a Mac mini M1 for VSCodium builds</td>
  </tr>
  <tr>
    <td><a href="https://github.com/daiyam" target="_blank">@daiyam</a></td>
    <td>for macOS certificate for VSCodium</td>
  </tr>
  <tr>
    <td><a href="https://signpath.org/" target="_blank"><img src="https://avatars.githubusercontent.com/u/34448643" height="30" alt="SignPath logo" /></a></td>
    <td>free code signing on Windows provided by <a href="https://signpath.io/" target="_blank">SignPath.io</a>, certificate by <a href="https://signpath.org/" target="_blank">SignPath Foundation</a></td>
  </tr>
</table>

## License

This project is licensed under the [MIT License](LICENSE).
