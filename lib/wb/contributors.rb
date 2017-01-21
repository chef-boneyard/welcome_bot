module WelcomeBot
  class Contributors
    include Aws::Record
    #include ActiveModel::Validations

    string_attr     :username, hash_key: true
    datetime_attr   :first_contribution
    string_attr     :pr_url

    #validates_presence_of :username
  end
end
