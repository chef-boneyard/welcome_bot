module WelcomeBot
  class Config
    CONFIG_OPTIONS = %w{
      github_access_token
      github_secret_token
      github_org
      pr_welcome_message
      issue_welcome_message
      aws_region
      aws_access_key_id
      aws_secret_access_key
      port
    }.freeze

    CONFIG_OPTIONS.each do |config_opt|
      define_singleton_method(config_opt) do
        instance_variable_get("@#{config_opt}") || instance_variable_set("@#{config_opt}", load_config_val(config_opt))
      end
    end

    def self.config_file
      @config ||=
        begin
        require "yaml"
        YAML.load_file("welcome_bot.yml")
      rescue Errno::ENOENT
        puts "Environmental variables or config file welcome_bot.yml not found!\nSee README.md for usage information"
        exit!
      rescue Psych::SyntaxError
        puts "welcome_bot.yml does not contain valid YAML. Check your syntax and try again."
        exit!
      end
    end

    def self.load_config_val(val)
      return ENV[val.upcase] if ENV[val.upcase]
      if config_file[val]
        config_file[val]
      else
        puts "Environmental variable '#{val.upcase}' or welcome_bot.yml config option '#{val}' not found!\nSee README.md for usage information"
        exit!
      end
    end
  end
end
