# WelcomeBot

The welcome bot comments on the Github Issues and PRs of first time users at a organization level. It does so by keeping a running list of the github usernames of all users that have opened a PRs and Issues against a repo in your organization. Each list is stored in AWS DynamoDB so that no state is stored in the application itself.

## Configuration

WelcomeBot loads configuration via either a YAML config or environmental variables. The YAML config is a simple flat config named welcome_bot.yml. See the example file in this repo for a list of available configuration options. Each option can be configured via this YAML config or via an environmental variable of the same name (except capitalized). For example the YAML config contains the value 'aws_access_key_id', and the environmental variable 'AWS_ACCESS_KEY_ID' can also be used, and will take precedence over the YAML config value.

## Contributing

For information on contributing to this project see <https://github.com/chef/chef/blob/master/CONTRIBUTING.md>

## Setup

WelcomeBot functions using either Github repo level webhook, or org level webhooks. At current the setup binary does not configure webhooks, which allows you to chose the hook configuration that works best for you. You can setup an organization hook via the organization setting page as follows:

![setup image](https://raw.githubusercontent.com/chef/welcomebot/master/setup.png)

## License

- Author:: Tim Smith ([tsmith@chef.io](mailto:tsmith@chef.io))
- Copyright:: Copyright (c) 2016-2017 Chef Software, Inc.
- License:: Apache License, Version 2.0

```text
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
