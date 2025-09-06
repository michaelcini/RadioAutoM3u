
# RadioAutoM3U

Flutter radio app that plays M3U links and exposes stations to Android Auto via a MediaBrowserService (using audio_service + just_audio).

## Features
- Add an M3U playlist URL or a direct stream URL.
- Stations saved locally.
- Background playback with notification.
- Android Auto support: visible in the Auto launcher as a media app.

## Build (APK)
```bash
flutter pub get
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```
For debug run:
```bash
flutter run
```

## Test in Android Auto (Desktop Head Unit)
- Enable developer mode in Android Auto on your phone and use Google's DHU to test.
- Make sure your app is installed on the phone; you should see "Radio Auto" in the media apps list.


## Added features
- OPML and PLS parsing support (import lists).
- HLS (.m3u8) streams supported (just_audio handles HLS).
- Voice search support: Android Auto voice queries call `playFromSearch` which matches station names or URLs.
- Assets: placeholder icon and station logos folder.
- Improved detection/merge when adding links.

## Notes on Car App Library
A full Car App Library (AndroidX `car-app` library) requires native Android modules and manifest entries; this project includes an Android Auto-compatible MediaBrowserService path (recommended) and `automotive_app_desc.xml`. For most media apps this is sufficient to appear in Android Auto. If you need a separate `car-app` module for the new Car App Library UI, I can also add a native Android module skeleton (Kotlin) that demonstrates it.
# Test
