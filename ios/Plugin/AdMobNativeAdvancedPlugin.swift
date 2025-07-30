import Foundation
import Capacitor
import GoogleMobileAds
import UIKit

@objc(AdMobNativeAdvancedPlugin)
public class AdMobNativeAdvancedPlugin: CAPPlugin {
    private var isInitialized = false
    private var loadedAds: [String: GADNativeAd] = [:]
    private var nativeAdViews: [String: GADNativeAdView] = [:] // Store native ad views
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
    
    @objc func positionNativeAd(_ call: CAPPluginCall) {
        guard let adId = call.getString("adId"),
              let nativeAdView = nativeAdViews[adId],
              let x = call.getDouble("x"),
              let y = call.getDouble("y"),
              let width = call.getDouble("width"),
              let height = call.getDouble("height") else {
            call.reject("Invalid parameters or ad not found")
            return
        }

        DispatchQueue.main.async {
            // Position the native ad view over the webview
            nativeAdView.frame = CGRect(x: x, y: y, width: width, height: height)
            
            // Add to the main view controller's view if not already added
            if nativeAdView.superview == nil {
                self.bridge?.viewController?.view.addSubview(nativeAdView)
            }
            
            // Bring to front to ensure it's visible over webview
            self.bridge?.viewController?.view.bringSubviewToFront(nativeAdView)
            
            call.resolve()
        }
    }
    
    @objc func hideNativeAd(_ call: CAPPluginCall) {
        guard let adId = call.getString("adId"),
              let nativeAdView = nativeAdViews[adId] else {
            call.reject("Ad not found")
            return
        }

        DispatchQueue.main.async {
            nativeAdView.removeFromSuperview()
            call.resolve()
        }
    }
    
    @objc func configureNativeAdStyle(_ call: CAPPluginCall) {
        guard let adId = call.getString("adId"),
              let nativeAdView = nativeAdViews[adId],
              let styleData = call.getObject("style") else {
            call.reject("Invalid parameters or ad not found")
            return
        }

        DispatchQueue.main.async {
            self.applyStyleToNativeAdView(nativeAdView, style: styleData)
            call.resolve()
        }
    }
    
    private func createNativeAdView(for nativeAd: GADNativeAd) -> GADNativeAdView {
        let nativeAdView = GADNativeAdView(frame: CGRect.zero)
        
        // Apply container styling to match .native-ad-container
        nativeAdView.backgroundColor = UIColor.white
        nativeAdView.layer.cornerRadius = 8
        nativeAdView.layer.borderWidth = 1
        nativeAdView.layer.borderColor = UIColor(hex: "#e0e0e0")?.cgColor
        nativeAdView.clipsToBounds = true
        
        // Add subtle shadow to match hover effect
        nativeAdView.layer.shadowColor = UIColor.black.cgColor
        nativeAdView.layer.shadowOffset = CGSize(width: 0, height: 2)
        nativeAdView.layer.shadowRadius = 4
        nativeAdView.layer.shadowOpacity = 0.05
        nativeAdView.layer.masksToBounds = false
        
        // Create and configure icon view (matches .ad-icon img)
        let iconView = UIImageView()
        iconView.image = nativeAd.icon?.image
        iconView.contentMode = .scaleAspectFill
        iconView.layer.cornerRadius = 4
        iconView.clipsToBounds = true
        nativeAdView.iconView = iconView
        nativeAdView.addSubview(iconView)
        
        // Create and configure headline label (matches .ad-headline)
        let headlineLabel = UILabel()
        headlineLabel.text = nativeAd.headline
        headlineLabel.font = UIFont.boldSystemFont(ofSize: 16)
        headlineLabel.textColor = UIColor(hex: "#333333")
        headlineLabel.numberOfLines = 0
        headlineLabel.lineBreakMode = .byWordWrapping
        nativeAdView.headlineView = headlineLabel
        nativeAdView.addSubview(headlineLabel)
        
        // Create and configure body label (matches .ad-body)
        let bodyLabel = UILabel()
        bodyLabel.text = nativeAd.body
        bodyLabel.font = UIFont.systemFont(ofSize: 14)
        bodyLabel.textColor = UIColor(hex: "#666666")
        bodyLabel.numberOfLines = 0
        bodyLabel.lineBreakMode = .byWordWrapping
        nativeAdView.bodyView = bodyLabel
        nativeAdView.addSubview(bodyLabel)
        
        // Create and configure media view (matches .ad-media img)
        let mediaView = GADMediaView()
        mediaView.mediaContent = nativeAd.mediaContent
        mediaView.contentMode = .scaleAspectFit
        mediaView.layer.cornerRadius = 4
        mediaView.clipsToBounds = true
        nativeAdView.mediaView = mediaView
        nativeAdView.addSubview(mediaView)
        
        // Create app info container (matches .ad-app-info)
        let appInfoStack = UIStackView()
        appInfoStack.axis = .horizontal
        appInfoStack.spacing = 8
        appInfoStack.alignment = .center
        nativeAdView.addSubview(appInfoStack)
        
        // Store info (matches .ad-store)
        if let store = nativeAd.store {
            let storeLabel = UILabel()
            storeLabel.text = store
            storeLabel.font = UIFont.systemFont(ofSize: 12)
            storeLabel.textColor = UIColor(hex: "#1976d2")
            storeLabel.backgroundColor = UIColor(hex: "#e3f2fd")
            storeLabel.layer.cornerRadius = 4
            storeLabel.clipsToBounds = true
            storeLabel.textAlignment = .center
            storeLabel.layoutMargins = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)
            appInfoStack.addArrangedSubview(storeLabel)
        }
        
        // Price info (matches .ad-price)
        if let price = nativeAd.price {
            let priceLabel = UILabel()
            priceLabel.text = price
            priceLabel.font = UIFont.boldSystemFont(ofSize: 12)
            priceLabel.textColor = UIColor(hex: "#4caf50")
            appInfoStack.addArrangedSubview(priceLabel)
        }
        
        // Star rating (matches .ad-rating)
        if let starRating = nativeAd.starRating {
            let ratingLabel = UILabel()
            let stars = String(repeating: "★", count: Int(starRating.doubleValue))
            let emptyStars = String(repeating: "☆", count: 5 - Int(starRating.doubleValue))
            ratingLabel.text = stars + emptyStars
            ratingLabel.font = UIFont.systemFont(ofSize: 12)
            ratingLabel.textColor = UIColor(hex: "#ff9800")
            appInfoStack.addArrangedSubview(ratingLabel)
        }
        
        // Create and configure call-to-action button (matches .ad-cta-button)
        let ctaButton = UIButton(type: .system)
        ctaButton.setTitle(nativeAd.callToAction, for: .normal)
        ctaButton.backgroundColor = UIColor(hex: "#2196f3")
        ctaButton.setTitleColor(UIColor.white, for: .normal)
        ctaButton.layer.cornerRadius = 4
        ctaButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        ctaButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        ctaButton.isUserInteractionEnabled = false // Let SDK handle full ad clicks
        nativeAdView.callToActionView = ctaButton
        nativeAdView.addSubview(ctaButton)
        
        // Create and configure advertiser label (matches .ad-advertiser)
        let advertiserLabel = UILabel()
        advertiserLabel.text = nativeAd.advertiser
        advertiserLabel.font = UIFont.systemFont(ofSize: 11)
        advertiserLabel.textColor = UIColor(hex: "#999999")
        nativeAdView.advertiserView = advertiserLabel
        nativeAdView.addSubview(advertiserLabel)
        
        // Create ad label (matches .ad-label)
        let adLabel = UILabel()
        adLabel.text = "Ad"
        adLabel.font = UIFont.boldSystemFont(ofSize: 11)
        adLabel.textColor = UIColor.white
        adLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        adLabel.layer.cornerRadius = 3
        adLabel.clipsToBounds = true
        adLabel.textAlignment = .center
        adLabel.translatesAutoresizingMaskIntoConstraints = false
        nativeAdView.addSubview(adLabel)
        
        // Create AdChoices button (matches .ad-choices)
        let adChoicesButton = UIButton(type: .system)
        adChoicesButton.setTitle("ⓘ", for: .normal) // Info symbol as fallback
        adChoicesButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        adChoicesButton.setTitleColor(UIColor(hex: "#666666"), for: .normal)
        adChoicesButton.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        adChoicesButton.layer.cornerRadius = 3
        adChoicesButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
        adChoicesButton.isUserInteractionEnabled = false // Let SDK handle
        nativeAdView.addSubview(adChoicesButton)
        
        // Layout subviews programmatically
        setupNativeAdViewLayout(nativeAdView, appInfoStack: appInfoStack, adLabel: adLabel, adChoicesButton: adChoicesButton)
        
        // Associate the native ad (required for tracking)
        nativeAdView.nativeAd = nativeAd
        
        return nativeAdView
    }
    
    private func setupNativeAdViewLayout(_ nativeAdView: GADNativeAdView, appInfoStack: UIStackView, adLabel: UILabel, adChoicesButton: UIButton) {
        // Disable autoresizing mask translation for all subviews
        nativeAdView.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        appInfoStack.translatesAutoresizingMaskIntoConstraints = false
        adLabel.translatesAutoresizingMaskIntoConstraints = false
        adChoicesButton.translatesAutoresizingMaskIntoConstraints = false
        
        guard let headlineView = nativeAdView.headlineView,
              let bodyView = nativeAdView.bodyView,
              let advertiserView = nativeAdView.advertiserView,
              let mediaView = nativeAdView.mediaView,
              let iconView = nativeAdView.iconView,
              let ctaView = nativeAdView.callToActionView else { return }
        
        NSLayoutConstraint.activate([
            // Container padding: 12px all around (matches SCSS padding)
            
            // Ad label constraints (absolute top-left, matches .ad-label)
            adLabel.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: 8),
            adLabel.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: 8),
            adLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 24),
            adLabel.heightAnchor.constraint(equalToConstant: 21),
            
            // AdChoices button constraints (absolute top-right, matches .ad-choices)
            adChoicesButton.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: 8),
            adChoicesButton.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -8),
            adChoicesButton.heightAnchor.constraint(equalToConstant: 24),
            adChoicesButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 24),
            
            // Icon constraints (40x40, float left with margin-right: 12px)
            iconView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: 12),
            iconView.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: 32), // After ad label
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalToConstant: 40),
            
            // Headline constraints (next to icon, matches layout)
            headlineView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            headlineView.topAnchor.constraint(equalTo: iconView.topAnchor),
            headlineView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -12),
            
            // Body constraints (full width, below icon/headline)
            bodyView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: 12),
            bodyView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -12),
            bodyView.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 8),
            
            // Media view constraints (full width, below body, max-height: 200px)
            mediaView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: 12),
            mediaView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -12),
            mediaView.topAnchor.constraint(equalTo: bodyView.bottomAnchor, constant: 8),
            mediaView.heightAnchor.constraint(lessThanOrEqualToConstant: 200),
            mediaView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
            
            // App info stack constraints (below media, matches .ad-app-info)
            appInfoStack.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: 12),
            appInfoStack.trailingAnchor.constraint(lessThanOrEqualTo: nativeAdView.trailingAnchor, constant: -12),
            appInfoStack.topAnchor.constraint(equalTo: mediaView.bottomAnchor, constant: 8),
            appInfoStack.heightAnchor.constraint(equalToConstant: 20),
            
            // CTA button constraints (full width, below app info)
            ctaView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: 12),
            ctaView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -12),
            ctaView.topAnchor.constraint(equalTo: appInfoStack.bottomAnchor, constant: 8),
            ctaView.heightAnchor.constraint(equalToConstant: 36),
            
            // Advertiser constraints (below CTA, matches .ad-advertiser)
            advertiserView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: 12),
            advertiserView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -12),
            advertiserView.topAnchor.constraint(equalTo: ctaView.bottomAnchor, constant: 4),
            advertiserView.bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor, constant: -12)
        ])
    }
    
    private func applyStyleToNativeAdView(_ nativeAdView: GADNativeAdView, style: [String: Any]) {
        // Container styling
        if let backgroundColor = style["backgroundColor"] as? String {
            nativeAdView.backgroundColor = UIColor(hex: backgroundColor)
        }
        
        if let cornerRadius = style["cornerRadius"] as? Double {
            nativeAdView.layer.cornerRadius = CGFloat(cornerRadius)
        }
        
        if let borderWidth = style["borderWidth"] as? Double {
            nativeAdView.layer.borderWidth = CGFloat(borderWidth)
        }
        
        if let borderColor = style["borderColor"] as? String {
            nativeAdView.layer.borderColor = UIColor(hex: borderColor)?.cgColor
        }
        
        // Headline styling
        if let headlineLabel = nativeAdView.headlineView as? UILabel {
            if let headlineColor = style["headlineColor"] as? String {
                headlineLabel.textColor = UIColor(hex: headlineColor)
            }
            if let headlineFontSize = style["headlineFontSize"] as? Double {
                headlineLabel.font = UIFont.boldSystemFont(ofSize: CGFloat(headlineFontSize))
            }
        }
        
        // Body styling
        if let bodyLabel = nativeAdView.bodyView as? UILabel {
            if let bodyColor = style["bodyColor"] as? String {
                bodyLabel.textColor = UIColor(hex: bodyColor)
            }
            if let bodyFontSize = style["bodyFontSize"] as? Double {
                bodyLabel.font = UIFont.systemFont(ofSize: CGFloat(bodyFontSize))
            }
        }
        
        // Advertiser styling
        if let advertiserLabel = nativeAdView.advertiserView as? UILabel {
            if let advertiserColor = style["advertiserColor"] as? String {
                advertiserLabel.textColor = UIColor(hex: advertiserColor)
            }
            if let advertiserFontSize = style["advertiserFontSize"] as? Double {
                advertiserLabel.font = UIFont.systemFont(ofSize: CGFloat(advertiserFontSize))
            }
        }
        
        // CTA button styling
        if let ctaButton = nativeAdView.callToActionView as? UIButton {
            if let ctaBackgroundColor = style["ctaBackgroundColor"] as? String {
                ctaButton.backgroundColor = UIColor(hex: ctaBackgroundColor)
            }
            if let ctaTextColor = style["ctaTextColor"] as? String {
                ctaButton.setTitleColor(UIColor(hex: ctaTextColor), for: .normal)
            }
            if let ctaFontSize = style["ctaFontSize"] as? Double {
                ctaButton.titleLabel?.font = UIFont.systemFont(ofSize: CGFloat(ctaFontSize))
            }
        }
        
        // Apply hover-like shadow effect
        nativeAdView.layer.shadowOpacity = 0.1
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
        
        // Mark as natively rendered for iOS
        adData["nativeRendered"] = true
        
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
    
    deinit {
        // Clean up native ad views
        for (_, adView) in nativeAdViews {
            adView.removeFromSuperview()
        }
        nativeAdViews.removeAll()
        
        // Clean up timeout tasks
        for (_, task) in timeoutTasks {
            task.cancel()
        }
        timeoutTasks.removeAll()
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
        
        // Set delegate for click handling
        nativeAd.delegate = self
        
        // Create native ad view for iOS overlay
        let nativeAdView = createNativeAdView(for: nativeAd)
        nativeAdViews[adId] = nativeAdView
        
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

// MARK: - GADNativeAdDelegate
extension AdMobNativeAdvancedPlugin: GADNativeAdDelegate {
    public func nativeAdDidRecordClick(_ nativeAd: GADNativeAd) {
        // Find the ad ID for this native ad
        for (adId, ad) in loadedAds {
            if ad === nativeAd {
                // Notify JavaScript listeners about the click
                notifyListeners("adClicked", data: ["adId": adId])
                break
            }
        }
    }
    
    public func nativeAdDidRecordImpression(_ nativeAd: GADNativeAd) {
        // Find the ad ID for this native ad
        for (adId, ad) in loadedAds {
            if ad === nativeAd {
                // Notify JavaScript listeners about the impression
                notifyListeners("adImpression", data: ["adId": adId])
                break
            }
        }
    }
    
    public func nativeAdWillPresentScreen(_ nativeAd: GADNativeAd) {
        // Ad will present a full screen view
        for (adId, ad) in loadedAds {
            if ad === nativeAd {
                notifyListeners("adWillPresentScreen", data: ["adId": adId])
                break
            }
        }
    }
    
    public func nativeAdDidDismissScreen(_ nativeAd: GADNativeAd) {
        // Ad did dismiss full screen view
        for (adId, ad) in loadedAds {
            if ad === nativeAd {
                notifyListeners("adDidDismissScreen", data: ["adId": adId])
                break
            }
        }
    }
}

// MARK: - UIColor Extension for Hex Colors
extension UIColor {
    convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x0000ff) / 255
                    a = 1.0

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
} 