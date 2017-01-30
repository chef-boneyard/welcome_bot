module WelcomeBot
  class DynamoDB
    def initialize
      @dyndb_client = setup_connection
    end

    def setup_connection
      Aws::DynamoDB::Client.new(
        region: WelcomeBot::Config.aws_region,
        access_key_id: WelcomeBot::Config.aws_access_key_id,
        secret_access_key: WelcomeBot::Config.aws_secret_access_key
      )
    end

    def table_exists?(db_classname)
      @dyndb_client.list_tables.table_names.include?(db_classname.name.gsub("::", "_"))
    end

    def run_migration(db_class)
      puts "Setting up DynamoDB table #{db_class}. This make take a bit..."
      migration = Aws::Record::TableMigration.new(db_class, opts = { client: @dyndb_client })
      migration.create!(
        provisioned_throughput: {
          read_capacity_units: 1,
          write_capacity_units: 1,
        }
      )
      migration.wait_until_available
    end
  end
end
