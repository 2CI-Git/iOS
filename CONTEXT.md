# CONTEXT.md

Orientation document for the 2CI app. Read this first, before touching code.

Last updated: October 26, 2026, at the point Mark Schindler picked the project back up.

---

## 1. What 2CI is

The Second Circle Institute is a private, invitation-only leadership development network for VPs, Directors, and senior operators just below the C-suite. Members go through a cohort-based accelerator (Denver, Scottsdale, Charlotte, with Nashville following) and stay connected afterward.

Mark Schindler founded it and is the product lead on this app.

## 2. What this app is for

Senior leaders do not need another professional network. They need a trusted room that remembers who they are, what they are working through, and who else has lived a version of the same problem.

The app makes that room persistent between cohort sessions. The bar is high: members are SaaS operators who notice everything, and the design target has always been "whoa, this is awesome," not "functional."

Two principles that have driven every decision so far:

- Human content over algorithmic noise. No engagement theater.
- When in doubt, do less. A smaller app members actually use beats a bigger one they do not.

## 3. Repository layout

The project lives in the `2CI-Git` GitHub organization across three repos.

| Repo | Status | What it holds |
|---|---|---|
| `iOS` | Active | This repo. Native SwiftUI iPhone app. |
| `backend` | Active | Supabase schema, migrations, seeds, and data/auth docs. Source of truth for the data contract. |
| `app` | Archived | An earlier TypeScript web attempt, abandoned June 25, 2026. Do not build on it. |

The split is deliberate: the backend repo owns the contract, the iOS app consumes it. Schema changes start in `backend`.

## 4. Current state

Built by Ryan Wilson across three working sessions: June 6, June 11, and July 23, 2026. All sixteen commits to date are his. Work paused after July 23.

### Built and working

- Native launch screen and branded in-app splash
- Supabase magic-link authentication
- First-run onboarding flow for profile completion
- Feed with post detail, replies, and member post composition
- Member directory with filter modes
- Rich member profile detail
- Cohort view with cohort identity and member context
- Profile and settings screen with notification preferences

### Not built yet

- Messaging and DMs. The original PRD flagged this as the hardest piece and the first architectural decision to make (build vs. embed a service like Stream or Sendbird). It remains undecided and unstarted.
- Events, and the travel flag feature ("I am in Chicago next week, who else is around")
- Content library for Mark's material
- Push notifications. The preference toggles exist in the UI, but there is no APNs integration behind them.
- Admin portal
- LinkedIn OAuth for profile seeding
- Calendly. Currently a link on the profile screen, not an integration.

## 5. Architecture

### iOS

SwiftUI, targeting iOS 17+, built with Xcode 15+. Project file: `TwoCi.xcodeproj`.

| File | Role |
|---|---|
| `TwoCiApp.swift` | App entry point |
| `ContentView.swift` | Root view, tab navigation, and the data loading decision |
| `AuthManager.swift` | Supabase magic-link auth and session state |
| `AuthView.swift` | Sign-in screen |
| `SupabaseConfig.swift` | Project URL, publishable key, request headers |
| `SupabaseDataService.swift` | Live data fetching from Supabase |
| `MockServices.swift` | `MockDataStore`, the demo dataset |
| `Models.swift` | Core types: Member, FeedPost, Cohort, and related |
| `FeedView.swift`, `FeedDetailView.swift`, `ComposePostView.swift` | Feed surface |
| `DirectoryView.swift` | Member directory and filtering |
| `ProfileView.swift` | Member profile and settings |
| `CohortView.swift` | Cohort identity and stats |
| `OnboardingView.swift` | First-run profile completion |
| `SplashView.swift`, `Components.swift`, `AppTheme.swift` | Branding and shared UI |

### Backend

Supabase Postgres with Supabase Auth and row-level security. Seven tables:

`cohorts`, `member_profiles`, `affinity_labels`, `member_affinity_labels`, `feed_posts`, `feed_replies`, `notification_preferences`

Migrations live in `backend/supabase/migrations/`. They are currently applied by hand through the Supabase dashboard SQL editor rather than the Supabase CLI.

### The mock data fallback

This is the most important thing to understand about the current code, and the easiest thing to be misled by.

`ContentView.loadSupabaseDataIfAvailable()` attempts to load real data when a user is authenticated. If anything at all goes wrong, it silently falls back to `MockDataStore` and sets a `dataSourceMessage` string. There is no error surfaced to the developer or the user.

This was a reasonable choice for building UI before the backend contract settled. It is now a liability: a working app on mock data and a working app on live data look identical. Anyone picking this up should make the data source unmistakable before trusting any backend work.

## 6. Known issues and open decisions

1. **Silent fallback masks backend failures.** See above. Fix this first.
2. **RLS coverage is incomplete.** There are twelve policies across seven tables. The iOS app ships the Supabase publishable key in source, which is by design (that key is meant to be public), but it means row-level security is the only thing protecting member data. Audit every table before real member data goes in.
3. **Messaging is undecided.** Build vs. embed. This is the biggest remaining architectural fork.
4. **Migrations are applied by hand.** Moving to the Supabase CLI would make the schema reproducible.
5. **Henry's role.** The original plan paired Ryan (design engineer, frontend) with Henry (M.S. in AI, backend and AI features). Henry has no commits in either repo. The AI layer described in the PRD has not been started.
6. **No tests.** None anywhere.

## 7. Running it

```
git clone https://github.com/2CI-Git/ios
open TwoCi.xcodeproj
```

Select the `TwoCi` scheme, choose an iPhone simulator, build and run. It will come up on mock data with no backend configuration required.

Requires a Mac with Xcode 15 or newer.

## 8. Conventions

- Feature branches and pull requests, not commits straight to main. Ryan's existing branch names follow `feature/<short-description>`.
- The backend repo owns the data contract. Schema changes start there.
- Never commit Supabase `service_role` keys or other production secrets. The publishable key in `SupabaseConfig.swift` is intentionally public and is not an exception to this rule.
- iOS only. Android is a later question, driven by member demand.
- The app is for members only. Prospects and guests are handled outside it, on Squarespace and email. The velvet rope is a product decision, not an oversight.

## 9. Suggested next moves

In order, smallest to largest:

1. Get it building locally and confirm it runs on the simulator.
2. Make the data source visible. Replace the silent fallback with an explicit, obvious indicator and real error logging.
3. Audit RLS policies across all seven tables.
4. Verify the live Supabase path end to end with a real test member: sign in by magic link, confirm the feed and directory are reading from Postgres rather than mocks.
5. Decide messaging: build or embed.
6. Then pick the next feature from the not-yet-built list based on what members would actually use first.

Steps 1 through 4 are orientation and hardening. Do not start step 6 before step 4 is done, or you will be building new features on a foundation you have not confirmed works.
