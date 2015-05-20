require 'active_record'
require 'yaml'

config_file = 'config/database.yml'
config = YAML::load(File.open(config_file))
ActiveRecord::Base.establish_connection(config)
