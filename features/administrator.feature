Feature: Administrator
  In order to configure global settings
  As an administrator
  I want access to certain application configurations

  Background:
    Given I have no users
    And I have the usual slide scanning email
    And I have users
      | login    | email                     | first_name | last_name |
      | georgina | georgina@example.com.au | Georgina   | Edwards   |
      | raul     | raul@example.com.au     | Raul       | Carrizo   |
    And I have the usual roles and permissions
    And "georgina" has role "Superuser"
    And "raul" has role "Researcher"

  Scenario: Setting range of dataset handles
    Given I am logged in as "georgina"
    And I follow "Admin Tasks"
    And I follow "Edit Handle Range"
    And I should see "Edit range of dataset handles"
    And I fill in "Start Handle Range" with "hdl:1959.4/004_300"
    And I fill in "End Handle Range" with "hdl:1959.4/004_301"
    And I press "Save"
    Then I should be on the admin page
    And I should see "Dataset handles have been configured successfully"

  Scenario: Non superusers cannot edit handle ranges
    Given I am logged in as "raul"
    And I am on the edit handles page
    Then I should be on the projects page
    And I should see "You are not authorized to access this page"

  Scenario: Start handle range must be defined if there is an end handle range
    Given I am logged in as "georgina"
    And I follow "Admin Tasks"
    And I follow "Edit Handle Range"
    And I should see "Edit range of dataset handles"
    And I fill in "Start Handle Range" with ""
    And I fill in "End Handle Range" with "hdl:1959.4/004_300"
    And I press "Save"
    Then I should see "Start handle range must be defined if end handle range is specified"

  Scenario: Start handle range must be less than end handle range
    Given I am logged in as "georgina"
    And I follow "Admin Tasks"
    And I follow "Edit Handle Range"
    And I should see "Edit range of dataset handles"
    And I fill in "Start Handle Range" with "hdl:1959.4/004_400"
    And I fill in "End Handle Range" with "hdl:1959.4/004_300"
    And I press "Save"
    Then I should see "Start handle range must be less than end handle range"

  Scenario: Validates format of handles
    Given I am logged in as "georgina"
    And I follow "Admin Tasks"
    And I follow "Edit Handle Range"
    And I should see "Edit range of dataset handles"
    And I fill in "Start Handle Range" with "hdl:1959.4/005_300"
    And I fill in "End Handle Range" with "hdl:1959.4/004_"
    And I press "Save"
    Then I should see "Start handle range is invalid"
    Then I should see "End handle range is invalid"

  Scenario: Validates slide scanning email
    Given I am logged in as "georgina"
    And I follow "Admin Tasks"
    And I follow "Edit Slide Scanning Email"
    And I should see "Edit slide scanning email"
    And I fill in "Slide Scanning Email" with ""
    And I press "Save"
    Then I should see "Slide scanning email can't be blank"
    Then I should not see "Slide scanning email is invalid"
    And I fill in "Slide Scanning Email" with "acdata"
    And I press "Save"
    Then I should see "Slide scanning email is invalid"
    And I fill in "Slide Scanning Email" with "acdata@unsw.edu.au"
    And I press "Save"
    Then I should see "Slide scanning email has been configured successfully"