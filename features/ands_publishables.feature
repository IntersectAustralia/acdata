Feature: Manage Ands Publishable
  In order to publish my project details
  As a user
  I want to be able to create and publish my project details to RDA

  Background:
    Given I have the usual roles and permissions
    And I have users
      | login | email                  | first_name | last_name | role       |
      | user1 | user1@example.com.au | User       | One       | Researcher |
      | user2 | user2@example.com.au | User       | Two       | Superuser  |
      | user4 | user4@example.com.au | User       | Four      | Researcher |
    And I have the usual datasets


  Scenario: User cannot publish data if they are not the project owner or collaborator
    Given I am logged in as "user1"
    And I am on the project page for "project b"
    Then I should not see "Publish Data to RDA"

  Scenario: User can create publishable data to RDA if they have collaborator privileges
    Given I have the following collaborators for projects
      | name      | members |
      | project b | user4   |
    And I am logged in as "user4"
    And I am on the project page for "project b"
    Then I should see "Publish Data to RDA"

  @javascript
  Scenario: User can republish data when the previously submitted publishable data is approved
    Given I have users
      | login | email                  | first_name | last_name | role      |
      | user3 | user3@example.com.au | User       | Three     | Moderator |
    And I am logged in as "user1"
    And I have an ANDS Publishable request "my collection" for project "project a" with moderator "user3"
    And the publishable data "my collection" is approved
    And I am on the project page for "project a"
    And I click on "Share"
    When I follow "Update Data to RDA"
    Then I should see "Edit Publishable Project Details"
    When I press "Next"
    Then I should see "2. Specify Related Information"
    And I follow "Add"
    Then I should see a warning containing "You must specify a type, identifier and description before adding."
    And I confirm popup
    When I press "Next"
    Then I should see "3. Specify Party and Activity Information"
    When I press "Next"
    Then I should see a warning containing "There must be at least one party member specified."
    And I confirm popup
    And I have ANDS Parties
      | given_name | family_name | group | key  |
      | Ands User  | 1           | UNSW  | 1111 |
    And I start filling in "non_unsw_party" with "ANDS"
    And I wait for 2 seconds
    Then I should see the following autocomplete options:
      | Ands User 1 (UNSW) |
    And I choose "Ands User 1 (UNSW)" from the autocomplete list
    And I should see "Ands User 1 (UNSW)"
    When I press "Next"
    And I wait for 2 seconds
    Then I should see "4. Publishable Data Preview"
    When I press "Submit to Moderator"
    Then I should be on the project page for "project a"
    And I should see "The project's publishable data was successfully created and is pending approval by User Three"

  Scenario: User cannot republish data that is not approved by moderator
    Given I have users
      | login | email                  | first_name | last_name | role      |
      | user3 | user3@example.com.au | User       | Three     | Moderator |
    And I am logged in as "user1"
    And I have an ANDS Publishable request "my collection" for project "project a" with moderator "user3"
    And I am on the project page for "project a"
    Then the link "Update Data to RDA" should be disabled

  @javascript
  Scenario: Users cannot publish data to RDA if there are no moderators or superusers present
    Given "user2" is deactivated
    And I am logged in as "user1"
    Then I am on the project page for "project a"
    And I click on "Share"
    And I follow "Publish Data to RDA"
    And I wait for 2 seconds
    And I should see "You cannot publish data if there are no moderators."

  @javascript
  Scenario: Users can create publishable data to RDA if there are no moderators but there are superusers present
    Given I am logged in as "user1"
    Then I am on the project page for "project a"
    And I click on "Share"
    And I follow "Publish Data to RDA"
    Then I should see "1. Publishable Project Details"

  @javascript
  Scenario: Users will be prevented from entering invalid information
    Given I am logged in as "user1"
    And I have users
      | login | email                  | first_name | last_name | role      |
      | user3 | user3@example.com.au | User       | Three     | Moderator |
    Then I am on the project page for "project a"
    And I click on "Share"
    And I follow "Publish Data to RDA"
    And I wait for the wizard
    And I fill in "Collection Name" with ""
    And I fill in "Description" with ""
    And I fill in "Address" with ""
    And I fill in "Access Rights" with ""
    And I check "Temporal Coverage"
    And I fill in "From:" with "11/11/2011"
    And I fill in "To:" with "01/11/2011"
    And I press "Next"
    And I should see "Collection name can't be blank"
    And I should see "Collection description can't be blank"
    And I should see "Address can't be blank"
    And I should see "Access rights can't be blank"
    And I should see "From date must be before To date"


  @javascript
  Scenario: Users can create publishable data to RDA if they own the project
    Given I am logged in as "user1"
    And I have users
      | login | email                  | first_name | last_name | role      |
      | user3 | user3@example.com.au | User       | Three     | Moderator |
    And I have FOR codes
      | name       | code  |
      | for code 1 | 00111 |
      | for code 2 | 00222 |
      | for code 3 | 00333 |
      | for code 4 | 00444 |
    And I have ANDS Parties
      | given_name | family_name | group | key  |
      | Ands User  | 1           | UNSW  | 1111 |
      | Ands User  | 2           | UNSW  | 2222 |
      | Ands User  | 3           | UNSW  | 3333 |
      | Ands User  | 4           | UNSW  | 4444 |
    And I have exported dataset "dataset1" to ELN

    Then I am on the project page for "project a"
    And I click on "Share"
    And I follow "Publish Data to RDA"
    And I wait for 2 seconds
    And I fill in "Collection Name" with "My Collection"
    And I fill in "Description" with "This is my collection"
    And I fill in "Address" with "My Address"
    And I select "Template 2" from "templates"
    And I fill in "Contact me on my mobile" for "Access Rights"

    And I press "Next"
    And I should see "2. Specify Related Information"

  #for codes
    And I start filling in "for_code" with "001"
    And I wait for 2 seconds
    Then I should see the following autocomplete options:
      | 00111 - for code 1 |
    And I choose "00111 - for code 1" from the autocomplete list
    And I should see "00111 - for code 1"

    And I start filling in "for_code" with "for"
    And I wait for 2 seconds
    Then I should see the following autocomplete options:
      | 00111 - for code 1 |
      | 00222 - for code 2 |
      | 00333 - for code 3 |
      | 00444 - for code 4 |
    And I choose "00444 - for code 4" from the autocomplete list
    And I should see "00444 - for code 4"

  # ands subjects
    And I start filling in "ands_subject" with "chemistry"
    And I wait for 2 seconds
    Then I should see the following autocomplete options:
      | chemistry (create new) |
    And I choose "chemistry (create new)" from the autocomplete list
    And I should see "chemistry"

  # related info
    And I select "Digital Object Identifier" from "Type:"
    And I fill in "Identifier:" with "My Identifier"
    And I fill in "Description:" with "My Description"
    And I follow "Add"
    And I should see "(doi) My Identifier"
    And I should see "My Description"
    Then I press "Next"
    And I wait for 2 seconds
    And I should see "3. Specify Party and Activity Information"

    And I should see "Autolab PGSTAT 12 Potentiostat"
    And I should see "ELN"

  #TODO test unsw party

  #test non unsw party
    And I start filling in "non_unsw_party" with "ANDS"
    And I wait for 2 seconds
    Then I should see the following autocomplete options:
      | Ands User 1 (UNSW) |
      | Ands User 2 (UNSW) |
      | Ands User 3 (UNSW) |
      | Ands User 4 (UNSW) |
    And I choose "Ands User 2 (UNSW)" from the autocomplete list
    And I should see "Ands User 2 (UNSW)"


    Then I press "Next"
    And I wait for the wizard
    And I should see "4. Publishable Data Preview"
    And I should see "No temporal coverage included"
    And I should see "00444"
    And I should see "chemistry"
    And I should see "Ands User 2 (UNSW)"
    And I should see "My Collection"
    And I should see "This is my collection"
    And I should see "Contact me on my mobile"
    And I should see "Autolab PGSTAT 12 Potentiostat"
    And I press "Submit to Moderator"
    Then I should be on the project page for "project a"
    And I should see "The project's publishable data was successfully created and is pending approval by User Three"

  @javascript
  Scenario: After creating the publishable data, click 'Back' will let you edit the previous data
    Given I am logged in as "user1"
    And I have users
      | login | email                  | first_name | last_name | role      |
      | user3 | user3@example.com.au | User       | Three     | Moderator |
    And I have FOR codes
      | name       | code  |
      | for code 1 | 00111 |
      | for code 2 | 00222 |
      | for code 3 | 00333 |
      | for code 4 | 00444 |
    And I have ANDS Parties
      | given_name | family_name | group | key  |
      | Ands User  | 1           | UNSW  | 1111 |
      | Ands User  | 2           | UNSW  | 2222 |
      | Ands User  | 3           | UNSW  | 3333 |
      | Ands User  | 4           | UNSW  | 4444 |
    Then I am on the project page for "project a"
    And I click on "Share"


    And I follow "Publish Data to RDA"
    And I wait for 2 seconds
    And I check "Temporal Coverage"
    And I fill in "From:" with "01/10/2011"
    And I fill in "To:" with "01/11/2011"
    And I fill in "Collection Name" with "My Collection"
    And I fill in "Description" with "This is my collection"
    And I fill in "Address" with "My Address"
    And I select "Template 2" from "templates"
    And I fill in "Contact me on my mobile" for "Access Rights"


    And I press "Next"
    And I should see "2. Specify Related Information"
    #for codes
    And I start filling in "for_code" with "001"
    And I wait for 2 seconds
    Then I should see the following autocomplete options:
      | 00111 - for code 1 |
    And I choose "00111 - for code 1" from the autocomplete list
    And I should see "00111 - for code 1"
    And I start filling in "for_code" with "for"
    And I wait for 2 seconds
    Then I should see the following autocomplete options:
      | 00111 - for code 1 |
      | 00222 - for code 2 |
      | 00333 - for code 3 |
      | 00444 - for code 4 |
    And I choose "00444 - for code 4" from the autocomplete list
    And I should see "00444 - for code 4"
    # ands subjects
    And I start filling in "ands_subject" with "chemistry"
    And I wait for 2 seconds
    Then I should see the following autocomplete options:
      | chemistry (create new) |
    And I choose "chemistry (create new)" from the autocomplete list
    And I should see "chemistry"


    Then I press "Next"
    And I wait for 2 seconds
    And I should see "3. Specify Party and Activity Information"
    # TODO test unsw party
    #test non unsw party
    And I start filling in "non_unsw_party" with "ANDS"
    And I wait for 2 seconds
    Then I should see the following autocomplete options:
      | Ands User 1 (UNSW) |
      | Ands User 2 (UNSW) |
      | Ands User 3 (UNSW) |
      | Ands User 4 (UNSW) |
    And I choose "Ands User 2 (UNSW)" from the autocomplete list
    And I should see "Ands User 2 (UNSW)"


    Then I press "Next"
    And I wait for 2 seconds
    And I should see "4. Publishable Data Preview"
    And I should see "My Collection"
    And I should see "This is my collection"
    And I should see "00111"
    And I should see "00444"
    And I should see "chemistry"
    And I should see "Ands User 2 (UNSW)"
    And I should see "Autolab PGSTAT 12 Potentiostat"
    And I should see "From: 2011-10-01"
    And I should see "To: 2011-11-01"

    Then I follow "Back"
    And I should see "3. Specify Party and Activity Information"
    And I should see "Ands User 2 (UNSW)"
    And I start filling in "non_unsw_party" with "ANDS"
    And I wait for 2 seconds
    Then I should see the following autocomplete options:
      | Ands User 1 (UNSW) |
      | Ands User 2 (UNSW) |
      | Ands User 3 (UNSW) |
      | Ands User 4 (UNSW) |
    And I choose "Ands User 3 (UNSW)" from the autocomplete list


    And I press "Back"
    And I should see "2. Specify Related Information"
    And I should see "chemistry"
    And I should see "00111 - for code 1"
    And I should see "00444 - for code 4"
    And I start filling in "for_code" with "002"
    And I wait for 2 seconds
    Then I should see the following autocomplete options:
      | 00222 - for code 2 |
    And I choose "00222 - for code 2" from the autocomplete list


    Then I press "Back"
    And I fill in "collection A" for "Collection Name"


    And I press "Next"
    And I should see "2. Specify Related Information"
    And I should see "00222 - for code 2"
    And I start filling in "ands_subject" with "physics"
    And I wait for 2 seconds
    Then I should see the following autocomplete options:
      | physics (create new) |
    And I choose "physics (create new)" from the autocomplete list
    And I should see "physics"


    Then I press "Next"
    And I should see "3. Specify Party and Activity Information"
    And I should see "Ands User 3 (UNSW)"
    And I should see "Autolab PGSTAT 12 Potentiostat"
    And I should not see "ELN"


    Then I press "Next"
    And I should see "4. Publishable Data Preview"
    And I should see "00111"
    And I should see "00222"
    And I should see "00444"
    And I should see "chemistry"
    And I should see "physics"
    And I should see "Ands User 2 (UNSW)"
    And I should see "Ands User 3 (UNSW)"
    And I should see "Autolab PGSTAT 12 Potentiostat"
    And I should see "collection A"
    And I should see "This is my collection"


    Then I press "Submit to Moderator"
    And I should see "The project's publishable data was successfully created and is pending approval by User Three"

  @javascript
  Scenario: User can republish data when the moderator has approved it
    Given I am logged in as "user1"
    And I have users
      | login | email                  | first_name | last_name | role      |
      | user3 | user3@example.com.au | User       | Three     | Moderator |
    And I have an ANDS Publishable request "ands1" for project "project a" with moderator "user3"
    And the publishable data "ands1" is approved
    And I am on the project page for "project a"
    And I click on "Share"
    Then I should see "Update Data to RDA"

  @javascript
  Scenario: User can republish data when the moderator has rejected it
    Given I am logged in as "user1"
    And I have users
      | login | email                  | first_name | last_name | role      |
      | user3 | user3@example.com.au | User       | Three     | Moderator |
    And I have an ANDS Publishable request "ands1" for project "project a" with moderator "user3"
    And the publishable data "ands1" is rejected
    And I am on the project page for "project a"
    And I click on "Share"
    Then I should see "Update Data to RDA"

  @javascript
  Scenario: User republishing data doesn't change handle
    Given I am logged in as "user1"
    And I have ANDS Parties
      | given_name | family_name | group | key  |
      | Ands User  | 1           | UNSW  | 1111 |
      | Ands User  | 2           | UNSW  | 2222 |
      | Ands User  | 3           | UNSW  | 3333 |
      | Ands User  | 4           | UNSW  | 4444 |
    And I have users
      | login | email                  | first_name | last_name | role      |
      | user3 | user3@example.com.au | User       | Three     | Moderator |
    And I have an ANDS Publishable request "ands1" for project "project a" with moderator "user3"
    And the publishable data "ands1" is approved
    And the publishable "ands1" should have key "hdl:1959.4/004_320" assigned
    And I am on the project page for "project a"
    And I click on "Share"
    Then I follow "Update Data to RDA"
    And I wait for 2 seconds
    And I press "Next"
    And I should see "2. Specify Related Information"
    And I press "Next"
    And I should see "3. Specify Party and Activity Information"
    And I start filling in "non_unsw_party" with "ANDS"
    And I wait for 2 seconds
    Then I should see the following autocomplete options:
      | Ands User 1 (UNSW) |
      | Ands User 2 (UNSW) |
      | Ands User 3 (UNSW) |
      | Ands User 4 (UNSW) |
    And I choose "Ands User 3 (UNSW)" from the autocomplete list
    And I should see "Ands User 3 (UNSW)"
    And I press "Next"
    And I should see "4. Publishable Data Preview"
    And I press "Submit to Moderator"
    And I should see "The project's publishable data was successfully created and is pending approval by User Three"
    And I follow "Logout"
    And I am logged in as "user3"
    And I follow "RDA Publishables"
    Then I should see "ands1"
    And I follow "Approve"
    And I wait for 2 seconds
    Then I should see "The RDA publishable has been approved"
    And the publishable "ands1" should have key "hdl:1959.4/004_320" assigned

  @javascript  @publish

  Scenario: User publishing data publishes unpublished service records and activity records linked to project
    Given I am logged in as "user1"
    And I have ANDS Parties
      | given_name | family_name | group | key  |
      | Ands User  | 1           | UNSW  | 1111 |
      | Ands User  | 2           | UNSW  | 2222 |
      | Ands User  | 3           | UNSW  | 3333 |
      | Ands User  | 4           | UNSW  | 4444 |
    And I have users
      | login | email                  | first_name | last_name | role      |
      | user3 | user3@example.com.au | User       | Three     | Moderator |
    And I have the following datasets
      | name     | sample | instrument                     |
      | dataset3 | s1     | Autolab PGSTAT 12 Potentiostat |
      | dataset4 | s1     | Perkin Elmer Ramanstation 400  |
    And I have assigned a grant "project a grant" to project "project a"
    And I am on the project page for "project a"
    And I click on "Share"
    Then I follow "Publish Data to RDA"
    And I wait for 2 seconds
    And I press "Next"
    And I wait for 2 seconds
    And I should see "2. Specify Related Information"
    And I press "Next"
    And I wait for 2 seconds
    And I should see "3. Specify Party and Activity Information"
    And I start filling in "non_unsw_party" with "ANDS"
    And I wait for 2 seconds
    Then I should see the following autocomplete options:
      | Ands User 1 (UNSW) |
      | Ands User 2 (UNSW) |
      | Ands User 3 (UNSW) |
      | Ands User 4 (UNSW) |
    And I choose "Ands User 3 (UNSW)" from the autocomplete list
    And I should see "Ands User 3 (UNSW)"
    And I should see "Autolab PGSTAT 12 Potentiostat"
    And I should see "Perkin Elmer Ramanstation 400"
    And I should see "project a grant"
    And I press "Next"
    And I wait for 2 seconds
    And I should see "4. Publishable Data Preview"
    And I press "Submit to Moderator"
    And I should see "The project's publishable data was successfully created and is pending approval by User Three"
    And I follow "Logout"
    And I am logged in as "user3"
    And I follow "RDA Publishables"
    Then I should see "project a"
    And I follow "Approve"
    And I wait for 2 seconds
    Then I should see "The RDA publishable has been approved"
  # handle assigned for new grant
    And the publishable "project a" should have key "hdl:1959.4/004_321" assigned
    And the instrument "Autolab PGSTAT 12 Potentiostat" should have a published xml
    And the instrument "Perkin Elmer Ramanstation 400" should have a published xml
    And the grant "project a grant" should have a published xml

  @javascript  @publish

  Scenario: User publishing data does not publish rda grants
    Given I am logged in as "user1"
    And I have ANDS Parties
      | given_name | family_name | group | key  |
      | Ands User  | 1           | UNSW  | 1111 |
      | Ands User  | 2           | UNSW  | 2222 |
      | Ands User  | 3           | UNSW  | 3333 |
      | Ands User  | 4           | UNSW  | 4444 |
    And I have users
      | login | email                  | first_name | last_name | role      |
      | user3 | user3@example.com.au | User       | Three     | Moderator |
    And I have the following datasets
      | name     | sample | instrument                     |
      | dataset3 | s1     | Autolab PGSTAT 12 Potentiostat |
      | dataset4 | s1     | Perkin Elmer Ramanstation 400  |
    And I have assigned an rda grant "project a rda grant" of key "http://purl.org/au-research/grants/arc/FF0348307" to project "project a"
    And I am on the project page for "project a"
    And I click on "Share"
    Then I follow "Publish Data to RDA"
    And I wait for 2 seconds
    And I press "Next"
    And I wait for 2 seconds
    And I should see "2. Specify Related Information"
    And I press "Next"
    And I wait for 2 seconds
    And I should see "3. Specify Party and Activity Information"
    And I start filling in "non_unsw_party" with "ANDS"
    And I wait for 2 seconds
    Then I should see the following autocomplete options:
      | Ands User 1 (UNSW) |
      | Ands User 2 (UNSW) |
      | Ands User 3 (UNSW) |
      | Ands User 4 (UNSW) |
    And I choose "Ands User 3 (UNSW)" from the autocomplete list
    And I should see "Ands User 3 (UNSW)"
    And I should see "Autolab PGSTAT 12 Potentiostat"
    And I should see "Perkin Elmer Ramanstation 400"
    And I should see "project a rda grant"
    And I press "Next"
    And I wait for 2 seconds
    And I should see "4. Publishable Data Preview"
    And I press "Submit to Moderator"
    And I should see "The project's publishable data was successfully created and is pending approval by User Three"
    And I follow "Logout"
    And I am logged in as "user3"
    And I follow "RDA Publishables"
    Then I should see "project a"
    And I follow "Approve"
    And I wait for 2 seconds
  # handle not assigned for rda grant
    Then I should see "The RDA publishable has been approved"
    And the publishable "project a" should have key "hdl:1959.4/004_320" assigned
    And the instrument "Autolab PGSTAT 12 Potentiostat" should have a published xml
    And the instrument "Perkin Elmer Ramanstation 400" should have a published xml
    And the grant "project a rda grant" should not have a published xml

  @javascript
  Scenario: User publishing data after changing grants reflects correctly
    Given I am logged in as "user1"
    And I have ANDS Parties
      | given_name | family_name | group | key  |
      | Ands User  | 1           | UNSW  | 1111 |
      | Ands User  | 2           | UNSW  | 2222 |
      | Ands User  | 3           | UNSW  | 3333 |
      | Ands User  | 4           | UNSW  | 4444 |
    And I have users
      | login | email                  | first_name | last_name | role      |
      | user3 | user3@example.com.au | User       | Three     | Moderator |
    And I have the following datasets
      | name     | sample | instrument                     |
      | dataset3 | s1     | Autolab PGSTAT 12 Potentiostat |
      | dataset4 | s1     | Perkin Elmer Ramanstation 400  |
    And I have assigned an rda grant "project a rda grant" of key "http://purl.org/au-research/grants/arc/FF0348307" to project "project a"
    And I am on the project page for "project a"
    And I click on "Share"
    Then I follow "Publish Data to RDA"
    And I wait for 2 seconds
    And I press "Next"
    And I wait for 2 seconds
    And I should see "2. Specify Related Information"
    And I press "Next"
    And I wait for 2 seconds
    And I should see "3. Specify Party and Activity Information"
    And I start filling in "non_unsw_party" with "ANDS"
    And I wait for 2 seconds
    Then I should see the following autocomplete options:
      | Ands User 1 (UNSW) |
      | Ands User 2 (UNSW) |
      | Ands User 3 (UNSW) |
      | Ands User 4 (UNSW) |
    And I choose "Ands User 3 (UNSW)" from the autocomplete list
    And I should see "Ands User 3 (UNSW)"
    And I should see "Autolab PGSTAT 12 Potentiostat"
    And I should see "Perkin Elmer Ramanstation 400"
    And I should see "project a rda grant"
    And I press "Next"
    And I wait for 2 seconds
    And I should see "4. Publishable Data Preview"
    And I press "Submit to Moderator"
    And I should see "The project's publishable data was successfully created and is pending approval by User Three"
    And the publishable data "project a" is approved
    And I am on the project page for "project a"
    And I follow "Edit Grant"
    And I should see "Edit Project Grant"
    And I follow "Back"
    And I follow "No"
    And I fill in "Project Name" with "Test"
    And I fill in "Funding Sponsor" with "Test"
    And I press "Finish"
    And I should be redirected to the project page for "project a"
    And I wait for 2 seconds
    Then I should see "Activity record was successfully updated"
    And I click on "Share"
    Then I follow "Update Data to RDA"
    And I wait for 2 seconds
    And I press "Next"
    And I wait for 2 seconds
    And I should see "2. Specify Related Information"
    And I press "Next"
    And I wait for 2 seconds
    And I should see "3. Specify Party and Activity Information"
    And I should see "Test"


  @javascript
  Scenario: User assigning a grant after publishing to ands is reminded
    Given I am logged in as "user1"
    And I have ANDS Parties
      | given_name | family_name | group | key  |
      | Ands User  | 1           | UNSW  | 1111 |
      | Ands User  | 2           | UNSW  | 2222 |
      | Ands User  | 3           | UNSW  | 3333 |
      | Ands User  | 4           | UNSW  | 4444 |
    And I have users
      | login | email                  | first_name | last_name | role      |
      | user3 | user3@example.com.au | User       | Three     | Moderator |
    And I have an ANDS Publishable request "ands1" for project "project a" with moderator "user3"
    And the publishable data "ands1" is approved
    And I am on the project page for "project a"
    And I follow "Assign Grant"
    And I should see "Assign a Grant"
    And I should see "Note: Republishing the project is required to include a newly assigned grant"