//
//  KPButton.h
//  VortexRemote
//
//  Created by Eric Mika on 5/24/14.
//  Copyright (c) 2014 Kitschpatrol. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KPButton : UIControl

@property (nonatomic, strong) NSString* buttonName;
@property (nonatomic, strong) UIColor* colorUp;
@property (nonatomic, strong) UIColor* colorDown;
@property (nonatomic, strong) UIColor* textColorUp;
@property (nonatomic, strong) UIColor* textColorDown;

@end
