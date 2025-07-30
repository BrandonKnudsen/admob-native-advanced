import type { AdMobNativeAdvancedPlugin, InitializeOptions, LoadAdOptions, NativeAdData, PositionNativeAdOptions, HideNativeAdOptions, ConfigureNativeAdStyleOptions } from './definitions';
export declare class AdMobNativeAdvancedWeb implements AdMobNativeAdvancedPlugin {
    private isInitialized;
    initialize(_options: InitializeOptions): Promise<void>;
    loadAd(_options: LoadAdOptions): Promise<NativeAdData>;
    reportClick(adId: string): Promise<void>;
    reportImpression(adId: string): Promise<void>;
    positionNativeAd(_options: PositionNativeAdOptions): Promise<void>;
    hideNativeAd(_options: HideNativeAdOptions): Promise<void>;
    configureNativeAdStyle(_options: ConfigureNativeAdStyleOptions): Promise<void>;
}
