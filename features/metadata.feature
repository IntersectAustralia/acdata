Feature: Extract metadata from certain file types
  In order to store and organise datasets for a sample
  As a user
  I want to be able to upload and download datasets

  Background:
    Given I have the usual roles and permissions
    And I have users
      | login | email                  | first_name | last_name | role       |
      | user1 | user1@example.com.au | User       | One       | Researcher |
      | user2 | user2@example.com.au | User       | Two       | Superuser  |
    And I have the following projects
      | name      | description   | owner |
      | project a | The A Project | user1 |
      | project b | The B Project | user2 |
    And I have the following experiments
      | name | description | project   |
      | exp1 | desc1       | project a |
    And I have the following samples
      | name | description | experiment |
      | s1   | desc1       | exp1       |
    And I have the following samples
      | name | description | project   |
      | s2   | desc2       | project b |
    And I have the usual instrument file types
    And I have the usual instruments
    And I have the following datasets
      | name     | sample | instrument                    |
      | Dataset1 | s2     | Perkin Elmer Ramanstation 400 |

  Scenario: Empty Extracted Metadata and Supplied Metadata when nothing is uploaded
    Given I am logged in as "user2"
    And I am on the view dataset page for "Dataset1"
    And I click on the "Extended Metadata" tab
    Then I should see "Extended Metadata requires a file of type"

  @upload
  Scenario: Metadata is shown after uploading an SP file
    Given I am logged in as "user2"
    And I have uploaded "sample sp file 1" through the applet for dataset "Dataset1" as user "user2"
    And I am on the view dataset page for "Dataset1"
    Then I should see the core metadata for "Dataset1"
    When I click on the "Extended Metadata" tab
    Then I should see the metadata for "Dataset1" in the "Extended Metadata table"

  @javascript
  @upload
  @applet
  Scenario: Metadata is shown in the dataset wizard
    Given I am logged in as "user1"
    And I am on the sample page for "s1"
    And I click on "Add"
    And I follow "Add Dataset"
    And I wait for the wizard
    And I fill in "Dataset name" with "dataset1"
    And I select "Raman Spectrometers" from "Instrument class"
    And I select "Perkin Elmer Ramanstation 400" from "Instrument name"
    And I press "Next"
    And I wait for the wizard
    And I wait for the applet to load
    And I upload "sample sp file 1" through the applet for dataset "dataset1" as user "user1"
    And I press "Next"
    And I wait for the wizard
    Then I should see "Extracted Metadata"
    And I should see the metadata for "dataset1" in the "Extracted Metadata table"
    And I should see "Supplied Metadata"

  @applet
  @javascript

  Scenario: User supplies additional metadata
    Given I am logged in as "user2"
    And I follow "project b"
    And I click on "Add"
    And I follow "Add Dataset"
    And I wait for the wizard
    And I select "s2" from "dataset_sample_id"
    And I press "Next"
    And I wait for the wizard
    Then I should see "Add Dataset"
    And I fill in "Dataset name" with "TEST 1"
    And I select "Potentiostats" from "Instrument class"
    And I press "Next"
    And I wait for the wizard
    And I wait for the applet to load
    And I press "Next"
    And I confirm popup
    And I wait for the wizard
    Then I should see "View Metadata"
    And I follow "Add metadata"
    And I fill in the 1st supplied metadata field with "electrode"
    And I fill in the 2nd supplied metadata field with "silver"

    And I press "Finish"
  #Then I should be on the view dataset page for "TEST 1"
    Then I should be redirected to the view dataset page for "TEST 1"
    Then I should see the core metadata for "TEST 1"

  @applet
  @javascript

  Scenario: User leaves supplied metadata blank
    Given I am logged in as "user2"
    And I follow "project b"
    And I click on "Add"
    And I follow "Add Dataset"
    And I wait for the wizard
    And I select "s2" from "dataset_sample_id"
    And I press "Next"
    And I wait for the wizard
    Then I should see "Add Dataset"
    And I fill in "Dataset name" with "TEST 1"
    And I select "Potentiostats" from "Instrument class"
    And I press "Next"
    And I wait for the wizard
    And I wait for the applet to load
    And I have uploaded "sample potentiostat frp file 1" through the applet for dataset "TEST 1" as user "user2"
    And I have uploaded "sample potentiostat ifi file 1" through the applet for dataset "TEST 1" as user "user2"
    And I have uploaded "sample potentiostat ifw file 1" through the applet for dataset "TEST 1" as user "user2"
    And I have uploaded "sample potentiostat ofw file 1" through the applet for dataset "TEST 1" as user "user2"
    And I have uploaded "sample potentiostat txt file 1" through the applet for dataset "TEST 1" as user "user2"
    And I press "Next"
    And I confirm popup
    And I wait for the wizard
    Then I should see "View Metadata"
    And I press "Finish"
    Then I should be redirected to the view dataset page for "TEST 1"
    Then I should see the core metadata for "TEST 1"
    Then I should see the supplied metadata for "TEST 1"


  @applet
  @javascript

  Scenario: User supplies additional metadata with very long values
    Given I am logged in as "user2"
    And I follow "project b"
    And I click on "Add"
    And I follow "Add Dataset"
    And I wait for the wizard
    And I select "s2" from "dataset_sample_id"
    And I press "Next"
    And I wait for the wizard
    Then I should see "Add Dataset"
    And I fill in "Dataset name" with "TEST 1"
    And I select "Potentiostats" from "Instrument class"
    And I press "Next"
    And I wait for the wizard
    And I wait for the applet to load
    And I press "Next"
    And I confirm popup
    And I wait for the wizard
    Then I should see "View Metadata"
    And I follow "Add metadata"
    And I fill in the 1st supplied metadata field with 300 characters
    And I fill in the 2nd supplied metadata field with 300 characters
    And I press "Finish"
    And I should see "Supplied metadata key is too long (maximum is 255 characters)"
    And I should see "Supplied metadata value is too long (maximum is 255 characters)"

  @applet
  @javascript

  Scenario: User supplies additional metadata without a key
    Given I am logged in as "user2"
    And I follow "project b"
    And I click on "Add"
    And I follow "Add Dataset"
    And I wait for the wizard
    And I select "s2" from "dataset_sample_id"
    And I press "Next"
    And I wait for the wizard
    Then I should see "Add Dataset"
    And I fill in "Dataset name" with "TEST 1"
    And I select "Potentiostats" from "Instrument class"
    And I press "Next"
    And I wait for the wizard
    And I wait for the applet to load
    And I press "Next"
    And I confirm popup
    And I wait for the wizard
    Then I should see "View Metadata"
    And I follow "Add metadata"
    And I fill in the 2nd supplied metadata field with "blah"
    And I press "Finish"
    And I should see "Supplied metadata key can't be blank"

