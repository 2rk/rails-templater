gem 'haml'

remove_file 'app/views/layouts/application.html.erb'
create_file 'app/views/layouts/application.html.haml', load_template('app/views/layouts/application.html.haml','haml')
create_file 'lib/templates/haml/scaffold/_form.html.haml', load_template('scaffold/_form.html.haml','haml')
create_file 'lib/templates/haml/scaffold/edit.html.haml', load_template('scaffold/edit.html.haml','haml')
create_file 'lib/templates/haml/scaffold/index.html.haml', load_template('scaffold/index.html.haml','haml')
create_file 'lib/templates/haml/scaffold/new.html.haml', load_template('scaffold/new.html.haml','haml')
create_file 'lib/templates/haml/scaffold/show.html.haml', load_template('scaffold/show.html.haml','haml')


initializer 'haml.rb',<<EOF
Haml::Template.options[:format] = :html5
EOF