Feature: Manage Sample
  In order to store and organise sample data
  As a user
  I want to be able to create and edit sample

  Background:
    Given I have the usual roles and permissions
    And I have users
      | login | email                | first_name | last_name | role       |
      | user1 | user1@example.com.au | User       | One       | Researcher |
      | user2 | user2@example.com.au | User       | Two       | Superuser  |
    And I am logged in as "user1"
    And I have the following projects
      | name      | description   | owner |
      | project a | The A Project | user1 |
      | project b | The B Project | user2 |
      | project c | The C Project | user1 |

  @javascript
  Scenario: Create a sample in a project
    Given I am on the project page for "project a"
    And I click on "Add"
    And I follow "Add Sample"
    And I wait for the wizard
    Then I should see "Create New Sample"
    And I fill in "Name" with "New Sample"
    And I fill in "Description" with "desc1"
    And I press "Create Sample"
    And I wait for the wizard
    Then I should be redirected to the sample page for "New Sample"
    And I should see "Sample was successfully created"
    And I should have a sample "New Sample" under project "project a"

  @javascript
  Scenario: Create a sample in a project as a collaborator
    Given I have the following collaborators for projects
      | name      | members |
      | project a | user2   |
    And I follow "Logout"
    And I am logged in as "user2"
    And I am on the project page for "project a"
    And I click on "Add"
    And I follow "Add Sample"
    And I wait for the wizard
    Then I should see "Create New Sample"
    And I fill in "Name" with "sample name"
    And I fill in "Description" with "description"
    And I press "Create Sample"
    And I wait for the wizard
    Then I should be redirected to the sample page for "sample name"
    And I should see "Sample was successfully created"
    Then I should have a sample "sample name" under project "project a"

  @javascript
  Scenario: Creating a sample with missing mandatory field
    Given I am on the project page for "project a"
    And I click on "Add"
    And I follow "Add Sample"
    And I wait for the wizard
    Then I should see "Create New Sample"
    And I fill in "Description" with "sample name"
    And I press "Create Sample"
    Then I should see "Name can't be blank"

  @javascript
  Scenario: Create a sample in an experiment
    Given I have the following experiments
      | name | description | project   |
      | exp1 | desc1       | project a |
    And I am on the experiment page for "exp1"
    And I click on "Add"
    And I follow "Add Sample"
    And I wait for the wizard
    And I fill in "Name" with "sample name"
    And I fill in "Description" with "description"
    And I press "Create Sample"
    And I wait for the wizard
    Then I should be redirected to the sample page for "sample name"
    And I should see "Sample was successfully created"
    Then I should have a sample "sample name" under experiment "exp1"

  @javascript
  Scenario: Create a sample in an experiment as a collaborator
    Given I have the following experiments
      | name | description | project   |
      | exp1 | desc1       | project a |
    And I have the following collaborators for projects
      | name      | members |
      | project a | user2   |
    And I am on the projects page
    And I follow "Logout"
    And I am logged in as "user2"
    And I am on the experiment page for "exp1"
    And I click on "Add"
    And I follow "Add Sample"
    And I wait for the wizard
    And I fill in "Name" with "sample name"
    And I fill in "Description" with "description"
    And I press "Create Sample"
    And I wait for the wizard
    Then I should be redirected to the sample page for "sample name"
    And I should see "Sample was successfully created"
    Then I should have a sample "sample name" under experiment "exp1"


  Scenario: View a sample in a project
    Given I have the following samples
      | name | description | project   |
      | s1   | desc1       | project a |
    And I am on the sample page for "s1"
    Then I should see "s1"
    And I should see "desc1"

  Scenario: Distinguish between multiple different samples in a project with the same sample name
    Given I have the following samples with defined ids
      | name | description | project   | id |
      | exp1 | desc1       | project a | 5  |
      | exp1 | desc1       | project a | 6  |
      | exp2 | desc1       | project a | 7  |
    And I am on the project page for "project a"
    Then I should see "exp1 (5)"
    And I should see "exp1 (6)"
    And I should see "exp2"

  @javascript
  Scenario: Edit a sample in a project
    Given I have the following samples
      | name | description | project   |
      | exp1 | desc1       | project a |
    And I am on the sample page for "exp1"
    And I follow "Edit"
    And I wait for the wizard
    And I fill in "exp1a" for "Name"
    And I fill in "another desc" for "Description"
    And I press "Update Sample"
    And I wait for the wizard
    Then I should be redirected to the sample page for "exp1a"
    And I should have a sample "exp1a"
    And I should see "Sample was successfully updated."
    And I should see "exp1a"
    And I should see "another desc"

  @javascript
  Scenario: Edit a sample in an experiment
    Given I have the following experiments
      | name | description | project   |
      | exp1 | desc1       | project a |
    And I have the following samples
      | name | description | experiment |
      | s1   | desc1       | exp1       |
    And I am on the sample page for "s1"
    And I follow "Edit"
    And I wait for the wizard
    And I fill in "s2" for "Name"
    And I fill in "another desc" for "Description"
    And I press "Update Sample"
    And I wait for the wizard
    Then I should be redirected to the sample page for "s2"
    And I should have a sample "s2"
    And I should see "Sample was successfully updated."
    And I should see "s2"
    And I should see "another desc"

  @javascript
  Scenario: Edit a sample in a project as a collaborator
    Given I have the following samples
      | name | description | project   |
      | exp1 | desc1       | project a |
    And I have the following collaborators for projects
      | name      | members |
      | project a | user2   |
    And I follow "Logout"
    Given I am logged in as "user2"
    And I am on the sample page for "exp1"
    And I follow "Edit"
    And I wait for the wizard
    And I fill in "exp1a" for "Name"
    And I fill in "another desc" for "Description"
    And I press "Update Sample"
    And I wait for the wizard
    Then I should have a sample "exp1a"
    And I should be redirected to the sample page for "exp1a"
    And I should see "Sample was successfully updated."
    And I should see "exp1a"
    And I should see "another desc"

  @javascript
  Scenario: Edit a sample in an experiment as a collaborator
    Given I have the following experiments
      | name | description | project   |
      | exp1 | desc1       | project a |
    And I have the following samples
      | name | description | experiment |
      | s1   | desc1       | exp1       |
    And I have the following collaborators for projects
      | name      | members |
      | project a | user2   |
    And I follow "Logout"
    And I am logged in as "user2"
    And I am on the sample page for "s1"
    And I follow "Edit"
    And I wait for the wizard
    And I fill in "s2" for "Name"
    And I fill in "another desc" for "Description"
    And I press "Update Sample"
    Then I should have a sample "s2"
    And I should be redirected to the sample page for "s2"
    And I should see "Sample was successfully updated."
    And I should see "s2"
    And I should see "another desc"

  @javascript
  Scenario: Owner can remove a sample from a project
    Given I have the following samples
      | name | description | project   |
      | s1   | desc1       | project a |
    And I am on the sample page for "s1"
    And I follow "Delete"
    And I confirm popup
    Then I should see "The sample s1 has been successfully removed."
    And I should be on the projects page

  @javascript
  Scenario: Owner can remove a sample from an experiment
    Given I have the following experiments
      | name | description | project   |
      | exp1 | desc1       | project a |
    And I have the following samples
      | name | description | experiment |
      | s1   | desc1       | exp1       |
    And I am on the sample page for "s1"
    Then I should be able to delete "s1"
    And I follow "Delete"
    And I confirm popup
    Then I should see "The sample s1 has been successfully removed."
    Then I should be on the projects page

  @javascript
  Scenario: Collaborator can remove a sample from a project
    Given I follow "Logout"
    And I am logged in as "user2"
    Given I have the following samples
      | name | description | project   |
      | s1   | desc1       | project a |
    Given I have the following collaborators for projects
      | name      | members |
      | project a | user2   |
    And I am on the sample page for "s1"
    And I follow "Delete"
    And I confirm popup
    Then I should see "The sample s1 has been successfully removed."
    And I should be on the projects page

  Scenario: User cannot remove a sample that they have view access only on
    Given I have the following samples
      | name | description | project   |
      | s1   | desc1       | project b |
    Given I have the following members for projects
      | name      | members |
      | project b | user1   |
    And I am on the sample page for "s1"
    Then I should not be able to delete "s1"

  @javascript
  @moving

  Scenario: User can move a sample to a different project
    Given I have the following samples
      | name | description | project   |
      | s1   | desc1       | project a |
    And I am on the sample page for "s1"
    And I follow "Edit"
    And I wait for the wizard
    And I select "project c" from "Project"
    And I press "Update Sample"
    Then I should be redirected to the sample page for "s1"
    And I should have a sample "s1" under project "project c"

  @javascript
  @moving

  Scenario: User can move a sample to a different experiment
    Given I have the following experiments
      | name | description | project   |
      | exp1 | desc1       | project a |
      | exp2 | desc1       | project c |
    Given I have the following samples
      | name | description | experiment |
      | s1   | desc1       | exp1       |
    And I am on the sample page for "s1"
    And I follow "Edit"
    And I wait for the wizard
    And I select "project c" from "Project"
    And I select "exp2" from "Experiment"
    And I press "Update Sample"
    Then I should be redirected to the sample page for "s1"
    And I should see "Sample was successfully updated"
    And I should have a sample "s1" under experiment "exp2"

