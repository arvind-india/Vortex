//
//  KPViewController.m
//  VortexRemote
//
//  Created by Eric Mika on 5/18/14.
//  Copyright (c) 2014 Kitschpatrol. All rights reserved.
//

#import "KPViewController.h"
#import "BLE.h"

@interface KPViewController () <BLEDelegate>


@property (nonatomic, strong) BLE *bleMini;

// View model
@property (nonatomic, assign) NSUInteger blinkInterval;
@property (nonatomic, assign) CGFloat drillSpeed;
    // Log scale for the slider, 0 to 1,000,000

// Controls
@property (weak, nonatomic) IBOutlet UILabel *connectionLabel;

@property (weak, nonatomic) IBOutlet UILabel *drillSpeedLabel;
@property (weak, nonatomic) IBOutlet UISlider *drillSpeedSlider;
@property (weak, nonatomic) IBOutlet UIStepper *drillSpeedStepper;

@property (weak, nonatomic) IBOutlet UILabel *blinkIntervalLabel;
@property (weak, nonatomic) IBOutlet UISlider *blinkIntervalSlider;
@property (weak, nonatomic) IBOutlet UIStepper *blinkIntervalStepper;

@end

@implementation KPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.bleMini = [[BLE alloc] init];
    [self.bleMini controlSetup];
    self.bleMini.delegate = self;
    
    self.drillSpeed = 0.0;
    self.blinkInterval = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
       [self addObserver:self forKeyPath:@"self.bleMini.activePeripheral.state" options:0 context:NULL];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self removeObserver:self forKeyPath:@"self.bleMini.activePeripheral.state"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"self.bleMini.activePeripheral.state"]) {
        [self updateInterfaceFromViewModel];
    }
}

- (void)setDrillSpeed:(CGFloat)drillSpeed {
    _drillSpeed = drillSpeed;
    
    // Send the message
    NSString *message = [NSString stringWithFormat:@"d%.4f\n", self.drillSpeed];
    [self sendMessageToBle:message];
    
    [self updateInterfaceFromViewModel];
}

- (void)setBlinkInterval:(NSUInteger)blinkInterval {
    _blinkInterval = blinkInterval;
    
    // Send the message
    NSString *message = [NSString stringWithFormat:@"b%lu\n", (unsigned long)self.blinkInterval];
    [self sendMessageToBle:message];
    
    [self updateInterfaceFromViewModel];
}

# pragma mark - BLE Connection

- (void)connectionTimer:(NSTimer *)timer {
    if(self.bleMini.peripherals.count > 0)
    {
        [self.bleMini connectPeripheral:[self.bleMini.peripherals objectAtIndex:0]];
    }
    else {
        //[activityIndicator stopAnimating];
    }
}

- (IBAction)BLEShieldScan:(id)sender {
    if (self.bleMini.activePeripheral)
        if(self.bleMini.activePeripheral.state == CBPeripheralStateConnected)
        {
            [[self.bleMini CM] cancelPeripheralConnection:[self.bleMini activePeripheral]];
            return;
        }
    
    if (self.bleMini.peripherals)
        self.bleMini.peripherals = nil;
    
    [self.bleMini findBLEPeripherals:3];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)3.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
}

# pragma mark - BLEDelegate

-(void) bleDidReceiveData:(unsigned char *)data length:(int)length{
    //NSData *d = [NSData dataWithBytes:data length:length];
    //NSString *s = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
}


-(void) bleDidConnect {
    [self updateInterfaceFromViewModel];
}

- (void) bleDidDisconnect {
    [self updateInterfaceFromViewModel];
}


- (void)sendMessageToBle:(NSString *)message {
    
    NSString *s;
    NSData *d;
    
    if (message.length > 16) {
        s = [message substringToIndex:16];
    }
    else {
        s = message;
    }
    
    d = [s dataUsingEncoding:NSUTF8StringEncoding];
    if (self.bleMini.activePeripheral.state == CBPeripheralStateConnected) {
        [self.bleMini write:d];
    }
}


#pragma mark - Event handling

- (IBAction)didChangeDrillSpeed:(id)sender {
    self.drillSpeed = ((UISlider *)sender).value;
}

- (IBAction)didStepDrillSpeed:(id)sender {
    self.drillSpeed = ((UIStepper *)sender).value;
}

- (IBAction)didChangeBlinkInterval:(id)sender {
    self.blinkInterval = pow(10, ((UISlider *)sender).value); // Log
}

- (IBAction)didStepBlinkInterval:(id)sender {
    self.blinkInterval = pow(10, ((UIStepper *)sender).value); // Log
}

- (void)updateInterfaceFromViewModel {
    self.drillSpeedLabel.text = [NSString stringWithFormat:@"%i%%", (NSUInteger)(self.drillSpeed * 100)];
    self.drillSpeedStepper.value = self.drillSpeed;
    self.drillSpeedSlider.value = self.drillSpeed;

    
    NSString *blinkLabel;
    if (self.blinkInterval < 1000) {
        blinkLabel = [NSString stringWithFormat:@"%iµs", self.blinkInterval];
    }
    else if (self.blinkInterval < 1000000) {
        blinkLabel = [NSString stringWithFormat:@"%.2fms", (CGFloat)self.blinkInterval / 1000.0];
    }
    else {
        blinkLabel = [NSString stringWithFormat:@"%.2fs", (CGFloat)self.blinkInterval / 1000000.0];
    }
    
    self.blinkIntervalLabel.text = blinkLabel;
    self.blinkIntervalStepper.value = log(self.blinkInterval) / log(10); // cope with log scale
    self.blinkIntervalSlider.value = log(self.blinkInterval) / log(10); // cope with log scale

    if (self.bleMini.activePeripheral.state == CBPeripheralStateConnected) {
        self.connectionLabel.text = @"Connected";
    }
    else if (self.bleMini.activePeripheral.state == CBPeripheralStateConnecting) {
        self.connectionLabel.text = @"Searching";
    }
    else {
       self.connectionLabel.text = @"Disconnected";
    }
    
    self.connectionLabel.text = (self.bleMini.activePeripheral.state == CBPeripheralStateConnected) ? @"Connected" : @"Disconnected";
}
     

@end
