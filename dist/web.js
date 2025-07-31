export class AdMobNativeAdvancedWeb {
    async initialize(options) {
        console.log('AdMob Native Advanced web implementation', options);
    }
    async loadAd(options) {
        console.log('Loading ad in web', options);
        throw new Error('AdMob Native Advanced is not supported on web platform');
    }
    async reportClick(adId) {
        console.log('Reporting click for ad:', adId);
    }
    async reportImpression(adId) {
        console.log('Reporting impression for ad:', adId);
    }
    async positionNativeAd(options) {
        console.log('Positioning native ad (web):', options);
    }
    async hideNativeAd(options) {
        console.log('Hiding native ad (web):', options);
    }
    async configureNativeAdStyle(options) {
        console.log('Configuring native ad style (web):', options);
    }
    async handleScrollEvent(options) {
        console.log('Handling scroll event (web):', options);
    }
    async setAutoScrollTracking(options) {
        console.log('Setting auto scroll tracking (web):', options);
    }
}
