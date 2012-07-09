Feature: Edit my details
  In order to keep my details up to date
  As a user
  I want to edit my details

  Background:
    Given I have no users
    Given I have the usual roles and permissions
    And I have users
      | login    | email                   | first_name | last_name | role       |
      | georgina | georgina@example.com.au | Georgina   | Edwards   | Researcher |
    And I am logged in as "georgina"

  Scenario: Edit my information
    Given I am on the projects page
    When I follow "Preferences"
    And I fill in "Email" with "foo@example.com"
    And I fill in "Phone Number" with "123"
    And I press "Update"
    Then I should see "Your account details have been successfully updated."
    And I should be on the projects page
    And I follow "Preferences"
    And the "Email" field should contain "foo@example.com"
    And the "Phone Number" field should contain "123"

  Scenario: Cancel editing my information
    Given I am on the projects page
    When I follow "Preferences"
    And I follow "Cancel"
    Then I should be on the projects page

  @javascript
  Scenario: Invalid fields
    Given I am on the projects page
    When I follow "Preferences"
    And I check "I'm a research student"
    And I fill in "Phone Number" with "123"
    And I fill in "Supervisor Name" with "       "
    And I fill in "Supervisor Email" with "       "
    And I fill in "Email" with ""
    And I press "Update"
    Then I should see "Supervisor name can't be blank"
    And I should see "Supervisor email can't be blank"
    And I should not see "Supervisor email is invalid"
    And I should see "Email can't be blank"
    And I fill in "Supervisor Email" with "invalid"
    And I fill in "Email" with "invalid"
    And I press "Update"
    Then I should see "Supervisor email is invalid"
    Then I should see "Email is invalid"
    And I fill in "Supervisor Email" with "invalid"
    And I fill in "Email" with "invalid"
    And I uncheck "I'm a research student"
    And I press "Update"
    Then I should not see "Supervisor name can't be blank"
    Then I should not see "Supervisor email is invalid"
    Then I should see "Email is invalid"

  Scenario:  User cannot enable slide scanning requests unless phone number is provided
    Given I am on the projects page
    When I follow "Preferences"
    And I fill in "Phone Number" with ""
    And I follow "Automation"
    And I check "Enable Slide Scanning Service requests"
    And I press "Update"
    Then I should see "Phone number must be provided for Slide Scanning Service requests"

  Scenario:  Phone number not required if slide scanning requests not specified
    Given I am on the projects page
    When I follow "Preferences"
    And I fill in "Phone Number" with "     "
    And I follow "Automation"
    And I uncheck "Enable Slide Scanning Service requests"
    And I press "Update"
    And I should see "Your account details have been successfully updated."
    Then I should not see "Phone number must be provided for Slide Scanning Service requests"

