gem 'capybara', '>= 2.0', group: [:development, :test]

stategies << lambda do
  inject_into_file 'spec/spec_helper.rb', "\n\s\sconfig.include Capybara::DSL", after: "RSpec.configure do |config|\n"
end
