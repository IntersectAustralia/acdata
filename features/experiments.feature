Feature: Manage Experiment
  In order to store and organise experiment data
  As a user
  I want to be able to create and edit experiment

  Background:
    Given I have the usual roles and permissions
    And I have the usual users
    And I have the usual projects
    And I am logged in as "user1"

  @wizard
  @javascript
  Scenario: Create an experiment in a project
    Given I am on the project page for "project a"
    And I click on "Add"
    And I follow "Add Experiment"
    Then I should see "Create New Experiment"
    And I should see "project a"
    And I fill in "Name" with "New Exp"
    And I fill in "Description" with "This is my description"
    And I press "Create Experiment"
    And I wait until the wizard completes
    Then I should have an experiment "New Exp"
    Then I should be redirected to the experiment page for "New Exp"
    And I should see "The experiment was successfully added."
    And I should see "New Exp"
    And I should see "This is my description"

  @wizard
  @javascript
  Scenario: Create an experiment in a project as a collaborator
    Given I have the following collaborators for projects
      | name      | members |
      | project a | user2   |
    And I follow "Logout"
    And I am logged in as "user2"
    And I am on the project page for "project a"
    And I click on "Add"
    And I follow "Add Experiment"
    Then I should see "Create New Experiment"
    And I should see "project a"
    And I fill in "Name" with "New Exp"
    And I fill in "Description" with "This is my description"
    And I press "Create Experiment"
    And I wait until the wizard completes
    Then I should be on the experiment page for "New Exp"
    And I should see "The experiment was successfully added."
    And I should see "New Exp"
    And I should see "This is my description"

  Scenario: View an experiment in a project
    Given I have the following experiments
      | name | description | project   |
      | exp1 | desc1       | project a |
    And I am on the experiment page for "exp1"
    Then I should see "exp1"
    And I should see "desc1"

  @wizard
  @javascript
  Scenario: Edit an experiment in a project
    Given I have the following experiments
      | name | description | project   |
      | exp1 | desc1       | project a |

    And I am on the experiment page for "exp1"
    And I follow "Edit"
    And I wait for the wizard
    And I fill in "exp1a" for "Name"
    And I fill in "another desc" for "Description"
    And I press "Update Experiment"
    And I wait until the wizard completes
    Then I should be on the experiment page for "exp1a"
    And I should see "The experiment was successfully updated."
    And I should see "exp1a"
    And I should see "another desc"

  @javascript
  Scenario: Give an existing experiment a related link
    Given I have the following experiments
      | name | description | project   |
      | exp1 | desc1       | project a |
    And I am on the experiment page for "exp1"
    And I follow "Edit"
    And I wait for the wizard
    And I fill in "http://www.intersect.org.au/" for "Related Link"
    And I press "Update Experiment"
    And I wait for the wizard
    Then I should be redirected to the experiment page for "exp1"
    And I should see "The experiment was successfully updated."
    And I should see "exp1"
    And I should see "Visit (via www.intersect.org.au)"

  @wizard
  @javascript
  Scenario: Edit an experiment in a project as a collaborator
    Given I have the following experiments
      | name | description | project   |
      | exp1 | desc1       | project a |
    And I have the following collaborators for projects
      | name      | members |
      | project a | user2   |
    And I follow "Logout"
    And I am logged in as "user2"
    And I am on the experiment page for "exp1"
    And I follow "Edit"
    And I fill in "exp1a" for "Name"
    And I fill in "another desc" for "Description"
    And I press "Update Experiment"
    And I wait until the wizard completes
    Then I should be on the experiment page for "exp1a"
    And I should see "The experiment was successfully updated."
    And I should see "exp1a"
    And I should see "another desc"

  Scenario: User can delete an experiment if they own the project
    Given I have the following experiments
      | name | description | project   |
      | exp1 | desc1       | project a |
    And I am on the experiment page for "exp1"
    And I follow "Delete"
    Then I should see "The experiment exp1 has been successfully removed."
    And I should be on the projects page

  Scenario: User cannot delete an experiment if they don't own the project
    Given I have the following experiments
      | name | description | project   |
      | exp1 | desc1       | project b |
    And "user1" is a member of "project b"
    And I am on the experiment page for "exp1"
    Then I should not be able to delete "exp1"

  @javascript
  Scenario: User cannot create experiment of the same name within project
    Given I have the following experiments
      | name | description | project   |
      | exp1 | desc1       | project a |
    And I am on the project page for "project a"
    And I click on "Add"
    And I follow "Add Experiment"
    And I fill in "exp1" for "Name"
    And I press "Create Experiment"
    And I wait until the wizard completes
    And I should see "Name has been taken"

  @wizard
  @javascript
  Scenario: User can create experiment of the same name between projects
    Given I have the following experiments
      | name | description | project   |
      | exp1 | desc1       | project a |
    And I have the following collaborators for projects
      | name      | members |
      | project b | user1   |
    And I am on the project page for "project b"
    And I click on "Add"
    And I follow "Add Experiment"
    And I fill in "exp1" for "Name"
    And I press "Create Experiment"
    And I wait until the wizard completes
    And I should see "The experiment was successfully added."

  @javascript
  Scenario: Adding related documents
    Given I have the following experiments
      | name | description | project   |
      | exp1 | desc1       | project a |
    When I have attached related document "test.txt" to experiment "exp1"
    Then I should have a document "test.txt" for experiment "exp1"

  @javascript
  @moving
  Scenario: User can move the experiment to another project
    Given I have the following projects
      | name   | description     | owner |
      | source | The Source      | user1 |
      | dest   | The Destination | user1 |
    Given I have the following experiments
      | name | description | project |
      | exp1 | desc1       | source  |
    And I have attached related document "test.txt" to experiment "exp1"
    And I am on the experiment page for "exp1"
    And I follow "Edit"
    And I wait for the wizard
    And I select "dest" from "Project"
    And I press "Update Experiment"
    And I wait for the wizard
    Then I should be redirected to the experiment page for "exp1"
    And I should have an experiment "exp1" under project "dest"
    And the documents for experiment "exp1" should be moved from "source" to "dest"

  @javascript
  @moving
  Scenario: Move an experiment while adding attachment
    Given I have the following projects
      | name   | description     | owner |
      | source | The Source      | user1 |
      | dest   | The Destination | user1 |
    Given I have the following experiments
      | name | description | project |
      | exp1 | desc1       | source  |
    And I am on the experiment page for "exp1"
    And I follow "Edit"
    And I wait for the wizard
    And I select "dest" from "Project"
    And I attach related document "test.txt"
    And I press "Update Experiment"
    And I wait for the wizard
    Then I should be redirected to the experiment page for "exp1"
    And I should have an experiment "exp1" under project "dest"
    And I should have a document "test.txt" for experiment "exp1"

  @javascript
  @moving
  Scenario: Move an experiment while replacing attachment
    Given I have the following projects
      | name   | description     | owner |
      | source | The Source      | user1 |
      | dest   | The Destination | user1 |
    Given I have the following experiments
      | name | description | project |
      | exp1 | desc1       | source  |
    And I have attached related document "test.txt" to experiment "exp1"
    And I am on the experiment page for "exp1"
    And I follow "Edit"
    And I wait for the wizard
    And I select "dest" from "Project"
    And I attach related document "test2.txt"
    And I press "Update Experiment"
    And I wait for the wizard
    Then I should be redirected to the experiment page for "exp1"
    And I should have an experiment "exp1" under project "dest"
    And I should have a document "test2.txt" for experiment "exp1"
    And I should not have a document "test.txt" for experiment "exp1"

  @javascript
  Scenario: Create a sample from an experiment
    Given I have the following experiments
      | name | description | project   |
      | exp1 | desc1       | project a |
    And I am on the experiment page for "exp1"
    And I add a sample "sample1" to "exp1"
    Then I should have a sample "sample1"

  @javascript
  Scenario: Can create a dataset from an experiment under an existing sample
    Given I have the following experiments
      | name | description | project   |
      | exp1 | desc1       | project a |
    And I have the following samples
      | name | description | experiment |
      | s1   | desc1       | exp1       |
    And I am on the experiment page for "exp1"
    And I click on "Add"
    And I follow "Add Dataset"
    And I wait for the wizard
    Then I should see the following options for "Sample name"
      | exp1: s1 |

