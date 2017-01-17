module WelcomeBot
  class DynamoDB
    def initialize
      @dyndb_client = setup_connection
    end

    def setup_connection
      Aws::DynamoDB::Client.new(
        region: WelcomeBot::Config.aws_region,
        access_key_id: WelcomeBot::Config.aws_access_key_id,
        secret_access_key: WelcomeBot::Config.aws_secret_access_key,
      )
    end
  end
end
