import type { 
  AdMobNativeAdvancedPlugin, 
  InitializeOptions, 
  LoadAdOptions, 
  NativeAdData,
  PositionNativeAdOptions,
  HideNativeAdOptions,
  ConfigureNativeAdStyleOptions,
  HandleScrollEventOptions,
  AutoScrollTrackingOptions
} from './definitions';

export class AdMobNativeAdvancedWeb implements AdMobNativeAdvancedPlugin {
  async initialize(options: InitializeOptions): Promise<void> {
    console.log('AdMob Native Advanced web implementation', options);
  }

  async loadAd(options: LoadAdOptions): Promise<NativeAdData> {
    console.log('Loading ad in web', options);
    throw new Error('AdMob Native Advanced is not supported on web platform');
  }

  async reportClick(adId: string): Promise<void> {
    console.log('Reporting click for ad:', adId);
  }

  async reportImpression(adId: string): Promise<void> {
    console.log('Reporting impression for ad:', adId);
  }

  async positionNativeAd(options: PositionNativeAdOptions): Promise<void> {
    console.log('Positioning native ad (web):', options);
  }

  async hideNativeAd(options: HideNativeAdOptions): Promise<void> {
    console.log('Hiding native ad (web):', options);
  }

  async configureNativeAdStyle(options: ConfigureNativeAdStyleOptions): Promise<void> {
    console.log('Configuring native ad style (web):', options);
  }

  async handleScrollEvent(options: HandleScrollEventOptions): Promise<void> {
    console.log('Handling scroll event (web):', options);
  }

  async setAutoScrollTracking(options: AutoScrollTrackingOptions): Promise<void> {
    console.log('Setting auto scroll tracking (web):', options);
  }
} 