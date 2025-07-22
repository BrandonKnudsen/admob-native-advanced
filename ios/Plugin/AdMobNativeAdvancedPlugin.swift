import Foundation
import Capacitor
import GoogleMobileAds
import UIKit

@objc(AdMobNativeAdvancedPlugin)
public class AdMobNativeAdvancedPlugin: CAPPlugin {
    private var isInitialized = false
    private var loadedAds: [String: GADNativeAd] = [:]
    private var pendingCalls: [Int: CAPPluginCall] = [:] // Keyed by adLoader's hashValue
    
    @objc func initialize(_ call: CAPPluginCall) {
        guard let appId = call.getString("appId"), !appId.isEmpty else {
            call.reject("App ID is required")
            return
        }
        // Initialize MobileAds SDK
        GADMobileAds.sharedInstance().start { [weak self] status in
            DispatchQueue.main.async {
                self?.isInitialized = true
                print("AdMob initialized successfully")
                call.resolve()
            }
        }
    }
    
    @objc func loadAd(_ call: CAPPluginCall) {
        guard isInitialized else {
            call.reject("AdMob must be initialized before loading ads")
            return
        }
        guard let adUnitId = call.getString("adUnitId"), !adUnitId.isEmpty else {
            call.reject("Ad Unit ID is required")
            return
        }
        // Create AdLoader for native ads
        let adLoader = GADAdLoader(adUnitID: adUnitId, rootViewController: nil, adTypes: [.native], options: nil)
        adLoader.delegate = self
        // Store the call for later resolution, keyed by adLoader's hashValue
        pendingCalls[adLoader.hash] = call
        // Load the ad
        let request = GADRequest()
        adLoader.load(request)
    }
    
    @objc func reportClick(_ call: CAPPluginCall) {
        // No longer possible to programmatically report clicks in the latest SDK
        call.resolve(["message": "Click reporting is handled automatically by the SDK."])
    }
    
    @objc func reportImpression(_ call: CAPPluginCall) {
        // No longer possible to programmatically report impressions in the latest SDK
        call.resolve(["message": "Impression reporting is handled automatically by the SDK."])
    }
    
    private func extractAdData(from nativeAd: GADNativeAd, adId: String) -> [String: Any] {
        var adData: [String: Any] = [:]
        adData["adId"] = adId
        if let headline = nativeAd.headline { adData["headline"] = headline }
        if let body = nativeAd.body { adData["body"] = body }
        if let callToAction = nativeAd.callToAction { adData["callToAction"] = callToAction }
        if let advertiser = nativeAd.advertiser { adData["advertiser"] = advertiser }
        if let store = nativeAd.store { adData["store"] = store }
        if let price = nativeAd.price { adData["price"] = price }
        if let starRating = nativeAd.starRating { adData["starRating"] = starRating.doubleValue }
        // Media content: check for video content, otherwise get images
        let mediaContent = nativeAd.mediaContent
        adData["hasVideoContent"] = mediaContent.hasVideoContent
        // No videoURL available in SDK 11.x
        // Get main image from images array
        if let images = nativeAd.images, let mainImage = images.first?.image {
            adData["mediaContentUrl"] = imageToBase64(mainImage)
        } else {
            adData["mediaContentUrl"] = nil
        }
        // Icon
        if let iconImage = nativeAd.icon?.image {
            adData["iconUrl"] = imageToBase64(iconImage)
        } else {
            adData["iconUrl"] = nil
        }
        // AdChoices: No longer available as adChoicesInfo, so we can't extract icon/text
        adData["adChoicesIconUrl"] = nil
        adData["adChoicesText"] = nil
        // Determine ad type
        adData["isAppInstallAd"] = nativeAd.store != nil
        adData["isContentAd"] = nativeAd.store == nil
        return adData
    }
    
    private func imageToBase64(_ image: UIImage) -> String? {
        guard let data = image.pngData() else { return nil }
        return "data:image/png;base64," + data.base64EncodedString()
    }
}
// MARK: - GADNativeAdLoaderDelegate
extension AdMobNativeAdvancedPlugin: GADNativeAdLoaderDelegate {
    public func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        let adId = UUID().uuidString
        loadedAds[adId] = nativeAd
        let adData = extractAdData(from: nativeAd, adId: adId)
        // Resolve the call
        if let call = pendingCalls.removeValue(forKey: adLoader.hash) {
            call.resolve(adData)
        }
    }
    public func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        print("Ad failed to load: \(error.localizedDescription)")
        if let call = pendingCalls.removeValue(forKey: adLoader.hash) {
            call.reject("Ad failed to load: \(error.localizedDescription)")
        }
    }
} 