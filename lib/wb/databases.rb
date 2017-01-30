module WelcomeBot
  class Contributors
    include Aws::Record

    string_attr     :username, hash_key: true
    datetime_attr   :interaction_date
    string_attr     :url
  end

  class Reporters
    include Aws::Record

    string_attr     :username, hash_key: true
    datetime_attr   :interaction_date
    string_attr     :url
  end
end
