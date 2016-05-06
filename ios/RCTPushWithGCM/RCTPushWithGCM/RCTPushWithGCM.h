//
//  RCTPushWithGCM.h
//  RCTPushWithGCM
//
//  Created by Lilach Adir on 4/26/16.
//  Copyright © 2016 Lilach Adir. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Google/CloudMessaging.h>
#import "RCTBridgeModule.h"


@interface PushWithGCM : NSObject <RCTBridgeModule, GCMReceiverDelegate, GGLInstanceIDDelegate>

@end
