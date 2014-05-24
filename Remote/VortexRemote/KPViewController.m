//
//  KPViewController.m
//  VortexRemote
//
//  Created by Eric Mika on 5/18/14.
//  Copyright (c) 2014 Kitschpatrol. All rights reserved.
//

#import "KPViewController.h"
#import "KPVortex.h"
#import "KPKit.h"
#import "KPButtonPad.h"
#import "KPButton.h"
#import "KPSlider.h"

const CGFloat minLoopDurationMicros =  250000; // quarter second
const CGFloat maxLoopDurationMicros = 3000000; // three seconds

const CGFloat drawLoopDurationMultiplier = 1.0;

@interface KPViewController () <KPButtonPadDelegate>

// Controls

@property (strong, nonatomic) UIColor *ledColor;

@property (weak, nonatomic) IBOutlet KPSlider *drawLoopDurationSlider;
@property (weak, nonatomic) IBOutlet KPSlider *drillSpeedSlider;
@property (weak, nonatomic) IBOutlet KPSlider *hueSlider;

@property (weak, nonatomic) IBOutlet KPButton *connectionButton;
@property (weak, nonatomic) IBOutlet UILabel *connectionLabel;

@property (weak, nonatomic) IBOutlet KPButtonPad *buttonGrid;

@property (weak, nonatomic) IBOutlet KPButton *allOffButton;
@property (weak, nonatomic) IBOutlet KPButton *allOnButton;


@end

@implementation KPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  
  //self.buttonGrid = [[KPButtonPad alloc] initWithFrame:CGRectMake(0, 350, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 350)];
  self.buttonGrid.delegate = self;
//  [self.view addSubview:self.buttonGrid];
  
  _ledColor = [UIColor whiteColor];

  
  
  self.drawLoopDurationSlider.sliderName = @"Time Scale";
  self.drillSpeedSlider.sliderName = @"Rotation Speed";
  self.connectionButton.buttonName = @"Connect";
  self.allOffButton.buttonName = @"Clear";
  self.allOnButton.buttonName = @"All On";
  
  self.hueSlider.sliderName = @"Color";
  
  [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
  
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[KPVortex defaultVortex] addObserver:self forKeyPath:@"drawLoopDuration" options:0 context:NULL];
    [[KPVortex defaultVortex] addObserver:self forKeyPath:@"drillSpeed" options:0 context:NULL];
    [[KPVortex defaultVortex] addObserver:self forKeyPath:@"connectionState" options:0 context:NULL];
    
    [self updateInterfaceFromViewModel];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[KPVortex defaultVortex] removeObserver:self forKeyPath:@"drawLoopDuration"];
    [[KPVortex defaultVortex] removeObserver:self forKeyPath:@"drillSpeed"];
    [[KPVortex defaultVortex] removeObserver:self forKeyPath:@"connectionState"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSLog(@"Value change for key path: %@", keyPath);
    [self updateInterfaceFromViewModel];
}


#pragma mark - Event handling

- (IBAction)didTouchConnectButton:(id)sender {
    [[KPVortex defaultVortex] connect];
    self.connectionLabel.text = @"Connecting";
}

- (IBAction)didChangeDrillSpeed:(id)sender {
  [KPVortex defaultVortex].drillSpeed = self.drillSpeedSlider.currentValue;
}




- (IBAction)didChangeDrawLoopDuration:(id)sender {
  [KPVortex defaultVortex].timeScale = self.drawLoopDurationSlider.currentValue;
//  if (self.drawLoopDurationSlider.currentValue == 0) {
//    [KPVortex defaultVortex].drawLoopDuration = 0;
//  }
//  else {
//    [KPVortex defaultVortex].drawLoopDuration = KPMap(self.drawLoopDurationSlider.currentValue, (CGFloat)0.0, (CGFloat)1.0, minLoopDurationMicros, maxLoopDurationMicros);
//    //[KPVortex defaultVortex].drawLoopDuration = pow(10, self.drawLoopDurationSlider.currentValue * 6) * drawLoopDurationMultiplier; // Log
//  }
//  
//  
}

- (IBAction)didChangeHue:(id)sender {
  
  if (self.hueSlider.currentValue == 0) {
    self.ledColor = [UIColor whiteColor];
  }
  else {
    CGFloat targetHue = self.hueSlider.currentValue + 0.5;

    // Wrap it
    if (targetHue > 1.0) targetHue = targetHue - 1.0;
    
    self.ledColor = [UIColor colorWithHue:targetHue saturation:1.0 brightness:1.0 alpha:1.0];
  }
  
  self.hueSlider.backgroundColor = self.ledColor;
}


- (void)updateInterfaceFromViewModel {

    self.drillSpeedSlider.currentValue = [KPVortex defaultVortex].drillSpeed;
  self.drawLoopDurationSlider.currentValue = [KPVortex defaultVortex].timeScale;
//  if ([KPVortex defaultVortex].drawLoopDuration == 0) {
//    self.drawLoopDurationSlider.currentValue = 0;
//  }
//  else {
//    self.drawLoopDurationSlider.currentValue = KPMap([KPVortex defaultVortex].drawLoopDuration, minLoopDurationMicros, maxLoopDurationMicros, (CGFloat)0.0, (CGFloat)1.0);
//    //self.drawLoopDurationSlider.currentValue = ((log([KPVortex defaultVortex].drawLoopDuration) / log(10)) / 6) / drawLoopDurationMultiplier; // cope with log scale
//  }
  
    if ([KPVortex defaultVortex].connectionState == CBPeripheralStateConnected) {
        self.connectionLabel.text = @"Connected";
    }
    else if ([KPVortex defaultVortex].connectionState == CBPeripheralStateConnecting) {
        self.connectionLabel.text = @"Searching";
    }
    else if ([KPVortex defaultVortex].connectionState == CBPeripheralStateDisconnected) {
        self.connectionLabel.text = @"Disconnected";
    }
    else {
        self.connectionLabel.text = @"";
    }
}



//- (IBAction)didTouchStepAndOnButton:(id)sender {
//  static NSUInteger indexStep = 0;
//  
//  UIColor *randomColor = [KPKit randomColorWithAlpha:1.0];
//  [[KPVortex defaultVortex] setLEDatIndex:indexStep toColor:randomColor];
//  
//  indexStep++;
//  indexStep %= 255;
//}

- (IBAction)didTouchAllOnButton:(id)sender {
  [[KPVortex defaultVortex] setAllLEDsOn];
}

- (IBAction)didTouchAllOffButton:(id)sender {
   [[KPVortex defaultVortex] setAllLEDsOff];
  [self.buttonGrid clearGrid];
}


-(void)didActivateGridLocation:(CGPoint)point {
  [[KPVortex defaultVortex] setLEDatPosition:point toColor:self.ledColor];
}


@end


