module WelcomeBot
  class Contributors
    include Aws::Record
    include ActiveModel::Validations

    string_attr     :username, hash_key: true
    datetime_attr   :first_contribution

    validates_presence_of :username, :first_contribution
  end
end
