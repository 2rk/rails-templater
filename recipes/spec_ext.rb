# load new scaffold controller
create_file 'spec_ext/spec_helper_ext.rb', load_template('spec_helper_ext.rb','spec_ext')
create_file 'spec_ext/my_ip_spec.rb', load_template('my_ip_spec.rb', 'spec_ext')
