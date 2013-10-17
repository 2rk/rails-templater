gem 'rspec-rails', '~> 2.14.0', group: [:development, :test]

stategies << lambda do
  generate 'rspec:install'
  spec_helper_path = 'spec/spec_helper.rb'
end
