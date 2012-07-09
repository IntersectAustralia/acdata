Feature: Project User Access
  In order to restrict access to my projects
  As a user
  I want to allow only members of my project to manage the project

  Background:
    Given I have the usual roles and permissions
    And I have users
      | login | email                  | first_name | last_name | role       |
      | user1 | user1@example.com.au | User       | One       | Researcher |
      | user2 | user2@example.com.au | User       | Two       | Researcher |
      | user3 | user3@example.com.au | User       | Three     | Researcher |
      | user4 | user4@example.com.au | User       | Four      | Researcher |
    And I have the following projects
      | name      | description   | owner |
      | project a | The A Project | user1 |
      | project b | The B Project | user2 |
      | project c | The C Project | user1 |
    And I have the following members for projects
      | name      | members     |
      | project a | user1,user3 |
      | project b | user3       |
      | project c | user2       |
    And I have the following collaborators for projects
      | name      | members |
      | project a | user4   |
      | project b | user4   |

  @javascript
  Scenario: User can view projects they own
    Given I am logged in as "user1"
    And I am on my projects page
    Then I should see "project a"
    Then I should not see "project b"
    Then I should see "project c"
    And I follow "project a"
    Then I should be on the project page for "project a"
    And I should see "Edit"
    And I should be able to delete "project a"
    And I should see "Add Experiment"
    And I should see "Add Sample"
    And I should see "Add User"
    And I should see "Publish Data to RDA"
    And I should not see "Remove Me"
    When I follow "Edit"
    Then I should see "Project Members"

  @javascript
  Scenario: User can edit projects they are collaborating on
    Given I am logged in as "user4"
    And I am on my projects page
    Then I should see "project a"
    Then I should see "project b"
    Then I should not see "project c"
    And I follow "project b"
    Then I should be on the project page for "project b"
    And I should see "Edit"
    And I should not be able to delete "project b"
    And I should see "Add Experiment"
    And I should see "Add Sample"
    And I should see "Publish Data to RDA"
    And I should not see "Add User"
    And I should see "Remove Me"
    When I follow "Edit"
    And I wait for the wizard
    And I should see "Edit Project"
    Then "Project Members" should not be visible

  Scenario: User can only view projects they are members of
    Given I am logged in as "user3"
    And I am on my projects page
    Then I should see "project a"
    Then I should see "project b"
    Then I should not see "project c"
    And I follow "project b"
    Then I should be on the project page for "project b"
    And I should not see "Edit"
    And I should not be able to delete "project b"
    And I should not see "Add Experiment"
    And I should not see "Add Sample"
    And I should not see "Publish Data to RDA"
    And I should not see "Add User"
    And I should see "Remove Me"

  Scenario: User cannot hard-code url to view other projects
    Given I am logged in as "user2"
    And I am on the project page for "project a"
    Then I should see "You are not authorized to access this page."

