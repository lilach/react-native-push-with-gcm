package com.pushwithgcm.helpers;

import com.facebook.react.bridge.ReadableArray;

import java.io.IOException;

public class BridgeHelper {

    public static String[] ReadableArrayToStringArray(ReadableArray readableArray) throws IOException {
        if (readableArray == null) {
            return null;
        }

        String[] stringArray = new String[readableArray.size()];

        for (int i = 0; i < readableArray.size(); i++) {
            String s = readableArray.getString(i);

            if (s == null) {
                throw new IOException("Readable array cannot be transformed to a string array");
            } else {
                stringArray[i] = s;
            }

        }

        return stringArray;
    }

}
