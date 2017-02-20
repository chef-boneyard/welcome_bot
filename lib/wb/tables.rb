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

  class Messages
    include Aws::Record

    string_attr     :org, hash_key: true
    string_attr     :pr_message
    string_attr     :issue_message
  end
end
