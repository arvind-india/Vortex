//
//  LPSlider.h
//  SciGames2
//
//  Created by Eric Mika on 1/3/14.
//  Copyright (c) 2014 Local Projects. All rights reserved.
//

@import UIKit;

@interface KPSlider : UIControl

@property (nonatomic, strong) UIColor *handleColor;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic) CGFloat currentValue;
@property (nonatomic, readonly, strong) UIView *handle;
@property (nonatomic, strong) NSString *sliderName;

@end
