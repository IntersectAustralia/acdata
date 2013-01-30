set(:user) { 'acdata' }
set :deploy_base, '/home/acdata'
set :data_dir, '/home/acdata/data'
set(:deploy_to) { "#{deploy_base}/acdata-web" }
set :deploy_via, :copy
set :scm, :none
set :repository, "/home/acdata/code_base/acdata-master/"
set :use_sudo, true
set :copy_dir, "/home/#{user}/tmp/"
set :remote_copy_dir, "/tmp"
set :rails_env, "production"
set :stage, "production"
# Your HTTP server, Apache/etc
role :web, ''
# This may be the same as your Web server
role :app, ''
# This is where Rails migrations will run
role :db,  '', :primary => true

