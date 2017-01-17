require "octokit"
require "faraday-http-cache"
require "openssl"
require "aws-sdk"
require "aws-record"
require "sinatra"
require "wb/version"
require "wb/config"
require "wb/contributor"
require "wb/dynamodb"

module WelcomeBot
  class Server < Sinatra::Base
  end
end
