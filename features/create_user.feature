Feature: Create a new user
  As an unregistered user
  In order to use the service
  I want to create a new user account

  Scenario: Create a user using json in POST body without password_confirmation
    When I send and accept JSON
    And I send a POST request to "/v1/users" with the following:
    """
    {"user":{"username":"tester","password":"secret","email":"test@example.com","deviceid":"foo123bar"}}
    """
    Then a user should exist with username: "tester"
    Then the response status should be "201"

  Scenario: Create a user using factory girl and seding it's json in POST body without password_confirmation
    When I send and accept JSON
    Given a User exists with username: "tester"
    And I send a POST request to "/v1/users" with the user
    Then a user should exist with username: "tester"
    Then the response status should be "201"
