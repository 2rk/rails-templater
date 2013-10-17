gem 'fracture', group: [:development, :test]

strategies << lambda do
  append_file 'config/boot.rb', load_template('boot.rb','fracture')
end