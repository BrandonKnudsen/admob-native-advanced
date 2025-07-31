export interface AdMobNativeAdvancedPlugin {
  /**
   * Initialize AdMob with your app ID
   * @param options Configuration options including app ID
   */
  initialize(options: InitializeOptions): Promise<void>;

  /**
   * Load a native advanced ad
   * @param options Ad loading options including ad unit ID
   */
  loadAd(options: LoadAdOptions): Promise<NativeAdData>;

  /**
   * Report ad click to AdMob
   * @param adId The ID of the ad that was clicked
   */
  reportClick(adId: string): Promise<void>;

  /**
   * Report ad impression to AdMob
   * @param adId The ID of the ad that was shown
   */
  reportImpression(adId: string): Promise<void>;

  /**
   * Position and show the native ad view on iOS
   * @param options Positioning and ad ID
   */
  positionNativeAd(options: PositionNativeAdOptions): Promise<void>;

  /**
   * Hide or remove the native ad view on iOS
   * @param adId The ID of the ad to hide
   */
  hideNativeAd(options: HideNativeAdOptions): Promise<void>;

  /**
   * Configure native ad view styling on iOS
   * @param options Styling options for the native ad view
   */
  configureNativeAdStyle(options: ConfigureNativeAdStyleOptions): Promise<void>;

  /**
   * Handle scroll events for native ad synchronization
   * @param options Scroll event options including ad ID
   */
  handleScrollEvent(options: HandleScrollEventOptions): Promise<void>;

  /**
   * Enable or disable automatic scroll tracking for native ads
   * @param options Auto-scroll options
   */
  setAutoScrollTracking(options: AutoScrollTrackingOptions): Promise<void>;
}

export interface InitializeOptions {
  /**
   * Your AdMob app ID (e.g., "ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy")
   */
  appId: string;
}

export interface LoadAdOptions {
  /**
   * Your AdMob ad unit ID (e.g., "ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy")
   */
  adUnitId: string;
}

export interface PositionNativeAdOptions {
  /**
   * The ID of the ad to position
   */
  adId: string;
  /**
   * Screen X coordinate (pixels)
   */
  x: number;
  /**
   * Screen Y coordinate (pixels)
   */
  y: number;
  /**
   * Width of the ad view (pixels)
   */
  width: number;
  /**
   * Height of the ad view (pixels)
   */
  height: number;
}

export interface HideNativeAdOptions {
  /**
   * The ID of the ad to hide
   */
  adId: string;
}

export interface ConfigureNativeAdStyleOptions {
  /**
   * The ID of the ad to style
   */
  adId: string;
  /**
   * Style configuration for the native ad view
   */
  style: NativeAdViewStyle;
}

export interface HandleScrollEventOptions {
  /**
   * The ID of the ad to handle scroll for
   */
  adId: string;
}

export interface AutoScrollTrackingOptions {
  /**
   * Whether to enable automatic scroll tracking
   */
  enabled: boolean;
  /**
   * Optional throttle interval in milliseconds (default: 16ms for 60fps)
   */
  throttleMs?: number;
}

export interface NativeAdViewStyle {
  /**
   * Background color of the ad view (hex format, e.g., '#FFFFFF')
   */
  backgroundColor?: string;
  /**
   * Headline text color (hex format, e.g., '#000000')
   */
  headlineColor?: string;
  /**
   * Body text color (hex format, e.g., '#666666')
   */
  bodyColor?: string;
  /**
   * Advertiser text color (hex format, e.g., '#999999')
   */
  advertiserColor?: string;
  /**
   * Call-to-action button background color (hex format, e.g., '#007AFF')
   */
  ctaBackgroundColor?: string;
  /**
   * Call-to-action button text color (hex format, e.g., '#FFFFFF')
   */
  ctaTextColor?: string;
  /**
   * Corner radius for rounded corners (pixels)
   */
  cornerRadius?: number;
  /**
   * Border width (pixels)
   */
  borderWidth?: number;
  /**
   * Border color (hex format, e.g., '#DDDDDD')
   */
  borderColor?: string;
  /**
   * Headline font size (points)
   */
  headlineFontSize?: number;
  /**
   * Body font size (points)
   */
  bodyFontSize?: number;
  /**
   * Advertiser font size (points)
   */
  advertiserFontSize?: number;
  /**
   * CTA button font size (points)
   */
  ctaFontSize?: number;
}

export interface NativeAdData {
  /**
   * Unique identifier for this ad instance
   */
  adId: string;
  
  /**
   * Ad headline/title
   */
  headline?: string;
  
  /**
   * Ad body text/description
   */
  body?: string;
  
  /**
   * Ad call-to-action text
   */
  callToAction?: string;
  
  /**
   * Advertiser name
   */
  advertiser?: string;
  
  /**
   * App store name (for app install ads)
   */
  store?: string;
  
  /**
   * App price (for app install ads)
   */
  price?: string;
  
  /**
   * Star rating (for app install ads)
   */
  starRating?: number;
  
  /**
   * Main ad image URL
   */
  mediaContentUrl?: string;
  
  /**
   * Ad icon URL
   */
  iconUrl?: string;
  
  /**
   * AdChoices icon URL
   */
  adChoicesIconUrl?: string;
  
  /**
   * AdChoices text
   */
  adChoicesText?: string;
  
  /**
   * Whether this is an app install ad
   */
  isAppInstallAd?: boolean;
  
  /**
   * Whether this is a content ad
   */
  isContentAd?: boolean;

  /**
   * Whether the ad is rendered natively (iOS only)
   */
  nativeRendered?: boolean;
}

export interface AdMobError {
  /**
   * Error code
   */
  code: string;
  
  /**
   * Error message
   */
  message: string;
} 