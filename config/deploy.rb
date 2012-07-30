#$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require 'rvm/capistrano'
require 'capistrano/ext/multistage'
require 'bundler/capistrano'
set :whenever_environment, defer { stage }
set :whenever_command, "bundle exec whenever"
require 'whenever/capistrano'

set :stages, %w(qa staging production)
set :default_stage, "qa"
set :application, 'acdata'
set :shared_children, shared_children + %w(log_archive)
set :shell, '/bin/bash'
set :rvm_ruby_string, 'ruby-1.9.3-p194@acdata'
set :rvm_type, :user

# Deploy using copy  for now
set :scm, 'git'
set :repository, 'https://github.com/IntersectAustralia/acdata.git'
set :deploy_via, :copy
set :copy_exclude, [".git/*"]

set(:user) { "#{defined?(user) ? user : 'devel'}" }
set(:group) { "#{defined?(group) ? group : user}" }
set(:deploy_base) { "/home/#{user}" }
set(:deploy_to) { "#{deploy_base}/#{application}" }
set(:data_dir) { "#{defined?(data_dir) ? data_dir : '/data/acdata-samples'}" }

default_run_options[:pty] = true

namespace :noop do
  task :info do
    puts "stage=#{stage}, user=#{user}, group=#{group}, home=#{deploy_base}"
    puts "deploy_to=#{deploy_to}, data_dir=#{data_dir}"
  end
end

namespace :server_setup do
  namespace :filesystem do
    task :dir_perms, :roles => :app do
      run "[[ -d #{data_dir} ]] || #{try_sudo} mkdir -p #{data_dir}"
      run "#{try_sudo} chown -R #{user}.#{group} #{data_dir}"
      run "[[ -d #{deploy_to} ]] || #{try_sudo} mkdir #{deploy_to}"
      run "#{try_sudo} chown -R #{user}.#{group} #{deploy_to}"
      run "#{try_sudo} chmod 0711 #{deploy_base}"
    end
  end
  namespace :rvm do
    task :trust_rvmrc do
      run "rvm rvmrc trust #{release_path}"
    end
  end
  task :gem_install, :roles => :app do
    run "gem install bundler passenger"
  end
  task :passenger, :roles => :app do
    run "passenger-install-apache2-module -a"
  end
  namespace :config do
    task :apache do
      src = "#{release_path}/config/httpd/#{stage}_rails_#{application}.conf"
      dest = "/etc/httpd/conf.d/rails_#{application}.conf"
      run "cmp -s #{src} #{dest} > /dev/null; [ $? -ne 0 ] && #{try_sudo} cp #{src} #{dest} && #{try_sudo} /sbin/service httpd graceful; /bin/true"
    end
  end
  namespace :logging do
    task :rotation, :roles => :app do
      src = "#{release_path}/config/#{stage}.logrotate"
      dest = "/etc/logrotate.d/#{application}"
      run "cmp -s #{src} #{dest} > /dev/null; [ $? -ne 0 ] && #{try_sudo} cp #{src} #{dest}; /bin/true"
      if stage != :production
        src = "#{release_path}/config/httpd/httpd.logrotate"
        dest = "/etc/logrotate.d/httpd"
        run "cmp -s #{src} #{dest} > /dev/null; [ $? -ne 0 ] && #{try_sudo} cp #{src} #{dest}; /bin/true"
      else
        puts 'Skipping installing httpd logrotation on production'
      end
    end
  end
end

after 'deploy:setup', "server_setup:filesystem:dir_perms"
after 'deploy:update' do
  server_setup.logging.rotation
  server_setup.config.apache
  server_setup.rvm.trust_rvmrc
  deploy.restart
end


namespace :deploy do

  # Passenger specifics: restart by touching the restart.txt file
  task :start, :roles => :app, :except => {:no_release => true} do
    restart
  end
  task :stop do
    ;
  end
  task :restart, :roles => :app, :except => {:no_release => true} do
    run "touch #{File.join(current_path, 'tmp', 'restart.txt')}"
  end

  # Remote bundle install
  task :rebundle do
    run "cd #{current_path} && bundle install"
    restart
  end

  task :bundle_update do
    run "cd #{current_path} && bundle update"
    restart
  end

  # Create the db
  desc "Create the database"
  task :db_create, :roles => :db do
    run("cd #{current_path} && bundle exec rake db:create", :env => {'RAILS_ENV' => "#{stage}"})
  end

  # Load the schema
  desc "Load the schema into the database (WARNING: destructive!)"
  task :schema_load, :roles => :db do
    run("cd #{current_path} && bundle exec rake db:schema:load", :env => {'RAILS_ENV' => "#{stage}"})
  end

  # Run the sample data populator
  desc "Run the test data populator script to load test data into the db (WARNING: destructive!)"
  task :populate, :roles => :db do
    run("cd #{current_path} && bundle exec rake db:populate", :env => {'RAILS_ENV' => "#{stage}"})
  end

  # Seed the db
  desc "Run the seeds script to load seed data into the db (WARNING: destructive!)"
  task :seed, :roles => :db do
    run("cd #{current_path} && bundle exec rake db:seed", :env => {'RAILS_ENV' => "#{stage}"})
  end

  # Create initial users in test LDAP
  desc "Create initial users in test LDAP. Meant for staging, where sample data would not be added."
  task :initial_users, :roles => :db do
    run("cd #{current_path} && bundle exec rake ldap:initial_users", :env => {'RAILS_ENV' => "#{stage}"})
  end

  # Delete previous project files from the filesystem
  desc "Delete project data files from the filesystem (WARNING: destructive)"
  task :project_data_delete, :roles => :app do
    if stage != :production
      puts "Are you sure you want to delete all project data from disk? [N/y]"
      input = STDIN.gets.chomp
      if input.match(/^y/)
        run("rm -rf #{data_dir}/project_*")
      end
    else
      puts "Deletion of project data in production is prohibited"
    end
  end

  # Save current project data
  desc "Create a backup of current projects."
  task :project_data_save, :roles => :app do
    run("cd #{current_path} && bundle exec rake project_data:save", :env => {'RAILS_ENV' => "#{stage}"})
  end

  # Restore backed up project data
  desc "Restore (re-create) backed up projects."
  task :project_data_restore, :roles => :app do
    run("cd #{current_path} && bundle exec rake project_data:restore", :env => {'RAILS_ENV' => "#{stage}"})
  end

  # Assign handles to instruments
  desc "Assign handles to instruments"
  task :assign_instrument_handles, :roles => :app do
    run("cd #{current_path} && bundle exec rake ands_handles:assign_instruments", :env => {'RAILS_ENV' => "#{stage}"})
  end

  # Populate FOR Codes
  desc "Populate FOR codes"
  task :load_for_codes, :roles => :db do
    run("cd #{current_path} && bundle exec rake data:for_codes:load", :env => {'RAILS_ENV' => "#{stage}"})
  end

  desc "Populate SEO codes"
  task :load_seo_codes, :roles => :db do
    run("cd #{current_path} && bundle exec rake data:seo_codes:load", :env => {'RAILS_ENV' => "#{stage}"})
  end

  desc "Populate fluorescent labels"
  task :load_fluorescent_labels, :roles => :db do
    run("cd #{current_path} && bundle exec rake data:fluorescent_labels:load", :env => {'RAILS_ENV' => "#{stage}"})
  end

  desc "Populate slide guidelines"
  task :load_slide_guidelines, :roles => :db do
    run("cd #{current_path} && bundle exec rake data:slide_guidelines:load", :env => {'RAILS_ENV' => "#{stage}"})
  end
  #
  ## Set the revision
  #desc "Set SVN revision on the server so that we can see it in the deployed application"
  #task :set_svn_revision, :roles => :app do
  #  put("#{real_revision}", "#{release_path}/app/views/layouts/_revision.rhtml")
  #end

  desc "Full redeployment, it runs deploy:update, deploy:refresh_db, and deploy:restart"
  task :full_redeploy do
    update
    rebundle
    refresh_db
    restart
  end

  # Helper task which re-creates the database
  task :refresh_db, :roles => :db do
    schema_load
    seed
    populate

  end

  task :load_data, :roles => :db do
    load_for_codes
    load_seo_codes
    load_fluorescent_labels
    load_slide_guidelines
    ands_parties.retrieve_all
    rda_grants.retrieve_all
    memre.retrieve
  end

  namespace :ands_parties do
    task :retrieve, :roles => :db do
      run("cd #{current_path} && bundle exec rake ands_parties:retrieve", :env => {'RAILS_ENV' => "#{stage}"})
    end
    task :retrieve_all, :roles => :db do
      run("cd #{current_path} && bundle exec rake ands_parties:retrieve_all", :env => {'RAILS_ENV' => "#{stage}"})
    end
  end

  namespace :rda_grants do
    task :retrieve, :roles => :db do
      run("cd #{current_path} && bundle exec rake rda_grants:retrieve", :env => {'RAILS_ENV' => "#{stage}"})
    end
    task :retrieve_all, :roles => :db do
      run("cd #{current_path} && bundle exec rake rda_grants:retrieve_all", :env => {'RAILS_ENV' => "#{stage}"})
    end
  end

  namespace :memre do
    task :retrieve, :roles => :db do
      run("cd #{current_path} && bundle exec rake memre:retrieve", :env => {'RAILS_ENV' => "#{stage}"})
    end
    task :refresh, :roles => :db do
      run("cd #{current_path} && bundle exec rake memre:refresh", :env => {'RAILS_ENV' => "#{stage}"})
    end
  end

end

after 'deploy:update_code' do
  generate_database_yml
  generate_initial_users_yml
  generate_deploy_config
  #deploy.set_svn_revision
end

desc "After updating code we need to populate a new database.yml"
task :generate_database_yml, :roles => :app do
  require "yaml"
  set :production_database_password, proc { Capistrano::CLI.password_prompt("Database password: ") }

  buffer = YAML::load_file('config/database.yml')
  # get rid of unneeded configurations
  buffer.delete('test')
  buffer.delete('development')
  buffer.delete('cucumber')
  buffer.delete('spec')

  # Populate production password
  buffer['production']['password'] = production_database_password

  put YAML::dump(buffer), "#{release_path}/config/database.yml", :mode => 0664
end

task :generate_deploy_config, :roles => :app do
  require "yaml"

  acdata_config = YAML::load_file('config/acdata_config.yml')
  file_path = "#{acdata_config[stage.to_s]['deploy_config_root']}/acdata_deploy_config.yml"

  output = capture("ls #{acdata_config[stage.to_s]['deploy_config_root']} | grep '^acdata_deploy_config.yml$'").strip

  if output.empty?
    buffer = YAML::load_file('config/acdata_deploy_config_template.yml')

    # get rid of unneeded configurations
    buffer.delete('test')
    buffer.delete('development')
    buffer.delete('cucumber')
    buffer.delete('spec')

    put YAML::dump(buffer), file_path, :mode => 0664
    puts "\nNOTICE: Please update #{file_path} with the appropriate values and restart the server\n\n"
  else
    puts "\nALERT: Config file #{file_path} detected. Will not overwrite\n\n"
  end

end

task :generate_initial_users_yml, :roles => :app do
  if stage != :production
    require "yaml"
    set :production_default_password, proc { Capistrano::CLI.password_prompt("Default initial user password: ") }

    buffer = YAML::load_file('config/initial_users.yml')

    # Populate password
    buffer['staging']['users'].each do |user|
      user['password'] = production_default_password
    end

    put YAML::dump(buffer), "#{release_path}/config/initial_users.yml", :mode => 0664
  end
end

