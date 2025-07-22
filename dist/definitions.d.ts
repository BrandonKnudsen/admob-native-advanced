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
