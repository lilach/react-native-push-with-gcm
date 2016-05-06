import React from 'react-native'
var PushWithGCM = React.NativeModules.PushWithGCM

module.exports = {
  configure () {
    PushWithGCM.configureGCM()
  },

  registerToken (deviceToken, sandbox) {
    PushWithGCM.registerToGCMWithDeviceToken(deviceToken, sandbox)
  },

  unregisterToken () {
    PushWithGCM.unregisterTokenFromGCM()
  },

  subscribeToTopics (topics) {
    PushWithGCM.subscribeToTopics(topics)
  },

  unsubscribeFromTopics (topics) {
    PushWithGCM.unsubscribeFromTopics(topics)
  }
}
