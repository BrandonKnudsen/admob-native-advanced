package com.capacitorjs.plugins.admobnativeadvanced;

import android.app.Activity;
import android.content.Context;
import android.util.Log;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.google.android.gms.ads.AdError;
import com.google.android.gms.ads.AdLoader;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.FullScreenContentCallback;
import com.google.android.gms.ads.LoadAdError;
import com.google.android.gms.ads.MobileAds;
import com.google.android.gms.ads.nativead.NativeAd;
import com.google.android.gms.ads.nativead.NativeAdView;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@CapacitorPlugin(name = "AdMobNativeAdvanced")
public class AdMobNativeAdvancedPlugin extends Plugin {
    private static final String TAG = "AdMobNativeAdvanced";
    private boolean isInitialized = false;
    private Map<String, NativeAd> loadedAds = new HashMap<>();

    @PluginMethod
    public void initialize(PluginCall call) {
        try {
            String appId = call.getString("appId");
            if (appId == null || appId.isEmpty()) {
                call.reject("App ID is required");
                return;
            }

            Activity activity = getActivity();
            if (activity == null) {
                call.reject("Activity is null");
                return;
            }

            // Initialize MobileAds SDK
            MobileAds.initialize(activity, initializationStatus -> {
                isInitialized = true;
                Log.d(TAG, "AdMob initialized successfully");
                call.resolve();
            });

        } catch (Exception e) {
            Log.e(TAG, "Error initializing AdMob", e);
            call.reject("Failed to initialize AdMob: " + e.getMessage());
        }
    }

    @PluginMethod
    public void loadAd(PluginCall call) {
        try {
            if (!isInitialized) {
                call.reject("AdMob must be initialized before loading ads");
                return;
            }

            String adUnitId = call.getString("adUnitId");
            if (adUnitId == null || adUnitId.isEmpty()) {
                call.reject("Ad Unit ID is required");
                return;
            }

            Activity activity = getActivity();
            if (activity == null) {
                call.reject("Activity is null");
                return;
            }

            // Create AdLoader for native ads
            AdLoader adLoader = new AdLoader.Builder(activity, adUnitId)
                    .forNativeAd(nativeAd -> {
                        // Generate unique ID for this ad
                        String adId = UUID.randomUUID().toString();
                        loadedAds.put(adId, nativeAd);

                        // Extract ad data
                        JSObject adData = extractAdData(nativeAd, adId);
                        call.resolve(adData);
                    })
                    .withAdListener(new com.google.android.gms.ads.AdListener() {
                        @Override
                        public void onAdFailedToLoad(LoadAdError loadAdError) {
                            Log.e(TAG, "Ad failed to load: " + loadAdError.getMessage());
                            call.reject("Ad failed to load: " + loadAdError.getMessage());
                        }
                    })
                    .build();

            // Load the ad
            AdRequest adRequest = new AdRequest.Builder().build();
            adLoader.loadAd(adRequest);

        } catch (Exception e) {
            Log.e(TAG, "Error loading ad", e);
            call.reject("Failed to load ad: " + e.getMessage());
        }
    }

    @PluginMethod
    public void reportClick(PluginCall call) {
        try {
            String adId = call.getString("adId");
            if (adId == null || adId.isEmpty()) {
                call.reject("Ad ID is required");
                return;
            }

            NativeAd nativeAd = loadedAds.get(adId);
            if (nativeAd != null) {
                // Report click to AdMob
                nativeAd.recordClick();
                call.resolve();
            } else {
                call.reject("Ad not found with ID: " + adId);
            }

        } catch (Exception e) {
            Log.e(TAG, "Error reporting click", e);
            call.reject("Failed to report click: " + e.getMessage());
        }
    }

    @PluginMethod
    public void reportImpression(PluginCall call) {
        try {
            String adId = call.getString("adId");
            if (adId == null || adId.isEmpty()) {
                call.reject("Ad ID is required");
                return;
            }

            NativeAd nativeAd = loadedAds.get(adId);
            if (nativeAd != null) {
                // Report impression to AdMob
                nativeAd.recordImpression();
                call.resolve();
            } else {
                call.reject("Ad not found with ID: " + adId);
            }

        } catch (Exception e) {
            Log.e(TAG, "Error reporting impression", e);
            call.reject("Failed to report impression: " + e.getMessage());
        }
    }

    private JSObject extractAdData(NativeAd nativeAd, String adId) {
        JSObject adData = new JSObject();
        adData.put("adId", adId);

        // Extract headline
        if (nativeAd.getHeadline() != null) {
            adData.put("headline", nativeAd.getHeadline());
        }

        // Extract body
        if (nativeAd.getBody() != null) {
            adData.put("body", nativeAd.getBody());
        }

        // Extract call to action
        if (nativeAd.getCallToAction() != null) {
            adData.put("callToAction", nativeAd.getCallToAction());
        }

        // Extract advertiser
        if (nativeAd.getAdvertiser() != null) {
            adData.put("advertiser", nativeAd.getAdvertiser());
        }

        // Extract store (for app install ads)
        if (nativeAd.getStore() != null) {
            adData.put("store", nativeAd.getStore());
        }

        // Extract price (for app install ads)
        if (nativeAd.getPrice() != null) {
            adData.put("price", nativeAd.getPrice());
        }

        // Extract star rating (for app install ads)
        if (nativeAd.getStarRating() != null) {
            adData.put("starRating", nativeAd.getStarRating().doubleValue());
        }

        // Extract media content
        if (nativeAd.getMediaContent() != null && nativeAd.getMediaContent().getMediaUri() != null) {
            adData.put("mediaContentUrl", nativeAd.getMediaContent().getMediaUri().toString());
        }

        // Extract icon
        if (nativeAd.getIcon() != null && nativeAd.getIcon().getUri() != null) {
            adData.put("iconUrl", nativeAd.getIcon().getUri().toString());
        }

        // Extract AdChoices icon
        if (nativeAd.getAdChoicesInfo() != null && nativeAd.getAdChoicesInfo().getLogo() != null) {
            adData.put("adChoicesIconUrl", nativeAd.getAdChoicesInfo().getLogo().getUri().toString());
        }

        // Extract AdChoices text
        if (nativeAd.getAdChoicesInfo() != null) {
            adData.put("adChoicesText", "AdChoices");
        }

        // Determine ad type
        adData.put("isAppInstallAd", nativeAd.getStore() != null);
        adData.put("isContentAd", nativeAd.getStore() == null);

        return adData;
    }

    @Override
    public void handleOnDestroy() {
        super.handleOnDestroy();
        // Clean up loaded ads
        loadedAds.clear();
    }
} 