require "octokit"
require "faraday-http-cache"
require "openssl"
require "aws-sdk"
require "aws-record"
require "sinatra"
require "wb/version"
require "wb/config"
require "wb/tables"
require "wb/dynamodb"
require "wb/github"

module WelcomeBot
  class Server < Sinatra::Base
    before do
      @payload_body = request.body.read
      request_signature = request.env.fetch("HTTP_X_HUB_SIGNATURE", "")
      check_signature = "sha1=" + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha1"), WelcomeBot::Config.github_secret_token, @payload_body)
      return halt 500, "Signatures didn't match!" unless Rack::Utils.secure_compare(check_signature, request_signature)
    end

    set(:event_type) do |type|
      condition { request.env["HTTP_X_GITHUB_EVENT"] == type }
    end

    post "/payload", event_type: "ping" do
      ping = JSON.parse(@payload_body)
      logger.info ping
      [200, {}, "PONG"]
    end

    post "/payload", event_type: "repository" do
      begin
        repo = JSON.parse(@payload_body)
        if !repo["repository"]["private"] && %w{created publicized}.include?(repo["action"])
          callback_url = request.url
          result = WelcomeBot::Github.hookit(repo["repository"]["full_name"], callback_url)
          [200, {}, "Hooked #{repo["repository"]["full_name"]}"]
        else
          [200, {}, "Nothing to do here."]
        end
      rescue Octokit::Error => e
        [500, {}, "nope"]
      end
    end

    post "/payload", event_type: "pull_request" do
      pr = JSON.parse(@payload_body)
      repo_id = pr["repository"]["id"]
      if pr["action"] == "opened"
        puts "Processing #{pr['pull_request']['head']['repo']['name']} ##{pr['number']}"
        WelcomeBot::Github.apply_comment(repo_id, pr["number"], WelcomeBot::Config.pr_welcome_message )
        WelcomeBot::Dynamodb.add_user("WelcomeBot_Contributors", pr["pull_request"]["user"]["login"], pr["pull_request"]["url"])
      end
    end

    post "/payload", event_type: "issue" do
      issue = JSON.parse(@payload_body)
      repo_id = pr["repository"]["id"]
      if issue["action"] == "opened"
        puts "Processing #{issue['pull_request']['head']['repo']['name']} ##{issue['number']}"
        WelcomeBot::Github.apply_comment(repo_id, issue["number"], WelcomeBot::Config.issue_welcome_message )
        WelcomeBot::Dynamodb.add_user("WelcomeBot_Reporters", pr["issue"]["user"]["login"], pr["issue"]["url"])
      end
    end
  end
end
