require File.join(File.dirname(__FILE__), 'core_extensions.rb')

initialize_templater

#Create Gemspec 
create_file ".rvmrc", "rvm gemset use #{app_name}"

required_recipes = %w(default haml fracture rspec factory_girl shoulda capybara database_cleaner hirb awesome_print timecop)
required_recipes.each {|required_recipe| apply recipe(required_recipe)}

inside app_name do
  run 'bundle install'
end

execute_strategies

generators_configuration = <<-END
config.generators do |g|
  g.view_specs false
end
END

inside app_name do
  run 'rake db:create:all'
end


environment generators_configuration

git :add => "."
git :commit => "-m 'Initial commit'"  