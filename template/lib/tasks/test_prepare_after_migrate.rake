namespace :db do
  task :migrate do
    Rake::Task["db:test:prepare"].invoke if Rails.env.development?
  end
end
