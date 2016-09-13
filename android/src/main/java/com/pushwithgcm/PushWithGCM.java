package com.pushwithgcm;

import android.util.Log;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.google.android.gms.gcm.GcmPubSub;
import com.google.android.gms.gcm.GoogleCloudMessaging;
import com.google.android.gms.iid.InstanceID;
import com.pushwithgcm.helpers.BridgeHelper;
import com.pushwithgcm.R;

import java.io.IOException;

public class PushWithGCM extends ReactContextBaseJavaModule {

    private static final String TAG = "PushWithGCM";
    private static String gcmSenderId;
    private static String[] topics = new String[]{};
    private static GcmPubSub gcmPubSub;
    private static InstanceID instanceID;

    public PushWithGCM(ReactApplicationContext reactContext, String GCMSenderId) {
        super(reactContext);
        PushWithGCM.gcmSenderId = gcmSenderId;
        PushWithGCM.gcmPubSub = GcmPubSub.getInstance(getReactApplicationContext());
        PushWithGCM.instanceID = InstanceID.getInstance(getReactApplicationContext());
    }

    @Override
    public String getName() {
        return "PushWithGCM";
    }

    @ReactMethod
    public void subscribeToTopics(ReadableArray topics) throws IOException {
        subscribeToTopics(BridgeHelper.ReadableArrayToStringArray(topics));
    }

    @ReactMethod
    public void unsubscribeFromTopics(ReadableArray topics) throws IOException {
        unsubscribeFromTopics(BridgeHelper.ReadableArrayToStringArray(topics));
    }

    public static void subscribeToTopics() {
        subscribeToTopics(PushWithGCM.topics);
    }

    public static void subscribeToTopics(String[] topics) {
        PushWithGCM.topics = topics;

        String token = obtainToken();

        if(token != null) {
            for (String topic : topics) {
                try {
                    gcmPubSub.subscribe(token, "/topics/" + topic, null);
                } catch (IOException e) {
                    Log.e(TAG, String.format("Subscription failed for topic %s: %s", topic, e.getMessage()));
                }
            }
        }
    }

    public static void unsubscribeFromTopics() {
        unsubscribeFromTopics(PushWithGCM.topics);
    }

    public static void unsubscribeFromTopics(String[] topics) {
        PushWithGCM.topics = new String[]{};

        String token = obtainToken();

        if(token != null) {
            for (String topic : topics) {
                try {
                    gcmPubSub.unsubscribe(token, "/topics/" + topic);
                } catch (IOException e) {
                    Log.e(TAG, String.format("UnSubscription failed for topic %s: %s", topic, e.getMessage()));
                }
            }
        }
    }

    private static String obtainToken() {
        String token = null;
        try {
            token = instanceID.getToken(gcmSenderId,
                    GoogleCloudMessaging.INSTANCE_ID_SCOPE);
        } catch (IOException e) {
            Log.e(TAG, String.format("Registration to GCM failed with error: %s", e.getMessage()));
        }

        return token;
    }
}
