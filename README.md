# react-native-push-with-gcm

[![npm
version](https://badge.fury.io/js/react-native-push-with-gcm@2x.png)](http://badge.fury.io/js/react-native-push-with-gcm)

Register device for GCM push notifications services (supported only for
iOS)

## Installation

Make sure that you are in your React Native project directory and run:

```bash
npm install react-native-push-with-gcm --save
```

### Installing with rnpm

```bash
rnpm install react-native-push-with-gcm
```
will install the npm package and link it to your project.

If you already installed the package using the previous command,
```bash
rnpm link react-native-push-with-gcm
```
will magically link it

### Installing manually

#### iOS

In XCode, in the project navigator:
- Right click Libraries
- Add Files to [your project's name]
- Go to node_modules/react-native-push-with-gcm
- Add the Add the .xcodeproj file

In XCode, in the project navigator, select your project.

Add the libRCTPushWithGCM.a from the deviceinfo project to your project's
Build Phases ➜ Link Binary With Libraries
Click .xcodeproj file you added before in the project navigator and go
the Build Settings tab. Make sure 'All' is toggled on (instead of
'Basic').
Look for Header Search Paths and add this as `non-recursive`:
`$(SRCROOT)/../node_modules/react-native-push-with-gcm/ios/RCTPushWithGCM/RCTPushWithGCM`

#### Android

- Edit `build.gradle` to look like this:
```java
apply plugin: 'com.android.application'

android {
  ...
}

dependencies {
  ...
+ compile project(':react-native-push-with-gcm')
}
```

- In `settings.gradle`, insert the following code:
```
include ':react-native-push-with-gcm'
project(':react-native-push-with-gcm').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-push-with-gcm/android')
```

## Requirements

- Google Cloud Messaging. You can find the instructions
  [here](https://developers.google.com/cloud-messaging/ios/start).
- react-native

## Usage

### Setup

#### iOS

For iOS devices only, you'll need to configure and connect to GCM:

```javascript
var PushWithGCM = require('react-native-push-with-gcm')

componentDidMount() {
  PushWithGCM.configure()
}
```

Once your app registers for push notifications, grab that token
(PushNotificationsIOS will give this token as a string) and register
that token in GCM. You also need to supply a boolean value for your APNS
server sandbox option (hint: sandbox is used for development):

```javascript
PushWithGCM.registerToken(token, isSandbox)
```

To unregister a user from GCM service:
```javascript
PushWithGCM.unregisterToken()
```
> Note, you can only have one token or deleteToken call for a given
> authorizedEntity and scope at a point of time. Making another such
> call with the same authorizedEntity and scope before the last one
> finishes will result in an error with code OperationInProgress.
>
> (from the
> [docs](https://developers.google.com/instance-id/reference/ios/api/interface_g_g_l_instance_i_d.html#method-detail))

#### Android

- Get a `GCM_SENDER_ID` by registering your app in the following [link](https://developers.google.com/mobile/add).

- Edit your MainActivity.java to look like this:
```
package com.myapp;

+ import com.oblador.keychain.KeychainPackage;
....

public class MainActivity extends extends ReactActivity {

  @Override
  protected List<ReactPackage> getPackages() {
      return Arrays.<ReactPackage>asList(
              new MainReactPackage(),
+             new PushWithGCMPackage(<GCM_SENDER_ID>)
      );
  }
  ...
}
```

- Create a GCM listener service to handle received notifications:

```
package com.myklarnamobile;

import com.google.android.gms.gcm.GcmListenerService;

public class PushWithGCMListenerService extends GcmListenerService {
    @Override
    public void OnMessage(String from, Bundle data) {
    // Customized notification handling.
    }
}
```

> For more information, read [overview of GCM message format] (https://developers.google.com/cloud-messaging/concept-options#notifications_and_data_messages) and [guide for implementing a GCM listener service](https://developers.google.com/cloud-messaging/downstream).

- Edit your AndroidManifest.xml to look like this:

```
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="<YOUR_PACKAGE_NAME>">
    ...
+   <permission android:name="com.myklarnamobile.permission.C2D_MESSAGE"
+       android:protectionLevel="signature" />
+   <uses-permission android:name="com.myklarnamobile.permission.C2D_MESSAGE" />
+   <uses-permission android:name="android.permission.WAKE_LOCK" />

    <application>
      ...
+     <receiver
+       android:name="com.google.android.gms.gcm.GcmReceiver"
+       android:exported="true"
+       android:permission="com.google.android.c2dm.permission.SEND" >
+       <intent-filter>
+         <action android:name="com.google.android.c2dm.intent.RECEIVE" />
+         <action android:name="com.google.android.c2dm.intent.REGISTRATION" />
+           <category android:name="com.myklarnamobile" />
+       </intent-filter>
+     </receiver>
+     <service android:name="<YOUR_PACKAGE_NAME>.PushWithGCMListenerService"
+              android:exported="false" >
+       <intent-filter>
+         <action android:name="com.google.android.c2dm.intent.RECEIVE" />
+       </intent-filter>
+     </service>
+     <service
+         android:name="com.pushwithgcm.GCMInstanceIDListenerService"
+         android:exported="false">
+       <intent-filter>
+         <action android:name="com.google.android.gms.iid.InstanceID" />
+       </intent-filter>
+     </service>
    </application>
</manifest>
```

### Subscription to topics
If there are topics you'd like this device to be registered to, you can
easily do that too. after registration send an array of all the topics
to register to:

```javascript
PushWithGCM.subscribeToTopics(['push', 'with', 'gcm'])
```
These topics will be registered as `/topics/push`, `/topics/with` and
`/topics/gcm`.

When you're done with these topics, simply call
```js
PushWithGCM.unsubscribeFromTopics(['first-time-users'])
```

## Troubleshooting

If you installed GoogleCloudMessaging using cocoapods (which is the
recommended way, so awesome) and are having trouble with compiling the
app, make sure these properties are set properly in your XCode project:

- add `$(inherited)` to `Other Linker Flags` (or `OTHER_LDFLAGS`)
- set `Enable Modules` to `YES`
- set `iOS Deployment Target` to `7.1` at least
- set `Enable Bitcode` to `NO`

## Contributing

1. Fork it (
   https://github.com/lilach/react-native-push-with-gcm/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
