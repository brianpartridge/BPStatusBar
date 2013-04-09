//
//  BPDemoViewController.m
//  Demo
//
//  Created by Brian Partridge on 4/9/13.
//  Copyright (c) 2013 Brian Partridge. All rights reserved.
//

#import "BPDemoViewController.h"
#import "BPStatusBar.h"

@interface BPDemoViewController ()

@end

@implementation BPDemoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)indetermianteTapped:(id)sender {
    [BPStatusBar showWithStatus:@"Processing..."];
}

- (IBAction)dismissTapped:(id)sender {
    [BPStatusBar dismiss];
}

- (IBAction)successTapped:(id)sender {
    [BPStatusBar showSuccessWithStatus:@"Task Success"];
}

- (IBAction)errorTapped:(id)sender {
    [BPStatusBar showErrorWithStatus:@"Task Failed"];
}
@end
