Feature: Administer users
  In order to allow users to access the system
  As an administrator
  I want to administer users

  Background:
    Given I have no users
    And I have users
      | login    | email                     | first_name | last_name |
      | georgina | georgina@example.com.au | Georgina   | Edwards   |
      | raul     | raul@example.com.au     | Raul       | Carrizo   |
    And I have access requests
      | login | email                  | first_name | last_name        |
      | ryan  | ryan@example.com.au  | Ryan       | Braganza         |
      | diego | diego@example.com.au | Diego      | Alonso de Marcos |
    And I have the usual roles and permissions
    And "georgina" has role "Superuser"
    And I am logged in as "georgina"

  Scenario: View a list of users
    And "raul" is deactivated
    When I am on the list users page
    Then I should see "users" table with
      | First name | Last name | Email                     | Role        | Status |
      | Georgina   | Edwards   | georgina@example.com.au | Superuser   | Active |
      | Raul       | Carrizo   | raul@example.com.au     |             | Deactivated |

  Scenario: View user details
    Given "raul" has role "Researcher"
    And I am on the list users page
    When I follow "View Details" for "raul"
    Then I should see field "Email" with value "raul@example.com.au"
    And I should see field "First name" with value "Raul"
    And I should see field "Last name" with value "Carrizo"
    And I should see field "Role" with value "Researcher"
    And I should see field "Status" with value "Active"

  Scenario: Go back from user details
    Given I am on the list users page
    When I follow "View Details" for "georgina"
    And I follow "Back"
    Then I should be on the list users page

  Scenario: Edit role
    Given "raul" has role "Researcher"
    And I am on the list users page
    When I follow "View Details" for "raul"
    And I follow "Edit role"
    And I select "Superuser" from "Role"
    And I press "Save"
    Then I should be on the user details page for raul
    And I should see "The role for Raul Carrizo was successfully updated."
    And I should see field "Role" with value "Superuser"

  Scenario: Edit role from list page
    Given "raul" has role "Researcher"
    And I am on the list users page
    When I follow "Edit role" for "raul"
    And I select "Superuser" from "Role"
    And I press "Save"
    Then I should be on the user details page for raul
    And I should see "The role for Raul Carrizo was successfully updated."
    And I should see field "Role" with value "Superuser"

  Scenario: Cancel out of editing roles
    Given "raul" has role "Researcher"
    And I am on the list users page
    When I follow "View Details" for "raul"
    And I follow "Edit role"
    And I select "Superuser" from "Role"
    And I follow "Cancel"
    Then I should be on the user details page for raul
    And I should see field "Role" with value "Researcher"

  Scenario: Deactivate active user
    Given I am on the list users page
    When I follow "View Details" for "raul"
    And I follow "Deactivate"
    Then I should see "The user has been deactivated"
    And I should see "Activate"

  Scenario: Activate deactivated user
    Given "raul" is deactivated
    And I am on the list users page
    When I follow "View Details" for "raul"
    And I follow "Activate"
    Then I should see "The user has been activated"
    And I should see "Deactivate"

  Scenario: Approve an access request
    Given I am on the access requests page
    When I follow "Approve" for "ryan"
    And I select "Researcher" from "Role"
    And I press "Approve"
    Then I should see "The access request for Ryan Braganza was approved."

  Scenario: Reject an access request
    Given I am on the access requests page
    When I follow "Reject" for "diego"
    Then I should see "The access request for Diego Alonso de Marcos was rejected."

  Scenario: Permanently reject an access request
    Given I am on the access requests page
    When I follow "Reject Permanently" for "diego"
    Then I should see "The access request for Diego Alonso de Marcos was rejected and this user will be permanently blocked."
