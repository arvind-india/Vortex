//
//  LPSlider.m
//  SciGames2
//
//  Created by Eric Mika on 1/3/14.
//  Copyright (c) 2014 Local Projects. All rights reserved.
//

#import "KPSlider.h"
#import "KPKit.h"

@interface KPSlider ()

@property (nonatomic, strong) CAShapeLayer *trackLine;
@property (nonatomic, strong) CAShapeLayer *handleCircle;

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *valueLabel;

@property (nonatomic, readwrite, strong) UIView *handle;

@property (nonatomic) CGFloat handleWidth;     // Recalculated on frame changes, potentially
@property (nonatomic) CGFloat scrubbableWidth; // Recalculated on frame changes

//@property (nonatomic, getter=isHumanScrubbing) BOOL humanScrubbing;

@end

@implementation KPSlider

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self sharedInit];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self sharedInit];
  }
  return self;
}


- (void)sharedInit {
  _backgroundColor = [UIColor grayColor];
  _handleColor = [UIColor blackColor];
  _currentValue = 0.0;
  
  self.backgroundColor = _backgroundColor;
  
  // "Track" line behind slider
  self.trackLine = [CAShapeLayer layer];
  self.trackLine.strokeColor = nil;
  self.trackLine.lineWidth = 0;
  self.trackLine.fillColor = [self.backgroundColor CGColor];
  [self.layer addSublayer:self.trackLine];
  
  self.handle = [[UIView alloc] init];
  self.handle.userInteractionEnabled = NO;
  
  // "Circle" in the handle
  self.handleCircle = [CAShapeLayer layer];
  self.handleCircle.fillColor = [UIColor whiteColor].CGColor;
  self.handleCircle.strokeColor = nil;
  self.handleCircle.lineWidth = 0;
  [self.handle.layer addSublayer:self.handleCircle];
  [self addSubview:self.handle];
  
  // Labels
  _sliderName = @"Slider Name";
  self.nameLabel = [[UILabel alloc] init];
  self.nameLabel.font = [UIFont fontWithName:@"DIN Alternate" size:30.0];
  self.nameLabel.textAlignment = NSTextAlignmentLeft;
  self.nameLabel.text = [self.sliderName uppercaseString];
  [self addSubview:self.nameLabel];
  
  self.valueLabel = [[UILabel alloc] init];
  self.valueLabel.font = [UIFont fontWithName:@"DIN Alternate" size:30.0];
  self.valueLabel.textAlignment = NSTextAlignmentRight;
  [self addSubview:self.valueLabel];
  
  [self setNeedsLayout];
}

- (void)setCurrentValue:(CGFloat)currentValue {
  _currentValue = currentValue;
  [self setNeedsLayout];
}

- (void)setHandleColor:(UIColor *)handleColor {
  _handleColor = handleColor;
  self.handle.backgroundColor = self.handleColor;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  self.handle.frame = CGRectMake(self.currentValue * self.scrubbableWidth, 0, self.bounds.size.height, self.bounds.size.height);
  CGFloat circleInset = 4; //CGRectGetHeight(self.handle.bounds) * 0.2f;
  CGRect circleBounds = CGRectInset(self.handle.bounds, circleInset, circleInset);
  UIBezierPath *circlePath = [UIBezierPath bezierPathWithRoundedRect:circleBounds cornerRadius:5];
  self.handleCircle.path = circlePath.CGPath;


  // Background track thing
  UIBezierPath *trackLinePath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:8];
  self.trackLine.path = trackLinePath.CGPath;

  self.handleWidth = self.handle.bounds.size.width;
  self.scrubbableWidth = self.bounds.size.width - self.handle.bounds.size.width;
  
  
  // Labels
  self.nameLabel.frame = CGRectInset(self.bounds, 10, 0);
  self.valueLabel.frame = CGRectInset(self.bounds, 10, 0);
  self.valueLabel.text = [NSString stringWithFormat:@"%.2f", self.currentValue];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
  CGPoint touchPoint = [touch locationInView:self];

  // Validate point
  if ((touchPoint.x >= 0) && (touchPoint.x <= self.bounds.size.width)) {
    self.currentValue = MIN(touchPoint.x - (self.handleWidth / 2), self.scrubbableWidth) / self.scrubbableWidth;
    [self setNeedsLayout];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
  } else {
    return NO;
  }
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
  CGPoint touchPoint = [touch locationInView:self];
  self.currentValue = KPClamp(touchPoint.x - (self.handleWidth / 2), 0, self.scrubbableWidth) / self.scrubbableWidth;
  [self setNeedsLayout];
  [self sendActionsForControlEvents:UIControlEventValueChanged];
  return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
  KP_LOG_FUNCTION
}


- (void)setBackgroundColor:(UIColor *)backgroundColor {
  _backgroundColor = backgroundColor;
    self.trackLine.fillColor = [self.backgroundColor CGColor];
//  [self setNeedsLayout];
}

- (void)setSliderName:(NSString *)sliderName {
  _sliderName = sliderName;
  self.nameLabel.text = [self.sliderName uppercaseString];
  [self setNeedsLayout];
}

@end
