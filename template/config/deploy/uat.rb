set :rails_env, 'uat'

#set :rvm_ruby_string, "1.9.3-p125@pwi_#{rails_env}"
$:.unshift(File.expand_path('./lib', ENV['rvm_path']))

set :rvm_install_ruby_params, '--verify-downloads 1'
set :rvm_type, :user
set :branch, 'develop'


#default_run_option[:pty] = true
ssh_options[:forward_agent] = true


# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`


#server 'standby.unitedsynergies.com.au', :web, :app, :db, primary: true


before 'deploy:setup', 'rvm:install_rvm' # update RVM
before 'deploy:setup', 'rvm:install_ruby'