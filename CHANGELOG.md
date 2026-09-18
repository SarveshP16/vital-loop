# Changelog

All notable changes to Vital Loop are documented here.

## [Unreleased]

### Added

- Initial app scaffold: Flutter + Riverpod (plain `Notifier`s, no code-gen) + go_router (`StatefulShellRoute`, Home/Stats/Settings bottom nav) + Hive for local, offline-first storage.
- **Home** screen matching the supplied mockup: a "Next up" banner showing the soonest reminder across all activities with a live countdown, the first activity rendered as a full-width progress-bar hero card, and every other activity as a square grid card with a `+amount` log button. A streak pill (top right) counts consecutive days every scheduled activity's daily goal was fully met.
- **Stats** screen: one card per activity showing its real logged total for whichever period (Daily/Weekly/Monthly) that activity was configured to feature — summed from actual daily logs, not a projected target.
- **Settings** screen: add/edit/delete activities (icon via the device's own emoji keyboard, name, a predefined unit dropdown, per-reminder amount, daily goal, a per-activity active-hours window, which stats period to feature, and which days of the week to remind on).
- **Automatic reminder scheduling**: no user-set interval — the number of reminders per day is computed as `ceil(dailyGoal / perReminderAmount)` and spread evenly across the activity's active-hours window. Reminders for the rest of the day are cancelled automatically once the daily goal is met.
- **Office day toggle**: mutes all reminders and excludes the day from Stats/streak; automatically stops applying the next day with no action needed.
- **On trip toggle**: same muting effect as Office day, but persists across multiple days until manually switched off.
- Three default activities (Water, Push-ups, Squats) seeded on first launch to match the mockup out of the box — fully editable/deletable afterwards like any user-added activity.
- Notifications via `flutter_local_notifications`, scheduled as one-off exact alarms for the current day only (re-evaluated on every log, activity edit, app launch, and app resume). Applied the known Android manifest gotchas up front: explicit `ScheduledNotificationReceiver`/`ScheduledNotificationBootReceiver` declarations and `AndroidScheduleMode.exactAllowWhileIdle`.
- Real adaptive app icon (all densities + Play Store icon).
- Windows cross-drive Kotlin incremental-compiler crash worked around via `kotlin.incremental=false` (project lives on `E:`, pub cache on `C:`), and core library desugaring enabled for `flutter_local_notifications`.
- Signed release build support (`android/key.properties`, gitignored; `key.properties.example` as the template) with a custom `VitalLoop-<version>-release.apk` output name.
- MIT license, and a README with features, screenshots, and build instructions.

### Fixed

- Home didn't reflect a logged `+amount` until the app was restarted — caused by watching `dailyLogsProvider.notifier` (the Notifier instance, which never changes identity) instead of `dailyLogsProvider` itself (the state).

### Known gaps

- Notification permission request happens once automatically on first launch; there's no in-app way to preview/test a reminder without waiting for one to actually fire.
- No dark mode, data export/import, or app lock yet.
