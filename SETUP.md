# AdMob Native Advanced Setup Guide

## Overview

This plugin provides Google AdMob Native Advanced Ads support for Capacitor applications with a hybrid approach:

- **iOS**: Native rendering using `GADNativeAdView` overlays for proper click tracking and URL handling
- **Android**: JavaScript rendering with programmatic click/impression reporting (or native rendering if desired)
- **Web**: Mock data for development

## Installation

```bash
npm install your-plugin-name
npx cap sync
```

## Configuration

### iOS Setup

1. Add your AdMob App ID to `ios/App/App/Info.plist`:
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy</string>
```

2. Ensure your `ios/Podfile` includes the Google Mobile Ads SDK (usually auto-included).

### Android Setup

1. Add your AdMob App ID to `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy"/>
```

## Usage

### Basic Implementation

```typescript
import { AdMobNativeAdvanced } from 'your-plugin-name';
import { Capacitor } from '@capacitor/core';

// Initialize
await AdMobNativeAdvanced.initialize({
  appId: 'ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy'
});

// Load ad
const adData = await AdMobNativeAdvanced.loadAd({
  adUnitId: 'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy'
});
```

### Angular Component Example

```typescript
// native-ad.component.ts
import { Component, ElementRef, ViewChild, AfterViewInit, OnDestroy, ChangeDetectorRef } from '@angular/core';
import { AdMobNativeAdvanced, NativeAdData } from 'your-plugin-name';
import { Capacitor } from '@capacitor/core';

@Component({
  selector: 'app-native-ad',
  template: `
    <div class="native-ad-container">
      <!-- iOS: Invisible placeholder for native overlay positioning -->
      <div 
        #adPlaceholder 
        class="native-ad-placeholder"
        [style.visibility]="isIOS && adData ? 'hidden' : 'visible'"
        *ngIf="adData">
        
        <!-- Android/Web: Rendered in HTML -->
        <div class="native-ad" *ngIf="!isIOS && adData">
          <div class="ad-header">
            <img [src]="adData.iconUrl" class="ad-icon" *ngIf="adData.iconUrl">
            <div class="ad-text">
              <h3 class="ad-headline">{{ adData.headline }}</h3>
              <p class="ad-advertiser">{{ adData.advertiser }}</p>
            </div>
          </div>
          
          <div class="ad-media" *ngIf="adData.mediaContentUrl">
            <img [src]="adData.mediaContentUrl" class="ad-image">
          </div>
          
          <p class="ad-body">{{ adData.body }}</p>
          
          <button 
            class="ad-cta" 
            (click)="onAdClick()"
            *ngIf="adData.callToAction">
            {{ adData.callToAction }}
          </button>
          
          <span class="ad-choices">{{ adData.adChoicesText || 'Sponsored' }}</span>
        </div>
        
        <!-- iOS: Placeholder maintains layout space -->
        <div 
          class="native-ad native-ad-ios-placeholder" 
          *ngIf="isIOS"
          [style.height.px]="calculateAdHeight()">
          <div class="loading-indicator">Loading Ad...</div>
        </div>
      </div>
    </div>
  `,
  styles: [`
    .native-ad-container {
      margin: 16px 0;
    }
    
    .native-ad {
      background: white;
      border: 1px solid #ddd;
      border-radius: 8px;
      padding: 12px;
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
      border-radius: 6px;
      margin-right: 8px;
      object-fit: cover;
    }
    
    .ad-headline {
      margin: 0;
      font-size: 16px;
      font-weight: 600;
      line-height: 1.3;
    }
    
    .ad-advertiser {
      margin: 4px 0 0 0;
      font-size: 12px;
      color: #666;
    }
    
    .ad-media {
      margin: 12px 0;
    }
    
    .ad-image {
      width: 100%;
      max-height: 150px;
      object-fit: cover;
      border-radius: 6px;
    }
    
    .ad-body {
      margin: 8px 0;
      font-size: 14px;
      line-height: 1.4;
      color: #333;
    }
    
    .ad-cta {
      width: 100%;
      padding: 12px;
      background: #007AFF;
      color: white;
      border: none;
      border-radius: 6px;
      font-size: 14px;
      font-weight: 600;
      margin: 12px 0 8px 0;
      cursor: pointer;
    }
    
    .ad-choices {
      font-size: 10px;
      color: #999;
      text-transform: uppercase;
    }
    
    .native-ad-ios-placeholder {
      display: flex;
      align-items: center;
      justify-content: center;
      background: #f5f5f5;
      color: #666;
    }
    
    .loading-indicator {
      font-size: 14px;
    }
  `]
})
export class NativeAdComponent implements AfterViewInit, OnDestroy {
  @ViewChild('adPlaceholder') adPlaceholder!: ElementRef;
  
  adData: NativeAdData | null = null;
  isIOS = Capacitor.getPlatform() === 'ios';
  private resizeObserver?: ResizeObserver;
  private intersectionObserver?: IntersectionObserver;
  
  constructor(private cdr: ChangeDetectorRef) {}

  async ngAfterViewInit() {
    await this.loadAd();
    
    if (this.isIOS && this.adData) {
      this.setupIOSPositioning();
    }
  }

  ngOnDestroy() {
    if (this.isIOS && this.adData) {
      AdMobNativeAdvanced.hideNativeAd({ adId: this.adData.adId });
    }
    
    this.resizeObserver?.disconnect();
    this.intersectionObserver?.disconnect();
  }

  private async loadAd() {
    try {
      this.adData = await AdMobNativeAdvanced.loadAd({
        adUnitId: 'ca-app-pub-3940256099942544/2247696110' // Test ad unit
      });
      
      this.cdr.detectChanges();
      
      // Configure styling for iOS
      if (this.isIOS && this.adData) {
        await AdMobNativeAdvanced.configureNativeAdStyle({
          adId: this.adData.adId,
          style: {
            // Container styling (matches .native-ad-container)
            backgroundColor: '#ffffff',
            cornerRadius: 8,
            borderWidth: 1,
            borderColor: '#e0e0e0',
            
            // Text styling (matches your SCSS)
            headlineColor: '#333333',      // .ad-headline
            headlineFontSize: 16,
            bodyColor: '#666666',          // .ad-body  
            bodyFontSize: 14,
            advertiserColor: '#999999',    // .ad-advertiser
            advertiserFontSize: 11,
            
            // CTA button styling (matches .ad-cta-button)
            ctaBackgroundColor: '#2196f3',
            ctaTextColor: '#ffffff',
            ctaFontSize: 14
          }
        });
      }
    } catch (error) {
      console.error('Failed to load ad:', error);
    }
  }

  private setupIOSPositioning() {
    if (!this.adPlaceholder || !this.adData) return;

    // Initial positioning
    this.positionNativeAd();

    // Setup resize observer for window resizing
    this.resizeObserver = new ResizeObserver(() => {
      this.positionNativeAd();
    });
    this.resizeObserver.observe(document.body);

    // Setup intersection observer for scroll positioning
    this.intersectionObserver = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          this.positionNativeAd();
        } else {
          // Hide when not visible
          AdMobNativeAdvanced.hideNativeAd({ adId: this.adData!.adId });
        }
      });
    }, { threshold: 0.1 });
    
    this.intersectionObserver.observe(this.adPlaceholder.nativeElement);

    // Listen for scroll events to reposition
    window.addEventListener('scroll', this.throttle(() => {
      this.positionNativeAd();
    }, 16)); // ~60fps
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

  private calculateAdHeight(): number {
    // Estimate height based on content
    let height = 0;
    height += 52; // Header (icon + text)
    height += 150; // Media
    height += 60; // Body text (estimate)
    height += 44; // CTA button
    height += 40; // Padding
    return height;
  }

  async onAdClick() {
    if (!this.adData) return;
    
    // For Android, manually report click
    if (!this.isIOS) {
      try {
        await AdMobNativeAdvanced.reportClick(this.adData.adId);
      } catch (error) {
        console.error('Failed to report click:', error);
      }
    }
    // iOS clicks are handled automatically by the SDK
  }

  private throttle(func: Function, limit: number) {
    let lastFunc: NodeJS.Timeout;
    let lastRan: number;
    return function(this: any, ...args: any[]) {
      if (!lastRan) {
        func.apply(this, args);
        lastRan = Date.now();
      } else {
        clearTimeout(lastFunc);
        lastFunc = setTimeout(() => {
          if ((Date.now() - lastRan) >= limit) {
            func.apply(this, args);
            lastRan = Date.now();
          }
        }, limit - (Date.now() - lastRan));
      }
    };
  }
}
```

### Feed Component Integration

```typescript
// feed.component.ts
export class FeedComponent {
  feedItems: (FeedPost | AdItem)[] = [];

  constructor() {
    this.loadFeed();
  }

  private loadFeed() {
    // Mix regular content with ads
    this.feedItems = [
      { type: 'post', content: 'Regular post 1' },
      { type: 'post', content: 'Regular post 2' },
      { type: 'ad', adIndex: 0 }, // Insert ad every 3 posts
      { type: 'post', content: 'Regular post 3' },
      { type: 'post', content: 'Regular post 4' },
      { type: 'ad', adIndex: 1 },
      // ... more items
    ];
  }

  // Update ad positions on feed changes
  updateAdPositions() {
    // Called when feed scrolls, resizes, or updates
    this.feedItems.forEach(item => {
      if (item.type === 'ad') {
        // Ad components will handle their own repositioning
      }
    });
  }
}
```

## Event Handling

```typescript
import { AdMobNativeAdvanced } from 'your-plugin-name';

// Listen for ad events (iOS only)
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

## Best Practices

### iOS Native Rendering
1. **Positioning**: Use `getBoundingClientRect()` for accurate positioning
2. **Scroll Handling**: Update positions on scroll with throttling
3. **Visibility**: Hide ads when not visible to save resources
4. **Cleanup**: Always call `hideNativeAd()` when components unmount

### Android/Web Rendering
1. **Click Handling**: Manually call `reportClick()` for tracking
2. **Impression Tracking**: Call `reportImpression()` when ad becomes visible
3. **Styling**: Match your app's design system

### General
1. **Test Ads**: Always use test ad unit IDs during development
2. **AdChoices**: Ensure AdChoices or "Sponsored" label is visible
3. **Layout**: Reserve appropriate space to prevent layout shifts
4. **Error Handling**: Implement fallbacks for ad load failures
5. **Performance**: Limit the number of concurrent ad requests

## Testing

Use these test ad unit IDs:
- **Test Native Ad**: `ca-app-pub-3940256099942544/2247696110`

## Troubleshooting

### iOS Issues
- **Overlay not visible**: Check if positioning coordinates are correct
- **Clicks not working**: Ensure `GADNativeAdView` has correct frame and is in view hierarchy
- **Layout issues**: Verify Auto Layout constraints in `setupNativeAdViewLayout`

### Android Issues
- **Clicks not tracked**: Ensure `reportClick()` is called
- **Images not loading**: Check network permissions and image URLs

### Common Issues
- **Ads not loading**: Verify app ID and ad unit ID are correct
- **Test ads in production**: Replace test ad units with live ones before release 

## Matching Your Existing Design

If you have an existing `native-ad.component.scss` file like the one you've shared, here's how to configure the iOS native ad to match it perfectly:

### iOS Styling Configuration

```typescript
// In your native-ad.component.ts after loading the ad
if (this.isIOS && this.adData) {
  await AdMobNativeAdvanced.configureNativeAdStyle({
    adId: this.adData.adId,
    style: {
      // Container (.native-ad-container)
      backgroundColor: '#ffffff',
      cornerRadius: 8,
      borderWidth: 1,
      borderColor: '#e0e0e0',
      
      // Headlines (.ad-headline)
      headlineColor: '#333333',
      headlineFontSize: 16,
      
      // Body text (.ad-body)
      bodyColor: '#666666',
      bodyFontSize: 14,
      
      // Advertiser text (.ad-advertiser)
      advertiserColor: '#999999',
      advertiserFontSize: 11,
      
      // CTA Button (.ad-cta-button)
      ctaBackgroundColor: '#2196f3',
      ctaTextColor: '#ffffff',
      ctaFontSize: 14
    }
  });
}
```

### Layout Specifications

The iOS native ad will automatically match these layout elements from your SCSS:

- **Container**: 12px padding, 8px border-radius, #e0e0e0 border
- **Icon**: 40x40px, 4px border-radius, positioned top-left with 12px margin-right
- **Headline**: Bold 16px, #333 color, positioned next to icon
- **Body**: 14px, #666 color, full width below header section
- **Media**: Full width, 4px border-radius, max-height 200px (automatically handled)
- **App Info**: Horizontal stack with 8px spacing (store badge, price, star rating)
- **CTA Button**: Full width, #2196f3 background, white text, 4px border-radius
- **Advertiser**: 11px, #999 color, bottom of container
- **Ad Label**: Top-left overlay, "Ad" text, dark background
- **AdChoices**: Top-right overlay with info icon

### Component Integration

```typescript
export class NativeAdComponent implements AfterViewInit, OnDestroy {
  @ViewChild('adPlaceholder') adPlaceholder!: ElementRef;
  
  adData: NativeAdData | null = null;
  isIOS = Capacitor.getPlatform() === 'ios';
  
  async ngAfterViewInit() {
    await this.loadAd();
    
    if (this.isIOS && this.adData) {
      await this.configureIOSNativeAd();
      this.setupIOSPositioning();
    }
  }

  ngOnDestroy() {
    if (this.isIOS && this.adData) {
      AdMobNativeAdvanced.hideNativeAd({ adId: this.adData.adId });
    }
  }

  private async loadAd() {
    try {
      this.adData = await AdMobNativeAdvanced.loadAd({
        adUnitId: 'your-ad-unit-id'
      });
    } catch (error) {
      console.error('Failed to load ad:', error);
    }
  }

  private async configureIOSNativeAd() {
    if (!this.adData) return;
    
    // Apply exact styling to match your SCSS
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

    // Position native overlay
    this.positionNativeAd();

    // Handle scroll and resize
    this.setupResponsivePositioning();
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
      height: this.calculateExpectedHeight()
    });
  }

  private calculateExpectedHeight(): number {
    // Match your SCSS layout calculations
    let height = 24; // Container padding (12px top + 12px bottom)
    height += 21; // Ad label height
    height += 8;  // Spacing after ad label
    height += 40; // Icon height
    height += 8;  // Spacing after icon/headline section
    height += 60; // Estimated body text height (varies by content)
    height += 8;  // Spacing before media
    height += 150; // Media height (average)
    height += 8;  // Spacing after media
    height += 20; // App info section height
    height += 8;  // Spacing before CTA
    height += 36; // CTA button height
    height += 4;  // Spacing before advertiser
    height += 16; // Advertiser text height
    return height;
  }

  private setupResponsivePositioning() {
    // Throttled scroll listener
    let ticking = false;
    
    const updatePosition = () => {
      this.positionNativeAd();
      ticking = false;
    };

    const requestTick = () => {
      if (!ticking) {
        requestAnimationFrame(updatePosition);
        ticking = true;
      }
    };

    window.addEventListener('scroll', requestTick, { passive: true });
    window.addEventListener('resize', requestTick);

    // Intersection observer for visibility
    const observer = new IntersectionObserver((entries) => {
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

    observer.observe(this.adPlaceholder.nativeElement);
  }

  async onAdClick() {
    if (!this.adData) return;
    
    // Android manual click reporting (iOS handled automatically)
    if (!this.isIOS) {
      try {
        await AdMobNativeAdvanced.reportClick(this.adData.adId);
      } catch (error) {
        console.error('Failed to report click:', error);
      }
    }
  }
}
```

### Template Updates

Your template can remain largely the same, just add the iOS placeholder:

```html
<div class="native-ad-container" [class.ios-native]="isIOS" *ngIf="adData">
  <!-- iOS: Hidden placeholder for positioning -->
  <div 
    #adPlaceholder 
    class="native-ad-placeholder"
    [style.height.px]="isIOS ? calculateExpectedHeight() : null"
    [style.visibility]="isIOS ? 'hidden' : 'visible'">
    
    <!-- Your existing HTML template for Android/Web -->
    <div class="native-ad" *ngIf="!isIOS">
      <!-- Existing ad content from your component -->
      <div class="ad-icon" *ngIf="adData.iconUrl">
        <img [src]="adData.iconUrl" alt="Ad icon">
      </div>
      
      <div class="ad-content">
        <div class="ad-headline">{{ adData.headline }}</div>
        <div class="ad-body">{{ adData.body }}</div>
        
        <div class="ad-media" *ngIf="adData.mediaContentUrl">
          <img [src]="adData.mediaContentUrl" alt="Ad media">
        </div>
        
        <div class="ad-app-info" *ngIf="adData.store || adData.price || adData.starRating">
          <span class="ad-store" *ngIf="adData.store">{{ adData.store }}</span>
          <span class="ad-price" *ngIf="adData.price">{{ adData.price }}</span>
          <span class="ad-rating" *ngIf="adData.starRating">
            {{ '★'.repeat(adData.starRating) }}{{ '☆'.repeat(5 - adData.starRating) }}
          </span>
        </div>
        
        <div class="ad-cta" *ngIf="adData.callToAction">
          <button class="ad-cta-button" (click)="onAdClick()">
            {{ adData.callToAction }}
          </button>
        </div>
        
        <div class="ad-advertiser" *ngIf="adData.advertiser">
          {{ adData.advertiser }}
        </div>
      </div>
      
      <!-- AdChoices -->
      <div class="ad-choices" (click)="onAdChoicesClick($event)">
        <img class="ad-choices-icon" [src]="adData.adChoicesIconUrl" *ngIf="adData.adChoicesIconUrl">
        <span class="ad-choices-text">{{ adData.adChoicesText || 'AdChoices' }}</span>
      </div>
      
      <!-- Ad Label -->
      <div class="ad-label">
        <small>Ad</small>
      </div>
    </div>
  </div>
</div>
```

### SCSS Additions

Add these styles to your existing SCSS to support iOS:

```scss
.native-ad-container.ios-native {
  .native-ad-placeholder {
    border: none;
    background: transparent;
    color: transparent;
  }
}
```

This configuration will make the iOS native ad overlay match your existing design pixel-perfectly while maintaining all the automatic click tracking and impression reporting benefits of the native SDK. 