Feature: Register users
  In order to allow users to access the system
  As a user
  I want to be able to register for access

  Background:
    Given I have no users
    And I have the usual roles and permissions

  Scenario: New registration request
    Given I have unregistered users
      | login | email               | first_name | last_name |
      | test  | test@example.com.au | test       | user      |
    And I am on the user registration page
    And I fill in "zID" with "test"
    And I fill in "zPass" with "Pas$w0rd"
    And I press "Complete Registration"
    Then I should be on the home page
    And I should see "Thanks for requesting an account. You will receive an email when your request has been approved."
    And I should have registration requests
      | login | email               | first_name | last_name |
      | test  | test@example.com.au | test       | user      |

  Scenario: Repeat registration request after having already registered
    Given I have users
      | login   | email                  | first_name | last_name |
      | another | another@example.com.au | another    | user      |
    And I am on the user registration page
    And I fill in "zID" with "another"
    And I fill in "zPass" with "Pas$w0rd"
    And I press "Complete Registration"
    Then I should be on the home page
    And I should see "You have already registered and have been approved."

  Scenario: Repeat registration request after having been rejected permanently
    Given I have users
      | login   | email                  | first_name | last_name |
      | another | another@example.com.au | another    | user      |
    And I reject permanently user "another"
    And I am on the user registration page
    And I fill in "zID" with "another"
    And I fill in "zPass" with "Pas$w0rd"
    And I press "Complete Registration"
    Then I should be on the home page
    And I should see "You have been blocked from registering. Contact the ACData administrator if you believe this is in error."

  Scenario: Email address from directory service is used when one is not supplied
    Given I have unregistered users
      | login | email               | first_name | last_name |
      | test  | test@example.com.au | test       | user      |
    And I am on the user registration page
    And I fill in "zID" with "test"
    And I fill in "zPass" with "Pas$w0rd"
    And I press "Complete Registration"
    Then user "test" should have email address "test@example.com.au"

  Scenario: Supplying an email address when registering supplants the one from the directory service
    Given I have unregistered users
      | login | email               | first_name | last_name |
      | test  | test@example.com.au | test       | user      |
    And I am on the user registration page
    And I fill in "zID" with "test"
    And I fill in "zPass" with "Pas$w0rd"
    And I fill in "Email" with "test@example.com"
    And I press "Complete Registration"
    Then user "test" should have email address "test@example.com"

  Scenario: Supplying a phone number when registering
    Given I have unregistered users
      | login | email               | first_name | last_name |
      | test  | test@example.com.au | test       | user      |
    And I am on the user registration page
    And I fill in "zID" with "test"
    And I fill in "zPass" with "Pas$w0rd"
    And I fill in "Phone Number" with "12345"
    And I press "Complete Registration"
    Then user "test" should have phone number "12345"

