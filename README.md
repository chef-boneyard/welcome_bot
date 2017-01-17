# Welcome Bot

The welcome bot comments on the PRs of first time committers at a Github organization level. It does so by keeping a running list of the user names of all users that have opened a PR accross a github organization. This list is stored in AWS DynamoDB so this app can be run in a container.
