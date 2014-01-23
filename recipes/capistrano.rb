# load new scaffold controller
create_file 'config/deploy.rb', load_template('deploy.rb','config')
create_file 'config/deploy/integ.rb', load_template('deploy/integ.rb','config')
create_file 'config/deploy/uat.rb', load_template('deploy/uat.rb','config')
create_file 'config/deploy/production.rb', load_template('deploy/production.rb','config')