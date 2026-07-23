# 2CI Supabase Data Model v0

This document captures the first backend contract for the 2CI iOS app. It is intentionally narrow: enough to support invite-only auth, onboarding/profile completion, directory, feed, replies, cohorts, and notification preferences.

## Supabase Project

- Project URL: `https://rpdnwkpenataotqiejxq.supabase.co`
- Client key type: publishable key
- Client key location: `TwoCi/SupabaseConfig.swift`

Do not place the Supabase `service_role` key in the iOS app or repository. It should only be used in trusted server/admin environments.

## Auth Recommendation

2CI should start as invite-only.

- Use Supabase Auth for user identity.
- Use email magic links / OTP for v1.
- Add Sign in with Apple before App Store submission if required.
- Disable open public signup unless an invite exists.
- Store member-facing data in `public.member_profiles`, linked to `auth.users.id`.

## Core Tables

### `member_profiles`

The profile row for each authenticated user.

Key fields:

- `id`
- `user_id`
- `role`
- `name`
- `title`
- `company`
- `city`
- `cohort_id`
- `function`
- `challenge`
- `email`
- `onboarding_completed_at`
- `is_active`

### `cohorts`

Named cohorts and Council grouping.

### `affinity_labels`

Directory/filter labels such as Product, Operations, Sales, Denver, Series B, Scaling Challenges.

### `member_affinity_labels`

Join table between members and affinity labels.

### `feed_posts`

Human-created feed items.

Allowed v1 types:

- `prompt`
- `update`
- `resource`
- `milestone`

### `feed_replies`

Text replies to feed posts.

### `notification_preferences`

Per-member preference rows for feed activity, direct messages, travel flags, and coaching nudges.

## RLS Principles

Enable Row Level Security on every public table used by the app.

Baseline v1 policy:

- Authenticated users can read active member profiles, cohorts, affinity labels, feed posts, and feed replies.
- Members can update only their own profile.
- Members can manage only their own affinity labels.
- Members can create feed posts and replies only as themselves.
- Members can update their own notification preferences.
- Admin/Mark actions should go through a trusted server/admin path or explicit admin policies.

## Open Questions

- Should invites live in Supabase only, or be managed by an admin portal service?
- Does Council see all cohorts/channels by default?
- Do profiles expose raw email/phone, or should contact always route through platform actions?
- Should vulnerability prompts be `feed_posts` with type `prompt`, or a separate scheduled prompt table?
- Should feed posts be global-only in v1, or scoped by cohort/affinity/channel earlier?
