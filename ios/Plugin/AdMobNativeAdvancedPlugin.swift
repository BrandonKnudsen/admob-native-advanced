import Foundation
import Capacitor
import GoogleMobileAds
import UIKit

@objc(AdMobNativeAdvancedPlugin)
public class AdMobNativeAdvancedPlugin: CAPPlugin {
    private var isInitialized = false
    private var loadedAds: [String: GADNativeAd] = [:]
    
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
        
        // Load the ad
        let request = GADRequest()
        adLoader.load(request)
        
        // Store the call for later resolution
        adLoader.userInfo = ["call": call]
    }
    
    @objc func reportClick(_ call: CAPPluginCall) {
        guard let adId = call.getString("adId"), !adId.isEmpty else {
            call.reject("Ad ID is required")
            return
        }
        
        guard let nativeAd = loadedAds[adId] else {
            call.reject("Ad not found with ID: \(adId)")
            return
        }
        
        // Report click to AdMob (assuming click on call to action)
        nativeAd.performClickOnAsset(withKey: GADNativeCallToActionAsset)
        call.resolve()
    }
    
    @objc func reportImpression(_ call: CAPPluginCall) {
        guard let adId = call.getString("adId"), !adId.isEmpty else {
            call.reject("Ad ID is required")
            return
        }
        
        guard let nativeAd = loadedAds[adId] else {
            call.reject("Ad not found with ID: \(adId)")
            return
        }
        
        // Report impression to AdMob
        nativeAd.recordImpression()
        call.resolve()
    }
    
    private func extractAdData(from nativeAd: GADNativeAd, adId: String) -> [String: Any] {
        var adData: [String: Any] = [:]
        adData["adId"] = adId
        
        // Extract headline
        if let headline = nativeAd.headline {
            adData["headline"] = headline
        }
        
        // Extract body
        if let body = nativeAd.body {
            adData["body"] = body
        }
        
        // Extract call to action
        if let callToAction = nativeAd.callToAction {
            adData["callToAction"] = callToAction
        }
        
        // Extract advertiser
        if let advertiser = nativeAd.advertiser {
            adData["advertiser"] = advertiser
        }
        
        // Extract store (for app install ads)
        if let store = nativeAd.store {
            adData["store"] = store
        }
        
        // Extract price (for app install ads)
        if let price = nativeAd.price {
            adData["price"] = price
        }
        
        // Extract star rating (for app install ads)
        if let starRating = nativeAd.starRating {
            adData["starRating"] = starRating.doubleValue
        }
        
        // Extract media content
        var mediaContentUrl: String? = nil
        if let mediaContent = nativeAd.mediaContent {
            if mediaContent.hasVideoContent, let videoURL = mediaContent.videoURL {
                mediaContentUrl = videoURL.absoluteString
            } else if let mainImage = mediaContent.mainImage {
                mediaContentUrl = imageToBase64(mainImage)
            }
        }
        adData["mediaContentUrl"] = mediaContentUrl
        
        // Extract icon
        var iconUrl: String? = nil
        if let iconImage = nativeAd.icon?.image {
            iconUrl = imageToBase64(iconImage)
        }
        adData["iconUrl"] = iconUrl
        
        // Extract AdChoices icon
        var adChoicesIconUrl: String? = nil
        if let adChoicesInfo = nativeAd.adChoicesInfo, let logoImage = adChoicesInfo.images.first?.image {
            adChoicesIconUrl = imageToBase64(logoImage)
        }
        adData["adChoicesIconUrl"] = adChoicesIconUrl
        
        // Extract AdChoices text
        if nativeAd.adChoicesInfo != nil {
            adData["adChoicesText"] = "AdChoices"
        }
        
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
        // Generate unique ID for this ad
        let adId = UUID().uuidString
        loadedAds[adId] = nativeAd
        
        // Extract ad data
        let adData = extractAdData(from: nativeAd, adId: adId)
        
        // Resolve the call
        if let call = adLoader.userInfo?["call"] as? CAPPluginCall {
            call.resolve(adData)
        }
    }
    
    public func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        print("Ad failed to load: \(error.localizedDescription)")
        
        if let call = adLoader.userInfo?["call"] as? CAPPluginCall {
            call.reject("Ad failed to load: \(error.localizedDescription)")
        }
    }
} 