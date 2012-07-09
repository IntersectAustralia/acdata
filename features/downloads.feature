Feature: Download Projects, Experiments, Samples and Datasets
  In order to get a copy of my data
  As a user
  I want to be able to download my data

  Background:
    Given I have the usual roles and permissions
    Given I have the usual users
    Given I have the usual datasets
    And I have uploaded "sample sp file 1" through the applet for dataset "dataset1" as user "user1"
    Given I am logged in as "user1"

  @javascript
  Scenario: User can download a project that has datasets with attachments
    Given I am on the project page for "project a"
    And I click on "Share"
    Then I should see "Download Project Data"

  @javascript
  Scenario: User can download an experiment that has datasets with attachments
    Given I am on the experiment page for "exp1"
    And I click on "Share"
    Then I should see "Download Experiment Data"

  @javascript
  Scenario: User can download a sample that has datasets with attachments
    Given I am on the sample page for "s1"
    And I click on "Share"
    Then I should see "Download Sample Data"

  @javascript
  Scenario: User can download a dataset that has attachments
    Given I am on the view dataset page for "dataset1"
    And I click on "Share"
    Then I should see "Download"

