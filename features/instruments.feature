Feature: Set Instrument for Datasets
  In order to describe how a dataset was produced
  As a user
  I want to be specify the instrument for a dataset

  Background:
    Given I have the usual roles and permissions
    And I have users
      | login | email                  | first_name | last_name | role       |
      | user1 | user1@example.com.au | User       | One       | Researcher |
    And I have the usual instrument file types
    And I have the usual instruments
    And I have the following projects
      | name      | description   | owner |
      | project a | The A Project | user1 |
    And I have the following samples
      | name | description | project   |
      | s3   | desc1       | project a |

  @javascript
  @applet
  Scenario: User adds a dataset and selects an instrument
    Given I am logged in as "user1"
    And I am on the sample page for "s3"
    And I click on "Add"
    And I follow "Add Dataset"
    And I wait for the wizard
    And I fill in "Dataset name" with "dataset1"
    And I select "NMR" from "Instrument class"
    And I select "Bruker DPX 300 (Flip)" from "Instrument name"
    And I press "Next"
    And I wait for the wizard
    Then I should have a dataset "dataset1" with instrument "Bruker DPX 300 (Flip)"

