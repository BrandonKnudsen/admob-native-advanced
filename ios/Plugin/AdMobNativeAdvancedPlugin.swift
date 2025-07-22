import Foundation
import Capacitor
import GoogleMobileAds
import UIKit

@objc(AdMobNativeAdvancedPlugin)
public class AdMobNativeAdvancedPlugin: CAPPlugin {
    private var isInitialized = false
    private var loadedAds: [String: GADNativeAd] = [:]
    private var pendingCalls: [Int: CAPPluginCall] = [:] // Keyed by adLoader's hashValue
    private var timeoutTasks: [Int: DispatchWorkItem] = [:] // Track timeout tasks
    
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
            call.reject("Missing adUnitId parameter")
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                call.reject("Plugin instance deallocated")
                return
            }
            
            // Create AdLoader for native ads
            let adLoader = GADAdLoader(
                adUnitID: adUnitId,
                rootViewController: nil,
                adTypes: [.native],
                options: nil
            )
            adLoader.delegate = self
            
            // Store the call for later resolution
            self.pendingCalls[adLoader.hash] = call
            
            // Create timeout task (10 seconds as specified in instructions)
            let timeoutTask = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                
                // Check if call is still pending and resolve with timeout error
                if let pendingCall = self.pendingCalls.removeValue(forKey: adLoader.hash) {
                    self.timeoutTasks.removeValue(forKey: adLoader.hash)
                    pendingCall.reject("Ad load timeout - no response within 10 seconds")
                }
            }
            
            // Store timeout task
            self.timeoutTasks[adLoader.hash] = timeoutTask
            
            // Schedule timeout
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0, execute: timeoutTask)
            
            // Load the ad
            let request = GADRequest()
            adLoader.load(request)
        }
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
    
    private func cleanupCall(for adLoader: GADAdLoader) {
        // Cancel timeout task if it exists
        if let timeoutTask = timeoutTasks.removeValue(forKey: adLoader.hash) {
            timeoutTask.cancel()
        }
        // Remove pending call
        pendingCalls.removeValue(forKey: adLoader.hash)
    }
}

// MARK: - GADNativeAdLoaderDelegate
extension AdMobNativeAdvancedPlugin: GADNativeAdLoaderDelegate {
    public func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        // Get the pending call before cleanup
        guard let call = pendingCalls[adLoader.hash] else {
            print("Warning: Received ad but no pending call found")
            return
        }
        
        // Clean up timeout and pending call
        cleanupCall(for: adLoader)
        
        // Generate unique ad ID and store the ad
        let adId = UUID().uuidString
        loadedAds[adId] = nativeAd
        
        // Extract ad data and resolve the call
        let adData = extractAdData(from: nativeAd, adId: adId)
        call.resolve(adData)
    }
    
    public func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        print("Ad failed to load: \(error.localizedDescription)")
        
        // Get the pending call before cleanup
        guard let call = pendingCalls[adLoader.hash] else {
            print("Warning: Ad load failed but no pending call found")
            return
        }
        
        // Clean up timeout and pending call
        cleanupCall(for: adLoader)
        
        // Reject the call with detailed error
        call.reject("Failed to load ad: \(error.localizedDescription)")
    }
} 