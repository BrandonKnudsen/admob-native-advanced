import { registerPlugin } from '@capacitor/core';
const AdMobNativeAdvanced = registerPlugin('AdMobNativeAdvanced', {
    web: () => import('./web').then(m => new m.AdMobNativeAdvancedWeb()),
});
export * from './definitions';
export { AdMobNativeAdvanced };
