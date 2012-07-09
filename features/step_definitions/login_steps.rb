include Warden::Test::Helpers

Given /^I am logged in as "([^"]*)"$/ do |login|
  visit path_to("the login page")
  fill_in("user_login", :with => login)
  fill_in("user_password", :with => "Pas$w0rd")
  click_button("Log in")
  @current_user = User.find_by_login(login)
end

Given /^I have no users$/ do
  User.delete_all
end

Then /^I should be able to log in with "([^"]*)" and "([^"]*)"$/ do |login, password|
  visit path_to("the logout page")
  visit path_to("the login page")
  fill_in("user_login", :with => login)
  fill_in("user_password", :with => password)
  click_button("Log in")
  page.should have_content('Logged in successfully.')
  current_path.should == path_to('the home page')
end

Then /^I should have a user "([^"]*)"$/ do |login|
  User.find_by_login(login).present?
end

Then /^the "([^"]*)" account should be locked$/ do |login|
  User.find_by_login(login).locked_at.present?
end

Given /^the session for "([^"]*)" ends$/ do |login|
  logout
end

