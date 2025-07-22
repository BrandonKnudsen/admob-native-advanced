import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

const db = admin.firestore();

// Interface for AdMob configuration
interface AdMobConfig {
  appId: string;
  adUnitIds: {
    android: string;
    ios: string;
  };
  testMode: boolean;
  refreshInterval: number; // in seconds
}

// Interface for ad analytics
interface AdAnalytics {
  adId: string;
  adUnitId: string;
  platform: 'android' | 'ios';
  event: 'impression' | 'click' | 'load' | 'error';
  timestamp: admin.firestore.Timestamp;
  userId?: string;
  sessionId?: string;
}

/**
 * Get AdMob configuration for a specific app
 * This function can be used to dynamically configure ad settings
 */
export const getAdMobConfig = functions.https.onCall(async (data, context) => {
  try {
    const { appId } = data;
    
    if (!appId) {
      throw new functions.https.HttpsError('invalid-argument', 'App ID is required');
    }

    // Get configuration from Firestore
    const configDoc = await db.collection('admob-configs').doc(appId).get();
    
    if (!configDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Configuration not found for this app');
    }

    const config = configDoc.data() as AdMobConfig;
    
    return {
      success: true,
      config
    };
  } catch (error) {
    console.error('Error getting AdMob config:', error);
    throw new functions.https.HttpsError('internal', 'Failed to get configuration');
  }
});

/**
 * Log ad analytics events
 * This function can be used to track ad performance and user behavior
 */
export const logAdAnalytics = functions.https.onCall(async (data, context) => {
  try {
    const { adId, adUnitId, platform, event, userId, sessionId } = data;
    
    if (!adId || !adUnitId || !platform || !event) {
      throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
    }

    const analytics: AdAnalytics = {
      adId,
      adUnitId,
      platform,
      event,
      timestamp: admin.firestore.Timestamp.now(),
      userId: userId || context.auth?.uid,
      sessionId
    };

    // Store analytics in Firestore
    await db.collection('ad-analytics').add(analytics);
    
    return {
      success: true,
      message: 'Analytics logged successfully'
    };
  } catch (error) {
    console.error('Error logging ad analytics:', error);
    throw new functions.https.HttpsError('internal', 'Failed to log analytics');
  }
});

/**
 * Get ad performance metrics
 * This function provides aggregated analytics for dashboard or reporting
 */
export const getAdMetrics = functions.https.onCall(async (data, context) => {
  try {
    const { adUnitId, startDate, endDate, platform } = data;
    
    if (!adUnitId || !startDate || !endDate) {
      throw new functions.https.HttpsError('invalid-argument', 'Missing required fields');
    }

    let query = db.collection('ad-analytics')
      .where('adUnitId', '==', adUnitId)
      .where('timestamp', '>=', new Date(startDate))
      .where('timestamp', '<=', new Date(endDate));

    if (platform) {
      query = query.where('platform', '==', platform);
    }

    const snapshot = await query.get();
    
    const metrics = {
      totalImpressions: 0,
      totalClicks: 0,
      totalLoads: 0,
      totalErrors: 0,
      clickThroughRate: 0,
      platformBreakdown: {
        android: { impressions: 0, clicks: 0 },
        ios: { impressions: 0, clicks: 0 }
      }
    };

    snapshot.forEach(doc => {
      const data = doc.data() as AdAnalytics;
      
      switch (data.event) {
        case 'impression':
          metrics.totalImpressions++;
          metrics.platformBreakdown[data.platform].impressions++;
          break;
        case 'click':
          metrics.totalClicks++;
          metrics.platformBreakdown[data.platform].clicks++;
          break;
        case 'load':
          metrics.totalLoads++;
          break;
        case 'error':
          metrics.totalErrors++;
          break;
      }
    });

    // Calculate click-through rate
    if (metrics.totalImpressions > 0) {
      metrics.clickThroughRate = (metrics.totalClicks / metrics.totalImpressions) * 100;
    }

    return {
      success: true,
      metrics
    };
  } catch (error) {
    console.error('Error getting ad metrics:', error);
    throw new functions.https.HttpsError('internal', 'Failed to get metrics');
  }
});

/**
 * A/B Testing configuration for ad units
 * This function can be used to test different ad configurations
 */
export const getABTestConfig = functions.https.onCall(async (data, context) => {
  try {
    const { userId, experimentId } = data;
    
    if (!experimentId) {
      throw new functions.https.HttpsError('invalid-argument', 'Experiment ID is required');
    }

    // Get A/B test configuration from Firestore
    const experimentDoc = await db.collection('ab-tests').doc(experimentId).get();
    
    if (!experimentDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Experiment not found');
    }

    const experiment = experimentDoc.data();
    
    // Simple A/B test assignment based on user ID
    const userHash = userId ? userId.hashCode() : Math.random().toString().hashCode();
    const variant = userHash % 2 === 0 ? 'A' : 'B';
    
    return {
      success: true,
      variant,
      config: experiment[variant]
    };
  } catch (error) {
    console.error('Error getting A/B test config:', error);
    throw new functions.https.HttpsError('internal', 'Failed to get A/B test configuration');
  }
});

/**
 * Scheduled function to clean up old analytics data
 * Runs daily to maintain database performance
 */
export const cleanupOldAnalytics = functions.pubsub.schedule('every 24 hours').onRun(async (context) => {
  try {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const snapshot = await db.collection('ad-analytics')
      .where('timestamp', '<', thirtyDaysAgo)
      .limit(1000)
      .get();

    const batch = db.batch();
    snapshot.docs.forEach(doc => {
      batch.delete(doc.ref);
    });

    await batch.commit();
    
    console.log(`Cleaned up ${snapshot.docs.length} old analytics records`);
    return null;
  } catch (error) {
    console.error('Error cleaning up old analytics:', error);
    return null;
  }
});

// Helper function for string hashing (used in A/B testing)
declare global {
  interface String {
    hashCode(): number;
  }
}

String.prototype.hashCode = function() {
  let hash = 0;
  if (this.length === 0) return hash;
  for (let i = 0; i < this.length; i++) {
    const char = this.charCodeAt(i);
    hash = ((hash << 5) - hash) + char;
    hash = hash & hash; // Convert to 32-bit integer
  }
  return Math.abs(hash);
}; 