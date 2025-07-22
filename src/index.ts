import { registerPlugin } from '@capacitor/core';
import type { 
  AdMobNativeAdvancedPlugin, 
  InitializeOptions, 
  LoadAdOptions, 
  NativeAdData 
} from './definitions';

const AdMobNativeAdvanced = registerPlugin<AdMobNativeAdvancedPlugin>('AdMobNativeAdvanced', {
  web: () => import('./web').then(m => new m.AdMobNativeAdvancedWeb()),
});

export * from './definitions';
export { AdMobNativeAdvanced }; 