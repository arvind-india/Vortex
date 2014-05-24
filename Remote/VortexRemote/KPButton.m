//
//  KPButton.m
//  VortexRemote
//
//  Created by Eric Mika on 5/24/14.
//  Copyright (c) 2014 Kitschpatrol. All rights reserved.
//

#import "KPButton.h"

@interface KPButton ()

@property (nonatomic, strong) UILabel *buttonLabel;
@property (nonatomic, assign) BOOL buttonDown;

@end

@implementation KPButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      [self sharedInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self sharedInit];
  }
  return self;
}

- (void)sharedInit {
  _colorUp = [UIColor blackColor];
  _colorDown = [UIColor whiteColor];
  _textColorUp = [UIColor whiteColor];
  _textColorDown = [UIColor blackColor];
  self.backgroundColor = [UIColor clearColor];
  _buttonDown = NO;
  
  _buttonName = @"Button Name";
  _buttonLabel = [[UILabel alloc] init];
  _buttonLabel.font = [UIFont fontWithName:@"DIN Alternate" size:30.0];
  _buttonLabel.textAlignment = NSTextAlignmentCenter;
  _buttonLabel.text = [_buttonName uppercaseString];
  [self addSubview:_buttonLabel];
  
  [self setNeedsLayout];
}


- (void)drawRect:(CGRect)rect
{

  // draw background
  UIBezierPath *buttonRect = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:6];
  self.buttonDown ? [self.colorDown setFill] : [self.colorUp setFill];
  
  self.buttonLabel.textColor = self.buttonDown ? self.textColorDown : self.textColorUp;
  
  [buttonRect fill];
}


- (void)layoutSubviews {
    [super layoutSubviews];
  
  self.buttonLabel.frame = self.bounds;
  
}


- (void)setButtonName:(NSString *)buttonName {
  _buttonName = buttonName;
  self.buttonLabel.text = [self.buttonName uppercaseString];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

  if (!self.buttonDown) {
    self.buttonDown = YES;
    [self sendActionsForControlEvents:UIControlEventTouchDown];
    [self setNeedsDisplay];
  }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (self.buttonDown) {
    self.buttonDown = NO;
    [self setNeedsDisplay];
  }
}



@end
