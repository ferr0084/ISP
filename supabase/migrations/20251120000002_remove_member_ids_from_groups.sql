-- Migration: 20251120000002_remove_member_ids_from_groups.sql
ALTER TABLE public.groups
DROP COLUMN IF EXISTS member_ids;
