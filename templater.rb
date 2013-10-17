require File.join(File.dirname(__FILE__), 'core_extensions.rb')

initialize_templater

#Create Gemspec 
create_file ".rvmrc", "rvm gemset use #{app_name}"

required_recipes = %w(default haml rspec factory_girl shoulda capybara)
required_recipes.each {|required_recipe| apply recipe(required_recipe)}

load_options

inside app_name do
  run 'bundle install'
end

execute_stategies

generators_configuration = <<-END
config.generators do |g|
  g.view_specs false
end
END

environment generators_configuration

git :add => "."
git :commit => "-m 'Initial commit'"  