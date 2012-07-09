Feature: Logging Out
  In order to keep the system secure
  As a user
  I want to logout
  
  Background:
    Given I have the usual roles and permissions
    And I have a user "georgina"
    And "georgina" has role "Superuser"
    And I am on the login page
    And I am logged in as "georgina"
  
  Scenario: Successful logout
    Given I am on the home page
    When I follow "Logout"
    Then I should see "Logged out successfully."

  Scenario: Logged out user can't access secure pages
    Given I am on the list users page
    And I follow "Logout"
    When I am on the list users page
    Then I should be on the login page
    And I should see "You need to log in before continuing."
