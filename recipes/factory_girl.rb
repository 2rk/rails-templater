gem 'factory_girl_rails', '>= 4.2.1', group: [:development, :test]

strategies << lambda do
  # load factory girl syntax methods as part of rspec
  inject_into_file 'spec/spec_helper.rb', "\n\s\sconfig.include FactoryGirl::Syntax::Methods\n", after: "RSpec.configure do |config|\n"
end