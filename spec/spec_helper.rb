require 'bundler/setup'
require 'as_json_representations'
require 'active_support'
require 'active_record'

db_config = YAML.safe_load(File.open("#{__dir__}/support/database_sqlite.yml"))

ActiveRecord::Base.establish_connection(db_config['test'])

ActiveRecord::Base.connection.create_table(:cities, force: true) do |t|
  t.string :name
  t.string :type
end

ActiveRecord::Base.connection.create_table(:users, force: true) do |t|
  t.string :first_name
  t.string :last_name
  t.integer :age
  t.references :city
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
