module WelcomeBot
  class Contributors
    require "time"
    include Aws::Record

    string_attr     :username, hash_key: true
    datetime_attr   :interaction_date, default_value: Time.now
    string_attr     :url
  end

  class Reporters
    include Aws::Record

    string_attr     :username, hash_key: true
    datetime_attr   :interaction_date, default_value: Time.now
    string_attr     :url
  end
end
