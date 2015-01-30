#Create Gemspec
create_file ".ruby-version", "2.2"

# Delete all unnecessary files
remove_file "README"
remove_file "public/index.html"
remove_file "public/robots.txt"
remove_file "public/images/rails.png"
remove_file "config/database.yml"

create_file 'README'
create_file 'log/.gitkeep'
create_file 'tmp/.gitkeep'

# db stuffs
db_string = <<EOF
development:
  adapter: postgresql
  encoding: utf8
  reconnect: false
  database: #{app_name}_development
  pool: 5
  username: root
  password:

# Warning: The database defined as "test" will be erased and
# re-generated from your development database when you run "rake".
# Do not set this db to the same as development or production.
test:
  adapter: postgresql
  encoding: utf8
  reconnect: false
  database: #{app_name}_test
  pool: 5
  username: root
  password:

production:
  adapter: postgresql
  encoding: utf8
  reconnect: false
  database: #{app_name}_production
  pool: 5
  username: root
  password:

EOF
create_file "config/database.yml", db_string

git :init

## GEMFILE STUFF
gem 'haml-rails'
gem 'pg'
gem 'selections'

gem 'devise'
gem 'cancancan'

# TODO remove replace with Semantic UI
gem 'bootstrap-sass'

gem 'kitestrings'


gem_group :development do
  gem "spring-commands-rspec"
end

gem_group :development, :test do
  gem 'awesome_print'
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'fracture'
  gem 'database_cleaner'
  # dont use rspec 3
  gem 'rspec'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'timecop'
end

inside app_name do
  run 'bundle install'
end

inside app_name do
  run 'rake db:create:all'
end


## RSpec all the things

generate 'rspec:install'
run 'mkdir spec/support'

## END RSpec

## Haml all the things
remove_file 'app/views/layouts/application.html.erb'
# application.html.haml created above.

initializer 'haml.rb',<<EOF
Haml::Template.options[:format] = :html5
EOF

# END haml
# Start devise

generate 'devise:install'

# start can can
generate 'cancan:ability'

# start selections

generate 'selections_scaffold'
generate 'kitestrings:install'

# Start Fracture
append_file 'config/boot.rb', <<-EOF
ENV["FIXTURES_PATH"] ||= 'spec/fixtures'
EOF
# END Fracture

# Start .gitignore
append_file '.gitignore', <<-EOF
.ackrc
.rvmrc
config/database.yml
public/cache/
public/stylesheets/compiled/
public/system/*
tmp/restart.txt
.idea
/.bundle
.powrc

# Ignore the default SQLite database.
/db/*.sqlite3

# Ignore all logfiles and tempfiles.
/log/*.log
/tmp
EOF
# End .gitignore


# Start application.css.scss
copy_file 'app/assets/stylesheets/application.css', 'app/assets/stylesheets/application.css.scss'

append_file 'app/assets/stylesheets/application.css.scss' , <<-EOF
 @import "bootstrap";
 @import "bootstrap/theme";
EOF

remove_file 'app/assets/stylesheets/application.css'

# End
# Start application.js

inject_into_file 'app/assets/javascripts/application.js', "\n//= require bootstrap\n", after: "//= require jquery_ujs"

# End

## Gem specific Injections

append_file 'db/seeds.rb', "\n\s\sRake::Task['db:fixtures:load'].invoke\n"
append_file 'db/seeds.rb', "\n\s\sRake::Task['tmp:clear'].invoke unless ENV['RAILS_ENV'] == 'test'\n"
comment_lines 'spec/spec_helper.rb', /\'rspec\/autorun\'/
# Add common lets
create_file "spec/support/common_lets.rb"
generators_configuration = <<-END
config.generators do |g|
      g.view_specs false
    end
END

environment generators_configuration

run 'cp config/database.yml config/database.yml.example'
run 'cp config/database.yml config/database.yml.server'
inject_into_file 'config/environments/development.rb', "\n\s\sconfig.action_controller.action_on_unpermitted_parameters = :raise\n", after: "Rails.application.configure do\n"
inject_into_file 'config/environments/test.rb', "\n\s\sconfig.action_controller.action_on_unpermitted_parameters = :raise\n", after: "Rails.application.configure do\n"

git :add => "."
git :commit => "-m 'Initial commit'"

puts "If you need to change the email address in the initial commit, use git config --local --add user.email me@example.com"
puts "and then `git commit --amend --reset-author`"
