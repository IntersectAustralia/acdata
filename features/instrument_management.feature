Feature: In order to add new instruments and instrument classes
  As an Administrator
  I want to have an interface to manage instruments

  Background:
    Given I have the usual roles and permissions
    And I have users
      | login | email                  | first_name | last_name | role       |
      | user1 | user1@example.com.au | User       | One       | Superuser  |
      | user2 | user2@example.com.au | User       | Two       | Researcher |
    And I have the default handle range
    And I set the start handle range to "hdl:1959.4/004_301"
    And I have the following projects
      | name      | description   | owner |
      | Project A | description a | user1 |
    And I have the following file types
      | name  |
      | TypeA |
      | TypeB |
      | TypeC |
      | TypeD |
    And I have the following instruments
      | name         | instrument_class | is_available | instrument_file_types |
      | Instrument 1 | class 1          | true         | TypeA, TypeB          |
      | Instrument 2 | class 2          | false        | TypeA, TypeC          |
      | Instrument 3 | class 3          | true         | TypeC, TypeD          |

  Scenario: A Researcher cannot access the manage instruments interface
    Given I am logged in as "user2"
    Then I should not see "Admin Tasks"

  Scenario: A Superuser can view a list of existing instruments
    Given I am logged in as "user1"
    And I follow "Admin Tasks"
    And I follow "Instrument Management"
    And I should see the instruments table with
      | Name         | Key                | Instrument Class |
      | Instrument 1 | hdl:1959.4/004_301 | class 1          |
      | Instrument 2 | hdl:1959.4/004_302 | class 2          |
      | Instrument 3 | hdl:1959.4/004_303 | class 3          |

  Scenario: A superuser can view the details of an instrument
    Given I am logged in as "user1"
    And I am on the instrument management page
    When I follow view for "Instrument 1"
    Then I should see "Viewing Instrument 1"
    And I should see the values for instrument "Instrument 1"

  Scenario: A superuser can create a new instrument with existing instrument class
    Given I am logged in as "user1"
    And I am on the create new instrument page
    Then I should see "Create Instrument"
    And I fill in "Name" with "Instrument 4"
    And I select "class 1" from "Instrument class"
    And I press "Create Instrument"
    Then I should see "The instrument has been created."
    And I should see "instruments" table with
      | Name         | Key                | Instrument Class |
      | Instrument 1 | hdl:1959.4/004_301 | class 1          |
      | Instrument 4 | hdl:1959.4/004_304 | class 1          |
      | Instrument 2 | hdl:1959.4/004_302 | class 2          |
      | Instrument 3 | hdl:1959.4/004_303 | class 3          |

  @javascript
  Scenario: A Superuser can create a new instrument entering a new instrument class
    Given I am logged in as "user1"
    And I am on the create new instrument page
    And I fill in "Name" with "Instrument 4"
    And I follow "Add new class"
    And I fill in "instrument_class" with "class 4"
    And I press "Create Instrument"
    Then I should see "The instrument has been created."
    And I should see "instruments" table with
      | Name         | Key                | Instrument Class |
      | Instrument 1 | hdl:1959.4/004_301 | class 1          |
      | Instrument 2 | hdl:1959.4/004_302 | class 2          |
      | Instrument 3 | hdl:1959.4/004_303 | class 3          |
      | Instrument 4 | hdl:1959.4/004_304 | class 4          |

  Scenario: A superuser can select a number of files types associated with an instrument
    Given I am logged in as "user1"
    And I am on the create new instrument page
    And I fill in "Name" with "Instrument 4"
    And I select "class 3" from "Instrument class"
    And I select "TypeA" from "File types"
    And I select "TypeB" from "File types"
    And I press "Create Instrument"
    Then I should see "The instrument has been created."
    And instrument "Instrument 4" should have the following file types
      | name  |
      | TypeA |
      | TypeB |

  @javascript  @publish
  Scenario: A superuser creates a new instrument with instrument rules
    Given I am logged in as "user1"
    And I am on the instrument management page
    And I follow "Add New Instrument"
    Then I should be on the create new instrument page
    And I fill in "Name" with "New Instrument 1"
    And I select "class 1" from "Instrument class"
    And I select "TypeA" from "File types"
    And I select "TypeB" from "File types"
    And I select "TypeC" from "File types"
    Then I should see only the selected file types under each instrument rule
    And I select "TypeA" from "instrument_rule_metadata"
    And I select "TypeB" from "instrument_rule_visualisation"
    And I select "TypeC" from "instrument_rule_unique"
    And I press "Create Instrument"
    Then I should have an instrument "New Instrument 1"
    And I should have an instrument rule for "New Instrument 1"
    And I should be on the instrument management page
    And I follow view for "New Instrument 1"
    Then I should be on the instrument view page for "New Instrument 1"
    And I should see the values for instrument "New Instrument 1"
    And the instrument "New Instrument 1" should not have a published xml

  @javascript
  Scenario: A superuser editing an instrument can change the file types
    Given I am logged in as "user1"
    And I am on the instrument management page
    And I follow view for "Instrument 1"
    And I follow "Edit"
    Then I should see only the selected file types under each instrument rule
    And I select "TypeA" from "File types"
    Then I should see only the selected file types under each instrument rule

  @javascript
  Scenario: A superuser changing an instruments file types will be warned if there are existing instrument rules selected
    Given I am logged in as "user1"
    And I am on the instrument management page
    And I follow "Add New Instrument"
    Then I should be on the create new instrument page
    And I fill in "Name" with "New Instrument 1"
    And I select "class 1" from "Instrument class"
    And I select "TypeA" from "File types"
    And I select "TypeB" from "File types"
    And I select "TypeA" from "instrument_rule_metadata"
    And I select "TypeC" from "File types"
    And I confirm popup

  Scenario: A superuser can cancel editing an instrument
    Given I am logged in as "user1"
    And I am on the instrument management page
    And I follow view for "Instrument 1"
    And I follow "Edit"
    And I fill in "Name" with "A new name"
    And I follow "Cancel"
    And I follow "Back"
    Then I should see "instruments" table with
      | Name         | Key                | Instrument Class |
      | Instrument 1 | hdl:1959.4/004_301 | class 1          |
      | Instrument 2 | hdl:1959.4/004_302 | class 2          |
      | Instrument 3 | hdl:1959.4/004_303 | class 3          |

  @javascript
  Scenario: A superuser can create an instrument with a new instrument class
    Given I am logged in as "user1"
    And I am on the create new instrument page
    And I fill in "Name" with "Instrument 4"
    And I select "class 3" from "Instrument class"
    And I follow "Add new class"
    And I fill in "instrument_class" with "class 4"
    And I follow "Select existing class"
    And I select "class 2" from "Instrument class"
    And I follow "Add new class"
    And I fill in "instrument_class" with "class 5"
    And I press "Create Instrument"
    Then I should see "The instrument has been created."
    And I should see "instruments" table with
      | Name         | Key                | Instrument Class |
      | Instrument 1 | hdl:1959.4/004_301 | class 1          |
      | Instrument 2 | hdl:1959.4/004_302 | class 2          |
      | Instrument 3 | hdl:1959.4/004_303 | class 3          |
      | Instrument 4 | hdl:1959.4/004_304 | class 5          |

  @javascript
  Scenario: A Superuser can edit an instrument
    Given I am logged in as "user1"
    And I am on the instrument management page
    And I follow view for "Instrument 1"
    And I follow "Edit"
    When I fill in "Name" with "Instrument 0"
    And I follow "Add new class"
    And I fill in "Instrument class" with "class 5"
    And I press "Update Instrument"
    Then I should see "The instrument has been updated."
    And I follow "Back"
    Then I should be on the instrument management page
    And I should see "instruments" table with
      | Name         | Key                | Instrument Class |
      | Instrument 2 | hdl:1959.4/004_302 | class 2          |
      | Instrument 3 | hdl:1959.4/004_303 | class 3          |
      | Instrument 0 | hdl:1959.4/004_301 | class 5          |

  Scenario: A Superuser can mark an instrument as available and unavailable
    Given I am logged in as "user1"
    And I am on the instrument management page
    Then I should see that "Instrument 1" is available
    When I mark "Instrument 1" as unavailable
    Then I should see that "Instrument 1" is unavailable
    When I follow view for "Instrument 1"
    Then I should see that instrument is unavailable
    And I follow "Toggle status"
    Then I should be on the instrument management page
    And I should see that "Instrument 1" is available

  Scenario: Creating an instrument without including the required field "name"
    Given I am logged in as "user1"
    And I am on the create new instrument page
    And I press "Create Instrument"
    Then I should see "Name can't be blank"

  Scenario: A superuser cannot create an instrument with a duplicate name
    Given I am logged in as "user1"
    And I am on the create new instrument page
    And I fill in "Name" with "Instrument 1"
    And I press "Create Instrument"
    Then I should see "Name has already been taken"

  @javascript
  @applet
  Scenario: An instrument without upload prompt displays default prompt
    Given I am logged in as "user1"
    And I have the following samples
      | name | description | project   |
      | s2   | desc2       | Project A |
    And I am on the create new instrument page
    Then I should see "Create Instrument"
    And I fill in "Name" with "Instrument 4"
    And I fill in "Upload prompt" with ""
    And I select "class 1" from "Instrument class"
    And I press "Create Instrument"
    Then I should see "The instrument has been created."
    Then I mark "Instrument 4" as available
    When I am on the sample page for "s2"
    And I click on "Add"
    And I follow "Add Dataset"
    And I fill in "Dataset name" with "Blah"
    And I select "class 1" from "Instrument class"
    And I select "Instrument 4" from "Instrument name"
    And I press "Next"
    Then I should see "Select files or folders to upload"

  @javascript
  @applet
  Scenario: An instrument with upload prompt displays accordingly
    Given I am logged in as "user1"
    And I have the following samples
      | name | description | project   |
      | s2   | desc2       | Project A |
    And I am on the create new instrument page
    Then I should see "Create Instrument"
    And I fill in "Name" with "Instrument 4"
    And I fill in "Upload prompt" with "Upload some random files"
    And I select "class 1" from "Instrument class"
    And I press "Create Instrument"
    Then I should see "The instrument has been created."
    Then I mark "Instrument 4" as available
    When I am on the sample page for "s2"
    And I click on "Add"
    And I follow "Add Dataset"
    And I fill in "Dataset name" with "Blah"
    And I select "class 1" from "Instrument class"
    And I select "Instrument 4" from "Instrument name"
    And I press "Next"
    Then I should see "Upload some random files"

  @javascript @publish
  Scenario: An instrument does not get published on update if it hasn't been published
    Given I am logged in as "user1"
    And I am on the instrument management page
    And I follow view for "Instrument 1"
    And I follow "Edit"
    When I fill in "Name" with "Instrument 0"
    And I follow "Add new class"
    And I fill in "Instrument class" with "class 5"
    And I press "Update Instrument"
    Then I should see "The instrument has been updated."
    And I follow "Back"
    Then I should be on the instrument management page
    And I should see "instruments" table with
      | Name         | Key                | Instrument Class |
      | Instrument 2 | hdl:1959.4/004_302 | class 2          |
      | Instrument 3 | hdl:1959.4/004_303 | class 3          |
      | Instrument 0 | hdl:1959.4/004_301 | class 5          |
    And the instrument "Instrument 0" should not have a published xml

  @javascript @publish
  Scenario: An instrument gets republished on update
    Given I am logged in as "user1"
    And I am on the instrument management page
    And the instrument "Instrument 1" has been published
    And I follow view for "Instrument 1"
    And I follow "Edit"
    When I fill in "Name" with "Instrument 0"
    And I follow "Add new class"
    And I fill in "Instrument class" with "class 5"
    And I press "Update Instrument"
    Then I should see "The instrument has been updated."
    And I follow "Back"
    Then I should be on the instrument management page
    And I should see "instruments" table with
      | Name         | Key                | Instrument Class |
      | Instrument 2 | hdl:1959.4/004_302 | class 2          |
      | Instrument 3 | hdl:1959.4/004_303 | class 3          |
      | Instrument 0 | hdl:1959.4/004_301 | class 5          |
    And the instrument "Instrument 0" should have a published xml


