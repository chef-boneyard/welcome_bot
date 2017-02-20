require "openssl"
require "date"
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

    set :port, WelcomeBot::Config.port.to_i

    set(:event_type) do |type|
      condition { request.env["HTTP_X_GITHUB_EVENT"] == type }
    end

    post "/payload", event_type: "ping" do
      ping = JSON.parse(@payload_body)
      logger.info ping
      [200, {}, "PONG"]
    end

    post "/payload", event_type: "pull_request" do
      issue = JSON.parse(@payload_body)
      # we only care about issue open events
      return unless issue["action"] == "opened"

      puts "Processing #{issue["issue"]["html_url"]}"

      # if we already have a record then log and do nothing
      if WelcomeBot::DynamoDB.record_exists?(WelcomeBot::Contributors, issue["issue"]["user"]["login"], issue["repository"]["owner"]["login"])
        puts "Previous interaction found for user #{issue["issue"]["user"]["login"]} on #{issue["repository"]["owner"]["login"]} org. Skipping."
      else
        WelcomeBot::Github.add_comment(issue["pull_request"]["head"]["repo"]["full_name"],
                                       issue["issue"]["number"],
                                       WelcomeBot::DynamoDB.gh_welcome_message(issue["repository"]["owner"]["login"], "pr"))
        WelcomeBot::DynamoDB.add_record(WelcomeBot::Contributors,
                                        { username: issue["pull_request"]["user"]["login"],
                                          org: issue["repository"]["owner"]["login"],
                                          date: DateTime.now,
                                          url: issue["pull_request"]["html_url"] })
      end
    end

    post "/payload", event_type: "issues" do
      issue = JSON.parse(@payload_body)
      # we only care about issue open events
      return unless issue["action"] == "opened"

      puts "Processing #{issue["issue"]["html_url"]}"

      # if we already have a record then log and do nothing
      if WelcomeBot::DynamoDB.record_exists?(WelcomeBot::Reporters, issue["issue"]["user"]["login"], issue["repository"]["owner"]["login"])
        puts "Previous interaction found for user #{issue["issue"]["user"]["login"]} on #{issue["repository"]["owner"]["login"]} org. Skipping."
      else
        WelcomeBot::Github.add_comment(issue["repository"]["full_name"],
                                       issue["issue"]["number"],
                                       WelcomeBot::DynamoDB.gh_welcome_message(issue["repository"]["owner"]["login"], "issue"))
        WelcomeBot::DynamoDB.add_record(WelcomeBot::Reporters,
                                        { username: issue["issue"]["user"]["login"],
                                          org: issue["repository"]["owner"]["login"],
                                          date: DateTime.now,
                                          url: issue["issue"]["html_url"] })
      end
    end
  end
end
