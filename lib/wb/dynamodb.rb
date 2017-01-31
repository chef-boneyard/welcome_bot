module WelcomeBot
  # our all in one interface to DynamoDB. This is actually part aws-sdk
  # and part aws-record
  class DynamoDB
    require "aws-sdk"
    require "date"

    def self.connection
      @@conn ||= Aws::DynamoDB::Client.new
    end

    def self.table_exists?(table_class)
      connection.list_tables.table_names.include?(table_class.name.gsub("::", "_"))
    end

    # add the record to dynamodb, but don't overwrite records with an older date.
    # this allows you to run setup multiple times with multiple orgs and keep
    # the oldest PR / Issue a user filed.
    def self.add_record(table_class, record)
      old_record = table_class.find(username: record[:username])
      if old_record && (record[:interaction_date].to_datetime >= old_record.interaction_date)
        puts "#{record[:username]} interaction date not older than previous interaction date of #{old_record.interaction_date}. Keeping the old record."
      else
        puts "Adding record #{record} to #{table_class.name.gsub('::', '_')}"
        record = table_class.new(record)
        record.save!(opts = { force: true })
      end
    end

    def self.add_record_unless_present(table_class, record)
      if table_class.find(username: record[:username])
        puts "Record for user #{record[:username]} already exists in #{table_class.name.gsub('::', '_')}. Doing nothing."
      else
        add_record(table_class, record)
      end
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
