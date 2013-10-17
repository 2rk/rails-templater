# Delete all unnecessary files
remove_file "README"
remove_file "public/index.html"
remove_file "public/robots.txt"
remove_file "public/images/rails.png"

create_file 'README'
create_file 'log/.gitkeep'
create_file 'tmp/.gitkeep'

git :init

append_file '.gitignore', load_template('gitignore','git')


#haml stuff has moved out of rails3-generators
gem 'haml-rails'

# load new scaffold controller
create_file 'lib/templates/rails/scaffold_controller/controller.rb', load_template('scaffold_controller/controller.rb','rails')