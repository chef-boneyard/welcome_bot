module WelcomeBot
  class Github
    require "octokit"
    require "faraday-http-cache"

    def self.connection
      @@client ||= setup_connection
    end

    def self.setup_connection
      faraday = Faraday::RackBuilder.new do |builder|
        builder.use Faraday::HttpCache
        builder.use Octokit::Response::RaiseError
        builder.adapter Faraday.default_adapter
      end

      connection = Octokit::Client.new(access_token: WelcomeBot::Config.github_access_token)
      connection.auto_paginate = true
      connection.middleware = faraday
      connection
    end

    def self.fetch_issues(issue_type)
      puts "\nFetching all users that have opened issues of type '#{issue_type}' against the org #{WelcomeBot::Config.github_org}. This may take a long while..."
      users = {}
      # fetch any issue ever created that's in any state and don't filter anything
      connection.org_issues(WelcomeBot::Config.github_org, state: "all", filter: "all", sort: "created").each do |issue|

        # we're not doing this for private repos
        next if issue[:repository][:private] == true

        # skip if this is the wrong issue type
        if issue_type == "pull_request"
          next unless issue[:pull_request]
        else
          next if issue[:pull_request]
        end

        # skip the issues if there's an older PR from the same user in our hash already
        next if users[issue["user"]["login"]] && ( users[issue["user"]["login"]]["created_at"] < issue["created_at"] )

        # add the user to the hash with several attributes
        users[issue["user"]["login"]] = {}
        users[issue["user"]["login"]]["username"] = issue["user"]["login"]
        users[issue["user"]["login"]]["created_at"] = issue["created_at"]
        users[issue["user"]["login"]]["url"] = issue["html_url"]
      end

      users
    end
  end
end
