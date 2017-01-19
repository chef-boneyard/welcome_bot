module WelcomeBot
  class Github
    attr_accessor :client

    def initialize
      @client = setup_connection
    end

    def setup_connection
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
  end
end
