# Initialize development instance of LDAP
require 'ladle'

if defined?(::RSpec)
  puts 'Rspec task found'
end

if defined?(::Cucumber)
  puts 'Cucumber task found'
end

unless defined?(::Rake)
  # Setup LDAP for rails server
  if %w(development test).include?(Rails.env)
    $ladle = Ladle::Server.new(
        :port   => 3897,
        :ldif   => "lib/ladle/sample_data.ldif",
        :domain => "dc=localhost"
    )

    puts 'Initializing local LDAP...'
    $ladle.start

    at_exit do
      puts 'Terminating local LDAP...'
      $ladle.stop
      puts 'Done.'
    end
  else
    puts "WARNING: Will not start local instance of LDAP if in non-development/test environment"
  end
end

