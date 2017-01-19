require "octokit"
require "faraday-http-cache"
require "openssl"
require "aws-sdk"
require "aws-record"
require "active_model"
require "sinatra"
require "wb/version"
require "wb/config"
require "wb/contributors"
require "wb/dynamodb"
require "wb/github"

module WelcomeBot
  class Server < Sinatra::Base
  end
end
