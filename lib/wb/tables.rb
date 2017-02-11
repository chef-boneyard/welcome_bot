module WelcomeBot
  class Contributors
    include Aws::Record

    string_attr     :username, hash_key: true
    string_attr     :interactions
  end

  class Reporters
    include Aws::Record

    string_attr     :username, hash_key: true
    string_attr     :interactions
  end
end
