Feature: Logging In
  In order to use the system
  As a user
  I want to login

  Background:
    Given I have roles
      | name       |
      | Superuser  |
      | Researcher |
    And I have a user "user1"
    And "user1" has role "Researcher"

  Scenario: Successful login
    Given I am on the login page
    When I fill in "zID" with "user1"
    And I fill in "zPass" with "Pas$w0rd"
    And I press "Log in"
    Then I should be on the projects page

  Scenario: Should be redirected to the login page when trying to access a secure page
    Given I am on the list users page
    Then I should see "You need to log in before continuing."
    And I should be on the login page

  Scenario: Should be redirected to requested page after logging in
    Given I have a user "z1"
    And "z1" has role "Superuser"
    Given I am on the list users page
    When I fill in "zID" with "z1"
    And I fill in "zPass" with "Pas$w0rd"
    And I press "Log in"
    Then I should see "Logged in successfully."
    And I should be on the list users page

  Scenario: Failed login due to missing both login and password
    Given I am on the login page
    When I press "Log in"
    Then I should see "Invalid username or password. Please check your zID and zPass and try again."
    And I should be on the login page

  Scenario: Failed login due to missing login
    Given I am on the login page
    And I fill in "zPass" with "Pas$w0rd"
    And I press "Log in"
    Then I should see "Invalid username or password. Please check your zID and zPass and try again."
    And I should be on the login page

  Scenario: Failed login due to missing password
    Given I am on the login page
    When I fill in "zID" with "user1"
    And I press "Log in"
    Then I should see "Invalid username or password. Please check your zID and zPass and try again."
    And I should be on the login page

  Scenario: Failed login due to invalid username
    Given I am on the login page
    When I fill in "zID" with "asdf"
    And I fill in "zPass" with "Pas$w0rd"
    And I press "Log in"
    Then I should see "Invalid username or password. Please check your zID and zPass and try again."
    And I should be on the login page

  Scenario: Failed login due to incorrect password
    Given I am on the login page
    When I fill in "zID" with "user1"
    And I fill in "zPass" with "blah"
    And I press "Log in"
    Then I should see "Invalid username or password. Please check your zID and zPass and try again."
    And I should be on the login page

  Scenario: Multiple (3) failed logins resulting in account being locked.
    Given I am on the login page
    When I fill in "zID" with "user1"
    And I fill in "zPass" with "blah"
    And I press "Log in"
    Then I should see "Invalid username or password. Please check your zID and zPass and try again."
    And I should be on the login page
    When I fill in "zID" with "user1"
    And I fill in "zPass" with "blah"
    And I press "Log in"
    Then I should see "Invalid username or password. Please check your zID and zPass and try again."
    And I should be on the login page
    When I fill in "zID" with "user1"
    And I fill in "zPass" with "blah"
    And I press "Log in"
    Then I should see "Invalid username or password. Please check your zID and zPass and try again."
    And I should be on the login page
    When I fill in "zID" with "user1"
    And I fill in "zPass" with "blah"
    And I press "Log in"
    And I should be on the login page
    Then I should see "Invalid username or password. Please check your zID and zPass and try again."
    And the "user1" account should be locked

  Scenario: Successful login after lock expiring
    Given I am on the login page
    And I have a user "user3" with an expired lock
    When I fill in "zID" with "user3"
    And I fill in "zPass" with "Pas$w0rd"
    And I press "Log in"
    Then I should be on the projects page
