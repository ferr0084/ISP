## Use Case Name
**Create Group**

## Description
**User creates a private, invite-only group, becomes the admin, sets up a central chat thread, and invites friends.**

## Actors
- **Primary Actor:** User (group creator and initial admin)
- **Secondary Actors:** Friends (invitees), the system

## Preconditions
- User must be logged in
- User has an account

## Postconditions
- Group is created as private and invite-only
- Creator is designated as admin
- Initial chat thread is established
- Invitations are sent to friends
- Invite statuses are tracked (e.g., pending acceptance)

## Main Success Scenario
1. User navigates to the groups page
2. User selects "Create Group" button
3. System shows a form/dialog to name the group, add an optional description, and invite friends
4. User enters group name, optional description, and adds 1 or more friends' email addresses (or selects from contacts)
5. User reviews and clicks "Create Group" button
6. System creates the group as private, designates the user as admin, and initializes a central chat thread
7. System displays the new group's chat page
8. System sends invitations to friends via email or in-app notifications, with links to accept/decline
9. System tracks invite statuses (e.g., pending) and updates the group member list accordingly

## Exception Flows
### Group Exists
- If a group with the same name or exact members already exists:
  6. System displays a message that the group already exists and suggests alternatives (e.g., join existing or rename)

### Invalid Invitations
- If some email addresses are invalid:
  8. System shows an error for invalid emails, allows retry, and proceeds with valid ones

## Business Rules
- Groups are private and invite-only by default
- Multiple groups with the exact same members are not allowed (system checks for duplicates)
- Only the admin can invite new members initially; members can be promoted later
- Invitations expire after a set period (e.g., 7 days) for security

## Non-Functional Requirements
- **Security:** Invitations use secure, unique links that expire to prevent unauthorized access; group data is encrypted
- **Usability:** Display invited users' status as pending until they accept or reject; provide clear feedback on group creation success
- **Performance:** Group creation and invite sending should complete within 2 seconds
- **Scalability:** Support up to 100 members per group initially, with room for expansion
