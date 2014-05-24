//
//  KPVortex.m
//  VortexRemote
//
//  Created by Eric Mika on 5/18/14.
//  Copyright (c) 2014 Kitschpatrol. All rights reserved.
//

#import "KPVortex.h"
#import "BLE.h"


const NSUInteger ledRows = 16;
const NSUInteger ledColumns = 16;

@interface KPVortex () <BLEDelegate>

@property (nonatomic, strong) BLE *bleMini;

@end

@implementation KPVortex

+ (KPVortex *)defaultVortex {
    static KPVortex* sharedInstance = nil;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        sharedInstance = [[KPVortex alloc] init];
    });
    
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _blinkInterval = 0.0;
        _drillSpeed = 0.0;
        _drillSpeedMinimum = 0.0;
        _drillSpeedMaximum = 1.0;
        
        _bleMini = [[BLE alloc] init];
        [_bleMini controlSetup];
        _bleMini.delegate = self;
        
        [_bleMini addObserver:self forKeyPath:@"activePeripheral.state" options:0 context:NULL];
    }
    return self;
}

- (void)dealloc {
    [_bleMini removeObserver:self forKeyPath:@"activePeripheral.state"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"activePeripheral.state"]) {
        self.connectionState = self.bleMini.activePeripheral.state;
    }
}

# pragma mark - BLEDelegate

-(void) bleDidReceiveData:(unsigned char *)data length:(int)length{
    //NSData *d = [NSData dataWithBytes:data length:length];
    //NSString *s = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
}


-(void) bleDidConnect {

}

- (void) bleDidDisconnect {

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

- (void)BLEShieldScan {
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

- (void)sendMessageToBle:(NSString *)message {
  NSLog(@"Sending message: %@", message);
  
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


- (void)setDrillSpeed:(CGFloat)drillSpeed {
    _drillSpeed = drillSpeed;
    
    // Send the message
    NSString *message = [NSString stringWithFormat:@"d%.4f\n", self.drillSpeed];
    [self sendMessageToBle:message];
}

- (void)setBlinkInterval:(NSUInteger)blinkInterval {
    _blinkInterval = blinkInterval;
    
    // Send the message
    NSString *message = [NSString stringWithFormat:@"b%lu\n", (unsigned long)self.blinkInterval];
    [self sendMessageToBle:message];
}

- (void)setAllLEDsOn {
  // Send the message
  NSString *message = [NSString stringWithFormat:@"o\n"];
  [self sendMessageToBle:message];
}

- (void)setAllLEDsOff {
  NSString *message = [NSString stringWithFormat:@"c\n"];
  [self sendMessageToBle:message];
}

- (void)setLEDatPosition:(CGPoint)position toColor:(UIColor *)color {
  // Convert point to array address...
  NSUInteger ledIndex = (((ledRows - 1) - position.y) * ledColumns) + position.x;
  [self setLEDatIndex:ledIndex toColor:color];
}

- (void)setLEDatIndex:(NSUInteger)index toColor:(UIColor *)color {
  // TODO lookup table to map to "real" index?
  CGFloat r, g, b, a;
  [color getRed:&r green:&g blue:&b alpha:&a];
  
  NSUInteger redComponent = (NSUInteger)(r * 255.0);
  NSUInteger greenComponent = (NSUInteger)(g * 255.0);
  NSUInteger blueComponent = (NSUInteger)(b * 255.0);
  
  NSString *message = [NSString stringWithFormat:@"s%03i%03i%03i%03i\n", index, redComponent, greenComponent, blueComponent];
  
  [self sendMessageToBle:message];
  
}


- (void)connect {
    [self BLEShieldScan];
}

- (void)disconnect {
    // TODO
}


@end
