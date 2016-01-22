//
//  ViewController.m
//  CircleProcessBar
//
//  Created by dl on 16/1/21.
//  Copyright © 2016年 dl. All rights reserved.
//

#import "ViewController.h"
#import "CircleProcessBarView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet CircleProcessBarView *containerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)animate:(id)sender {
    [self.containerView animate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
