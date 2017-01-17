module WelcomeBot
  class Contributor
    include Aws::Record
    include ActiveModel::Validations

    string_attr     :username, hash_key: true
    datetime_attr   :first_contribution, database_attribute_name: "PostCreatedAtTime"

    validates_presence_of :username, :first_contribution
  end
end
