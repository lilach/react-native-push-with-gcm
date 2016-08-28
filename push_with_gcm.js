import ReactNative from 'react-native'
var PushWithGCM = ReactNative.NativeModules.PushWithGCM

module.exports = {
  configure () {
    PushWithGCM.configureGCM()
  },

  async registerToken (deviceToken, sandbox) {
    return await PushWithGCM.registerToGCMWithDeviceToken(deviceToken, sandbox)
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
