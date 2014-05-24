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

@interface KPViewController () <KPButtonPadDelegate>

// Controls
@property (weak, nonatomic) IBOutlet UILabel *connectionLabel;

@property (weak, nonatomic) IBOutlet UILabel *drillSpeedLabel;
@property (weak, nonatomic) IBOutlet UISlider *drillSpeedSlider;
@property (weak, nonatomic) IBOutlet UIStepper *drillSpeedStepper;

@property (weak, nonatomic) IBOutlet UILabel *blinkIntervalLabel;
@property (weak, nonatomic) IBOutlet UISlider *blinkIntervalSlider;
@property (weak, nonatomic) IBOutlet UIStepper *blinkIntervalStepper;

@property (strong, nonatomic) KPButtonPad *buttonGrid;

@end

@implementation KPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  
  self.buttonGrid = [[KPButtonPad alloc] initWithFrame:CGRectMake(0, 350, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 350)];
  self.buttonGrid.delegate = self;
  [self.view addSubview:self.buttonGrid];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[KPVortex defaultVortex] addObserver:self forKeyPath:@"blinkInterval" options:0 context:NULL];
    [[KPVortex defaultVortex] addObserver:self forKeyPath:@"drillSpeed" options:0 context:NULL];
    [[KPVortex defaultVortex] addObserver:self forKeyPath:@"connectionState" options:0 context:NULL];
    
    [self updateInterfaceFromViewModel];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[KPVortex defaultVortex] removeObserver:self forKeyPath:@"blinkInterval"];
    [[KPVortex defaultVortex] removeObserver:self forKeyPath:@"drillSpeed"];
    [[KPVortex defaultVortex] removeObserver:self forKeyPath:@"connectionState"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSLog(@"Value change for key path: %@", keyPath);
    [self updateInterfaceFromViewModel];
}


#pragma mark - Event handling

- (IBAction)connect:(id)sender {
    [[KPVortex defaultVortex] connect];
    self.connectionLabel.text = @"Connecting";
}

- (IBAction)didChangeDrillSpeed:(id)sender {
    [KPVortex defaultVortex].drillSpeed = ((UISlider *)sender).value;
}

- (IBAction)didStepDrillSpeed:(id)sender {
    [KPVortex defaultVortex].drillSpeed = ((UIStepper *)sender).value;
}

- (IBAction)didChangeBlinkInterval:(id)sender {
    [KPVortex defaultVortex].blinkInterval = pow(10, ((UISlider *)sender).value); // Log
}

- (IBAction)didStepBlinkInterval:(id)sender {
    [KPVortex defaultVortex].blinkInterval = pow(10, ((UIStepper *)sender).value); // Log
}

- (void)updateInterfaceFromViewModel {
    self.drillSpeedLabel.text = [NSString stringWithFormat:@"%i%%", (NSUInteger)([KPVortex defaultVortex].drillSpeed * 100)];
    self.drillSpeedStepper.value = [KPVortex defaultVortex].drillSpeed;
    self.drillSpeedSlider.value = [KPVortex defaultVortex].drillSpeed;
    
    NSString *blinkLabel;
    if ([KPVortex defaultVortex].blinkInterval < 1000) {
        blinkLabel = [NSString stringWithFormat:@"%iµs", [KPVortex defaultVortex].blinkInterval];
    }
    else if ([KPVortex defaultVortex].blinkInterval < 1000000) {
        blinkLabel = [NSString stringWithFormat:@"%.2fms", (CGFloat)[KPVortex defaultVortex].blinkInterval / 1000.0];
    }
    else {
        blinkLabel = [NSString stringWithFormat:@"%.2fs", (CGFloat)[KPVortex defaultVortex].blinkInterval / 1000000.0];
    }
    
    self.blinkIntervalLabel.text = blinkLabel;
    self.blinkIntervalStepper.value = log([KPVortex defaultVortex].blinkInterval) / log(10); // cope with log scale
    self.blinkIntervalSlider.value = log([KPVortex defaultVortex].blinkInterval) / log(10); // cope with log scale
    
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



- (IBAction)didTouchStepAndOnButton:(id)sender {
  static NSUInteger indexStep = 0;
  
  UIColor *randomColor = [KPKit randomColorWithAlpha:1.0];
  [[KPVortex defaultVortex] setLEDatIndex:indexStep toColor:randomColor];
  
  indexStep++;
  indexStep %= 255;
}

- (IBAction)didTouchAllOnButton:(id)sender {
  [[KPVortex defaultVortex] setAllLEDsOn];
}

- (IBAction)didTouchAllOffButton:(id)sender {
   [[KPVortex defaultVortex] setAllLEDsOff];
  [self.buttonGrid clearGrid];
}


-(void)didActivateGridLocation:(CGPoint)point {
  [[KPVortex defaultVortex] setLEDatPosition:point toColor:[UIColor whiteColor]];
}


@end


