//
//  UBSettingsViewController.m
//  Urba
//
//  Created by Ricardo Nazario on 12/2/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBSettingsViewController.h"
#import "UBUnitUsersTableViewController.h"
#import "UBWelcomeViewController.h"

@import FirebaseAuth;
@import FirebaseDatabase;

@interface UBSettingsViewController ()

@property (strong, nonatomic) NSString *unitName;
@property (strong, nonatomic) NSString *unitId;
@property (strong, nonatomic) NSString *address;

@end

@implementation UBSettingsViewController

- (IBAction)signOutPressed:(id)sender {
    
    NSLog(@"Current User: %@", [FIRAuth auth].currentUser.email);

    NSError *signOutError;
    BOOL status = [[FIRAuth auth] signOut:&signOutError];
    if (!status) {
        NSLog(@"Sign out error: %@", signOutError);
        return;
    }
    NSString *storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    UBWelcomeViewController *uwvc = [storyboard instantiateViewControllerWithIdentifier:@"Welcome"];
    [self presentViewController:uwvc animated:YES completion:nil];

}

- (IBAction)unitUsersPressed:(id)sender {
    [self performSegueWithIdentifier:@"ManageUsersSegue" sender:self];
}

- (IBAction)otherUnitPressed:(id)sender {
    [self performSegueWithIdentifier:@"ChangeUnitSegue" sender:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *name = [_unitDict valueForKeyPath:@"values.name"];
    NSString *superUnit = [_unitDict valueForKeyPath:@"values.super-unit"];
    _address = [NSString stringWithFormat:@"%@ %@", name, superUnit];
    
    _unitId = [_unitDict valueForKey:@"id"];
}

-(void)viewWillAppear:(BOOL)animated {
    // BUG: If accepting a user request before loading this view, the address remains null.
    self.navigationItem.title = _address;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    if ([segue.identifier isEqualToString:@"ManageUsersSegue"]) {
        UINavigationController *nav = [segue destinationViewController];
        UBUnitUsersTableViewController *uuvc = (UBUnitUsersTableViewController *)[nav topViewController];
        [uuvc setUnitId:_unitId];
    }
    
    // Pass the selected object to the new view controller.
}

@end
