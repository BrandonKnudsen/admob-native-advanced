import type { AdMobNativeAdvancedPlugin, InitializeOptions, LoadAdOptions, NativeAdData, PositionNativeAdOptions, HideNativeAdOptions, ConfigureNativeAdStyleOptions, HandleScrollEventOptions, AutoScrollTrackingOptions } from './definitions';
export declare class AdMobNativeAdvancedWeb implements AdMobNativeAdvancedPlugin {
    initialize(options: InitializeOptions): Promise<void>;
    loadAd(options: LoadAdOptions): Promise<NativeAdData>;
    reportClick(adId: string): Promise<void>;
    reportImpression(adId: string): Promise<void>;
    positionNativeAd(options: PositionNativeAdOptions): Promise<void>;
    hideNativeAd(options: HideNativeAdOptions): Promise<void>;
    configureNativeAdStyle(options: ConfigureNativeAdStyleOptions): Promise<void>;
    handleScrollEvent(options: HandleScrollEventOptions): Promise<void>;
    setAutoScrollTracking(options: AutoScrollTrackingOptions): Promise<void>;
}
