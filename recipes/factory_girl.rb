gem 'factory_girl_rails', '~> 4.2.1', group: [:development, :test]

stategies << lambda do
  # load factory girl syntax methods as part of rspec
  inject_into_file 'spec/spec_helper.rb', "\nconfig.include FactoryGirl::Syntax::Methods", after: "RSpec.configure do |config|\n"
end