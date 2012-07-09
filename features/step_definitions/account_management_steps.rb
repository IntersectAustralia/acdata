Given /^I have access requests$/ do |table|
  table.hashes.each do |hash|
    Factory(:user, hash.merge(:status => 'U'))
  end
end

Given /^I have unregistered users$/ do |table|
  table.hashes.each do |hash|
    add_ldap_user(hash)
  end
end

Given /^I have roles$/ do |table|
  table.hashes.each do |hash|
    Factory(:role, hash)
  end
end

Given /^I have permissions$/ do |table|
  table.hashes.each do |hash|
    create_permission_from_hash(hash)
  end
end

def create_permission_from_hash(hash)
  roles = hash[:roles].split(",")
  create_permission(hash[:entity], hash[:action], roles)
end

def create_permission(entity, action, roles)
  permission = Permission.new(:entity => entity, :action => action)
  permission.save!
  roles.each do |role_name|
    role = Role.where(:name => role_name).first
    role.permissions << permission
    role.save!
  end
end

Given /^"([^"]*)" has role "([^"]*)"$/ do |login, role|
  user = User.where(:login => login).first
  role = Role.where(:name => role).first
  user.role = role
  user.save!(:validate => false)
end

When /^I follow "Approve" for "([^"]*)"$/ do |login|
  user = User.where(:login => login).first
  click_link("approve_#{user.id}")
end

When /^I follow "Reject" for "([^"]*)"$/ do |login|
  user = User.where(:login => login).first
  click_link("reject_#{user.id}")
end

When /^I follow "Reject Permanently" for "([^"]*)"$/ do |login|
  user = User.where(:login => login).first
  click_link("reject_as_spam_#{user.id}")
end

When /^I follow "View Details" for "([^"]*)"$/ do |login|
  user = User.where(:login => login).first
  click_link("view_#{user.id}")
end

When /^I follow "Edit role" for "([^"]*)"$/ do |login|
  user = User.where(:login => login).first
  click_link("edit_role_#{user.id}")
end

Given /^"([^"]*)" is deactivated$/ do |login|
  user = User.where(:login => login).first
  user.deactivate
end

Given /^"([^"]*)" is pending approval$/ do |login|
  user = User.where(:login => login).first
  user.status = "U"
  user.save!
end

Given /^"([^"]*)" is rejected as spam$/ do |login|
  user = User.where(:login => login).first
  user.reject_access_request
end
