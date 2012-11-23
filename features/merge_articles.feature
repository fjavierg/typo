Feature: Merge articles
  As an admin
  In order to merge articles with similar contents
  I want to merge two articles
  
  Background:
  Given the blog is set up
	 And the following articles exist:
  | title      | type     | author    | published | body             |
  | My entry   | Article  | publisher | true      | First Article    | 
  | My entry2  | Article  | publisher | true      | Second Article   |
  | My entry3  | Article  | publisher | true      | Third Article    |
  | My entry4  | Article  | publisher | true      | Fourth Article   |

  Scenario: Merge articles allowed to admin users
    Given I am logged into the admin panel
	When I am on the edit article page
    Then I should see "Merge"

  Scenario: Merge articles not allowed to non admin users
    Given I am logged into the publisher panel
	When I edit article "My entry"
    Then I should not see "Merge"
	
  Scenario: When articles are merged the merged article should contain text of both articles
    Given I am logged into the admin panel
	And I merge articles "My entry" and "My entry2"
	When I view article "My entry"
    Then I should see "First Article"
	And I should see "Second Article"

  Scenario: When articles are merged the author of the merged article should be any of the authors
    Given I am logged into the admin panel
	And I merge articles "My entry" and "My entry2"
	When I view article "My entry"
    Then I should see "publisher"
	
  Scenario: When articles are merged the author of the merged article should be any of the authors
    Given I am logged into the admin panel
	And I merge articles "My entry" and "My entry2"
	When I view article "My entry"
    Then I should see /(My entry|My entry2)/