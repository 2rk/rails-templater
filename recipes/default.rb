# Delete all unnecessary files
remove_file 'README'
remove_file 'public/index.html'
remove_file 'public/robots.txt'
remove_file 'public/images/rails.png'
remove_file 'config/database.yml'

create_file 'README'
create_file 'log/.gitkeep'
create_file 'tmp/.gitkeep'

git :init

append_file '.gitignore', load_template('gitignore','git')

#haml stuff has moved out of rails3-generators
gem 'haml-rails'

#mysql by default
gem 'mysql2'

mysql_db_config = <<-END
development:
  adapter: mysql2
  encoding: utf8
  reconnect: false
  database: #{app_name}_development
  pool: 5
  username: root
  password:
  socket: /tmp/mysql.sock

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
END
create_file 'config/database.yml', mysql_db_config

# load new scaffold controller
create_file 'lib/templates/rails/scaffold_controller/controller.rb', load_template('scaffold_controller/controller.rb','rails')