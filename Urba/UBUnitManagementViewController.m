//
//  UBUnitManagementViewController.m
//  Urba
//
//  Created by Ricardo Nazario on 11/23/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBUnitManagementViewController.h"

@interface UBUnitManagementViewController ()

@property (weak, nonatomic) NSString *unitTitle;

@end

@implementation UBUnitManagementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *name = [_unit valueForKeyPath:@"values.name"];
    NSString *owner = [_unit valueForKeyPath:@"values.owner-name"];
    _unitTitle = [NSString stringWithFormat:@"%@ %@", name, owner];
    self.navigationItem.title = _unitTitle;
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
