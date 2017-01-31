require "octokit"
require "faraday-http-cache"
require "openssl"
require "aws-record"
require "sinatra"
require "wb/version"
require "wb/config"
require "wb/tables"
require "wb/dynamodb"
require "wb/github"

Aws.config.update({
  region: WelcomeBot::Config.aws_region,
  credentials: Aws::Credentials.new(WelcomeBot::Config.aws_access_key_id, WelcomeBot::Config.aws_secret_access_key),
  })

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
      issue = JSON.parse(@payload_body)
      if issue["action"] == "opened"
        puts "Processing #{issue["pull_request"]["url"]}"
        WelcomeBot::DynamoDB.add_record_unless_present(WelcomeBot::Contributors, { :username => issue["pull_request"]["user"]["login"], :url => issue["pull_request"]["html_url"] })
      end
    end

    post "/payload", event_type: "issues" do
      issue = JSON.parse(@payload_body)
      if issue["action"] == "opened"
        puts "Processing #{issue["issue"]["url"]}"
        WelcomeBot::DynamoDB.add_record_unless_present(WelcomeBot::Reporters, { :username => issue["issue"]["user"]["login"], :url => issue["issue"]["html_url"] })
      end
    end
  end
end
