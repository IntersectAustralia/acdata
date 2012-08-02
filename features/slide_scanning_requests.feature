Feature: Slide Scanning Requests
  In order to store and organise experiment data
  As a user
  I want to be able to create and edit projects

  Background:
    Given I have the usual roles and permissions
    And I have the usual slide scanning email
    And I have users
      | login | email                | first_name | last_name | role       | phone_number |
      | user1 | user1@example.com.au | User       | One       | Researcher | 123          |
      | user2 | user2@example.com.au | User       | Two       | Researcher | 234          |
      | user3 | user3@example.com.au | User       | Three     | Researcher | 345          |
    And I have the following projects
      | name      | description   | owner |
      | project a | The A Project | user1 |
      | project b | The B Project | user2 |
      | project c | The C Project | user3 |
    And I have the following members for projects
      | name      | members     |
      | project a | user3,user2 |
      | project b | user1,user3 |
      | project c | user2,user1 |
    And I have the following collaborators for projects
      | name      | members |
      | project a | user2   |
      | project b | user3   |
      | project c | user1   |
    And I have the usual fluorescent labels

  Scenario: Viewers of a project should not be able to see the Slide Scanning Request button at all
    Given I am logged in as "user1"
    And I am on the project page for "project b"
    Then I should not see "Request Slide Scanning"
    And I follow "Preferences"
    And I follow "Automation"
    And I check "Enable Slide Scanning Service requests"
    And I press "Update"
    Then I should see "Your account details have been successfully updated."
    And I am on the project page for "project b"
    Then I should not see "Request Slide Scanning"

  Scenario: Collaborators of a project should be able to see the Slide Scanning Request button accordingly
    Given I am logged in as "user3"
    And I am on the project page for "project b"
    Then I should not see "Request Slide Scanning"
    And I follow "Preferences"
    And I follow "Automation"
    And I check "Enable Slide Scanning Service requests"
    And I press "Update"
    Then I should see "Your account details have been successfully updated."
    And I am on the project page for "project b"
    Then I should see "Request Slide Scanning"

  Scenario: Owners of a project should be able to see the Slide Scanning Request button accordingly
    Given I am logged in as "user2"
    And I am on the project page for "project b"
    Then I should not see "Request Slide Scanning"
    And I follow "Preferences"
    And I follow "Automation"
    And I check "Enable Slide Scanning Service requests"
    And I press "Update"
    Then I should see "Your account details have been successfully updated."
    And I am on the project page for "project b"
    Then I should see "Request Slide Scanning"

  @javascript

  Scenario: User should see the slide scanning guidelines and the ability to download as pdf
    Given I am logged in as "user1"
    And "user1" has enabled slide scanning requests
    And I am on the project page for "project a"
    And I follow "Request Slide Scanning"
    Then I should see "Slide Scanning Services Request"
    And I should see "Guidelines for Slide Scanning"
    And I should see "Download as PDF"

  @javascript

  Scenario: All fields are present
    Given I am logged in as "user1"
    And "user1" has enabled slide scanning requests
    And I am on the project page for "project a"
    And I follow "Request Slide Scanning"
    Then I should see "Slide Scanning Services Request"
    And I should see "Guidelines for Slide Scanning"
    And I should see "Download as PDF"
    And I follow "Agree"
    And I should see "Name"
    And I should see "User One"
    And I should see "Email"
    And I should see "user1@example.com.au"
    And I should see "Phone"
    And I should see "123"
    And I should see "Supervisor"
    And I should see "Dept/Group"
    And I should see "Reference Lab"
    And I should see "Project Name"
    And I should see "project a"

    And I should see "Ethics Approval"
    And I should see "Ethics Approval No"
    And I should see "I confirm that ethics approval is not required for these samples"

    And I should see "Account Details"
    And I should see "Fund Number"
    And I should see "Dept ID"
    And I should see "Project Number"

    And I should see "Scanning Details"
    And I should see "Number of Slides"
    And I should see "Type of Scanning"
    And I should see "Magnification"
    And I should see "Include Algorithms"
    And I should see "Fluorescent Label"


  @javascript

  Scenario: User creates a request
    Given I am logged in as "user1"
    And "user1" has enabled slide scanning requests
    And I am on the project page for "project a"
    And I follow "Request Slide Scanning"
    Then I should see "Slide Scanning Services Request"
    And I should see "Guidelines for Slide Scanning"
    And I should see "Download as PDF"
    And I follow "Agree"
    And I should see "Name"
    And I should see "User One"
    And I should see "Email"
    And I should see "user1@example.com.au"
    And I should see "Phone"
    And I should see "123"
    And I should see "Supervisor"
    And I fill in "Dept/Group" with "Dept 1"
    And I fill in "Reference Lab" with "Lab 1"
    And I should see "Project Name"
    And I should see "project a"

    And I should see "Ethics Approval"
    And I fill in "Ethics Approval No" with "1"
    And I should see "I confirm that ethics approval is not required for these samples"

    And I should see "Account Details"
    And I fill in "Fund Number" with "1"
    And I fill in "Dept ID" with "1"
    And I fill in "Project Number" with "1"

    And I should see "Scanning Details"
    And I fill in "Number of Slides" with "1"
    And I select "Brightfield" from "Type of Scanning"
    And I select "20x" from "Magnification"
    And I select "Yes" from "Include Algorithms"
    And I select "AMCA" from "Fluorescent Label"
    And I press "Submit"
    And I should be redirected to the project page for "project a"
    #TODO check request that is sent out
#    And I should see "You have successfully lodged a request for slide scanning services. You may now submit your slides for scanning."

  @javascript

  Scenario:  User creates a request with invalid fields
    Given I am logged in as "user1"
    And "user1" has enabled slide scanning requests
    And I am on the project page for "project a"
    And I follow "Request Slide Scanning"
    Then I should see "Slide Scanning Services Request"
    And I should see "Guidelines for Slide Scanning"
    And I should see "Download as PDF"
    And I follow "Agree"
    And I should see "Name"
    And I should see "Account Details"
    And I should see "Scanning Details"
    And I press "Submit"
    Then I should see a warning containing "You must specify a value for every field"
    And I dismiss popup

  @javascript
  @fluorescent
  Scenario: A user can select multiple fluorescent labels
    Given I am logged in as "user1"
    And "user1" has enabled slide scanning requests
    Given I fill in the usual slide scanning details for "project a"
    And I select "Fluorescent" from "Type of Scanning"
    And I select "AMCA" from "Fluorescent Label"
    And I select "APC" from "Fluorescent Label"
    And I press "Submit"
    Then I should have a slide scanning request for "project a" with
     |Fluorescent Label|
     |AMCA|
     |APC|

  @javascript
  @fluorescent
  Scenario: Fluorescent Label is mandatory for the Fluorescent Type of Scanning
    Given I am logged in as "user1"
    And "user1" has enabled slide scanning requests
    Given I fill in the usual slide scanning details for "project a"
    And I select "Fluorescent" from "Type of Scanning"
    And I press "Submit"
    Then I should see a warning containing "Please select one or more Fluorescent Labels"
    And I dismiss popup

  @javascript
  @fluorescent
  Scenario: A user can select no more than 4 fluorescent labels
    Given I am logged in as "user1"
    And "user1" has enabled slide scanning requests
    Given I fill in the usual slide scanning details for "project a"
    And I select "Fluorescent" from "Type of Scanning"
    And I select "Alexa Fluor 350" from "Fluorescent Label"
    And I select "AMCA" from "Fluorescent Label"
    And I select "APC" from "Fluorescent Label"
    And I select "DAPI" from "Fluorescent Label"
    And I select "EBFP" from "Fluorescent Label"
    Then I should see a warning containing "There can be a maximum of four Fluorescent Labels"
    And I dismiss popup

  @javascript
  @fluorescent
  Scenario: Fluorescent Label selection is disabled for non-fluorescent scanning type
    Given I am logged in as "user1"
    And "user1" has enabled slide scanning requests
    Given I fill in the usual slide scanning details for "project a"
    Then "Fluorescent Label" should be disabled
