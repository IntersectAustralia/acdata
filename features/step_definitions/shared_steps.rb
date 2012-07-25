require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "selectors"))

Then /^I should see "([^"]*)" table with$/ do |table_id, expected_table|

  rows = find("table##{table_id}").all('tr')
  table = rows.map { |r| r.all('th,td').map { |c| c.text.strip } }
  expected_table.diff!(table)
end

Then /^I should see field "([^"]*)" with value "([^"]*)"$/ do |field, value|
  # this assumes you're using the helper to render the field which sets the div id based on the field name
  div_id = field.tr(" ,", "_").downcase
  div_scope = "div#display_#{div_id}"
  with_scope(div_scope) do
    page.should have_content(field)
    page.should have_content(value)
  end
end

Then /^I should see fields displayed$/ do |table|
  # as above, this assumes you're using the helper to render the field which sets the div id based on the field name
  table.hashes.each do |row|
    field = row[:field]
    value = row[:value]
    div_id = field.tr(" ,", "_").downcase
    div_scope = "div#display_#{div_id}"
    with_scope(div_scope) do
      page.should have_content(field)
      page.should have_content(value)
    end
  end
end

Then /^I should see button "([^"]*)"$/ do |arg1|
  page.should have_xpath("//input[@value='#{arg1}']")
end

Then /^I should see image "([^"]*)"$/ do |arg1|
  page.should have_xpath("//img[contains(@src, #{arg1})]")
end

Then /^I should not see button "([^"]*)"$/ do |arg1|
  page.should have_no_xpath("//input[@value='#{arg1}']")
end

Then /^I should see button "([^"]*)" within "([^\"]*)"$/ do |button, scope|
  with_scope(scope) do
    page.should have_xpath("//input[@value='#{button}']")
  end
end

Then /^I should not see button "([^"]*)" within "([^\"]*)"$/ do |button, scope|
  with_scope(scope) do
    page.should have_no_xpath("//input[@value='#{button}']")
  end
end

Then /^I should get a security error "([^"]*)"$/ do |message|
  page.should have_content(message)
  current_path = URI.parse(current_url).path
  current_path.should == path_to("the home page")
end

Then /^I should see link "([^"]*)"$/ do |text|
  # only look within the main content so we're not looking at the nav links
  with_scope("div.content") do
    page.should have_link(text)
  end
end

Then /^I should not see link "([^"]*)"$/ do |text|
  # only look within the main content so we're not looking at the nav links
  with_scope("div.content") do
    page.should_not have_link(text)
  end
end

Then /^I should see link "([^\"]*)" within "([^\"]*)"$/ do |text, scope|
  with_scope(scope) do
    page.should have_link(text)
  end
end

Then /^I should not see link "([^\"]*)" within "([^\"]*)"$/ do |text, scope|
  with_scope(scope) do
    page.should_not have_link(text)
  end
end

When /^(?:|I )deselect "([^"]*)" from "([^"]*)"(?: within "([^"]*)")?$/ do |value, field, selector|
  with_scope(selector) do
    unselect(value, :from => field)
  end
end

When /^I select$/ do |table|
  table.hashes.each do |hash|
    When "I select \"#{hash[:value]}\" from \"#{hash[:field]}\""
  end
end

When /^I fill in$/ do |table|
  table.hashes.each do |hash|
    When "I fill in \"#{hash[:field]}\" with \"#{hash[:value]}\""
  end
end

# can be helpful for @javascript features in lieu of "show me the page"
Then /^pause$/ do
  puts "Press Enter to continue"
  STDIN.getc
end

When /^I wait for (\d+) seconds?$/ do |secs|
  sleep secs.to_i
end

#http://makandra.com/notes/1049-check-that-a-page-element-is-not-visible-with-selenium
Then /^"([^\"]+)" should not be visible$/ do |text|
  paths = [
      "//*[@class='hidden']/*[contains(.,'#{text}')]",
      "//*[@class='invisible']/*[contains(.,'#{text}')]",
      "//*[@style='display: none;']/*[contains(.,'#{text}')]"
  ]
  xpath = paths.join '|'
  page.should have_xpath(xpath)
end

Then /^the "([^"]*)" tab should be open$/ do |tab_title|
  fragment = URI.parse(current_url).fragment
  fragment.should == selector_for(tab_title)
end

Then /^I should see the following options for "([^"]*)"$/ do |selector, table|
  with_scope(selector) do
    table.hashes.each do |row|
      option = row[:option]
      page.should have_content(option)
    end
  end
end

When /^I wait for the wizard$/ do
  wait_until do
    page.evaluate_script('$.active') == 0
  end
end

When /^I wait until the wizard completes$/ do
  wait_until do
    page.evaluate_script('$.active') == 0
  end
end

Then /^I should (|not )be able to delete "([^"]*)"$/ do |action, name|
  if action.match(/not/)
    page.should have_no_css("a[id$='delete_link']")
  else
    page.should have_css("a[id$='delete_link']")
  end
end

Then /^I should (|not )be able to edit "([^"]*)"$/ do |action, name|
  if action.match(/not/)
    page.should have_no_css("a[id^='show_edit']")
  else
    page.should have_css("a[id^='show_edit']")
  end
end

Then /^I should (?:have|see) a warning containing "([^"]+?)"$/ do |text|
  page.driver.browser.switch_to.alert.text.should have_content(text)
end

