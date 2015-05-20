require "bundler/gem_tasks"

namespace :db do
  require_relative "lib/blergers/init_db"

  desc "Run migrations"
  task :migrate do
    version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
    ActiveRecord::Migrator.migrate('db/migrate', version)
  end
end
