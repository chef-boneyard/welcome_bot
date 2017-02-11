module WelcomeBot
  # our all in one interface to DynamoDB. This is actually part aws-sdk
  # and part aws-record
  class DynamoDB
    require "aws-sdk"
    require "date"
    require "uri"
    require "json"

    def self.connection
      @@conn ||= Aws::DynamoDB::Client.new
    end

    def self.table_exists?(table_class)
      connection.list_tables.table_names.include?(table_class.name.gsub("::", "_"))
    end

    # add the record to dynamodb. Examines the interactions field and adds in new orgs as necessary
    #record_data format: { :username => string,
    #                      :org => string,
    #                      :date => datetime,
    #                      :url => string }
    def self.add_record(table_class, record_data)
      db_record = table_class.find(username: record_data[:username])

      # load the existing interactions value from the record or use an empty hash
      interactions = JSON.parse(db_record.interactions) rescue {}

      # add the values passed in
      interactions[record_data[:org]] = {}
      interactions[record_data[:org]][:url] = record_data[:url]
      interactions[record_data[:org]][:date] = record_data[:date]

      # update the existing record if it was returned above else create a record
      if db_record
        db_record.interactions = interactions.to_json
      else
        db_record = table_class.new({ :username => record_data[:username],
                                      :interactions => interactions.to_json })
      end

      db_record.save!(opts = { force: true })
      puts "Updated record for #{record_data[:username]} with #{record_data[:org]} org interaction"
    end

    def self.return_all_records(table_class)
      users = []
      table_class.scan.select do |val|
        users << {
          "username" => val.username,
          "interactions" => val.interactions,
        }
      end
      users
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
