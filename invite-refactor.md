# Group Invite Refactoring Plan

## Overview
This plan repurposes the existing contacts and invite friends functionality to be group-specific. Users will invite friends directly to specific groups rather than to the app globally, with member management accessible from each group's home page.

## Current State
- Contacts feature exists in main navigation (`/contacts`)
- Invite friends screen allows global app invitations
- Groups have a legacy `member_ids` array but no member management UI

## Target State
- Remove global contacts navigation
- Add "Members" section to group home screens
- Group-specific invite functionality using a scalable `group_members` table
- Full member list and management per group

## Implementation Phases

### Phase 1: UI/Navigation Changes (Week 1)

| Task ID | Task Description | Dependencies | Effort | Status |
|---------|------------------|--------------|--------|--------|
| remove_contacts_drawer | Remove 'Contacts' ListTile from main_drawer.dart | None | 15 min | Pending |
| remove_contacts_route | Remove /contacts route and sub-routes from app_router.dart | None | 30 min | Pending |
| add_members_section_ui | Add Members section to group_home_screen.dart with member preview | None | 1 hour | Pending |
| add_group_routes | Add /groups/detail/:groupId/members and /invite routes | remove_contacts_route | 30 min | Pending |

**Milestone**: Users see members section in group home (with placeholder data)

### Phase 2: Domain & Data Layer (Week 1-2)

| Task ID | Task Description | Dependencies | Effort | Status |
|---------|------------------|--------------|--------|--------|
| create_group_member_entity | Create GroupMember domain entity | None | 45 min | Pending |
| create_group_members_table | Create `group_members` junction table with RLS policies | None | 1.5 hours | Pending |
| extend_invitations_table | Extend `invitations` table with `group_id` column and updated RLS policy | create_group_members_table | 30 min | Pending |
| remove_member_ids_from_groups | **[Post-deployment]** Remove legacy `member_ids` from `groups` table | create_group_members_table | 30 min | Pending |
| create_group_members_provider | Create GroupMembersProvider for member data (using `group_members` table) | create_group_member_entity, create_group_members_table | 1.5 hours | Pending |
| update_group_detail_provider | Integrate member data into GroupDetailProvider | create_group_members_provider | 1 hour | Pending |

**Milestone**: Backend supports group invites, frontend can fetch member data from the new structure.

### Phase 3: Screen Development (Week 2)

| Task ID | Task Description | Dependencies | Effort | Status |
|---------|------------------|--------------|--------|--------|
| create_group_members_screen | Create group_members_screen.dart with full member list | create_group_member_entity, create_group_members_provider | 2 hours | Pending |
| create_group_invite_screen | Create group_invite_screen.dart adapted from invite_friends_screen.dart | update_invite_notifier | 3 hours | Pending |
| update_invite_notifier | Modify InviteFriendsNotifier for group context | extend_invitations_table | 1 hour | Pending |

**Milestone**: Users can view member lists and access group invite functionality

### Phase 4: Backend Integration (Week 2-3)

| Task ID | Task Description | Dependencies | Effort | Status |
|---------|------------------|--------------|--------|--------|
| update_send_invite_function | Modify send-invite function for group validation | extend_invitations_table | 1.5 hours | Pending |
| update_accept_invite_function | Update accept-invite to insert a row into the `group_members` table | extend_invitations_table | 1 hour | Pending |
| add_navigation_logic | Add navigation between members section, members screen, invite screen | All screen creation tasks | 45 min | Pending |

**Milestone**: Complete invite-accept-add flow functional

### Phase 5: Integration & Testing (Week 3)

| Task ID | Task Description | Dependencies | Effort | Status |
|---------|------------------|--------------|--------|--------|
| test_integration | Test end-to-end invite flow | All previous tasks | 2 hours | Pending |
| code_review | Clean Architecture compliance check | All tasks | 1 hour | Pending |
| ui_polish | Consistent styling and error handling | All UI tasks | 30 min | Pending |

**Milestone**: Production-ready group invite system

## Technical Specifications

### Database Changes
```sql
-- Migration: 20251120000000_create_group_members_table.sql
CREATE TABLE public.group_members (
    group_id uuid NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    role TEXT NOT NULL DEFAULT 'member', -- e.g., 'admin', 'member'
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (group_id, user_id)
);

-- Indexes for performance
CREATE INDEX idx_group_members_user_id ON public.group_members(user_id);

-- RLS policies for group_members table
CREATE POLICY "Group members can view other members" ON public.group_members
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.group_members gm
    WHERE gm.group_id = group_members.group_id AND gm.user_id = auth.uid()
  )
);

CREATE POLICY "Admins can manage members" ON public.group_members
FOR ALL USING (
  (SELECT role FROM public.group_members WHERE group_id = group_members.group_id AND user_id = auth.uid()) = 'admin'
);


-- Migration: 20251120000001_add_group_id_to_invitations.sql
ALTER TABLE public.invitations ADD COLUMN group_id uuid REFERENCES groups(id);
CREATE INDEX idx_invitations_group_id ON public.invitations(group_id);

-- RLS Policy for group invites on public.invitations
CREATE POLICY "Group members can create group invitations" ON public.invitations
FOR INSERT WITH CHECK (
  group_id IS NOT NULL AND
  EXISTS (
    SELECT 1 FROM public.group_members
    WHERE group_id = invitations.group_id AND
          user_id = auth.uid()
  )
);
```

### Key Entities

#### GroupMember
```dart
class GroupMember extends Equatable {
  final String userId;
  final String name;
  final String? avatarUrl;
  final String email;
  final DateTime joinedAt;
  final String role; // 'admin', 'member'

  const GroupMember({
    required this.userId,
    required this.name,
    this.avatarUrl,
    required this.email,
    required this.joinedAt,
    this.role = 'member',
  });

  @override
  List<Object?> get props => [userId, name, avatarUrl, email, joinedAt, role];
}
```

## Architecture Principles

### Clean Architecture Compliance
- **Presentation Layer**: Screens and widgets handle UI only
- **Domain Layer**: Business logic, entities, use cases
- **Data Layer**: Repositories, API calls, database interactions

### SOLID Principles
- **Single Responsibility**: Each class/screen has one clear purpose
- **Open/Closed**: Extending invite system rather than replacing
- **Dependency Inversion**: Abstract interfaces used throughout

## Risk Mitigation

1. **Data Migration**: A script will be needed to migrate existing `groups.member_ids` to the new `group_members` table. Test on staging before production.
2. **Breaking Changes**: Verify no other code depends on global contacts.
3. **User Experience**: Test complete invite flow, especially mobile deep linking.
4. **Backward Compatibility**: Existing app invites (`group_id` = null) must continue to work. Ensure RLS policies account for this.

## Success Criteria

- [ ] Users can access member management from group home screens
- [ ] Group invites successfully add members to the `group_members` table
- [ ] No regression in existing app functionality
- [ ] Code follows established Clean Architecture patterns
- [ ] Security: Only group members can send group invites

## Dependencies

- Flutter SDK
- Supabase (database, auth, functions)
- Existing Clean Architecture setup
- Provider for state management
- Go Router for navigation

## Notes

- Existing contacts functionality will be removed - ensure this aligns with product requirements.
- Group invites extend rather than replace the existing invite system.
- Member data is fetched by joining the `group_members` and `profiles` tables.
- Invite acceptance automatically adds users to the `group_members` table.
- A data migration script should be created to populate `group_members` from the existing `groups.member_ids` array before the `member_ids` column is removed.