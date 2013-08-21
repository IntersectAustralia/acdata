# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

#Run ONCE in non-dev environments


unless %w(qa development test staging).include?(Rails.env)
  if Instrument.first.present? || InstrumentFileType.first.present? || Role.first.present?
    puts "----------\nYou cannot reseed an existing live deployment!\nIf something has genuinely gone wrong then this is not the way to fix it\nConsider lodging a support ticket.\n----------"
    raise StandardError, "FATAL: running db:seed more than once on a live deployment"
  end
end


require File.dirname(__FILE__) + '/seed_helper.rb'
require File.expand_path("../../lib/tasks/test_ldap.rb", __FILE__)
require File.expand_path("../../lib/tasks/data_manager.rb", __FILE__)

backup_old_projects
set_slide_scanning_email
set_handle_ranges
add_settings
create_roles_and_permissions
create_instrument_file_types
create_instruments #todo comment this out again
create_initial_users
#TestLDAP.new(Rails.env).populate_ldap('initial_users') unless Rails.env == 'production'
import_for_codes
import_seo_codes
import_fluorescent_labels
import_slide_guidelines
