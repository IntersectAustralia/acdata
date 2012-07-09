Then /^I should have an ELN Blog "([^"]*)"$/ do |blog_name|
  ElnBlog.find_by_name(blog_name).should_not be_nil
end

Given /^I have enabled exporting to ELN$/ do
  @current_user.should_not be_nil
  @current_user.eln_enabled = true
  @current_user.save!
end

Given /^I have an ELN Blog "([^"]*)"$/ do |blog_name|
  ElnBlog.create(
    :name => blog_name,
    :user => @current_user
  )
  ElnBlog.find_by_name(blog_name).should_not be_nil
end

Given /^I fill in the (\d+)[a-z]* ELN Blogs field with "([^"]*)"$/ do |i, value|
  input_elems = all(:xpath, ".//input[starts-with(@id, 'user_eln_blogs_attributes_')]")
  input_elems[i.to_i-1].set(value)
end
