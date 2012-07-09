Feature: Manage Datasets
  In order to store and organise datasets for a sample
  As a user
  I want to be able to upload and download datasets

  Background:
    Given I have the usual roles and permissions
    And I have users
      | login | email                  | first_name | last_name | role       |
      | user1 | user1@example.com.au | User       | One       | Researcher |
      | user2 | user2@example.com.au | User       | Two       | Superuser  |
      | user3 | user3@example.com.au | User       | Three     | Superuser  |
    And I have the following projects
      | name      | description   | owner |
      | project a | The A Project | user1 |
      | project b | The B Project | user2 |
      | project c | The C Project | user3 |
    And I have the following experiments
      | name | description | project   |
      | exp1 | desc1       | project a |
    And I have the following samples
      | name | description | experiment |
      | s1   | desc1       | exp1       |
    And I have the following samples
      | name | description | project   |
      | s2   | desc2       | project b |
      | s3   | desc3       | project b |
      | s4   | desc4       | project b |
      | s5   | desc5       | project a |
    And I have the usual instrument file types
    And I have the default handle range
    And I have the following instruments
      | name       | instrument_class | instrument_file_types                                | upload_prompt                                     | visual types  | metadata types                       |
      | name one   | class one        | JCAMP-DX (v4), SP (RamanStation), FSM (RamanStation) | Select a JCAMP-DX (v4) file and an SP or FSM file | JCAMP-DX (v4) | SP (RamanStation),FSM (RamanStation) |
      | name two   | class two        | JCAMP-DX (v4), SP (RamanStation), FSM (RamanStation) | Select a JCAMP-DX (v4) file and an SP or FSM file | JCAMP-DX (v4) | SP (RamanStation),FSM (RamanStation) |
      | name three | class two        | JCAMP-DX (v4), SP (RamanStation), FSM (RamanStation) | Select a JCAMP-DX (v4) file and an SP or FSM file | JCAMP-DX (v4) | SP (RamanStation),FSM (RamanStation) |


  Scenario: User cannot see export/request buttons unless enabled in preferences
    Given I am logged in as "user1"
    And I have the following datasets
      | name     | sample | instrument |
      | dataset1 | s1     | name one   |
      | dataset2 | s2     | name one   |
    And I am on the project page for "project a"
    Then I should not see "Request Slide Scanning"
    And I am on the view dataset page for "dataset1"
    Then I should not see "Export to ELN"
    And I should not see "Export to MemRE"

  Scenario: User cannot see ELN export button unless enabled in preferences
    Given I am logged in as "user1"
    And I have the following datasets
      | name     | sample | instrument |
      | dataset1 | s1     | name one   |
      | dataset2 | s2     | name one   |
    And "user1" has enabled ELN export
    And "user1" has enabled MemRE export
    And "user1" has enabled slide scanning requests
    And I am on the project page for "project a"
    Then I should see "Request Slide Scanning"
    And I am on the view dataset page for "dataset1"
    Then I should see "Export to ELN"
    And I should see "Export to MemRE"


  Scenario: Users can only view datasets of project they are a member of
    Given I am logged in as "user1"
    And I have the following datasets
      | name     | sample | instrument |
      | dataset1 | s1     | name one   |
      | dataset2 | s2     | name one   |
    Given I am on the sample page for "s1"
    Then I should see "dataset1"
    And I should not see "dataset2"
    And I follow "dataset1"
    Then I should see "dataset1"
    Given I am on the view dataset page for "dataset2"
    Then I should see "You are not authorized to access this page"

  Scenario: Users cannot download datasets in a project they are not a member of
    Given I am logged in as "user1"
    And I have the following datasets
      | name | sample | instrument |
      | d1   | s1     | name one   |
      | d2   | s2     | name one   |
    And I am on the download page for dataset "d2"
    Then I should see "You are not authorized to access this page"

  @upload
  Scenario: User can download a dataset they have access to
    Given I am logged in as "user1"
    And I have the following datasets
      | name     | sample | instrument |
      | dataset1 | s1     | name one   |
    And I have uploaded "sample sp file 1" through the applet for dataset "dataset1" as user "user1"
    And I am on the view dataset page for "dataset1"
    And I follow "Download"
    Then I should get a download of dataset "dataset1"

  Scenario: No download button for empty datasets
    Given I am logged in as "user1"
    And I have the following datasets
      | name     | sample | instrument |
      | dataset1 | s1     | name one   |
    And I am on the view dataset page for "dataset1"
    Then I should not see "Download"

  @javascript
  @applet

  Scenario: Appropriate prompts based on instrument from show page
    Given I am logged in as "user1"
    And I have the usual instruments
    And I have the following datasets
      | name     | sample | instrument                     |
      | dataset1 | s1     | Perkin Elmer Ramanstation 400  |
      | dataset2 | s1     | Autolab PGSTAT 12 Potentiostat |

    And I am on the view dataset page for "dataset1"
    Then I should see "Visualisation requires a file of type JCAMP-DX (v4)/JCAMP-DX (v5)"
    And I follow "Upload Visualisation File"
    And I wait for the wizard

    Then I should see "Select a file of type: JCAMP-DX"
    And I am on the view dataset page for "dataset1"
    And I click on the "Extended Metadata" tab
    Then I should see "Extended Metadata requires a file of type SP (RamanStation)/FSM (RamanStation)"
    And I follow "Upload Metadata File"
    And I wait for the wizard

    Then I should see "Select a file of type: SP (RamanStation)/FSM (RamanStation)"

    And I am on the view dataset page for "dataset2"
    Then I should see "Visualisation requires a file of type Potentiostat (.txt)"
    And I follow "Upload Visualisation File"
    And I wait for the wizard

    Then I should see "Select a file of type: Potentiostat (.txt)"
    And I am on the view dataset page for "dataset2"
    And I click on the "Extended Metadata" tab
    Then I should see "Extended Metadata requires a file of type Potentiostat (.txt)"
    And I follow "Upload Metadata File"
    Then I should see "Select a file of type: Potentiostat (.txt)"

  @upload
  @javascript

  Scenario: Datasets have different indelible files
    Given I am logged in as "user1"
    And I have the usual instruments
    And I have the following datasets
      | name     | sample | instrument                     |
      | dataset1 | s1     | Renishaw Raman RM2000          |
      | dataset2 | s1     | Autolab PGSTAT 12 Potentiostat |
    And I have uploaded "sample sp file 1" through the applet for dataset "dataset1" as user "user1"
    And I am on the view dataset page for "dataset1"
    And I click on the "Show Files" tab
    Then I should not see "Delete" within "Show Files"
    Given I have uploaded "sample potentiostat txt file 1" through the applet for dataset "dataset1" as user "user1"
    And I am on the view dataset page for "dataset1"
    And I click on the "Show Files" tab
    And I should see "Delete" within "Show Files"

    Given I have uploaded "sample potentiostat frp file 1" through the applet for dataset "dataset2" as user "user1"
    And I have uploaded "sample potentiostat ifi file 1" through the applet for dataset "dataset2" as user "user1"
    And I have uploaded "sample potentiostat ifw file 1" through the applet for dataset "dataset2" as user "user1"
    And I have uploaded "sample potentiostat ofw file 1" through the applet for dataset "dataset2" as user "user1"
    And I have uploaded "sample potentiostat txt file 1" through the applet for dataset "dataset2" as user "user1"

    And I am on the view dataset page for "dataset2"
    And I click on the "Show Files" tab
    And I should not see "Delete" within "Show Files"

    And I have uploaded "sample sp file 1" through the applet for dataset "dataset2" as user "user1"

    Then I am on the view dataset page for "dataset2"
    And I click on the "Show Files" tab
    And I should see "Delete" within "Show Files"


  @applet
  @javascript

  Scenario: User creates a dataset from the project page
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
    And I select "class one" from "Instrument class"
    And I press "Next"
    And I wait for the wizard
    And I wait for the applet to load
    Then I should see "Upload Attachments"
    And I press "Next"
    And I confirm popup
    And I wait for the wizard
    Then I should see "View Metadata"
    And I press "Finish"
    Then I should be redirected to the view dataset page for "TEST 1"

  @applet
  @javascript

  Scenario: User creates a dataset from the project page as a collaborator
    Given I have the following collaborators for projects
      | name      | members |
      | project b | user1   |
    And I am logged in as "user1"
    And I follow "project b"
    And I click on "Add"
    And I follow "Add Dataset"
    And I select "s2" from "dataset_sample_id"
    And I press "Next"
    And I wait for the wizard
    Then I should see "Add Dataset"
    And I fill in "Dataset name" with "TEST 1"
    And I select "class one" from "Instrument class"
    And I press "Next"
    And I wait for the wizard
    And I wait for the applet to load
    And I press "Next"
    And I confirm popup
    And I press "Finish"
    Then I should be redirected to the view dataset page for "TEST 1"


  @javascript
  Scenario: User cannot add a dataset with blank name
    Given I am logged in as "user1"
    And I have the following datasets
      | name                      | sample | instrument |
      | d1.txt                    | s1     | name one   |
      | This is a test dataset d2 | s1     | name one   |
    And I am on the sample page for "s1"
    And I click on "Add"
    And I follow "Add Dataset"
    And I press "Next"
    And I should see "Name can't be blank"

  @javascript
  Scenario: User cannot add a dataset with same name within sample
    Given I am logged in as "user1"
    And I have the following datasets
      | name                      | sample | instrument |
      | d1.txt                    | s1     | name one   |
      | This is a test dataset d2 | s1     | name one   |
    And I am on the sample page for "s1"
    And I click on "Add"
    And I follow "Add Dataset"
    And I fill in "Dataset name" with "d1.txt"
    And I press "Next"
    And I should see "Name has been taken"

  @javascript
  Scenario: User cannot edit a dataset with the same name within sample
    Given I am logged in as "user1"
    And I have the following datasets
      | name                      | sample | instrument |
      | d1.txt                    | s1     | name one   |
      | This is a test dataset d2 | s1     | name one   |
    And I am on the sample page for "s1"
    And I am on the view dataset page for "This is a test dataset d2"
    And I follow "Edit"
    And I wait for the wizard
    And I fill in "Name" with "d1.txt"
    And I press "Update Dataset"
    And I wait for the wizard
    And I should see "Name has been taken"

  @javascript
  Scenario: User can edit the name of a dataset
    Given I am logged in as "user1"
    And I have the following datasets
      | name                      | sample | instrument |
      | d1.txt                    | s1     | name one   |
      | This is a test dataset d2 | s1     | name one   |
    And I am on the sample page for "s1"
    Then I should see "d1.txt"
    Then I should see "This is a test dataset d2"
    Then I should not see "d3"
    And I follow "d1.txt"
    Then I should be on the view dataset page for "d1.txt"
    And I follow "Edit"
    And I wait for the wizard
    And I fill in "Name" with "blah blah"
    And I press "Update Dataset"
    And I wait for the wizard
    Then I should be redirected to the view dataset page for "blah blah"
    And I should see "blah blah"
    And I should not see "d1.txt"

  Scenario: Users cannot edit datasets in a project they are a member
    Given I am logged in as "user2"
    And I have the following datasets
      | name | sample | instrument |
      | d1   | s5     | name one   |
    Given I have the following members for projects
      | name      | members |
      | project a | user2   |
    And I am on the view dataset page for "d1"
    Then I should not be able to edit "d1"

  @javascript
  Scenario: User can edit the name of a dataset as a collaborator
    Given I have the following collaborators for projects
      | name      | members |
      | project a | user2   |
    And I am logged in as "user2"
    And I have the following datasets
      | name                      | sample | instrument |
      | d1.txt                    | s1     | name one   |
      | This is a test dataset d2 | s1     | name one   |
    And I am on the sample page for "s1"
    Then I should see "d1.txt"
    Then I should see "This is a test dataset d2"
    And I follow "d1.txt"
    Then I should be on the view dataset page for "d1.txt"
    And I follow "Edit"
    And I wait for the wizard
    And I fill in "Name" with "blah blah"
    And I press "Update Dataset"
    And I wait for the wizard
    Then I should be redirected to the view dataset page for "blah blah"
    And I should see "blah blah"
    And I should not see "d1.txt"

  @applet
  @javascript

  Scenario: User closes modal after adding new dataset (in attachments dialog)
    Given I am logged in as "user2"
    And I am on the sample page for "s2"
    And I click on "Add"
    And I follow "Add Dataset"
    And I should see "Add New Dataset"
    And I fill in "Dataset name" with "TEST 1"
    And I select "class one" from "Instrument class"
    And I press "Next"
    And I wait for the applet to load
    And I should see "Upload Attachments"
    And I close the dataset wizard
    And I confirm popup
    And I should not see "TEST 1"
    And I should see "The dataset creation process was cancelled"
    And I should not see "Upload Attachments"

  @applet
  @javascript

  Scenario: User closes modal after adding new dataset (in metadata dialog)
    Given I am logged in as "user2"
    And I am on the sample page for "s2"
    And I click on "Add"
    And I follow "Add Dataset"
    And I should see "Add New Dataset"
    And I fill in "Dataset name" with "TEST 1"
    And I select "class one" from "Instrument class"
    And I press "Next"
    And I wait for the wizard
    And I wait for the applet to load
    Then I should see "Upload Attachments"
    And I press "Next"
    And I confirm popup
    And I wait for the wizard
    And I should see "View Metadata"
    And I close the dataset wizard
    And I confirm popup
    Then I should be redirected to the sample page for "s2"
    And I should not see "TEST 1"
    And I should see "The dataset creation process was cancelled"

  @applet
  @javascript

  Scenario: User closes modal after adding new dataset (in edit dialog)
    Given I am logged in as "user2"
    And I am on the sample page for "s2"
    And I click on "Add"
    And I follow "Add Dataset"
    And I should see "Add New Dataset"
    And I fill in "Dataset name" with "TEST 1"
    And I select "class one" from "Instrument class"
    And I press "Next"
    And I wait for the applet to load
    Then I should see "Upload Attachments"
    And I click on "Back"
    And I should see "Editing New Dataset Details"
    And I close the dataset wizard
    And I confirm popup
    And I should be on the sample page for "s2"
    And I should not see "TEST 1"
    And I should see "The dataset creation process was cancelled."

  @applet
  @javascript

  Scenario: User can add supplementary materials
    Given I am logged in as "user1"
    And I have the following datasets
      | name                      | sample | instrument |
      | d1.txt                    | s1     | name one   |
      | This is a test dataset d2 | s1     | name one   |
    Then I am on the view dataset page for "d1.txt"
    And I click on "Add"
    And I follow "Add Supplementary Material"
    And I wait for the applet to load
    And I should see "Add Supplementary Materials"
    And I should see button "Finish"
    And I should not see "Back"
    And I press "Finish"
    And I confirm popup
    Then I am on the view dataset page for "d1.txt"

  @applet
  @javascript

  Scenario: User goes back to edit the newly created dataset in the dataset wizard
    Given I am logged in as "user2"
    And I follow "project b"
    And I click on "Add"
    And I follow "Add Dataset"
    And I wait for the wizard
    And I select "s2" from "Sample name"
    And I press "Next"
    And I wait for the wizard
    Then I should see "Add New Dataset"
    And I fill in "Dataset name" with "TEST 1"
    And I select "class two" from "Instrument class"
    And I select "name three" from "Instrument name"
    And I press "Next"
    And I wait for the wizard
    And I wait for the applet to load
    Then I should see "Upload Attachments"
    And I click on "Back"
    And I wait for the wizard
    Then I should see "Editing New Dataset Details"
    And I fill in "Dataset name" with "TEST 2"
    And I should see "class two"
    And I should see "name three"
    And I press "Next"
    And I wait for the wizard
    And I wait for the applet to load
    And I should see "Upload Attachments"
    And I press "Next"
    And I confirm popup
    And I wait for the wizard
    And I press "Finish"
    Then I should be redirected to the view dataset page for "TEST 2"
    And I should not see "TEST 1"

  @applet
  @javascript

  Scenario: User goes back to edit the newly created dataset in the dataset wizard with invalid inputs
    Given I am logged in as "user2"
    And I follow "project b"
    And I click on "Add"
    And I follow "Add Dataset"
    And I wait for the wizard
    And I select "s2" from "dataset_sample_id"
    And I press "Next"
    And I wait for the wizard
    Then I should see "Add New Dataset"
    And I fill in "Dataset name" with "TEST 1"
    And I select "class two" from "Instrument class"
    And I press "Next"
    And I wait for the wizard
    And I wait for the applet to load
    Then I should see "Upload Attachments"
    And I click on "Back"
    And I wait for the wizard
    And I should see "Editing New Dataset Details"
    And I fill in "Dataset name" with ""
    And I press "Next"
    And I wait for the wizard
    And I should not see "Add New Dataset"
    And I should not see "Upload Attachments"
    And I should see "Name can't be blank"


  Scenario: User can destroy a dataset
    Given I am logged in as "user1"
    And I have the following datasets
      | name | sample | instrument |
      | d1   | s1     | name one   |
    And I am on the view dataset page for "d1"
    And I follow "Delete"
    Then I should see "The dataset was successfully deleted!"

  @javascript
  Scenario: User cannot see Add dataset link when no samples present in project
    Given I am logged in as "user3"
    When I follow "project c"
    And I click on "Add"
    Then I should not see "Add Dataset"

  @javascript
  Scenario: User can see Add Dataset link when a sample child to project exists
    Given I am logged in as "user3"
    And I have the following samples
      | name | description | project   |
      | S1   | description | project c |
    And I follow "project c"
    And I click on "Add"
    Then I should see "Add Dataset"

  @javascript
  Scenario: User can see Add Dataset link when a sample child to experiment in project exists
    Given I am logged in as "user3"
    And I have the following experiments
      | name | description | project   |
      | Exp3 | desc1       | project c |
    And I have the following samples
      | name | description | experiment |
      | s1   | desc1       | Exp3       |
    And I follow "project c"
    And I click on "Add"
    Then I should see "Add Dataset"

  Scenario: Dataset with JCAMP-DX file shows applet in visualisation tab
    Given I am logged in as "user1"
    And I have the following datasets
      | name     | sample | instrument |
      | dataset1 | s1     | name one   |
    And I have uploaded "sample JCAMP-DX file 1" through the applet for dataset "dataset1" as user "user1"
    And I am on the view dataset page for "dataset1"
    Then I should see "ramanstation.dx"
    And I should see the jspecview applet

  Scenario: Cannot delete metadata (SP or FSM) file from dataset
    Given I am logged in as "user1"
    And I have the usual instruments
    And I have the following datasets
      | name     | sample | instrument                    |
      | dataset1 | s1     | Perkin Elmer Ramanstation 400 |
    And I have uploaded "sample sp file 1" through the applet for dataset "dataset1" as user "user1"
    And I am on the view dataset page for "dataset1"
    When I click on the "Show Files" tab
    Then I should see "Ramanstation Spectrum File 1_SP.SP"
    And I should not see "Delete" within "Show Files"

  @wip
  @upload

  @javascript

  Scenario: Previously uploaded files are shown in the dataset wizard
    Given I am logged in as "user1"
    And I have the following datasets
      | name     | sample | instrument |
      | dataset1 | s1     | name one   |
    And I have uploaded "sample JCAMP-DX file 1" through the applet for dataset "dataset1" as user "user1"
    And I am on the view dataset page for "dataset1"
    And I click on "Add"
    And I follow "Add Supplementary Material"
    And I wait for the wizard
    And I wait for the applet to load
    Then I should see "ramanstation.dx"

  @applet
  @javascript

  Scenario: Newly uploaded files are shown in the dataset creation wizard after going back
    Given I am logged in as "user1"
    And I am on the sample page for "s1"
    And I click on "Add"
    And I follow "Add Dataset"
    And I wait for the wizard
    And I fill in "Dataset name" with "dataset1"
    And I press "Next"
    And I wait for the wizard
    And I wait for the applet to load
    And I upload "sample JCAMP-DX file 1" through the applet for dataset "dataset1" as user "user1"
    And I press "Next"
    And I wait for the wizard
    And I should see "View Metadata"
    And I click on "Back"
    And I wait for the wizard
    And I wait for the applet to load
    Then I should see "ramanstation.dx"
    And I press "Next"
    And I wait for the wizard
    And I should see "View Metadata"

  @wip
  @javascript

  Scenario: After adding a supplementary file I am returned to the Show Files tab
    Given I am logged in as "user1"
    And I have the following datasets
      | name     | sample | instrument |
      | dataset1 | s1     | name one   |
    And I have uploaded "sample JCAMP-DX file 1" through the applet for dataset "dataset1" as user "user1"
    And I am on the view dataset page for "dataset1"
    And I click on "Add"
    And I follow "Add Supplementary Material"
    And I press "Finish"
    Then I should be on the view dataset page for "dataset1"
    And the "Show Files" tab should be open
    And I should see the list of files for "dataset1"

  @ajaxfail
  @javascript

  Scenario: Session expires while using the dataset wizard
    Given I am logged in as "user1"
    And I am on the sample page for "s1"
    And I click on "Add"
    And I follow "Add Dataset"
    And I wait for the wizard
    And I fill in "Dataset name" with "dataset1"
    And the session for "user1" ends
    And I press "Next"
    Then I should see a warning containing "session timed out"
    And I confirm popup
    Then I should be redirected to the home page

  @javascript
  @upload

  @moving
  Scenario: A user should be able to move a dataset to a different sample
    Given I am logged in as "user1"
    And I have the following datasets
      | name     | sample | instrument |
      | dataset1 | s1     | name one   |
    And I have uploaded "sample sp file 1" through the applet for dataset "dataset1" as user "user1"
    And I am on the view dataset page for "dataset1"
    And I follow "Edit"
    And I wait for the wizard
    And I select "project a" from "Project"
    And I select "" from "Experiment"
    And I select "s5" from "Sample"
    And I press "Update Dataset"
    And I wait for the wizard
  #    Then I should be redirected to the view dataset page for "dataset1"
    And I should have a dataset "dataset1" under sample "s5"
    And the attachments for "dataset1" should be moved from "s1" to "s5"

  @javascript
  @upload

  @moving
  Scenario: A user should be able to move a dataset to a different sample under an experiment
    Given I am logged in as "user1"
    And I have the following projects
      | name      | description   | owner |
      | project d | The D Project | user1 |
    And I have the following experiments
      | name | description | project   |
      | exp2 | desc1       | project d |
    And I have the following samples
      | name | description | experiment |
      | s6   | desc1       | exp2       |
    And I have the following datasets
      | name     | sample | instrument |
      | dataset1 | s1     | name one   |
    And I have uploaded "sample sp file 1" through the applet for dataset "dataset1" as user "user1"
    And I have uploaded "test.png" through the applet for dataset "dataset1" as user "user1"
    And I am on the view dataset page for "dataset1"
    And I follow "Edit"
    And I wait for the wizard
    And I select "project d" from "Project"
    And I select "exp2" from "Experiment"
    And I select "s6" from "Sample"
    And I press "Update Dataset"
    And I wait for the wizard
  #    Then I should be redirected to the view dataset page for "dataset1"
    And I should have a dataset "dataset1" under sample "s6"
    And the attachments for "dataset1" should be moved from "s1" to "s6"
    And I should have a preview file for "test.png"

  @javascript
  @upload

  @moving
  Scenario: A user should be able to move a dataset as a collaborator
    Given I have the following collaborators for projects
      | name      | members |
      | project b | user1   |
    And I am logged in as "user1"
    And I have the following datasets
      | name     | sample | instrument |
      | dataset1 | s2     | name one   |
    And I have uploaded "sample sp file 1" through the applet for dataset "dataset1" as user "user1"
    And I am on the view dataset page for "dataset1"
    And I follow "Edit"
    And I wait for the wizard
    And I select "project a" from "Project"
    And I select "" from "Experiment"
    And I select "s5" from "Sample"
    And I press "Update Dataset"
    And I wait for the wizard
  #    Then I should be redirected to the view dataset page for "dataset1"
    And I should have a dataset "dataset1" under sample "s5"
    And the attachments for "dataset1" should be moved from "s1" to "s5"

  @javascript
  @upload

  @moving
  Scenario: A user should not be able to move a dataset as a member
    Given I have the following members for projects
      | name      | members |
      | project a | user2   |
    And I have the following datasets
      | name     | sample | instrument |
      | dataset1 | s5     | name one   |
    And I have uploaded "sample sp file 1" through the applet for dataset "dataset1" as user "user1"
    And I am logged in as "user2"
    And I am on the view dataset page for "dataset1"
    Then I should not be able to edit "d1"

  @javascript
  Scenario: Uploading an image file to a dataset creates a preview image
    Given I have the following datasets
      | name     | sample | instrument |
      | dataset1 | s5     | name one   |
    And I am logged in as "user1"
    And I have uploaded "test.png" through the applet for dataset "dataset1" as user "user1"
    Then I should have a preview file for "test.png"
    When I am on the view dataset page for "dataset1"
    And I click on the "Show Files" tab
    Then I should see the preview image for "test.png"

