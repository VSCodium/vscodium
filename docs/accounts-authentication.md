<!-- order: 0 -->

# Accounts authentication

## GitHub

VSCodium uses GitHub Personal Access Tokens (PATs) for features like settings sync or extensions requiring GitHub authentication. This method is used because VSCodium, aiming for a telemetry-free experience, does not implement the standard OAuth flow that official Visual Studio Code builds use for GitHub integration.

To create a new personal access token, follow the official GitHub documentation: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token

## Microsoft

Microsoft account authentication (e.g., for settings sync via Microsoft services) is not supported in VSCodium. This is in line with the project's goal of removing Microsoft-specific integrations and telemetry. Therefore, functionalities requiring Microsoft account sign-in will not work.

## When does it happen?

An account authentication occurs only when an extension is asking for it.

For `GitLens`, since the `12 non-plus` version, it won't ask for any new authentication.
