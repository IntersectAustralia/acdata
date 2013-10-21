require File.dirname(__FILE__) + '/secret_generator.rb'
begin
  namespace :app do

    desc "Generating new secret"
    task :generate_secret => :environment do
      generate_secret_task
    end

  end
end
