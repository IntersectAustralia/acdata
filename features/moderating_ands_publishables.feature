Feature: Moderating Ands Publishable
  In order to double check data before publishing
  As a moderator
  I want to be able to approve or reject requests to publish project details to RDA

  Background:
    Given I have the usual roles and permissions
    And I have users
      | login | email                  | first_name | last_name | role       |
      | user1 | user1@example.com.au | User       | One       | Researcher |
      | user2 | user2@example.com.au | User       | Two       | Superuser  |
      | user3 | user3@example.com.au | User       | Three     | Moderator  |
    And I have the default handle range
    And I have the following projects
      | name      | description   | owner |
      | project a | The A Project | user1 |
      | project b | The B Project | user2 |

  Scenario: No publishable requests
    Given I am logged in as "user3"
    And I follow "RDA Publishables"
    Then I should see "No RDA Publishables awaiting your approval"

  Scenario: Viewing requests
    Given I have an ANDS Publishable request "ands1" for project "project a" with moderator "user3"
    And I am logged in as "user3"
    And I follow "RDA Publishables"
    Then I should see "ands1"
    And I should see "Preview"
    And I should see "Approve"
    And I should see "Reject"

  @javascript
  Scenario: Previewing requests and then approving
    Given I have an ANDS Publishable request "ands1" for project "project a" with moderator "user3"
    And I am logged in as "user3"
    And I follow "RDA Publishables"
    Then I should see "ands1"
    And I follow "Preview"
    And I should see "Publishable Data Preview"
    And I should see "Approve"
    And I should see "Reject"
    And I follow "Approve"
    Then I should see "The RDA publishable has been approved"

  @javascript
  Scenario: Previewing requests and then rejecting
    Given I have an ANDS Publishable request "ands1" for project "project a" with moderator "user3"
    And I am logged in as "user3"
    And I follow "RDA Publishables"
    Then I should see "ands1"
    And I follow "Preview"
    And I should see "Publishable Data Preview"
    And I should see "Approve"
    And I should see "Reject"
    And I follow "Reject"
    And I should see "Rejecting RDA publishable for project a"
    And I should see "Please specify a reason"
    And I fill in "Please specify a reason:" with "blah"
    And I press "Reject"
    Then I should see "The RDA publishable was rejected"

  Scenario: Approving requests
    Given I have an ANDS Publishable request "ands1" for project "project a" with moderator "user3"
    And I am logged in as "user3"
    And I follow "RDA Publishables"
    Then I should see "ands1"
    And I follow "Approve"
    Then I should see "The RDA publishable has been approved"

  @javascript
  Scenario: Rejecting requests
    Given I have an ANDS Publishable request "ands1" for project "project a" with moderator "user3"
    And I am logged in as "user3"
    And I follow "RDA Publishables"
    Then I should see "ands1"
    And I follow "Reject"
    And I should see "Rejecting RDA publishable for project a"
    And I should see "Please specify a reason"
    And I fill in "Please specify a reason:" with "blah"
    And I press "Reject"
    Then I should see "The RDA publishable was rejected"

  @javascript
  Scenario: Rejecting requests requires reason
    Given I have an ANDS Publishable request "ands1" for project "project a" with moderator "user3"
    And I am logged in as "user3"
    And I follow "RDA Publishables"
    Then I should see "ands1"
    And I follow "Reject"
    And I should see "Rejecting RDA publishable for project a"
    And I should see "Please specify a reason"
    And I press "Reject"
    Then I should see "Reason can't be blank"
    Then I should not see "The RDA publishable was rejected"

  @javascript
  Scenario: Moderator cannot approve if handles are exhausted
    Given I set the end handle range to "hdl:1959.4/004_300"
    And I have an ANDS Publishable request "approved" for project "project b" with moderator "user3"
    And the publishable data "approved" is approved
    And I have an ANDS Publishable request "ands1" for project "project a" with moderator "user3"
    And I am logged in as "user3"
    And I follow "RDA Publishables"
    Then I should see "ands1"
    And I follow "Approve"
    Then I should see "Handles exhausted and cannot be assigned."
    Then I should see "ands1"

  @javascript
  Scenario: Moderator cannot approve if handle ranges are not defined
    Given I have an ANDS Publishable request "ands1" for project "project b" with moderator "user3"
    And I set the end handle range to ""
    And I set the start handle range to ""
    And I am logged in as "user3"
    And I follow "RDA Publishables"
    Then I should see "ands1"
    And I follow "Approve"
    Then I should see "No handles can be assigned at the moment."
    Then I should see "ands1"


