#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// Define the plugin using the CAP_PLUGIN macro
CAP_PLUGIN(AdMobNativeAdvancedPlugin, "AdMobNativeAdvanced",
           CAP_PLUGIN_METHOD(initialize, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(loadAd, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(reportClick, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(reportImpression, CAPPluginReturnPromise);
) 