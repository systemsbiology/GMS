require 'fileutils.rb'
require 'whenever/capistrano'
load 'config/cap_user.rb' # contains set :cap_user, "username"

set :application, "GMS"
set :deploy_to, "/local/www/software/gms/"
set :keep_releases, 3
#set :shared_host, "bobama.systemsbiology.net"
set :whenever_command, "bundle exec whenever"
set :environment, "production"
#set :whenever_environment, defer { environment }
set :whenever_identifier, defer { "#{application}_#{environment}" }
set :rail_env, "production"

set :rake, "bundle exec rake"
#set :rvm_ruby_string, ENV['GEM_HOME'].gsub(/.*\//,"")  # set up which gemset you're using
#set :rvm_ruby_string, "ruby-1.9.3-p448@global"
#set :rvm_install_ruby_params, '--1.9'
#set :rvm_install_pkgs, %w[libyaml openssl]
#set :rvm_install_ruby_params, '--with-opt-dir=/u5/tools/rvm/usr'

#before 'deploy', 'rvm:install_rvm'
#before 'deploy', 'rvm:install_pkgs'
#before 'deploy', 'rvm:install_ruby'
#before 'deploy', 'rvm:create_gemset'
#before 'deploy', 'rvm:import_gemset'
set :bundle_gemfile, "Gemfile"
set :bundle_dir, fetch(:shared_path)+"/bundle"
set :bundle_flags, "--deployment"


# IN ORDER TO MAKE THE DEPLOY WORK ON EC2 with a PEM, YOU HAVE TO 
# type 'ssh-agent', then copy and paste that into your shell to
# set the ssh agent information

set :user, 'ec2-user'
#capistrano pem ec2 info
default_run_options[:pty] = true
#ssh_options[:forward_agent] = true
ssh_options[:auth_methods] = ["publickey"]
ssh_options[:keys] = ["/home/ec2-user/.ssh/isb_engineers.pem"]
#ssh_options[:verbose] = :debug

before 'bundle:install', "bundle:list"
set :default_environment, {
  'PATH' => "/u5/tools/rvm/gems/ruby-1.9.3-p448@global/bin:/u5/tools/rvm/bin:/u5/tools/rvm:/u5/tools/rvm/scripts:/bin/:/tools/bin:/local/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/bin",
  'RUBY_VERSION' => 'ruby-1.9.3-p448@global',
  'GEM_HOME' => '/u5/tools/rvm/gems/ruby-1.9.3-p448@global',
  'GEM_PATH' => '/u5/tools/rvm/gems/ruby-1.9.3-p448@global',
  'BUNDLE_PATH' => '/u5/tools/rvm/gems/ruby-1.9.3-p448@global'
}

#set :scm, :subversion
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
set :scm, :git
set :repository, "git@github.com:systemsbiology/GMS.git"
set :branch, "master"
set :use_sudo, false

server "54.197.155.102", :app, :web, :db, :primary => true

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

namespace :bundle do
  desc "list gems"
  task :list do 
    run "cd #{release_path} && cat Gemfile"
  end
end

# If you are using Passenger mod_rails uncomment this:
 namespace :deploy do
   desc "starting mod_rails"
   task :start do ; end

   desc "stopping mod_rails"
   task :stop do ; end

   desc "Restarting mod_rails with restart.txt"
   task :restart, :roles => :app, :except => { :no_release => true } do
     run "touch #{File.join(current_path,'tmp','restart.txt')}"
   end
  
   desc "Symlinks the database.yml"
   task :symlink_db, :roles => :app do
     run "ln -nfs #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
   end

   desc "Symlinks the jquery.min"
   task :symlink_jquery, :roles => :app do
     run "ln -fs #{release_path}/public/javascripts/jquery.js #{release_path}/public/javascripts/jquery.min.js"
   end

   desc "Export files"
   task :run_all_exports, :roles => :app do
     run("cd #{release_path}; bundle exec rake export:export_all_assemblies")
     run("cd #{release_path}; bundle exec rake export:export_all_assembly_files")
     run("cd #{release_path}; bundle exec rake export:export_all_individuals")
     run("cd #{release_path}; bundle exec rake export:export_all_samples")
   end

 end

 namespace :assets do
   desc "Copies the production shared/system directory to local machine"
   task :prod_to_local do
     run_locally("rsync --archive --recursive --times --rsh=ssh --compress --human-readable --progress #{cap_user}@#{shared_host}:#{shared_path}/system public/")
   end

   desc "Copies the local public/system directory to production machine"
   task :local_to_prod do
     run_locally("rsync --archive --recursive --times --rsh=ssh --compress --human-readable --progress public/system #{cap_user}@#{shared_host}:#{shared_path}")
   end
 end

 namespace :data do
    require 'yaml'
    set :prod_dump_file, "prod-#{application}_#{Time.now.strftime("%Y%m%d%H%M%S%L")}.dmp"
    set :dev_dump_file, "dev-#{application}_#{Time.now.strftime("%Y%m%d%H%M%S%L")}.dmp"

    desc <<-DESC
      Dump development data, push it to production and load it.
    DESC
    task :deploy_data do
      cache_dev_data
      deploy_dev_data
    end

    desc <<-DESC
      Make a copy of the production data.
      Get development data and load it into production.  A new
      copy of the development database and public/system are cached
      and loaded into the production server.
    DESC
    task :load_from_prod do
      cache_dev_data
      cache_prod_data
      load_prod_cache
    end

    desc <<-DESC
      Download development data and cache it.
    DESC
    task :cache_dev_data do
      on_rollback { run "rm data/#{dev_dump_file}" }

      config = YAML::load_file('config/database.yml')['development']

      FileUtils.mkdir_p("data/development")

      run_locally "mysqldump #{mysql_options(config, false)}" +
          " > data/development/#{dev_dump_file}" do |ch, _, out|
        if out =~ /^Enter password: /
          ch.send_data "#{config['password']}\n"
        else
          puts out
        end
      end
    end
    desc <<-DESC
      Load development data to production. Expects data dump already created.
    DESC
    task :deploy_dev_data, :roles => [:db] do
      run "mkdir -p #{current_path}/tmp"
      upload('config/database.yml', "#{current_path}/tmp/prod.yml")
      config = YAML::load_file("#{current_path}/tmp/prod.yml")['production']
      run "mkdir -p #{current_path}/tmp/data"
      upload("data/development/#{dev_dump_file}","#{current_path}/tmp/data/#{dev_dump_file}")
      logger.debug "checking that #{current_path}/tmp/data/#{dev_dump_file} got transferred"
      if remote_file_exists?("#{current_path}/tmp/data/#{dev_dump_file}")
        mysql_load = "mysql #{mysql_options(config)} < #{current_path}/tmp/data/#{dev_dump_file}"
        logger.debug %(executing "#{mysql_load.sub(/-p\S+/, '-px')}")
        run mysql_load
        run "rm #{current_path}/tmp/data/#{dev_dump_file}"
      else
        abort "MySQLdump file did not transfer properly"
      end
    end

    desc <<-DESC
      Get production and cache it locally.  The production database
        is downloaded and cached.
    DESC
    task :cache_prod_data, :roles => [:db] do
      on_rollback { run "rm #{current_path}/tmp/#{prod_dump_file}" }
      run "mkdir -p #{current_path}/tmp"
      get("#{current_path}/config/database.yml", "tmp/prod.yml")
      config = YAML::load_file("tmp/prod.yml")['production']

      run "mysqldump #{mysql_options(config, false)}" +
          " > #{current_path}/tmp/#{prod_dump_file}" do |ch, _, out|
        if out =~ /^Enter password: /
          ch.send_data "#{config['password']}\n"
        else
          puts out
        end
      end

      FileUtils.mkdir_p("tmp/data/")

      logger.debug "sftping #{prod_dump_file} from #{application}"
      logger.debug "ls #{prod_dump_file}"
      run "ls -lah #{current_path}/tmp/#{prod_dump_file}"
#      system "rsync -lrp #{cap_user}@#{application}:#{current_path}/tmp/#{prod_dump_file} tmp/data"
      get("#{current_path}/tmp/#{prod_dump_file}", "tmp/data/#{prod_dump_file}")
      run "rm #{current_path}/tmp/#{prod_dump_file}"
    end


    desc <<-DESC
      Load production cache into local database.
    DESC
    task :load_prod_cache, :roles => [:dev] do
      config = YAML::load_file('config/database.yml')['development']
      if File.exist?("tmp/data/#{prod_dump_file}")
        mysql_load = "mysql #{mysql_options(config)} < tmp/data/#{prod_dump_file}"
        logger.debug %(executing "#{mysql_load.sub(/-p\S+/, '-px')}")
        system mysql_load
        FileUtils.mkdir_p("data/production")
        FileUtils.cp_r("tmp/data/#{prod_dump_file}", "data/production")
      else
        abort "The data cache is empty, try 'cap data:load_from_prod'"
      end
    end


    # Return MySQL options for a specific configuration.
    def mysql_options(config, prompt_for_password=false)
      if config['password']
        password_opt = prompt_for_password ? " -p" : " -p#{config['password']}"
      else
        password_opt = ""
      end
      if config['host']
       host_opt = "-h #{config['host']}"
      else
       host_opt = ""
      end
      " -u #{config['username']} " + host_opt + " #{config['database']}" + password_opt
    end

    def remote_file_exists?(full_path)
      'true' == capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
    end

 end # end data

after 'deploy:update_code', 'deploy:symlink_db'
after 'deploy:update_code', 'deploy:symlink_jquery'
after 'deploy:update_code', 'deploy:run_all_exports'
after 'deploy:publishing','deploy:restart'
require 'bundler/capistrano'
require 'whenever/capistrano'

