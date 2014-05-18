//
//  KPDrillSpeedRangeViewController.m
//  VortexRemote
//
//  Created by Eric Mika on 5/18/14.
//  Copyright (c) 2014 Kitschpatrol. All rights reserved.
//

#import "KPDrillSpeedRangeViewController.h"

@interface KPDrillSpeedRangeViewController ()

@property (weak, nonatomic) IBOutlet UIStepper *lowRangeStepper;
@property (weak, nonatomic) IBOutlet UIStepper *highRangeStepper;
@property (weak, nonatomic) IBOutlet UILabel *lowRangeLabel;
@property (weak, nonatomic) IBOutlet UILabel *highRangeLabel;

@end

@implementation KPDrillSpeedRangeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didChangeLowRange:(id)sender {
    
}

- (IBAction)didChangeHighRange:(id)sender {

}

- (void)updateInterfaceFromViewModel {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
