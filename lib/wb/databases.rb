module WelcomeBot
  class Contributors
    include Aws::Record

    string_attr     :username, hash_key: true
    datetime_attr   :first_contribution
    string_attr     :pr_url
  end

  class Reporters
    include Aws::Record

    string_attr     :username, hash_key: true
    datetime_attr   :first_issue
    string_attr     :issue_url
  end
end
