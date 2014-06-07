//
//  KPButtonPad.h
//  VortexRemote
//
//  Created by Eric Mika on 5/23/14.
//  Copyright (c) 2014 Kitschpatrol. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KPButtonPadDelegate <NSObject>

-(void)didActivateGridLocation:(CGPoint)point;
-(void)didDeactivateGridLocation:(CGPoint)point;

@end

@interface KPButtonPad : UIControl

- (void)clearGrid;

@property (nonatomic, strong) UIColor *colorDown;
@property (nonatomic, strong) UIColor *colorUp;

@property (nonatomic, assign) id<KPButtonPadDelegate> delegate;

@end
