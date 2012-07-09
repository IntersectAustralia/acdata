Feature: Capillary Porometer Datasets
  In order to store and organise datasets for a sample
  As a user
  I want to be able to upload and download datasets

  Background:
    Given I have the usual roles and permissions
    And I have users
      | login | email                  | first_name | last_name | role       |
      | user1 | user1@example.com.au | User       | One       | Researcher |
    And I have the following projects
      | name      | description   | owner |
      | project a | The A Project | user1 |
    And I have the following samples
      | name | description | project   |
      | s1   | desc1       | project a |
    And I have the usual instrument file types
    And I have the default handle range
    And I have the following instruments
      | name | instrument_class | instrument_file_types | upload_prompt | visual types | metadata types |
      | name one | Porometer | Capillary Porometer (.txt), Capillary Porometer (.xls) | | Capillary Porometer (.txt), Capillary Porometer (.xls) | Capillary Porometer (.txt), Capillary Porometer (.xls) |
    Given I have the following datasets
      | name     | sample | instrument |
      | dataset1 | s1     | name one   |
    Given I am logged in as "user1"

  Scenario: A visualisable dataset shows a visualisation
    Given I have uploaded "cp_POREDIST.txt" through the applet for dataset "dataset1" as user "user1"
    And I am on the view dataset page for "dataset1"
    Then I should have a visualisation for "dataset1"

  Scenario: A visualisable dataset without a visualisable attachment shows a prompt to upload
    Given I am on the view dataset page for "dataset1"
    Then I should see "Visualisation requires a file of type Capillary Porometer (.txt)/Capillary Porometer (.xls)."

  Scenario: A non-visualisable dataset shows a message
    Given I have uploaded "cp_BUBBLEPT.txt" through the applet for dataset "dataset1" as user "user1"
    And I am on the view dataset page for "dataset1"
    Then I should see /Test Method "BUBBLE POINT ANALYSIS" has no visualisation./
