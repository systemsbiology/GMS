set :stage, :production

server "hypatia.systemsbiology.net", roles: [:app, :web, :db], user: 'automaton'
set :rails_env, :production
set :rvm_ruby_version, 'ruby-2.7.0@rails6'
set :rvm_custom_path, '/u5/tools/rvm/'
set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }
set :whenever_environment, -> { fetch(:stage) }
set :whenever_command,     ->{ "cd #{fetch(:release_path)} && bundle exec whenever" }
