# Setup Guide for AdMob Native Advanced Plugin

This guide will walk you through setting up the complete Capacitor plugin for Google AdMob Native Advanced Ads.

## Prerequisites

- Node.js 16+ and npm
- Git
- Android Studio (for Android development)
- Xcode (for iOS development)
- Firebase CLI (for backend functions)

## Step 1: Create GitHub Repository

```bash
# Initialize git repository
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: AdMob Native Advanced Plugin"

# Create GitHub repository and push
# (Do this on GitHub.com first, then:)
git remote add origin https://github.com/yourusername/admob-native-advanced.git
git branch -M main
git push -u origin main
```

## Step 2: Build the Plugin

```bash
# Install dependencies
npm install

# Build TypeScript
npm run build

# Verify build output
ls dist/
```

## Step 3: Test in a Capacitor App

### Create a test Ionic app:

```bash
# Create new Ionic app
ionic start test-admob-app tabs --type=angular

cd test-admob-app

# Add Capacitor
ionic cap add android
ionic cap add ios

# Install the plugin locally
npm install ../path/to/admob-native-advanced

# Sync Capacitor
ionic cap sync
```

### Update the test app:

1. **Add to `src/app/app.component.ts`:**
```typescript
import { Component } from '@angular/core';
import { AdMobNativeAdvanced } from '@brandonknudsen/admob-native-advanced';

@Component({
  selector: 'app-root',
  templateUrl: 'app.component.html',
  styleUrls: ['app.component.scss'],
})
export class AppComponent {
  constructor() {
    this.initializeAdMob();
  }

  async initializeAdMob() {
    try {
      await AdMobNativeAdvanced.initialize({
        appId: 'ca-app-pub-3940256099942544~3347511713' // Test app ID
      });
      console.log('AdMob initialized successfully');
    } catch (error) {
      console.error('Failed to initialize AdMob:', error);
    }
  }
}
```

2. **Add to `src/app/tab1/tab1.page.ts`:**
```typescript
import { Component } from '@angular/core';
import { AdMobNativeAdvanced, NativeAdData } from '@brandonknudsen/admob-native-advanced';

@Component({
  selector: 'app-tab1',
  templateUrl: 'tab1.page.html',
  styleUrls: ['tab1.page.scss'],
})
export class Tab1Page {
  adData: NativeAdData | null = null;

  async loadAd() {
    try {
      this.adData = await AdMobNativeAdvanced.loadAd({
        adUnitId: 'ca-app-pub-3940256099942544/2247696110' // Test ad unit ID
      });
      console.log('Ad loaded:', this.adData);
    } catch (error) {
      console.error('Failed to load ad:', error);
    }
  }
}
```

3. **Update `src/app/tab1/tab1.page.html`:**
```html
<ion-header [translucent]="true">
  <ion-toolbar>
    <ion-title>
      AdMob Native Advanced Test
    </ion-title>
  </ion-toolbar>
</ion-header>

<ion-content [fullscreen]="true">
  <ion-header collapse="condense">
    <ion-toolbar>
      <ion-title size="large">AdMob Test</ion-title>
    </ion-toolbar>
  </ion-header>

  <div class="container">
    <ion-button (click)="loadAd()">Load Native Ad</ion-button>
    
    <div *ngIf="adData" class="native-ad">
      <h3>{{ adData.headline }}</h3>
      <p>{{ adData.body }}</p>
      <img *ngIf="adData.mediaContentUrl" [src]="adData.mediaContentUrl" alt="Ad media">
      <button>{{ adData.callToAction }}</button>
    </div>
  </div>
</ion-content>
```

## Step 4: Platform-Specific Configuration

### Android Setup

1. **Update `android/app/src/main/AndroidManifest.xml`:**
```xml
<application>
    <!-- Add your AdMob app ID -->
    <meta-data
        android:name="com.google.android.gms.ads.APPLICATION_ID"
        android:value="ca-app-pub-3940256099942544~3347511713" />
</application>
```

2. **Test on Android:**
```bash
ionic cap run android
```

### iOS Setup

1. **Update `ios/App/App/Info.plist`:**
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-3940256099942544~3347511713</string>
```

2. **Test on iOS:**
```bash
ionic cap run ios
```

## Step 5: Deploy Backend Functions (Optional)

### Setup Firebase:

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase project
cd backend
firebase init functions

# Deploy functions
firebase deploy --only functions
```

### Configure Firestore:

Create the following collections in Firestore:

1. **`admob-configs`** - Store app configurations
2. **`ad-analytics`** - Store ad performance data
3. **`ab-tests`** - Store A/B test configurations

Example document in `admob-configs`:
```json
{
  "appId": "ca-app-pub-3940256099942544~3347511713",
  "adUnitIds": {
    "android": "ca-app-pub-3940256099942544/2247696110",
    "ios": "ca-app-pub-3940256099942544/3985214057"
  },
  "testMode": true,
  "refreshInterval": 300
}
```

## Step 6: Publish to npm

```bash
# Login to npm
npm login

# Publish package
npm publish

# Or publish with scope
npm publish --access public
```

## Step 7: Create Release

1. **Update version in `package.json`**
2. **Create git tag:**
```bash
git tag v1.0.0
git push origin v1.0.0
```

3. **Create GitHub release with:**
   - Release notes
   - Installation instructions
   - Usage examples

## Testing Checklist

- [ ] Plugin builds successfully
- [ ] TypeScript definitions are correct
- [ ] Android ad loads and displays
- [ ] iOS ad loads and displays
- [ ] Click tracking works
- [ ] Impression tracking works
- [ ] Error handling works
- [ ] Web fallback works
- [ ] Documentation is complete

## Troubleshooting

### Common Issues:

1. **"Plugin not found" error:**
   - Run `ionic cap sync` after installing
   - Check plugin is in `package.json`

2. **"AdMob not initialized" error:**
   - Ensure `initialize()` is called before `loadAd()`
   - Check app ID is correct

3. **Ads not loading:**
   - Use test ad unit IDs during development
   - Check internet connection
   - Verify platform-specific setup

4. **Build errors:**
   - Check all dependencies are installed
   - Verify TypeScript configuration
   - Ensure Capacitor version compatibility

## Next Steps

1. **Add unit tests** using Jest
2. **Add integration tests** using Cypress
3. **Set up CI/CD** with GitHub Actions
4. **Add more ad formats** (Banner, Interstitial)
5. **Implement ad mediation** support
6. **Add analytics dashboard** for ad performance

## Support

For issues and questions:
- Create GitHub issue
- Check AdMob documentation
- Review Capacitor plugin guidelines 