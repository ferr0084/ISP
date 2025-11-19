create or replace function search_users_not_in_group(p_group_id uuid, p_search_term text)
returns setof profiles as $$
  select *
  from profiles
  where (full_name ilike '%' || p_search_term || '%' or email ilike '%' || p_search_term || '%')
  and id not in (
    select user_id from group_members where group_id = p_group_id
  );
$$ language sql;
