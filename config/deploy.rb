# config valid for current version and patch releases of Capistrano
lock "~> 3.14.0"

#set :application, "my_app_name"
#set :repo_url, "git@example.com:me/my_repo.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, "config/database.yml"

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", '.bundle'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

set :log_level, :debug
SSHKit.config.output_verbosity = Logger::DEBUG
set :application, "GMS"
set :deploy_user, "automaton"
set :deploy_to, "/local/www/software/gms/"
set :keep_releases, 3
set :shared_host, "hypatia.systemsbiology.net"
set :whenever_command, "bundle exec whenever"
set :environment, "production"
#set :whenever_environment, defer { environment }
set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:environment)}" }
set :rail_env, "production"

#set :rake, "bundle exec rake"
#set :rvm_ruby_string, ENV['GEM_HOME'].gsub(/.*\//,"")  # set up which gemset you're using
#set :rvm_ruby_string, "ruby-2.3.1@rails3"
#set :rvm_install_ruby_params, '--1.9'
#set :rvm_install_pkgs, %w[libyaml openssl]
#set :rvm_install_ruby_params, '--with-opt-dir=/u5/tools/rvm/usr'

#before 'deploy', 'rvm:install_rvm'
#before 'deploy', 'rvm:install_pkgs'
#before 'deploy', 'rvm:install_ruby'
#before 'deploy', 'rvm:create_gemset'
#before 'deploy', 'rvm:import_gemset'
set :bundle_gemfile, "Gemfile"
set :bundle_dir, ->{ "#{fetch(:shared_path)}/bundle" }
set :bundle_flags, "--deployment"

#before 'bundle:install', "bundle:list"
set :default_env, {
  'PATH' => "/u5/tools/rvm/wrappers/ruby-2.7.0@rails6:/u5/tools/rvm/rubies/ruby-2.7.0/bin/:/u5/tools/rvm/gems/ruby-2.7.0@rails6/bin:/u5/tools/rvm/bin:/u5/tools/rvm:/u5/tools/rvm/scripts:/bin/:/local/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/bin",
  'RUBY_VERSION' => 'ruby-2.7.0@rails6',
  'GEM_HOME' => '/u5/tools/rvm/gems/ruby-2.7.0@rails6',
  'GEM_PATH' => '/u5/tools/rvm/gems/ruby-2.7.0@rails6',
  'BUNDLE_PATH' => '/u5/tools/rvm/gems/ruby-2.7.0@rails6',
  'rvm_bin_path' => '/u5/tools/rvm/bin',
}
#capistrano pem ec2 info
#default_run_options[:pty] = true
#ssh_options[:forward_agent] = true
#ssh_options[:auth_methods] = ["publickey"]
#ssh_options[:keys] = ["/home/ec2-user/isb_engineers.pem"]
#before 'bundle:install', "bundle:list"
#set :default_environment, {
#  'PATH' => "/usr/local/share/ruby/gems/2.0/bin:/bin/:/tools/bin:/local/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/bin",
  #'GEM_HOME' => '/usr/local/share/ruby/gems/2.0',
  #'GEM_PATH' => '/usr/local/share/ruby/gems/2.0',
#  'BUNDLE_PATH' => '/usr/local/share/ruby/gems/2.0'
#}

set :repo_url, "/proj/famgen/git/gms"
#set :repository, "git@github.com:systemsbiology/GMS.git"
set :branch, "master"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts
namespace :deploy do
  # As of Capistrano 3.1, the `deploy:restart` task is not called
  # automatically.
  after 'deploy:publishing', 'deploy:restart'
end
