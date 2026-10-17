# CommunityCare FoodShare

A Flutter group project exploring how people could offer surplus food and arrange pickups. It includes donor and recipient flows, donation listings and pickup requests.

## What is included

Donors can create listings with food details, quantity, expiry information and a photo. Recipients can browse donations and request a pickup. The app also has request statuses, notifications and profile screens.

This version stores its records locally using SharedPreferences. It is a prototype on one device, not a shared service where separate phones exchange live donations.

## Run locally

Install Flutter, then run these commands from the project folder:

```sh
flutter pub get
flutter run
```

No cloud backend is required for the current local prototype.

## Project structure

The repositories in `lib/services/` handle donations, requests, notifications and profiles. `lib/providers/` contains authentication state, and `lib/main.dart` sets up the app.

This repository contains the combined group project. A shared service would need a backend, real account authentication and testing across devices.
