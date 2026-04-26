# BankaiBuddy App Store Checklist

This branch moves the app closer to a TestFlight/App Store candidate, but a few release items still need owner input in Apple Developer and App Store Connect.

## Required Before Submission

- Apple Developer Team selected in Xcode Signing & Capabilities.
- Bundle ID confirmed: `TonyB-224.BankaiBuddy`.
- Firebase iOS app registered for the final bundle ID.
- Privacy Policy URL added in App Store Connect.
- App privacy answers completed for Firebase Auth, Firestore, and Jikan API usage.
- Support URL and marketing URL prepared.
- App Store screenshots captured on real simulator/device sizes.
- Review notes mention that anime metadata and streaming links come from Jikan/MyAnimeList data.

## Current Data Practices To Declare

- Email address: collected for account authentication.
- User content: watched, watchlist, and favorites list entries are stored per user in Firestore.
- Diagnostics/analytics: declare if Firebase Analytics remains linked in the target.
- Third-party content/API: Jikan API is used for anime metadata, posters, genres, and streaming provider links.

## In-App Compliance Work Added

- Account deletion is available from Profile.
- Delete account flow removes saved list documents before deleting the Firebase Auth user.
- Profile explains core cloud-sync behavior and current privacy-policy readiness.
- App icon catalog now has light, dark, and tinted 1024px assets.

## Manual QA Pass

- Create a new account.
- Search for an anime and add it to all three lists.
- Confirm Library tabs update.
- Open a detail sheet and verify watch links open the correct provider.
- Sign out and sign back in; confirm lists reload.
- Delete the account; confirm the user returns to sign-on and data is gone.
- Test weak network states on Home and Search.
