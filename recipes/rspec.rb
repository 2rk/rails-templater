gem 'rspec-rails', '~> 2.14.0', group: [:development, :test]

# load rspec templates
create_file 'lib/templates/rails/rspec/helper/helper_spec.rb', load_template('helper/helper_spec.rb','rspec')
create_file 'lib/templates/rails/rspec/integration/request.rb', load_template('integration/request_spec.rb','rspec')
create_file 'lib/templates/rails/rspec/model/model_spec.rb', load_template('model/model_spec.rb','rspec')
create_file 'lib/templates/rails/rspec/scaffold/controller_spec.rb', load_template('scaffold/controller_spec.rb','rspec')
create_file 'lib/templates/rails/rspec/scaffold/routing_spec.rb', load_template('scaffold/routing_spec.rb','rspec')

stategies << lambda do
  generate 'rspec:install'
  spec_helper_path = 'spec/spec_helper.rb'
end