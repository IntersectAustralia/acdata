Feature: Export to ELN (Electronic Lab Notebook)

  In order to blog about my experiments
  As a user
  I want to be able to export my datasets to the ELN

  Background:
    Given I have the usual roles and permissions
    And I have the usual users
    And I have the usual datasets

  Scenario: Users can only view export to ELN if enabled in preferences
    Given I am logged in as "user1"
    And I follow "Preferences"
    And I follow "Sharing"
    And I check "Enable exporting to an ELN blog"
    And I press "Update"
    And I should be on the projects page
    And I should see "Your account details have been successfully updated"
    Given I am on the sample page for "s1"
    And I follow "dataset1"
    Then I should see "dataset1"
    And I should see "Export to ELN"

  @javascript
  Scenario: Configuring the blogs that the user wants to export to
    Given I am logged in as "user1"
    And I follow "Preferences"
    And I follow "Sharing"
    And I check "Enable exporting to an ELN blog"
    And I follow "Add ELN Blog"
    And I fill in the 1st ELN Blogs field with "Test_Blog"
    And I press "Update"
    And I should be on the projects page
    And I should see "Your account details have been successfully updated"
    Then I should have an ELN Blog "Test_Blog"

  @javascript
  @wizard
  Scenario: Can choose a configured blog to export to
    Given I am logged in as "user1"
    And I have enabled exporting to ELN
    And I have an ELN Blog "Test_Blog"
    Given I am on the view dataset page for "dataset1"
    And I click on "Share"
    And I follow "Export to ELN"
    And I wait for the wizard
    Then I should see the following options for "Export to Blog"
      | Test_Blog |

  @javascript
  Scenario: Configuring the blogs that the user wants to export to
    Given I am logged in as "user1"
    And I follow "Preferences"
    And I follow "Sharing"
    And I check "Enable exporting to an ELN blog"
    And I follow "Add ELN Blog"
    And I fill in the 1st ELN Blogs field with "Test Blog"
    And I press "Update"
    And I should see "ELN Blog name must be alphanumeric with optional underscores"