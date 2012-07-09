Feature: Export to MemRE

  In order to share Membrane research
  As a user
  I want to be able to export my datasets from ACData to MemRE

  Background:
    Given I have the usual roles and permissions
    And I have the usual users
    And I have the usual datasets
    And I have ANDS Parties
      | given_name | family_name | group | key  |
      | Ands User  | 1           | UNSW  | 1111 |
    And I have the usual membrane property types
    Given I am logged in as "user1"
    And "user1" has enabled MemRE export

  @javascript
  Scenario: Export a dataset to MemRE
    Given I am on the view dataset page for "dataset1"
    And I click on "Share"
    And I follow "Export to MemRE"
    And I wait for the wizard
    Then I should see "Share with MemRE"
    And I fill in "Material Name" with "test"
    And I should see the following options for "Class Name"
      | Organic    |
      | Inorganic  |
      | Biological |
      | Hybrid     |
    And I select "Organic" from "Class Name"
    And I fill in "Membrane Creator" with "test person"
    And I start filling in "Membrane Characterised by" with "An"
    And I wait for 2 seconds
    Then I should see the following autocomplete options:
      | Ands User 1 (UNSW) |
    And I choose "Ands User 1 (UNSW)" from the autocomplete list
    And I should see the following options for "Form Description"
      | Flat Sheet   |
      | Hollow Fibre |
      | Tubular      |
      | Other        |
    And I select "Flat Sheet" from "Form Description"
    And I fill in "Name" with "Test User"
    And I fill in "Notes" with "test note"
    And press "Next"
    And I select "Contact Angle" from "Property Type"
    Then I should see the following options for "Technique"
      | Goniometer Method   |
      | Sessile Drop Method |
      | Wilhemy Method      |
    And I select "Sessile Drop Method" from "Technique"
    And the "type_of_property" field should contain "surface"
    And the "Units" field should contain "degrees"
    And the "Description" field should contain "Test description"
    And I fill in "Qualifier 1" with "testing"
    And I select "Digital Object Identifier" from "info_type"
    And I fill in "identifier" with "test"
    And I fill in "notes" with "data source description"
    And I follow "Add"
    And I press "Finish"
    And I wait for the wizard
    Then I should have a MemRE export for "dataset1"
    And I click on "Share"
    And I follow "Export to MemRE"
    And I wait for the wizard
    Then I should see "Share with MemRE"
    And I should see "Ands User 1 (UNSW)"
    And press "Next"
    And I wait for the wizard
    And I should see "test"
    And I should see "data source description"
    And I should see "Sessile Drop Method"
    And I should see "Contact Angle"
    And I should see "testing"
    And the "Technique" field should contain "Goniometer Method"
    And the "Property Type" field should contain "Contact Angle"
    And the "Qualifier 1" field should contain ""

  @javascript
  Scenario: Optional fields are optional
    Given I am on the view dataset page for "dataset1"
    And I click on "Share"
    And I follow "Export to MemRE"
    And I wait for the wizard
    Then I should see "Share with MemRE"
    And I fill in "Material Name" with "test"
    And press "Next"
    And I select "Contact Angle" from "Property Type"
    Then I should see the following options for "Technique"
      | Goniometer Method   |
      | Sessile Drop Method |
      | Wilhemy Method      |
    And I select "Sessile Drop Method" from "Technique"
    And I press "Finish"
    And I wait for the wizard
    Then I should have a MemRE export for "dataset1"

  @javascript
  Scenario: Mandatory fields are mandatory
    Given I am on the view dataset page for "dataset1"
    And I click on "Share"
    And I follow "Export to MemRE"
    And I wait for the wizard
    Then I should see "Share with MemRE"
    And press "Next"
    Then I should see a warning containing "Material Name is required"
    And I dismiss popup
    And I fill in "Material Name" with "test"
    And press "Next"
    And I select "Contact Angle" from "Property Type"
    Then I should see the following options for "Technique"
      | Goniometer Method   |
      | Sessile Drop Method |
      | Wilhemy Method      |
    And I select "Sessile Drop Method" from "Technique"
    And I press "Finish"
    And I wait for the wizard
    Then I should have a MemRE export for "dataset1"


  @javascript
  Scenario: Editing a MemRE export
    Given I have exported "dataset1" to MemRE
    And I am on the view dataset page for "dataset1"
    And I click on "Share"
    And I follow "Export to MemRE"
    And I wait for the wizard
    And I fill in "Material Name" with "edited test"
    And I press "Next"
    And I press "Finish"
    And I wait for the wizard
    And I click on "Share"
    And I follow "Export to MemRE"
    And I wait for the wizard
    And the "Material Name" field should contain "edited test"

