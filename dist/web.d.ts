import type { AdMobNativeAdvancedPlugin, InitializeOptions, LoadAdOptions, NativeAdData } from './definitions';
export declare class AdMobNativeAdvancedWeb implements AdMobNativeAdvancedPlugin {
    private isInitialized;
    initialize(_options: InitializeOptions): Promise<void>;
    loadAd(_options: LoadAdOptions): Promise<NativeAdData>;
    reportClick(adId: string): Promise<void>;
    reportImpression(adId: string): Promise<void>;
}
