import type { 
  AdMobNativeAdvancedPlugin, 
  InitializeOptions, 
  LoadAdOptions, 
  NativeAdData 
} from './definitions';

export class AdMobNativeAdvancedWeb implements AdMobNativeAdvancedPlugin {
  private isInitialized = false;

  async initialize(_options: InitializeOptions): Promise<void> {
    console.warn('AdMob Native Advanced Ads are not supported on web platform');
    this.isInitialized = true;
  }

  async loadAd(_options: LoadAdOptions): Promise<NativeAdData> {
    if (!this.isInitialized) {
      throw new Error('AdMob must be initialized before loading ads');
    }

    // Return mock data for web platform
    return {
      adId: `web-ad-${Date.now()}`,
      headline: 'Sample Native Ad',
      body: 'This is a sample native ad for web platform. Native ads are only supported on mobile platforms.',
      callToAction: 'Learn More',
      advertiser: 'Sample Advertiser',
      mediaContentUrl: 'https://via.placeholder.com/300x200',
      iconUrl: 'https://via.placeholder.com/50x50',
      adChoicesIconUrl: 'https://via.placeholder.com/20x20',
      adChoicesText: 'AdChoices',
      isContentAd: true
    };
  }

  async reportClick(adId: string): Promise<void> {
    console.log(`Ad click reported for ad: ${adId}`);
  }

  async reportImpression(adId: string): Promise<void> {
    console.log(`Ad impression reported for ad: ${adId}`);
  }
} 