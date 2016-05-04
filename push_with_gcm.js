import React from 'react-native'
var PushWithGCM = React.NativeModules.PushWithGCM

module.exports = {
  configure () {
    PushWithGCM.configureGCM()
  },

  registerUser (deviceToken, sandbox) {
    PushWithGCM.registerToGCMWithDeviceToken(deviceToken, sandbox)
  },

  subscribeToTopics (topics) {
    PushWithGCM.subscribeToTopics(topics)
  }
}
