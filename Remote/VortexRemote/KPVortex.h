//
//  KPVortex.h
//  VortexRemote
//
//  Created by Eric Mika on 5/18/14.
//  Copyright (c) 2014 Kitschpatrol. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KPVortex : NSObject

+ (KPVortex *)defaultVortex;

- (void)connect;
- (void)disconnect;

@property (nonatomic, assign) NSUInteger blinkInterval;
@property (nonatomic, assign) CGFloat drillSpeed;

@end
