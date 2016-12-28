//
//  UBSettingsViewController.m
//  Urba
//
//  Created by Ricardo Nazario on 12/2/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBSettingsViewController.h"
#import "UBUnitUsersTableViewController.h"
#import "UBUnitSelectionViewController.h"
#import "UBNilViewController.h"
#import "UBWelcomeViewController.h"
#import "ActivityView.h"

@import FirebaseAuth;
@import FirebaseDatabase;

@interface UBSettingsViewController ()

@property (strong, nonatomic) NSString *unitName;
@property (strong, nonatomic) NSString *unitId;
@property (strong, nonatomic) NSString *address;

@end

@implementation UBSettingsViewController

- (IBAction)signOutPressed:(id)sender {
    
    NSError *signOutError;
    BOOL status = [[FIRAuth auth] signOut:&signOutError];
    if (!status) {
        NSLog(@"Sign out error: %@", signOutError);
        return;
    }
    
    // After sign out, go to log in screen
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

// Alert template
-(void)alert:(NSString *)title withMessage:(NSString *)errorMsg {
    
    UIAlertController *alertView = [UIAlertController
                                    alertControllerWithTitle:NSLocalizedString(title, nil)
                                    message:errorMsg
                                    preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Okay"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   [alertView dismissViewControllerAnimated:YES
                                                                                 completion:nil];
                                               }];
    [alertView addAction:ok];
    [self presentViewController:alertView animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
    // Unpack info from unit dict
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
    if ([segue.identifier isEqualToString:@"ChangeUnitSegue"]) {
        UINavigationController *nav = [segue destinationViewController];
        UBUnitSelectionViewController *usvc = (UBUnitSelectionViewController *)[nav topViewController];
        [usvc setJustLogged:NO];
    }
}

@end
