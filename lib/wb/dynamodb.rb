module WelcomeBot
  # our all in one interface to DynamoDB. This is actually part aws-sdk
  # and part aws-record
  class DynamoDB

    def self.connection
      @@conn ||= setup_connection
    end

    def self.setup_connection
      # This config is for aws-record
      Aws.config.update({
        region: WelcomeBot::Config.aws_region,
        credentials: Aws::Credentials.new(WelcomeBot::Config.aws_access_key_id, WelcomeBot::Config.aws_secret_access_key),
        })

      Aws::DynamoDB::Client.new(
        region: WelcomeBot::Config.aws_region,
        access_key_id: WelcomeBot::Config.aws_access_key_id,
        secret_access_key: WelcomeBot::Config.aws_secret_access_key
      )
    end

    def self.table_exists?(table_class)
      connection.list_tables.table_names.include?(table_class.name.gsub("::", "_"))
    end

    def self.add_record(table_class, record)
      puts "Adding record #{record} to #{table_class.name.gsub('::', '_')}"
      record = table_class.new(record)
      record.save!(opts = { force: true })
    end

    def self.run_migration(table_class)
      # don't try to migration a table that already exists. This fails
      if table_exists?(table_class)
        puts "Table #{table_class.name.gsub("::", '_')} already exists. Skipping migration."
        return
      end

      puts "Setting up DynamoDB table #{table_class}. This make take a bit..."
      migration = Aws::Record::TableMigration.new(table_class, opts = { client: connection })
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
