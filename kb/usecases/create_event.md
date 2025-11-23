## Use Case Name
**Create Event**

## Description
**Create an event with multiple time slots, invite friends, enable ranked-choice voting, and finalize the best time for a game session.**

## Actors
- **Primary Actor:** User (event creator)
- **Secondary Actors:** Friends (invitees), the system

## Preconditions
- User has an account
- User has logged in
- User is a member of at least one group (optional for associating event with a group, required for inviting friends from the group)

## Postconditions
- Event is created with proposed time slots
- Invitations are sent to friends
- Friends can vote on preferences
- System calculates and confirms the optimal time slot
- Event details are displayed and synced (e.g., to calendars)

## Main Success Scenario
1. User navigates to the events page
2. User selects "Create Event" button
3. System shows a form/dialog for event details: Title, description, duration, and 1-3 proposed time slots (user enters dates/times for each)
4. User optionally selects a group they are a member of for the event
5. User invites friends by entering email addresses or selecting from their group members
6. User reviews and clicks "Create Event" button
6. System creates the event in the database
7. System displays the new event details page, showing proposed time slots and voting options
8. System sends invitations to friends via email or in-app notifications, including a link to rank preferences (1st choice, 2nd, etc.)
9. Friends access the event, rank time slots by preference
10. System aggregates rankings using a ranked-choice algorithm (e.g., instant-runoff voting) and selects the optimal time slot
11. System updates the event with the selected time and sends confirmations/reminders to all participants

## Alternative Flows
- If no time slots are provided, system prompts user to add at least one
- If invitations fail (e.g., invalid emails), system shows an error message and allows retry
- If voting results in a tie, system could use a tie-breaker (e.g., creator's preference) or prompt for re-voting
