//
//  RCTPushWithGCM.m
//  RCTPushWithGCM
//
//  Created by Lilach Adir on 4/26/16.
//  Copyright © 2016 Lilach Adir. All rights reserved.
//

#import "RCTPushWithGCM.h"

@interface PushWithGCM ()

@property(nonatomic, copy) NSString *gcmSenderID;
@property(nonatomic, copy) NSString *registrationKey;
@property(nonatomic, copy) NSString *messageKey;
@property(nonatomic, copy) NSString *registrationToken;
@property(nonatomic, strong) NSArray *topics;
@property(nonatomic, strong) NSDictionary *registrationOptions;
@property(nonatomic, strong) void (^registrationHandler)(NSString *registrationToken, NSError *error);
@property(nonatomic, assign) BOOL connectedToGCM;
@property(nonatomic, assign) BOOL subscribedToTopic;

@end

@implementation PushWithGCM {
  
}

RCT_EXPORT_MODULE()

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

RCT_EXPORT_METHOD(configureGCM)
{
  _registrationKey = @"onRegistrationCompleted";
  _messageKey = @"onMessageReceived";
  // Configure the Google context: parses the GoogleService-Info.plist, and initializes
  // the services that have entries in the file
  NSError* configureError;
  [[GGLContext sharedInstance] configureWithError:&configureError];
  NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
  _gcmSenderID = [[[GGLContext sharedInstance] configuration] gcmSenderID];
  
  GCMConfig *gcmConfig = [GCMConfig defaultConfig];
  gcmConfig.receiverDelegate = self;
  [[GCMService sharedInstance] startWithConfig:gcmConfig];
  
  GGLInstanceIDConfig *instanceIDConfig = [GGLInstanceIDConfig defaultConfig];
  instanceIDConfig.delegate = self;
  [[GGLInstanceID sharedInstance] startWithConfig: instanceIDConfig];
  
  __weak typeof(self) weakSelf = self;
  // Handler for registration token request
  _registrationHandler = ^(NSString *registrationToken, NSError *error) {
    if (registrationToken != nil) {
      weakSelf.registrationToken = registrationToken;
      NSLog(@"Registration Token: %@", registrationToken);
      
      // Connect to the GCM server to receive non-APNS notifications
      [[GCMService sharedInstance] connectWithHandler:^(NSError *error) {
        if (error) {
          NSLog(@"Could not connect to GCM: %@", error.localizedDescription);
        } else {
          _connectedToGCM = true;
          NSLog(@"Connected to GCM");
          [weakSelf subscribeToTopics:(weakSelf.topics)];
        }
      }];
      
      NSDictionary *userInfo = @{@"registrationToken":registrationToken};
      [[NSNotificationCenter defaultCenter] postNotificationName: weakSelf.registrationKey
                                                          object: nil
                                                        userInfo: userInfo];
    } else {
      NSLog(@"Registration to GCM failed with error: %@", error.localizedDescription);
      NSDictionary *userInfo = @{@"error":error.localizedDescription};
      [[NSNotificationCenter defaultCenter] postNotificationName: weakSelf.registrationKey
                                                          object: nil
                                                        userInfo: userInfo];
    }
  };
}

- (NSData *)dataFromHexString:(NSString *)string
{
  string = [string lowercaseString];
  NSMutableData *data= [NSMutableData new];
  unsigned char whole_byte;
  char byte_chars[3] = {'\0','\0','\0'};
  int i = 0;
  NSUInteger length = string.length;
  while (i < length-1) {
    char c = [string characterAtIndex:i++];
    if (c < '0' || (c > '9' && c < 'a') || c > 'f')
      continue;
    byte_chars[0] = c;
    byte_chars[1] = [string characterAtIndex:i++];
    whole_byte = strtol(byte_chars, NULL, 16);
    [data appendBytes:&whole_byte length:1];
  }
  return data;
}

RCT_EXPORT_METHOD(registerToGCMWithDeviceToken:(NSString *)deviceToken isSandbox:(BOOL)sandbox)
{
  NSData *token = [self dataFromHexString:deviceToken];
  _registrationOptions = @{kGGLInstanceIDRegisterAPNSOption: token,
                           kGGLInstanceIDAPNSServerTypeSandboxOption: @(sandbox)};
  [[GGLInstanceID sharedInstance] tokenWithAuthorizedEntity: _gcmSenderID
                                                      scope: kGGLInstanceIDScopeGCM
                                                    options: _registrationOptions
                                                    handler: _registrationHandler];
}

RCT_EXPORT_METHOD(unregisterTokenFromGCM)
{
  [[GGLInstanceID sharedInstance] deleteTokenWithAuthorizedEntity:_gcmSenderID
                                                            scope:kGGLInstanceIDScopeGCM
                                                          handler:^(NSError *error) {
                                                            // handle the error
                                                            NSLog(@"Delete token failed: %@",
                                                                  error.localizedDescription);
                                                          }];
}

- (void)onTokenRefresh {
  // A rotation of the registration tokens is happening, so the app needs to request a new token.
  NSLog(@"The GCM registration token needs to be changed.");
  [[GGLInstanceID sharedInstance] tokenWithAuthorizedEntity: _gcmSenderID
                                                      scope: kGGLInstanceIDScopeGCM
                                                    options: _registrationOptions
                                                    handler: _registrationHandler];
}

RCT_EXPORT_METHOD(subscribeToTopics:(NSArray *)topics)
{
  // If the app has a registration token and is connected to GCM, proceed to subscribe to the
  // topic
  if (_registrationToken && _connectedToGCM) {
    for (NSString *topic in topics) {
      [[GCMPubSub sharedInstance] subscribeWithToken: _registrationToken
                                               topic: [NSString stringWithFormat:@"/topics/%@", topic]
                                             options: nil
                                             handler: ^(NSError *error) {
                                               if (error) {
                                                 // Treat the "already subscribed" error more gently
                                                 if (error.code == 3001) {
                                                   NSLog(@"Already subscribed to %@",
                                                         topic);
                                                 } else {
                                                   NSLog(@"Subscription failed: %@",
                                                         error.localizedDescription);
                                                 }
                                               } else {
                                                 self.subscribedToTopic = true;
                                                 NSLog(@"Subscribed to %@", topic);
                                               }
                                             }];
    }
    self.topics = nil;
  } else {
    self.topics = topics;
  }
}

RCT_EXPORT_METHOD(unsubscribeFromTopics:(NSArray *)topics)
{
  // If the app has a registration token and is connected to GCM, proceed to subscribe to the
  // topic
  if (_registrationToken && _connectedToGCM) {
    for (NSString *topic in topics) {
      [[GCMPubSub sharedInstance] unsubscribeWithToken: _registrationToken
                                                 topic: [NSString stringWithFormat:@"/topics/%@", topic]
                                               options: nil
                                               handler: ^(NSError *error) {
                                                 if (error) {
                                                   int code = error.code;
                                                   // handle the error, using exponential backoff to retry
                                                   NSLog(@"Unsubscribe failed: %@",
                                                         error.localizedDescription);
                                                 } else {
                                                   // Unsubscribe successfully
                                                   NSLog(@"Unsubscribed from %@", topic);
                                                 }
                                               }];
    }
  }
}

@end
