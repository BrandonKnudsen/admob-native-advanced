# Capacitor AdMob Native Advanced Plugin

A Capacitor plugin for displaying Google AdMob Native Advanced Ads in Ionic and Angular applications. This plugin allows you to load native ads and render them using your own custom UI components, perfect for social media feeds and content walls.

## Features

- ✅ Load Native Advanced Ads from Google AdMob
- ✅ Extract ad assets (headline, body, images, call-to-action, etc.)
- ✅ Custom rendering in Angular components
- ✅ Click and impression tracking
- ✅ Support for both app install and content ads
- ✅ AdChoices compliance
- ✅ Cross-platform (iOS &amp; Android)
- ✅ TypeScript support
- ✅ Base64 encoded image data URLs for custom rendering

## Installation

### 1. Install the plugin

```bash
npm install @capacitor-community/admob-native-advanced
```

### 2. Add to your Capacitor project

```bash
npx cap sync
```

### 3. Platform-specific setup

#### Android

Add the following to your `android/app/src/main/AndroidManifest.xml`:

```xml
<application>
    <!-- Replace with your actual AdMob app ID -->
    <meta-data
        android:name="com.google.android.gms.ads.APPLICATION_ID"
        android:value="ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy" />
</application>
```

#### iOS

Add the following to your `ios/App/App/Info.plist`:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy</string>
```

## Usage

### 1. Initialize AdMob

```typescript
import { AdMobNativeAdvanced } from '@capacitor-community/admob-native-advanced';

// Initialize with your AdMob app ID
await AdMobNativeAdvanced.initialize({
  appId: 'ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy'
});
```

### 2. Load a Native Ad

```typescript
// Load a native ad
const adData = await AdMobNativeAdvanced.loadAd({
  adUnitId: 'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy'
});

console.log('Ad loaded:', adData);
// {
//   adId: "unique-ad-id",
//   headline: "Amazing Product",
//   body: "Discover the amazing features...",
//   callToAction: "Learn More",
//   advertiser: "Brand Name",
//   mediaContentUrl: "https://example.com/image.jpg",
//   iconUrl: "https://example.com/icon.jpg",
//   adChoicesIconUrl: "https://example.com/adchoices.png",
//   adChoicesText: "AdChoices",
//   isAppInstallAd: false,
//   isContentAd: true
// }
```

### 3. Create an Angular Component for Ad Rendering

```typescript
// native-ad.component.ts
import { Component, Input, Output, EventEmitter } from '@angular/core';
import { AdMobNativeAdvanced, NativeAdData } from '@capacitor-community/admob-native-advanced';

@Component({
  selector: 'app-native-ad',
  template: `
    <div class="native-ad" (click)="onAdClick()">
      <div class="ad-header">
        <img *ngIf="adData.iconUrl" [src]="adData.iconUrl" class="ad-icon" alt="Ad icon">
        <div class="ad-info">
          <h3 *ngIf="adData.headline" class="ad-headline">{{ adData.headline }}</h3>
          <p *ngIf="adData.advertiser" class="ad-advertiser">{{ adData.advertiser }}</p>
        </div>
        <div class="ad-choices">
          <img *ngIf="adData.adChoicesIconUrl" [src]="adData.adChoicesIconUrl" alt="AdChoices">
          <span>{{ adData.adChoicesText }}</span>
        </div>
      </div>
      
      <div *ngIf="adData.mediaContentUrl" class="ad-media">
        <img [src]="adData.mediaContentUrl" alt="Ad media">
      </div>
      
      <div class="ad-content">
        <p *ngIf="adData.body" class="ad-body">{{ adData.body }}</p>
        
        <div *ngIf="adData.isAppInstallAd" class="app-install-info">
          <span *ngIf="adData.store" class="store">{{ adData.store }}</span>
          <span *ngIf="adData.price" class="price">{{ adData.price }}</span>
          <div *ngIf="adData.starRating" class="rating">
            ⭐ {{ adData.starRating }}
          </div>
        </div>
      </div>
      
      <button *ngIf="adData.callToAction" class="ad-cta">
        {{ adData.callToAction }}
      </button>
    </div>
  `,
  styles: [`
    .native-ad {
      border: 1px solid #ddd;
      border-radius: 8px;
      padding: 16px;
      margin: 16px 0;
      background: white;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    
    .ad-header {
      display: flex;
      align-items: center;
      margin-bottom: 12px;
    }
    
    .ad-icon {
      width: 40px;
      height: 40px;
      border-radius: 8px;
      margin-right: 12px;
    }
    
    .ad-info {
      flex: 1;
    }
    
    .ad-headline {
      margin: 0;
      font-size: 16px;
      font-weight: 600;
    }
    
    .ad-advertiser {
      margin: 4px 0 0 0;
      font-size: 14px;
      color: #666;
    }
    
    .ad-choices {
      display: flex;
      align-items: center;
      font-size: 12px;
      color: #999;
    }
    
    .ad-choices img {
      width: 16px;
      height: 16px;
      margin-right: 4px;
    }
    
    .ad-media img {
      width: 100%;
      height: 200px;
      object-fit: cover;
      border-radius: 8px;
      margin-bottom: 12px;
    }
    
    .ad-body {
      margin: 0 0 12px 0;
      font-size: 14px;
      line-height: 1.4;
    }
    
    .app-install-info {
      display: flex;
      align-items: center;
      gap: 12px;
      margin-bottom: 12px;
      font-size: 14px;
    }
    
    .ad-cta {
      width: 100%;
      padding: 12px;
      background: #007bff;
      color: white;
      border: none;
      border-radius: 6px;
      font-size: 16px;
      font-weight: 600;
      cursor: pointer;
    }
    
    .ad-cta:hover {
      background: #0056b3;
    }
  `]
})
export class NativeAdComponent {
  @Input() adData!: NativeAdData;
  @Output() adClicked = new EventEmitter<void>();

  async onAdClick() {
    try {
      // Report click to AdMob
      await AdMobNativeAdvanced.reportClick(this.adData.adId);
      this.adClicked.emit();
    } catch (error) {
      console.error('Error reporting ad click:', error);
    }
  }

  ngOnInit() {
    // Report impression when ad is displayed
    this.reportImpression();
  }

  private async reportImpression() {
    try {
      await AdMobNativeAdvanced.reportImpression(this.adData.adId);
    } catch (error) {
      console.error('Error reporting ad impression:', error);
    }
  }
}
```

### 4. Use in a Social Media Feed

```typescript
// feed.component.ts
import { Component, OnInit } from '@angular/core';
import { AdMobNativeAdvanced, NativeAdData } from '@capacitor-community/admob-native-advanced';

@Component({
  selector: 'app-feed',
  template: `
    <div class="feed">
      <div *ngFor="let item of feedItems" class="feed-item">
        <ng-container [ngSwitch]="item.type">
          <app-post *ngSwitchCase="'post'" [post]="item.data"></app-post>
          <app-native-ad *ngSwitchCase="'ad'" [adData]="item.data" (adClicked)="onAdClicked()"></app-native-ad>
        </ng-container>
      </div>
    </div>
  `
})
export class FeedComponent implements OnInit {
  feedItems: Array<{ type: 'post' | 'ad', data: any }> = [];

  async ngOnInit() {
    // Initialize AdMob
    await AdMobNativeAdvanced.initialize({
      appId: 'ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy'
    });

    // Load your feed data
    await this.loadFeed();
  }

  async loadFeed() {
    // Load your posts
    const posts = await this.getPosts();
    
    // Load an ad
    const adData = await AdMobNativeAdvanced.loadAd({
      adUnitId: 'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy'
    });

    // Mix posts and ads
    this.feedItems = [
      { type: 'post', data: posts[0] },
      { type: 'ad', data: adData },
      { type: 'post', data: posts[1] },
      // ... more items
    ];
  }

  onAdClicked() {
    console.log('Ad was clicked!');
    // Handle ad click (e.g., open URL, track analytics)
  }

  private async getPosts() {
    // Your post loading logic
    return [];
  }
}
```

## API Reference

### Methods

#### `initialize(options: InitializeOptions): Promise<void>`

Initialize AdMob with your app ID.

**Parameters:**
- `options.appId` (string): Your AdMob app ID

#### `loadAd(options: LoadAdOptions): Promise<NativeAdData>`

Load a native advanced ad.

**Parameters:**
- `options.adUnitId` (string): Your AdMob ad unit ID

**Returns:** Promise with ad data including all available assets

#### `reportClick(adId: string): Promise<void>`

Report ad click to AdMob for tracking.

**Parameters:**
- `adId` (string): The ID of the ad that was clicked

#### `reportImpression(adId: string): Promise<void>`

Report ad impression to AdMob for tracking.

**Parameters:**
- `adId` (string): The ID of the ad that was shown

### Types

#### `NativeAdData`

```typescript
interface NativeAdData {
  adId: string;                    // Unique ad identifier
  headline?: string;               // Ad headline/title
  body?: string;                   // Ad body text
  callToAction?: string;           // Call-to-action text
  advertiser?: string;             // Advertiser name
  store?: string;                  // App store name (app install ads)
  price?: string;                  // App price (app install ads)
  starRating?: number;             // Star rating (app install ads)
  mediaContentUrl?: string;        // Main ad image (base64 data URL) or video URL (iOS only)
  iconUrl?: string;                // Ad icon URL
  adChoicesIconUrl?: string;       // AdChoices icon URL
  adChoicesText?: string;          // AdChoices text
  isAppInstallAd?: boolean;        // Whether this is an app install ad
  isContentAd?: boolean;           // Whether this is a content ad
}
```

## Test Ad Unit IDs

Use these test ad unit IDs for development:

- **Android Native Advanced:** `ca-app-pub-3940256099942544/2247696110`
- **iOS Native Advanced:** `ca-app-pub-3940256099942544/3985214057`

## Best Practices

### 1. Ad Placement
- Place ads naturally within your content feed
- Don't place too many ads close together
- Follow AdMob's [Native Ad Policy](https://support.google.com/admob/answer/6239795)

### 2. Ad Labeling
- Always include "Ad" or "Sponsored" label
- Display AdChoices icon prominently
- Make it clear to users that content is promotional

### 3. Error Handling
```typescript
try {
  const adData = await AdMobNativeAdvanced.loadAd({
    adUnitId: 'your-ad-unit-id'
  });
  // Handle successful ad load
} catch (error) {
  console.error('Failed to load ad:', error);
  // Handle ad load failure (e.g., show fallback content)
}
```

### 4. Performance
- Load ads asynchronously
- Don't block UI while loading ads
- Implement proper error handling for failed ad loads
- Note: On Android, video ads are not currently supported for custom rendering; only image ads will have mediaContentUrl.

## Troubleshooting

### Common Issues

1. **"AdMob must be initialized" error**
   - Ensure you call `initialize()` before `loadAd()`
   - Check that your app ID is correct

2. **"Ad failed to load" error**
   - Verify your ad unit ID is correct
   - Check your internet connection
   - Ensure you're using test ad unit IDs during development

3. **Ads not showing on iOS**
   - Check that you've added the GADApplicationIdentifier to Info.plist
   - Verify your iOS deployment target is 13.0 or higher

4. **Ads not showing on Android**
   - Check that you've added the APPLICATION_ID metadata to AndroidManifest.xml
   - Verify your minSdkVersion is 21 or higher

### Debug Mode

Enable debug logging by adding this to your app initialization:

```typescript
// For development only
if (environment.production === false) {
  // Android debug
  // Add to your Android activity
  MobileAds.setRequestConfiguration(
    new RequestConfiguration.Builder()
      .setTestDeviceIds(Arrays.asList("TEST_DEVICE_ID"))
      .build()
  );
  
  // iOS debug
  // Add to your iOS app delegate
  GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["TEST_DEVICE_ID"];
}
```

## License

MIT License - see LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

For support, please open an issue on GitHub or check the [AdMob documentation](https://developers.google.com/admob). 