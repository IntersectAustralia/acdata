require File.expand_path('../../../lib/tasks/test_ldap.rb', __FILE__)

Before do
  @test_ldap = TestLDAP.new('test')
  @test_ldap.create_ldap_tree
end

After do
  @test_ldap.delete_all
  files_root = APP_CONFIG['files_root']
  if Dir.exist? files_root
    FileUtils.rm_rf(files_root)
  end
end

Before("@ajaxfail") do
  @resync = page.driver.options[:resynchronize]
  page.driver.options[:resynchronize] = false
end

After("@ajaxfail") do
  page.driver.options[:resynchronize] = @resync
end

After("@upload") do
  Sample.all.each do |sample|
    path = "tmp/#{sample.id}"
    FileUtils.rm_rf(path) if File.exists?(path)
  end
end

Before("@publish") do

end

After("@publish") do
  rda_files_root = APP_CONFIG['rda_files_root']
  if Dir.exist? rda_files_root
    FileUtils.rm_rf(rda_files_root)
  end
end


# Usage:
#  @wip @stop
#  Scenario: change password
#    ........................
# $ cucumber -p wip
After do |scenario|
  if scenario.failed? && scenario.source_tag_names.include?("@wip") && scenario.source_tag_names.include?("@stop")
    puts "Scenario failed. You are in rails console becuase of @stop. Type exit when you are done"
    require 'irb'
    require 'irb/completion'
    ARGV.clear
    IRB.start
  end
end
