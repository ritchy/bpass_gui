# password_manager

A simple password manager.

## Getting Started

flutter create password_manager
cd password_manager
flutter analyze
flutter test
flutter run lib/main.dart
flutter pub get table_sticky_headers
flutter pub get
flutter pub outdated
flutter pub upgrade


## Passing Arguments
flutter run -d macOS --dart-entrypoint-args searchTerm

This project is a starting point for a Flutter application that follows the
[simple app state management
tutorial](https://flutter.dev/docs/development/data-and-backend/state-mgmt/simple).


## Dependency notes

https://pub.dev/packages/pointycastle 

## Assets

The `assets` directory houses images, fonts, and any other files you want to
include with your application.

The `assets/images` directory contains [resolution-aware
images](https://flutter.dev/docs/development/ui/assets-and-images#resolution-aware).

## Localization

This project generates localized messages based on arb files found in
the `lib/src/localization` directory.

To support additional languages, please visit the tutorial on
[Internationalizing Flutter
apps](https://flutter.dev/docs/development/accessibility-and-localization/internationalization)



## Dependencies

dependencies:
  args: ^2.3.1
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  table_sticky_headers: ^2.0.2
  provider: ^6.0.0
  desktop_window: ^0.4.0
  path_provider: ^2.0.11
  flutter_widget_offset: ^1.1.0
  googleapis_auth: ^1.3.1
  googleapis: ^9.2.0
  intl: ^0.17.0
  url_launcher: ^6.1.5
  http: ^0.13.5
  _discoveryapis_commons: ^1.0.3
  logging: ^1.1.0
  pointycastle: ^3.6.2
  encrypt: ^5.0.1


## Building for Testflight

bump up version/build number in pubspec.yaml
flutter build ipa
Upload (build/ios/ipa/*.ipa) via Transporter (https://apps.apple.com/us/app/transporter/id1450874784?mt=12)
Head to app store connect https://appstoreconnect.apple.com/
Go to "builds" and complete encryption delcaration ("missing compliance" warning)
Open up TestFlight and update/install





## Requesting access to share google Drive file
https://console.cloud.google.com/apis/credentials/consent?pli=1


access.json
[
    client {
        client_id : 121212,
        client_name : "iphone",
        last_updated: 121211212121,
        public_key: "kajdflkajdflkasdj;fl;jadsfklajdsf",
        access_status: "requested/granted/denied",
        encrypted_access_key: "lkajdf;adfkjdjfa"
    },
    client {},
]
