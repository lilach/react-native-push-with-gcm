## react-native-push-with-gcm

Register device for GCM push notifications services (supported only for
iOS)

## Installation

Make sure that you are in your React Native project directory and run:

```bash
npm install react-native-push-with-gcm --save
```

### Installing manually

In XCode, in the project navigator:
- Right click Libraries
- Add Files to [your project's name]
- Go to node_modules/react-native-push-with-gcm
- Add the `RCTPushWithGCM` folder within `ios` directory

## Requirements

- Google Cloud Messaging. You can find the instructions
  [here](https://developers.google.com/cloud-messaging/ios/start).
- react-native

## Usage

First you need to configure and connect to GCM:

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
PushWithGCM.registerUser(token, isSandbox)
```

If there are topics you'd like this device to be registered to, you can
easily do that too. after registration send an array of all the topics
to register to:

```javascript
PushWithGCM.subscribeToTopics(['push', 'with', 'gcm'])
```

## Contributing

1. Fork it (
   https://github.com/lilach/react-native-push-with-gcm/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
