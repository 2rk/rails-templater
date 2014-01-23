require 'bundler/capistrano'
require 'rvm/capistrano'
require 'capistrano/ext/multistage'

set :stages, %w(integ, uat, production)
set :default_stage, "integ"
set :application, 'pwi'
set :user, 'pwi'
set (:deploy_to) { "/home/#{user}/apps/#{rails_env}" }
set :deploy_via, :remote_cache
set :use_sudo, false
set :scm, 'git'
#set :repository, 'git@github.com:2rk/pwi.git'
set :whenever_environment, defer { stage }
set :whenever_variables, defer { "'environment=#{rails_env}&log_path=#{shared_path}'" }

set :whenever_identifier, defer { "#{application}_#{stage}" }

namespace :deploy do
  task :symlink_config do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
  before "deploy:assets:precompile", "deploy:symlink_config"

  task :create_shared_database_config do
    run "mkdir -p #{shared_path}/config"
    run "cp #{current_path}/config/database.yml.example #{shared_path}/config/database.yml"
  end

  task :create_shared_rvmrc do
    run "cp #{release_path}/.rvmrc.#{rails_env}.example #{release_path}/.rvmrc"
  end

  after "deploy:finalize_update", "deploy:create_shared_rvmrc"


  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

namespace :ruby_make do
  desc "Run a task on a remote server."
  # run like: cap staging rake:invoke task=a_certain_task
  task :invoke do
    run("cd #{deploy_to}/current; /usr/bin/env rake #{ENV['task']} RAILS_ENV=#{rails_env}")
  end
end

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
  desc "reload the database with seed data"
  task :seed do
    run "cd #{current_path}; bundle exec rake db:seed RAILS_ENV=#{rails_env}"
  end
end

namespace :rvm do
  task :trust_rvmrc do
    run "rvm rvmrc trust #{release_path}"
  end
end

after "deploy", "rvm:trust_rvmrc"