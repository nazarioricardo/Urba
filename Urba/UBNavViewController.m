//
//  UBNavViewController.m
//  Urba
//
//  Created by Ricardo Nazario on 12/27/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBNavViewController.h"

@interface UBNavViewController ()

@end

@implementation UBNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, 20)];
    view.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:190.0/255.0 blue:58.0/255.0 alpha:1];
    [self.view addSubview:view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
