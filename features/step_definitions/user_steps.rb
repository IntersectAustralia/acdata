Given /^I have the usual users$/ do
  step "I have users", table(%{
    | login | email                | first_name | last_name | role       |
    | user1 | user1@example.com.au | User       | One       | Researcher |
    | user2 | user2@example.com.au | User       | Two       | Superuser  |
    | user3 | user3@example.com.au | User       | Three     | Superuser  |
  })
end

Given /^I have users$/ do |table|
  table.hashes.each do |hash|
    hash[:role] = Role.find_by_name(hash[:role])
    Factory(:user, hash.merge(:status => 'A'))
    add_ldap_user(hash)
  end
end

Given /^I have a user "([^"]*)"$/ do |login|
  user = create_user(login)
end

Given /^I have a locked user "([^"]*)"$/ do |login|
  user = create_user(login)
  user.locked_at = Time.now - 30.minute
  user.save!
end

Given /^I have a user "([^"]*)" with an expired lock$/ do |login|
  user = create_user(login)
  user.locked_at = Time.now - 1.hour - 1.second
  user.save!
end

Given /^I have a user "([^"]*)" with role "([^"]*)"$/ do |login, role|
  role = Role.where(:name => role).first
  add_user(login, role)
end

def create_user(login, role = nil)
  role ||= Role.where(:name => 'Researcher').first
  user = Factory(:user, :login => login, :status => 'A')
  user.role_id = role.id
  user.save!
  add_ldap_user({:login => login})
  return user
end

def add_ldap_user(hash)
  login = hash[:login]
  options = {
      :cn => login,
      :objectclass => ["top", "inetorgperson"],
      :sn => hash['last_name'] || login,
      :userPassword => 'Pas$w0rd'
  }
  options[:givenName] = hash['first_name'] if hash.include?('first_name')
  options[:mail] = hash['email'] if hash.include?('email')
  @test_ldap.add_user(
      "cn=#{login},ou=people,o=test,dc=localhost", options)
end

Given /^"([^"]*)" has enabled ELN export$/ do |login|
  User.find_by_login(login).update_attribute(:eln_enabled, true)
end

Given /^"([^"]*)" has enabled MemRE export$/ do |login|
  User.find_by_login(login).update_attribute(:memre_enabled, true)

end

Given /^"([^"]*)" has enabled slide scanning requests$/ do |login|
  User.find_by_login(login).update_attribute(:slide_request_enabled, true)

end
