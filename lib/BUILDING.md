# Building the XC610 Pro App

## Get an unsigned IPA (no Mac needed)

This repo includes a GitHub Actions workflow that builds the app on a real Mac
in the cloud and produces a downloadable unsigned IPA.

### Steps

1. **Push this repo to GitHub**
   - Create a free account at [github.com](https://github.com) if you don't have one
   - Create a new repository (can be private)
   - Upload or push the project files

2. **Trigger the build**
   - Go to your repo → **Actions** tab
   - Click **"Build iOS IPA"** in the left sidebar
   - Click **"Run workflow"** → **"Run workflow"**
   - Wait ~5–10 minutes for the Mac runner to finish

3. **Download the IPA**
   - Click the completed workflow run
   - Scroll down to **Artifacts**
   - Download **xc610-unsigned-ipa**
   - Unzip it — you'll find `xc610-unsigned.ipa` inside

4. **Sign and install**
   - Sign the IPA using your signing service (AltStore, Sideloadly, ESign, etc.)
   - Install on your iPhone

---

## Build locally (needs macOS + Xcode)

```bash
cd flutter
flutter pub get
flutter build ios --release --no-codesign

# Package into IPA manually
mkdir -p build/ios/ipa/Payload
cp -r build/ios/iphoneos/Runner.app build/ios/ipa/Payload/
cd build/ios/ipa && zip -r xc610-unsigned.ipa Payload/
```

---

## App details

| Item | Value |
|---|---|
| Bundle ID | `com.xc610.xc610Controller` |
| Min iOS | 12.0 |
| BLE Service | `FF10` |
| Write characteristic | `FF12` |
| Notify characteristic | `FF11` |
| Protocol | `A0`-prefix packets (DayBetter) |
