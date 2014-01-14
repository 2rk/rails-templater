#Create Gemspec
create_file ".rvmrc", "rvm use 2.0.0@#{app_name} --create" unless ENV['SKIP_RVMRC']
create_file ".ruby-version", "2.0.0"

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
# MySQL.  Versions 4.1 and 5.0 are recommended.
#
# Install the MYSQL driver
#   gem install mysql2
#
# Ensure the MySQL gem is defined in your Gemfile
#   gem 'mysql2'
#
# And be sure to use new-style password hashing:
#   http://dev.mysql.com/doc/refman/5.0/en/old-client.html
development:
  adapter: mysql2
  encoding: utf8
  reconnect: false
  database: #{app_name}_development
  pool: 5
  username: root
  password:
  socket: /tmp/mysql.sock

# Warning: The database defined as "test" will be erased and
# re-generated from your development database when you run "rake".
# Do not set this db to the same as development or production.
test:
  adapter: mysql2
  encoding: utf8
  reconnect: false
  database: #{app_name}_test
  pool: 5
  username: root
  password:
  socket: /tmp/mysql.sock

production:
  adapter: mysql2
  encoding: utf8
  reconnect: false
  database: #{app_name}_production
  pool: 5
  username: root
  password:
  socket: /tmp/mysql.sock
EOF
create_file "config/database.yml", db_string

git :init

## GEMFILE STUFF
gem 'haml-rails'
gem 'mysql2'

gem_group :development, :test do
  gem 'awesome_print'
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'fracture'
  gem 'database_cleaner'
  gem 'hirb'
  gem 'rspec-rails'
  gem 'shoulda-matchers', '~> 2.4.0'
  gem 'timecop'
  gem 'zeus', '~> 0.13.4.pre', :require => false
end



inside app_name do
  run 'bundle install'
end

inside app_name do
  run 'rake db:create:all'
end


ROOT = File.expand_path('../template', __FILE__)
Dir.glob(File.join(ROOT, '**/*')).select{|f|File.file?(f)}.each do |template|
  destination_filename = template.sub("#{ROOT}/",'')
  create_file(destination_filename, File.read(template))
end

## RSpec all the things

generate 'rspec:install'
spec_helper_path = 'spec/spec_helper.rb'
run 'mkdir spec/support'

## END RSpec

## Haml all the things
remove_file 'app/views/layouts/application.html.erb'
# application.html.haml created above.

initializer 'haml.rb',<<EOF
Haml::Template.options[:format] = :html5
EOF

# END haml


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

## Gem specific Injections

inject_into_file 'spec/spec_helper.rb', "\n\s\sconfig.include Capybara::DSL\n", after: "RSpec.configure do |config|\n"
inject_into_file 'spec/spec_helper.rb', "\n\s\sconfig.include FactoryGirl::Syntax::Methods\n", after: "RSpec.configure do |config|\n"

generators_configuration = <<-END
config.generators do |g|
      g.view_specs false
    end
END

environment generators_configuration

run 'cp .rvmrc .rvmrc.example'
run 'cp config/database.yml config/database.yml.example'

git :add => "."
git :commit => "-m 'Initial commit'"

puts "If you need to change the email address in the initial commit, use git config --local --add user.email me@example.com"
puts "and then `git commit --amend --reset-author`"
