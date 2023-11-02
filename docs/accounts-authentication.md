# Accounts authentication

## GitHub

The GitHub authentication has been patched to use personal access token.

Here how to create a new personal access token: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token

## Microsoft

The Microsoft authentication hasn't been patched so its status is unknown.

## When does it happened?

An account authentication occurs only when an extension is asking for it.

For `GitLens`, since the `12 non-plus` version, it won't ask for any new authentication.
