# CommunityCare FoodShare

A Flutter mobile app that connects food donors with recipients in the local community — donors publish surplus food, recipients browse and request it, and both sides track pickup through to completion.

Built for [module code / course name] as a group project.

## Team and Modules

| Member | Module | Screens |
|---|---|---|
| Member 1 | Authentication and Home | Splash, Login, Registration, Home |
| Member 2 | Food Discovery | Available Donations (Browse), Donation Details |
| Member 3 | Donor and Donation Management | Add Donation, My Donations, Edit Donation |
| Member 4 | Food Request and Pickup | My Requests, Request Confirmation, Pickup Details |
| Member 5 | Notifications, Profile and Integration | Notifications, Profile, Edit Profile, About and Help |

## Features

- Donor and recipient registration and login
- Browse, search and filter available food donations by category, location and expiry
- Publish, edit and manage donations with photo, quantity and pickup details
- Request a donation and track its status through to pickup
- Notifications for donation activity, request approvals and pickup reminders
- Profile management for both donors and recipients

## Tech Stack

- Flutter / Dart
- Material 3 design system
- [Firebase Auth + Firestore / your actual backend — confirm and fill in]
- Packages used: `image_picker`, `intl`, `path_provider`, `shared_preferences`

## Project Structure

```text
lib/
├── main.dart
├── models/          # Data models (Donation, Request, User, etc.)
├── screens/         # One file per screen, grouped by module
├── services/         # Repositories / data access (e.g. DonationRepository)
├── utils/           # Theme, helpers
└── widgets/         # Shared/reusable UI components
```

## Setup Instructions

1. Install Flutter (SDK >=3.3.0) — see [flutter.dev/get-started](https://docs.flutter.dev/get-started/install).
2. Clone the repository or unzip the project folder.
3. From the project root, install dependencies:

   ```bash
   flutter pub get
   ```

4. [If using Firebase: add your own `google-services.json` (Android) and `GoogleService-Info.plist` (iOS), or describe your actual backend setup here.]
5. Run the app on a connected device or emulator:

   ```bash
   flutter run
   ```

### iOS camera/photo permissions

If prompted, add the following to `ios/Runner/Info.plist` (already required by the donation photo upload feature):

```xml
<key>NSCameraUsageDescription</key>
<string>FoodShare uses the camera to photograph a food donation.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>FoodShare uses the photo library to add a food donation image.</string>
```

## Known Limitations

- [List anything still placeholder/incomplete at submission time — e.g. donor contact button, map view, push notifications — so the marker knows it's intentional, not a bug.]

## Repository / Submission Contents

This submission includes:
- Complete Flutter project source (`lib/`, `pubspec.yaml`, `assets/`)
- Final group report (PDF)
- Individual reflection and contribution reports (PDF, one per member)
- Video presentation / demonstration link
