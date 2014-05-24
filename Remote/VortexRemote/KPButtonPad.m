//
//  KPButtonPad.m
//  VortexRemote
//
//  Created by Eric Mika on 5/23/14.
//  Copyright (c) 2014 Kitschpatrol. All rights reserved.
//

#import "KPButtonPad.h"
@import QuartzCore;



const int rows = 16;
const int cols = 16;

int gridState[rows][cols];


@interface KPButtonPad ()

@property (nonatomic, assign) BOOL isTouched;
//@property (nonatomic, strong) NSArray *gridCells;

@end

@implementation KPButtonPad

- (id)initWithFrame:(CGRect)frame
{
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
  // Initialization code
  _isTouched = NO;
  _colorDown = [UIColor whiteColor];
  _colorUp = [UIColor blackColor];
  self.backgroundColor = [UIColor blackColor];
  
  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      gridState[x][y] = 0;
    }
  }
  
//  NSMutableArray *tempGridCells = [@[] mutableCopy];
//  for (int i = 0; i < cols * rows; i++) {
//    
//    CALayer gridCell = [CALayer layer];
//  }
  
}



- (void)drawRect:(CGRect)rect {
  CGFloat gridCellWidth = CGRectGetWidth(self.bounds) / (CGFloat)cols;
  CGFloat gridCellHeight = CGRectGetHeight(self.bounds) / (CGFloat)rows;
  
  // Cells
  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      
      if (gridState[x][y] == 1) {
      
      CGRect gridCellRect = CGRectMake(x * gridCellWidth, y * gridCellHeight, gridCellWidth, gridCellHeight);
      gridCellRect = CGRectInset(gridCellRect, 2, 2);
        
      UIBezierPath *gridCell = [UIBezierPath bezierPathWithRoundedRect:gridCellRect cornerRadius:6];
      [self.colorDown setFill];
//      if (gridState[x][y] == 0) {
//        [self.colorUp setFill];
//      }
//      else {
//        [self.colorDown setFill];
//      }
      [gridCell fill];
      }
    }
  }
}



//- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
//  CGPoint touchPoint = [touch locationInView:self];
//
//  self.isTouched = YES;
//  [self sendActionsForControlEvents:UIControlEventValueChanged];
//  [self setNeedsDisplay];
//
//  return YES;
//}
//
//- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
////  CGPoint touchPoint = [touch locationInView:self];
//
//  // Clamp it
//  //touchPoint.x = KPClamp(touchPoint.x, CGRectGetMinX(self.hitAreaRect), CGRectGetMaxX(self.hitAreaRect));
//  //touchPoint.y = KPClamp(touchPoint.y, CGRectGetMinY(self.hitAreaRect), CGRectGetMaxY(self.hitAreaRect));
//  //self.pickedPosition = touchPoint;
//  //[self sendActionsForControlEvents:UIControlEventValueChanged];
////  [self setNeedsDisplay];
//
//  return NO;
//}

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//
//}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [self dealWithTouches:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  [self dealWithTouches:touches];
}

- (void)dealWithTouches:(NSSet *)touches {
  for (UITouch *touch in touches) {
    CGPoint touchPoint = [touch locationInView:self];

    if ((touchPoint.x <= CGRectGetWidth(self.bounds)) && (touchPoint.y <= CGRectGetHeight(self.bounds))) {
      CGFloat gridCellWidth = CGRectGetWidth(self.bounds) / (CGFloat)cols;
      CGFloat gridCellHeight = CGRectGetHeight(self.bounds) / (CGFloat)rows;
      
      int gridX = floor(touchPoint.x / gridCellWidth);
      int gridY = floor(touchPoint.y / gridCellHeight);
      
      if (gridState[gridX][gridY] == 0) {
        gridState[gridX][gridY] = 1;
        if ([self.delegate respondsToSelector:@selector(didActivateGridLocation:)]) {
          [self.delegate didActivateGridLocation:CGPointMake(gridX, gridY)];
        }
      }
      
    }
    [self updateViewFromGridState];
  }
}

- (void)clearGrid {
  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      gridState[x][y] = 0;
    }
  }
  
  [self updateViewFromGridState];
}

- (void)updateViewFromGridState {
  [self setNeedsDisplay];
}







//- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
////  self.isTouched = NO;
//  [self setNeedsDisplay];
//}

@end
