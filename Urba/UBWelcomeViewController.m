//
//  ViewController.m
//  Urba
//
//  Created by Ricardo Nazario on 9/12/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBWelcomeViewController.h"
#import "UBTabViewController.h"
#import "UBNilViewController.h"
#import "UBUnitSelectionViewController.h"
#import "ActivityView.h"

@import FirebaseAuth;
@import Firebase;

@interface UBWelcomeViewController () {
    FIRDatabaseHandle _refHandle;
}

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSDictionary *unitDict;

@end

@implementation UBWelcomeViewController

#pragma mark - IBActions

- (IBAction)logInPressed:(id)sender {

    [self logIn];
}

#pragma mark - Private

- (void)logIn {
    
    ActivityView *spinner = [ActivityView loadSpinnerIntoView:self.view];
    
    [[FIRAuth auth] signInWithEmail:_emailTextField.text
                           password:_passwordTextField.text
                         completion:^(FIRUser *user, NSError *error) {
                             
                             if (error) {
                                 [spinner removeSpinner];
                                 [self alert:error.description];
                             } else {
                                 // Check to see if user already exists in a unit
                                 [self getUnits:spinner];
                             }
    }];
}

// Check for units with logging user
- (void)getUnits:(ActivityView *)spinner {
    
    NSString *unitRef = [NSString stringWithFormat:@"users/%@/name", [FIRAuth auth].currentUser.uid];
    
    _ref = [[[FIRDatabase database] reference] child:@"units"];
    FIRDatabaseQuery *query = [[_ref queryOrderedByChild:unitRef] queryEqualToValue:[FIRAuth auth].currentUser.email];
    
    _refHandle = [query observeEventType:FIRDataEventTypeValue
                               withBlock:^(FIRDataSnapshot *snapshot) {
                                   
                                   // If logging user exits in one unit or more...
                                   if ([snapshot exists]) {
                                       
                                       // If logging user is only in one unit, go straight to main view
                                       if (snapshot.childrenCount == 1) {
                                           
                                           for (FIRDataSnapshot *snap in snapshot.children) {
                                               _unitDict = [NSDictionary dictionaryWithObjectsAndKeys:snap.key,@"id", snap.value,@"values", nil];
                                           }
                                           [self performSegueWithIdentifier:@"OneUnitSegue" sender:self];
                                       } else {
                                           // If logging user exists in many units, go to unit selection view
                                           [self performSegueWithIdentifier:@"ManyUnitsSegue" sender:self];
                                       }
                                   } else {
                                       
                                       // If logging user does not exist in any units, go to onboarding view
                                       NSString *storyboardName = @"Main";
                                       UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
                                       UBNilViewController *unvc = [storyboard instantiateViewControllerWithIdentifier:@"No House"];
                                       [self presentViewController:unvc animated:YES completion:nil];
                                   }
                               }
                         withCancelBlock:^(NSError *error) {
                             [spinner removeSpinner];
                             [self alert:error.description];
                         }];
}

// Simple alert view
-(void)alert:(NSString *)errorMsg {
    
    UIAlertController *alertView = [UIAlertController
                                          alertControllerWithTitle:NSLocalizedString(@"Error!", nil)
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

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    // On pushing return, move from one text field to next, and attempt to log in when pushing return on final text field
    if (textField == _emailTextField) {
        [textField resignFirstResponder];
        [_passwordTextField becomeFirstResponder];
    } else {
        [self logIn];
        [textField resignFirstResponder];
    }
    
    return YES;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // Resign keyboard when touching outside keyboard
    [self.view endEditing:YES];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"OneUnitSegue"]) {
        UBTabViewController *tab = [segue destinationViewController];
        [tab setUnitDict:_unitDict];
    }
    
    if ([segue.identifier isEqualToString:@"ManyUnitsSegue"]) {
        UINavigationController *nav = [segue destinationViewController];
        UBUnitSelectionViewController *usvc = (UBUnitSelectionViewController *)[nav topViewController];
        [usvc setJustLogged:YES];
    }
}

@end
