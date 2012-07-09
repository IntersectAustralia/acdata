Then /^I should have registration requests$/ do |table|
  table.hashes.each do |hash|
    user = User.find_by_login(hash[:login])
    assert !user.nil?
    assert user.pending_approval?
  end
end

Given /^I reject permanently user "([^"]*)"$/ do |login|
  User.find_by_login(login).reject
end

Then /^user "([^"]*)" should have email address "([^"]*)"$/ do |login, email|
  User.find_by_login(login).email.should == email
end

Then /^user "([^"]*)" should have phone number "([^"]*)"$/ do |login, phone|
  User.find_by_login(login).phone_number.should == phone
end

