Feature: Manage Activity Records
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


  Scenario: User cannot assign a grant if they are not the project owner or collaborator
    Given I am logged in as "user1"
    And I am on the project page for "project b"
    Then I should not see "Assign Grant"

  Scenario: User can assign a grant to ANDS if they have collaborator privileges
    Given I have the following collaborators for projects
      | name      | members |
      | project b | user4   |
    And I am logged in as "user4"
    And I am on the project page for "project b"
    Then I should see "Assign Grant"

  @javascript
  Scenario: Users will be prevented from entering invalid information
    Given I am logged in as "user1"
    And I have users
      | login | email                  | first_name | last_name | role      |
      | user3 | user3@example.com.au | User       | Three     | Moderator |
    Then I am on the project page for "project a"
    And I follow "Assign Grant"
    And I should see "Assign a Grant to this Project"
    And I follow "No"
    And I fill in "Initial Year" with "a"
    And I press "Finish"
    And I should see "Initial year is not a number"
    And I should see "Project name can't be blank"
    And I should see "Funding sponsor can't be blank"


  @javascript
  Scenario: Users can assign a new grant if they own the project
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
    Then I am on the project page for "project a"
    And I follow "Assign Grant"
    And I wait for 2 seconds
    And I should see "Assign a Grant to this Project"
    And I follow "No"
    And I fill in "Project Name" with "Test"
    And I fill in "Funding Sponsor" with "Test"
    And I start filling in "for_code" with "001"
    And I wait for 2 seconds
    Then I should see the following autocomplete options:
      | 00111 - for code 1 |
    And I choose "00111 - for code 1" from the autocomplete list
    And I should see "00111 - for code 1"
    And I press "Finish"
    And I should be redirected to the project page for "project a"
    And I wait for 2 seconds
    Then I should see "Edit Grant"
    Then I should see "Activity record was successfully created"
    And I follow "Edit Grant"
    And I should see "Edit Project Grant"
    Then I should see "Field of Research (FOR) Tags"

  @javascript
  Scenario: Users cannot assign a new grant if there are no more handles
    Given I set the end handle range to "hdl:1959.4/004_300"
    And I am logged in as "user1"
    And I have users
      | login | email                  | first_name | last_name | role      |
      | user3 | user3@example.com.au | User       | Three     | Moderator |
    And I have FOR codes
      | name       | code  |
      | for code 1 | 00111 |
      | for code 2 | 00222 |
      | for code 3 | 00333 |
      | for code 4 | 00444 |
    Then I am on the project page for "project a"
    And I follow "Assign Grant"
    And I should see "Assign a Grant to this Project"
    And I follow "No"
    And I fill in "Project Name" with "Test"
    And I fill in "Funding Sponsor" with "Test"
    And I start filling in "for_code" with "001"
    And I wait for 2 seconds
    Then I should see the following autocomplete options:
      | 00111 - for code 1 |
    And I choose "00111 - for code 1" from the autocomplete list
    And I should see "00111 - for code 1"

    And I press "Finish"
    And I should see "Handles exhausted and cannot be assigned."

  @javascript
  Scenario: Users cannot assign a new grant if there are no handles
    Given I set the end handle range to ""
    Given I set the start handle range to ""
    And I am logged in as "user1"
    And I have users
      | login | email                  | first_name | last_name | role      |
      | user3 | user3@example.com.au | User       | Three     | Moderator |
    And I have FOR codes
      | name       | code  |
      | for code 1 | 00111 |
      | for code 2 | 00222 |
      | for code 3 | 00333 |
      | for code 4 | 00444 |
    Then I am on the project page for "project a"
    And I follow "Assign Grant"
    And I should see "Assign a Grant to this Project"
    And I follow "No"
    And I fill in "Project Name" with "Test"
    And I fill in "Funding Sponsor" with "Test"
    And I start filling in "for_code" with "001"
    And I wait for 2 seconds
    Then I should see the following autocomplete options:
      | 00111 - for code 1 |
    And I choose "00111 - for code 1" from the autocomplete list
    And I should see "00111 - for code 1"

    And I press "Finish"
    And I should see "No handles can be assigned at the moment."

  @javascript
  Scenario: Users can assign an rda grant if they own the project
    Given I am logged in as "user1"
    And I have users
      | login | email                  | first_name | last_name | role      |
      | user3 | user3@example.com.au | User       | Three     | Moderator |
    And I have RDA grants
      | primary_name | description | key                | grant_id | group                       |
      | grant 1      | 00111       | http://grant.gov/1 | 1        | Australian Research Council |
      | grant 2      | 00222       | http://grant.gov/2 | 2        | Australian Research Council |
      | grant 3      | 00333       | http://grant.gov/3 | 3        | Australian Research Council |
    Then I am on the project page for "project a"
    And I follow "Assign Grant"
    And I wait for 2 seconds
    And I should see "Assign a Grant to this Project"
    And I follow "Yes"
    And I should see "Research Data Australia Activity Records"
    And I fill in "Search Project ID" with "001"
    And I follow "Search"
    And I wait for 2 seconds
    And I should see "Grant with project ID '001' could not be found"
    And I fill in "Search Project ID" with "1"
    And I follow "Search"
    And I should see "1"
    And I should see "grant 1"
    And I should see "00111"
    And I press "Finish"
    And I wait for the wizard
    And I should be redirected to the project page for "project a"
    Then I should see "Activity record was successfully created"
    Then I should see "Edit Grant"
    And I follow "Edit Grant"
    And I wait for the wizard
    Then I should see "Edit Project Grant"
    And I should see "ARC and NHMRC Grants"
    And I should see "Search Project ID"
    And the activity record of project "project a" should not have an ands handle

  @javascript
  Scenario: Users can assign an rda grant even if there are no handles
    Given I am logged in as "user1"
    And I set the end handle range to "hdl:1959.4/004_300"
    And I have users
      | login | email                  | first_name | last_name | role      |
      | user3 | user3@example.com.au | User       | Three     | Moderator |
    And I have RDA grants
      | primary_name | description | key                | grant_id | group                       |
      | grant 1      | 00111       | http://grant.gov/1 | 1        | Australian Research Council |
      | grant 2      | 00222       | http://grant.gov/2 | 2        | Australian Research Council |
      | grant 3      | 00333       | http://grant.gov/3 | 3        | Australian Research Council |
    Then I am on the project page for "project a"
    And I follow "Assign Grant"
    And I wait for 2 seconds
    And I should see "Assign a Grant to this Project"
    And I follow "Yes"
    And I fill in "Search Project ID" with "001"
    And I follow "Search"
    And I wait for 2 seconds
    And I should see "Grant with project ID '001' could not be found"
    And I fill in "Search Project ID" with "1"
    And I follow "Search"
    And I should see "1"
    And I should see "grant 1"
    And I should see "00111"
    And I press "Finish"
    And I wait for the wizard
    And I should be redirected to the project page for "project a"
    Then I should see "Activity record was successfully created"
    Then I should see "Edit Grant"
    And I follow "Edit Grant"
    Then I should see "Edit Project Grant"
    And I should see "ARC and NHMRC Grants"
    And I should see "Search Project ID"
    And the activity record of project "project a" should not have an ands handle


  @javascript
  Scenario: Users can assign an rda grant and change it to an new grant
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
    And I have RDA grants
      | primary_name | description | key                | grant_id | group                       |
      | grant 1      | 00111       | http://grant.gov/1 | 1        | Australian Research Council |
      | grant 2      | 00222       | http://grant.gov/2 | 2        | Australian Research Council |
      | grant 3      | 00333       | http://grant.gov/3 | 3        | Australian Research Council |
    Then I am on the project page for "project a"
    And I follow "Assign Grant"
    And I wait for 2 seconds
    And I should see "Assign a Grant to this Project"
    And I follow "Yes"
    And I fill in "Search Project ID" with "001"
    And I follow "Search"
    And I wait for 2 seconds
    And I should see "Grant with project ID '001' could not be found"
    And I fill in "Search Project ID" with "1"
    And I follow "Search"
    And I should see "1"
    And I should see "grant 1"
    And I should see "00111"
    And I press "Finish"
    And I should be redirected to the project page for "project a"
    And I wait for 2 seconds
    Then I should see "Edit Grant"
    Then I should see "Activity record was successfully created"
    And the activity record of project "project a" should not have an ands handle
    And I follow "Edit Grant"
    Then I should see "Edit Project Grant"
    And I should see "ARC and NHMRC Grants"
    And I should see "Search Project ID"
    And I follow "Back"
    And I follow "No"
    And I fill in "Project Name" with "Test"
    And I fill in "Funding Sponsor" with "Test"
    And I start filling in "for_code" with "001"
    And I wait for 2 seconds
    Then I should see the following autocomplete options:
      | 00111 - for code 1 |
    And I choose "00111 - for code 1" from the autocomplete list
    And I should see "00111 - for code 1"
    And I press "Finish"
    And I should be redirected to the project page for "project a"
    And I wait for 2 seconds
    And I should see "Activity record was successfully updated"
    And the activity record of project "project a" should have an ands handle

  @javascript
  Scenario: Users can assign an rda grant but cannot change it to an new grant when handles are exhausted
    Given I am logged in as "user1"
    And I set the end handle range to "hdl:1959.4/004_300"
    And I have users
      | login | email                  | first_name | last_name | role      |
      | user3 | user3@example.com.au | User       | Three     | Moderator |
    And I have FOR codes
      | name       | code  |
      | for code 1 | 00111 |
      | for code 2 | 00222 |
      | for code 3 | 00333 |
      | for code 4 | 00444 |
    And I have RDA grants
      | primary_name | description | key                | grant_id | group                       |
      | grant 1      | 00111       | http://grant.gov/1 | 1        | Australian Research Council |
      | grant 2      | 00222       | http://grant.gov/2 | 2        | Australian Research Council |
      | grant 3      | 00333       | http://grant.gov/3 | 3        | Australian Research Council |
    Then I am on the project page for "project a"
    And I follow "Assign Grant"
    And I wait for 2 seconds
    And I should see "Assign a Grant to this Project"
    And I follow "Yes"
    And I fill in "Search Project ID" with "001"
    And I follow "Search"
    And I wait for 2 seconds
    And I should see "Grant with project ID '001' could not be found"
    And I fill in "Search Project ID" with "1"
    And I follow "Search"
    And I should see "1"
    And I should see "grant 1"
    And I should see "00111"
    And I press "Finish"
    And I should be redirected to the project page for "project a"
    And I wait for 2 seconds
    Then I should see "Activity record was successfully created"
    And the activity record of project "project a" should not have an ands handle
    Then I should see "Edit Grant"
    And I follow "Edit Grant"
    Then I should see "Edit Project Grant"
    And I should see "ARC and NHMRC Grants"
    And I should see "Search Project ID"
    And I follow "Back"
    And I follow "No"
    And I fill in "Project Name" with "Test"
    And I fill in "Funding Sponsor" with "Test"
    And I start filling in "for_code" with "001"
    And I wait for 2 seconds
    Then I should see the following autocomplete options:
      | 00111 - for code 1 |
    And I choose "00111 - for code 1" from the autocomplete list
    And I should see "00111 - for code 1"
    And I press "Finish"
    And I should see "Handles exhausted"
    And the activity record of project "project a" should not have an ands handle

