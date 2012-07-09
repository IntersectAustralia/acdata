set(:user) { 'intersect' }
set :deploy_base, '/spare/acdata'
set :data_dir, '/spare/acdata/data'
set(:deploy_to) { "#{deploy_base}/acdata-web" }
# Your HTTP server, Apache/etc
role :web, 'www.researchdata.unsw.edu.au'
# This may be the same as your Web server
role :app, 'www.researchdata.unsw.edu.au'
# This is where Rails migrations will run
role :db,  'www.researchdata.unsw.edu.au', :primary => true

