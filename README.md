# Capacitor AdMob Native Advanced Plugin

A Capacitor plugin for displaying Google AdMob Native Advanced Ads in Ionic and Angular applications with a **hybrid approach**: native iOS rendering for proper click tracking and JavaScript rendering for Android/web. Perfect for social media feeds and content walls.

## Features

- ✅ **Hybrid Rendering Approach**
  - **iOS**: Native `GADNativeAdView` overlays with automatic click/impression tracking
  - **Android**: JavaScript rendering with programmatic tracking
  - **Web**: Mock data for development
- ✅ Load Native Advanced Ads from Google AdMob
- ✅ Extract ad assets (headline, body, images, call-to-action, etc.)
- ✅ **iOS Native Overlays** - Seamless integration with webview positioning
- ✅ **Custom Styling System** - Match your app's design perfectly
- ✅ **Automatic Click Handling** - iOS SDK handles URL/app store opening
- ✅ **Automatic Impression Tracking** - No manual reporting needed on iOS
- ✅ Support for both app install and content ads
- ✅ AdChoices compliance with proper positioning
- ✅ Cross-platform (iOS & Android)
- ✅ TypeScript support with comprehensive interfaces
- ✅ Base64 encoded image data URLs for custom rendering
- ✅ **Responsive Positioning** - Handles scroll, resize, and orientation changes

## Why Hybrid Approach?

**iOS Issue**: Google Mobile Ads SDK v11+ requires native `GADNativeAdView` components for proper click tracking and URL opening. Extracting assets to JavaScript breaks this functionality.

**Our Solution**: 
- **iOS**: Load ads natively, render in `GADNativeAdView`, overlay on webview
- **Android**: Keep existing JavaScript rendering for simplicity
- **Result**: Native behavior on iOS, consistent experience across platforms

## Installation

### 1. Install the plugin

```bash
npm install @brandonknudsen/admob-native-advanced
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
import { AdMobNativeAdvanced } from '@brandonknudsen/admob-native-advanced';

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
//   mediaContentUrl: "data:image/png;base64,iVBORw0KGgoAAAANSU...",
//   iconUrl: "data:image/png;base64,iVBORw0KGgoAAAANSU...",
//   adChoicesIconUrl: "data:image/png;base64,iVBORw0KGgoAAAANSU...",
//   adChoicesText: "AdChoices",
//   isAppInstallAd: false,
//   isContentAd: true,
//   nativeRendered: true  // iOS only
// }
```

### 3. Create a Hybrid Angular Component

```typescript
// native-ad.component.ts
import { Component, Input, ViewChild, ElementRef, AfterViewInit, OnDestroy, ChangeDetectorRef } from '@angular/core';
import { AdMobNativeAdvanced, NativeAdData } from '@brandonknudsen/admob-native-advanced';
import { Capacitor } from '@capacitor/core';

@Component({
  selector: 'app-native-ad',
  template: `
    <div class="native-ad-container" [class.ios-native]="isIOS" *ngIf="adData">
      <!-- iOS: Hidden placeholder for native overlay positioning -->
      <div 
        #adPlaceholder 
        class="native-ad-placeholder"
        [style.visibility]="isIOS && adData ? 'hidden' : 'visible'">
        
        <!-- Android/Web: Rendered in HTML -->
        <div class="native-ad" *ngIf="!isIOS" (click)="onAdClick()">
          <div class="ad-header">
            <img *ngIf="adData.iconUrl" [src]="adData.iconUrl" class="ad-icon" alt="Ad icon">
            <div class="ad-info">
              <h3 *ngIf="adData.headline" class="ad-headline">{{ adData.headline }}</h3>
              <p *ngIf="adData.advertiser" class="ad-advertiser">{{ adData.advertiser }}</p>
            </div>
            <div class="ad-choices" (click)="onAdChoicesClick($event)">
              <img *ngIf="adData.adChoicesIconUrl" [src]="adData.adChoicesIconUrl" alt="AdChoices">
              <span>{{ adData.adChoicesText || 'AdChoices' }}</span>
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
                {{ '★'.repeat(adData.starRating) }}{{ '☆'.repeat(5 - adData.starRating) }}
              </div>
            </div>
          </div>
          
          <button *ngIf="adData.callToAction" class="ad-cta">
            {{ adData.callToAction }}
          </button>
          
          <div class="ad-label">Ad</div>
        </div>
        
        <!-- iOS: Transparent placeholder maintains layout space -->
        <div class="native-ad ios-placeholder" *ngIf="isIOS" [style.height.px]="estimatedHeight">
          <!-- Native overlay will cover this -->
        </div>
      </div>
    </div>
  `,
  styles: [`
    .native-ad-container {
      margin: 16px 0;
    }
    
    .native-ad {
      border: 1px solid #e0e0e0;
      border-radius: 8px;
      padding: 12px;
      background: white;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
      position: relative;
      cursor: pointer;
    }
    
    .native-ad:hover {
      box-shadow: 0 2px 8px rgba(0,0,0,0.15);
    }
    
    .ad-header {
      display: flex;
      align-items: center;
      margin-bottom: 12px;
    }
    
    .ad-icon {
      width: 40px;
      height: 40px;
      border-radius: 4px;
      margin-right: 12px;
      object-fit: cover;
    }
    
    .ad-info {
      flex: 1;
    }
    
    .ad-headline {
      margin: 0;
      font-size: 16px;
      font-weight: 600;
      color: #333;
      line-height: 1.3;
    }
    
    .ad-advertiser {
      margin: 4px 0 0 0;
      font-size: 11px;
      color: #999;
    }
    
    .ad-choices {
      display: flex;
      align-items: center;
      font-size: 10px;
      color: #666;
      cursor: pointer;
      padding: 2px 4px;
      border-radius: 3px;
      background: rgba(255,255,255,0.9);
    }
    
    .ad-choices img {
      width: 16px;
      height: 16px;
      margin-right: 4px;
    }
    
    .ad-media img {
      width: 100%;
      max-height: 200px;
      object-fit: contain;
      border-radius: 4px;
      margin-bottom: 8px;
    }
    
    .ad-body {
      margin: 0 0 8px 0;
      font-size: 14px;
      line-height: 1.4;
      color: #666;
    }
    
    .app-install-info {
      display: flex;
      align-items: center;
      gap: 8px;
      margin-bottom: 8px;
      font-size: 12px;
    }
    
    .store {
      background: #e3f2fd;
      color: #1976d2;
      padding: 2px 6px;
      border-radius: 4px;
    }
    
    .price {
      color: #4caf50;
      font-weight: bold;
    }
    
    .rating {
      color: #ff9800;
    }
    
    .ad-cta {
      width: 100%;
      padding: 8px 16px;
      background: #2196f3;
      color: white;
      border: none;
      border-radius: 4px;
      font-size: 14px;
      cursor: pointer;
      margin: 8px 0;
    }
    
    .ad-cta:hover {
      background: #1976d2;
    }
    
    .ad-label {
      position: absolute;
      top: 8px;
      left: 8px;
      background: rgba(0,0,0,0.8);
      color: white;
      padding: 3px 8px;
      border-radius: 3px;
      font-size: 11px;
      font-weight: bold;
    }
    
    .ios-native .native-ad-placeholder {
      border: none;
      background: transparent;
    }
    
    .ios-placeholder {
      background: #f5f5f5;
      display: flex;
      align-items: center;
      justify-content: center;
      color: #999;
      font-style: italic;
    }
  `]
})
export class NativeAdComponent implements AfterViewInit, OnDestroy {
  @ViewChild('adPlaceholder') adPlaceholder!: ElementRef;
  @Input() adData!: NativeAdData;
  
  isIOS = Capacitor.getPlatform() === 'ios';
  estimatedHeight = 300; // Estimated height for iOS placeholder
  
  private resizeObserver?: ResizeObserver;
  private intersectionObserver?: IntersectionObserver;

  constructor(private cdr: ChangeDetectorRef) {}

  async ngAfterViewInit() {
    if (this.isIOS && this.adData) {
      await this.configureIOSNativeAd();
      this.setupIOSPositioning();
    } else if (this.adData) {
      // Report impression for Android/web
      this.reportImpression();
    }
  }

  ngOnDestroy() {
    if (this.isIOS && this.adData) {
      AdMobNativeAdvanced.hideNativeAd({ adId: this.adData.adId });
    }
    
    this.resizeObserver?.disconnect();
    this.intersectionObserver?.disconnect();
  }

  private async configureIOSNativeAd() {
    if (!this.adData) return;
    
    // Configure styling to match your design
    await AdMobNativeAdvanced.configureNativeAdStyle({
      adId: this.adData.adId,
      style: {
        backgroundColor: '#ffffff',
        cornerRadius: 8,
        borderWidth: 1,
        borderColor: '#e0e0e0',
        headlineColor: '#333333',
        headlineFontSize: 16,
        bodyColor: '#666666',
        bodyFontSize: 14,
        advertiserColor: '#999999',
        advertiserFontSize: 11,
        ctaBackgroundColor: '#2196f3',
        ctaTextColor: '#ffffff',
        ctaFontSize: 14
      }
    });
  }

  private setupIOSPositioning() {
    if (!this.adPlaceholder || !this.adData) return;

    // Initial positioning
    this.positionNativeAd();

    // Handle resize
    this.resizeObserver = new ResizeObserver(() => {
      this.positionNativeAd();
    });
    this.resizeObserver.observe(document.body);

    // Handle visibility
    this.intersectionObserver = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (this.adData) {
          if (entry.isIntersecting) {
            this.positionNativeAd();
          } else {
            AdMobNativeAdvanced.hideNativeAd({ adId: this.adData.adId });
          }
        }
      });
    }, { threshold: 0.1 });
    
    this.intersectionObserver.observe(this.adPlaceholder.nativeElement);

    // Handle scroll with throttling
    let ticking = false;
    const updatePosition = () => {
      this.positionNativeAd();
      ticking = false;
    };

    window.addEventListener('scroll', () => {
      if (!ticking) {
        requestAnimationFrame(updatePosition);
        ticking = true;
      }
    }, { passive: true });
  }

  private positionNativeAd() {
    if (!this.adPlaceholder || !this.adData || !this.isIOS) return;

    const rect = this.adPlaceholder.nativeElement.getBoundingClientRect();
    const scrollY = window.pageYOffset || document.documentElement.scrollTop;

    AdMobNativeAdvanced.positionNativeAd({
      adId: this.adData.adId,
      x: rect.left,
      y: rect.top + scrollY,
      width: rect.width,
      height: rect.height
    });
  }

  async onAdClick() {
    if (!this.adData) return;
    
    // For Android, manually report click (iOS handled automatically)
    if (!this.isIOS) {
      try {
        await AdMobNativeAdvanced.reportClick(this.adData.adId);
      } catch (error) {
        console.error('Error reporting ad click:', error);
      }
    }
  }

  onAdChoicesClick(event: Event) {
    event.stopPropagation();
    // Open AdChoices info (handled automatically on iOS)
    if (!this.isIOS) {
      window.open('https://www.google.com/settings/ads', '_blank');
    }
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
import { AdMobNativeAdvanced, NativeAdData } from '@brandonknudsen/admob-native-advanced';

@Component({
  selector: 'app-feed',
  template: `
    <div class="feed">
      <div *ngFor="let item of feedItems" class="feed-item">
        <ng-container [ngSwitch]="item.type">
          <app-post *ngSwitchCase="'post'" [post]="item.data"></app-post>
          <app-native-ad *ngSwitchCase="'ad'" [adData]="item.data"></app-native-ad>
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

    // Mix posts and ads (insert ad every 3-4 posts)
    this.feedItems = [
      { type: 'post', data: posts[0] },
      { type: 'post', data: posts[1] },
      { type: 'post', data: posts[2] },
      { type: 'ad', data: adData },
      { type: 'post', data: posts[3] },
      // ... more items
    ];
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

Report ad click to AdMob for tracking (Android only - iOS handles automatically).

**Parameters:**
- `adId` (string): The ID of the ad that was clicked

#### `reportImpression(adId: string): Promise<void>`

Report ad impression to AdMob for tracking (Android only - iOS handles automatically).

**Parameters:**
- `adId` (string): The ID of the ad that was shown

#### `positionNativeAd(options: PositionNativeAdOptions): Promise<void>` *(iOS only)*

Position and show the native ad view overlay on iOS.

**Parameters:**
- `options.adId` (string): The ID of the ad to position
- `options.x` (number): Screen X coordinate in pixels
- `options.y` (number): Screen Y coordinate in pixels  
- `options.width` (number): Width in pixels
- `options.height` (number): Height in pixels

#### `hideNativeAd(options: HideNativeAdOptions): Promise<void>` *(iOS only)*

Hide or remove the native ad view overlay on iOS.

**Parameters:**
- `options.adId` (string): The ID of the ad to hide

#### `configureNativeAdStyle(options: ConfigureNativeAdStyleOptions): Promise<void>` *(iOS only)*

Configure the styling of the native ad view overlay on iOS.

**Parameters:**
- `options.adId` (string): The ID of the ad to style
- `options.style` (NativeAdViewStyle): Style configuration object

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
  mediaContentUrl?: string;        // Main ad image (base64 data URL)
  iconUrl?: string;                // Ad icon (base64 data URL)
  adChoicesIconUrl?: string;       // AdChoices icon (base64 data URL)
  adChoicesText?: string;          // AdChoices text
  isAppInstallAd?: boolean;        // Whether this is an app install ad
  isContentAd?: boolean;           // Whether this is a content ad
  nativeRendered?: boolean;        // Whether ad is rendered natively (iOS only)
}
```

#### `NativeAdViewStyle` *(iOS only)*

```typescript
interface NativeAdViewStyle {
  backgroundColor?: string;        // Container background color (hex)
  cornerRadius?: number;           // Border radius in pixels
  borderWidth?: number;            // Border width in pixels
  borderColor?: string;            // Border color (hex)
  headlineColor?: string;          // Headline text color (hex)
  headlineFontSize?: number;       // Headline font size in points
  bodyColor?: string;              // Body text color (hex)
  bodyFontSize?: number;           // Body font size in points
  advertiserColor?: string;        // Advertiser text color (hex)
  advertiserFontSize?: number;     // Advertiser font size in points
  ctaBackgroundColor?: string;     // CTA button background (hex)
  ctaTextColor?: string;           // CTA button text color (hex)
  ctaFontSize?: number;            // CTA button font size in points
}
```

## Event Listeners *(iOS only)*

```typescript
import { AdMobNativeAdvanced } from '@brandonknudsen/admob-native-advanced';

// Listen for ad events on iOS
AdMobNativeAdvanced.addListener('adClicked', (data) => {
  console.log('Ad clicked:', data.adId);
  // Track click in analytics
});

AdMobNativeAdvanced.addListener('adImpression', (data) => {
  console.log('Ad impression:', data.adId);
  // Track impression in analytics
});

AdMobNativeAdvanced.addListener('adWillPresentScreen', (data) => {
  console.log('Ad will present full screen:', data.adId);
  // Pause video, etc.
});

AdMobNativeAdvanced.addListener('adDidDismissScreen', (data) => {
  console.log('Ad dismissed full screen:', data.adId);
  // Resume video, etc.
});
```

## Test Ad Unit IDs

Use these test ad unit IDs for development:

- **Android/iOS Native Advanced:** `ca-app-pub-3940256099942544/2247696110`
- **iOS Native Advanced (legacy):** `ca-app-pub-3940256099942544/3985214057`

## Best Practices

### 1. Platform-Specific Behavior
- **iOS**: Let the SDK handle click/impression tracking automatically
- **Android**: Manually report clicks and impressions
- **Styling**: Use the styling system on iOS to match your design exactly

### 2. iOS Native Ad Positioning
- Use `getBoundingClientRect()` for accurate positioning
- Handle scroll events with throttling (`requestAnimationFrame`)
- Hide ads when not visible to save resources
- Always call `hideNativeAd()` when components unmount

### 3. Ad Placement
- Place ads naturally within your content feed
- Don't place too many ads close together
- Insert ads every 3-4 posts for optimal user experience
- Follow AdMob's [Native Ad Policy](https://support.google.com/admob/answer/6239795)

### 4. Ad Labeling
- Always include "Ad" or "Sponsored" label
- Display AdChoices icon prominently (handled automatically on iOS)
- Make it clear to users that content is promotional

### 5. Error Handling
```typescript
try {
  const adData = await AdMobNativeAdvanced.loadAd({
    adUnitId: 'your-ad-unit-id'
  });
  
  // Handle successful ad load
  if (Capacitor.getPlatform() === 'ios') {
    // Configure iOS native styling
    await AdMobNativeAdvanced.configureNativeAdStyle({
      adId: adData.adId,
      style: { /* your styling */ }
    });
  }
} catch (error) {
  console.error('Failed to load ad:', error);
  // Handle ad load failure (e.g., show fallback content)
}
```

### 6. Performance
- Load ads asynchronously without blocking UI
- Implement proper error handling for failed ad loads
- Use intersection observers for visibility detection
- Clean up native views on component destruction
- Limit concurrent ad requests

## Troubleshooting

### Common Issues

1. **"AdMob must be initialized" error**
   - Ensure you call `initialize()` before `loadAd()`
   - Check that your app ID is correct

2. **"Ad failed to load" error**
   - Verify your ad unit ID is correct
   - Check your internet connection
   - Ensure you're using test ad unit IDs during development

3. **iOS: Ads not showing or clicks not working**
   - Check that you've added the GADApplicationIdentifier to Info.plist
   - Verify your iOS deployment target is 13.0 or higher
   - Ensure `positionNativeAd()` is called after ad load
   - Check that positioning coordinates are correct

4. **iOS: Native overlay positioning issues**
   - Verify `getBoundingClientRect()` returns valid dimensions
   - Check scroll position calculations (`window.pageYOffset`)
   - Ensure the placeholder element has proper dimensions

5. **Android: Ads not showing**
   - Check that you've added the APPLICATION_ID metadata to AndroidManifest.xml
   - Verify your minSdkVersion is 21 or higher
   - Ensure you're calling `reportClick()` and `reportImpression()`

### Debug Mode

Enable debug logging by adding this to your app initialization:

```typescript
// For development only
if (!environment.production) {
  // Add test device IDs to see test ads
  console.log('Running in debug mode with test ads');
}
```

## Migration from Previous Versions

If you're upgrading from a version without iOS native rendering:

1. Update your Angular components to support the hybrid approach
2. Add iOS-specific positioning logic
3. Configure native ad styling for iOS
4. Test on both platforms to ensure consistency

## License

MIT License - see LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

For support, please:
- Open an issue on GitHub
- Check the [AdMob documentation](https://developers.google.com/admob)
- Review the [SETUP.md](./SETUP.md) for detailed implementation examples 