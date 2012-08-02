Feature: Manage Projects
  In order to store and organise experiment data
  As a user
  I want to be able to create and edit projects

  Background:
    Given I have the usual roles and permissions
    And I have users
      | login | email                  | first_name | last_name | role       |
      | user1 | user1@example.com.au | User       | One       | Researcher |
      | user2 | user2@example.com.au | User       | Two       | Researcher |
      | user3 | user3@example.com.au | User       | Three     | Researcher |
      | user4 | user4@example.com.au | User       | Four      | Researcher |
      | user5 | user5@example.com.au | User       | Five      | Researcher |

  Scenario: View a user's projects
    Given I am logged in as "user1"
    And I have the following projects
      | name      | description   | owner |
      | project a | The A Project | user1 |
      | project b | The B Project | user2 |
      | project c | The C Project | user1 |
    And I am on my projects page
    Then I should see "project a" in the project list
    And I should see "project c" in the project list
    And I should not see "project b" in the project list

  @javascript
  Scenario: Create a project
    Given I am logged in as "user1"
    And I am on my projects page
    And I follow "New Project"
    And I fill in "Name" with "Foo"
    And I fill in "Description" with "The Foo Project"
    And I press "Create Project"
    And I wait for the wizard
    Then I should be redirected to the project page for "Foo"
    And I should see "Project was successfully created"
    And I should have a project "Foo" for user "user1"
    And I should see "Foo" in the project list


  @javascript
  Scenario: Edit an experiment in a project
    Given I am logged in as "user1"
    And I have the following projects
      | name      | description   | owner |
      | project a | The A Project | user1 |
    And I am on the project page for "project a"
    And I follow "Edit"
    And I wait for the wizard
    And I fill in "project b" for "Name"
    And I fill in "another desc" for "Description"
    And I press "Update Project"
    And I wait for the wizard
    Then I should be redirected to the project page for "project b"
    And I should see "Project was successfully updated."
    And I should see "project b"
    And I should see "another desc"

  @javascript
  Scenario: Edit an experiment in a project
    Given I am logged in as "user1"
    And I have the following projects
      | name      | description   | owner |
      | project a | The A Project | user1 |
    And I am on the project page for "project a"
    And I follow "Edit"
    And I wait for the wizard
    And I fill in "http://www.intersect.org.au/" for "Related Link"
    And I press "Update Project"
    And I wait for the wizard
    Then I should be redirected to the project page for "project a"
    And I should see "Project was successfully updated."
    And I should see "project a"
    And I should see "Visit (via www.intersect.org.au)"


  @javascript
  @no-txn

  Scenario: Create a project and give access to other users
    Given I am logged in as "user1"
    And I am on my projects page
    And I follow "New Project"
    And I fill in "Name" with "Foo"
    And I fill in "Description" with "The Foo Project"
    And I start filling in "Project Members:" with "us"
    And I wait for 2 seconds
    Then I should see the following autocomplete options:
      | User Two   |
      | User Three |
      | User Four  |
      | User Five  |
    And I choose "User Two" from the autocomplete list
    Then I should see "User Two"
    And I press "Create Project"
    And I wait for the wizard
    Then I should be redirected to the project page for "Foo"
    And I should see "Project was successfully created"
    And I should have a project "Foo" for user "user1"
    And I should see "Foo" in the project list
    And user "user2" should have access to project "Foo"

  Scenario: User can view a project they are a member of
    Given I have the following projects
      | name      | description   | owner |
      | project b | The B Project | user2 |
    And "user1" is a member of "project b"
    Given I am logged in as "user1"
    When I am on my projects page
    Then I should see "project b"
    And "project b" should have owner "user2"
    When I am on the project page for "project b"
    Then I should see "User One" in the "People with Access" list

  Scenario: User should see the "Remove me" link when they are a member of a project they do not own
    Given I have the following projects
      | name      | description   | owner |
      | project a | The A project | user2 |
    And "user1" is a member of "project a"
    And I am logged in as "user1"
    When I follow "project a"
    Then "project a" should have the following members
      | member |
      | user1  |
    And I should see "Remove Me"

  Scenario: User should not see the "Remove me" link when they are not a member of a project they do not own
    Given I have the following projects
      | name      | description   | owner |
      | project a | The A project | user2 |
    And "user1" is a member of "project a"
    And I am logged in as "user2"
    When I follow "project a"
    Then I should not see "Remove Me"

  Scenario: Users should be able to remove themselves from a project if they are the only member and don't own it
    Given I have the following projects
      | name      | description   | owner |
      | project a | The A project | user1 |
    And "user2" is a member of "project a"
    And I am logged in as "user2"
    When I follow "project a"
    Then "project a" should have the following members
      | member |
      | user2  |
    And I follow "Remove Me"
    Then I should see "You have been removed from project a."
    And "project a" should have no members

  Scenario: Users should be able to remove themselves from a project if there are many members and don't own it
    Given I have the following projects
      | name      | description   | owner |
      | project a | The A project | user1 |
    And "user2" is a member of "project a"
    And I am logged in as "user2"
    When I follow "project a"
    Then "project a" should have the following members
      | member |
      | user2  |
      | user3  |
      | user4  |
      | user5  |
    And I follow "Remove Me"
    Then I should see "You have been removed from project a."
    And "project a" should have the following members
      | member |
      | user3  |
      | user4  |
      | user5  |

  Scenario: Users can remove a project if they own the project
    Given I have the following projects
      | name      | description   | owner |
      | project a | The A project | user1 |
    And I am logged in as "user1"
    When I am on the project page for "project a"
    Then I should be able to delete "project a"
    And I follow "Delete"
    Then I should see "The project project a has been successfully removed."

  Scenario: Users cannot remove a project if they are not the owner
    Given I have the following projects
      | name      | description   | owner |
      | project a | The A project | user1 |
    And I am logged in as "user2"
    When I am on the project page for "project a"
    Then I should not be able to delete "project a"

  @javascript
  Scenario: Adding related documents
    Given I have the following projects
      | name      | description   | owner |
      | project a | The A Project | user1 |
    And I am logged in as "user1"
    When I am on the project page for "project a"
    When I have attached related document "test.txt" to project "project a"
    Then I should have a document "test.txt" for project "project a"

  @javascript
  Scenario: Description is not mandatory
    Given I am logged in as "user1"
    And I have the following projects
      | name      | description | owner |
      | project a |             | user1 |
    When I am on the project page for "project a"
    Then the "Project description" section should be blank

  @javascript
  Scenario: User can change project's owner
    Given I have the following projects
      | name      | description   | owner |
      | project b | The B Project | user2 |
    And "user1" is a member of "project b"
    Given I am logged in as "user2"
    And I am on the project page for "project b"
    And I follow "Edit"
    When I follow "Make Owner"
    And I wait for the wizard
    Then "project b" should have owner "user1"

  @javascript
  Scenario: User can remove members from a Project
    Given I have the following projects
      | name      | description   | owner |
      | project b | The B Project | user2 |
    And "user1" is a member of "project b"
    Given I am logged in as "user2"
    And I am on the project page for "project b"
    And I follow "Edit"
    And I remove "user1" from membership of the project
    And I press "Update Project"
    And I wait for the wizard
    Then project "project b" should have 0 members
