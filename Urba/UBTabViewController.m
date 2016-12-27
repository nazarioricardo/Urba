//
//  UBTabViewController.m
//  Urba
//
//  Created by Ricardo Nazario on 12/16/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBTabViewController.h"
#import "UBUnitViewController.h"
#import "UBUnitRequestsViewController.h"
#import "UBSettingsViewController.h"

@interface UBTabViewController ()

@end

@implementation UBTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_unitDict forKey:@"currentUnit"];
    
    UINavigationController *navOne = [[self viewControllers] objectAtIndex:0];
    UBUnitViewController *uvc = (UBUnitViewController *)[navOne topViewController];
    UINavigationController *navTwo = [[self viewControllers] objectAtIndex:1];
    UBUnitRequestsViewController *rvc = (UBUnitRequestsViewController *)[navTwo topViewController];
    UINavigationController *navThree = [[self viewControllers] objectAtIndex:2];
    UBSettingsViewController *svc = (UBSettingsViewController *)[navThree topViewController];
    [uvc setUnitDict:_unitDict];
    [rvc setUnitDict:_unitDict];
    [svc setUnitDict:_unitDict];
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary  dictionaryWithObjectsAndKeys: [UIColor grayColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [[UITabBar appearance] setUnselectedItemTintColor:[UIColor grayColor]];

    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil] forState:UIControlStateSelected];
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
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
