//
//  ViewController.m
//  Urba
//
//  Created by Ricardo Nazario on 9/12/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBWelcomeViewController.h"
#import "UBNilViewController.h"
#import "UBUnitViewController.h"
#import "UBUnitSelectionViewController.h"
#import "FIRManager.h"
#import "ActivityView.h"

@import Firebase;

@interface UBWelcomeViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

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
                                 NSLog(@"There has been an error!\n %@", error.description);
                                 
                                 // TODO : SHOW ERROR ALERT
                             } else {
                                 NSLog(@"Logged in as %@", user.email);
                                 [self getUnits];
//                                 [self performSegueWithIdentifier:@"LogInSegue" sender:self];
                             }
                         }];
}

- (void)getUnits {
    
    [FIRManager getAllValuesFromNode:@"units"
                           orderedBy:@"user/id"
                          filteredBy:[FIRManager getCurrentUser]
                  withSuccessHandler:^(NSArray *results) {
                      
                      if (![results count]) {
                          
                          NSString *storyboardName = @"Main";
                          UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
                          UBNilViewController *unvc = [storyboard instantiateViewControllerWithIdentifier:@"No House"];
                          [self presentViewController:unvc animated:YES completion:nil];
                          
                      } else if ([results count] > 1){
                          
                          NSString *storyboardName = @"Main";
                          UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
                          UBUnitSelectionViewController *usvc = [storyboard instantiateViewControllerWithIdentifier:@"Unit List"];
                          [self presentViewController:usvc animated:YES completion:nil];
                          
                      } else {
                          
                          _unitDict = results[0];
                          [self performSegueWithIdentifier:@"OneUnitSegue" sender:self];
                      }
                  }
                      orErrorHandler:^(NSError *error) {
                          
                          NSLog(@"Error: %@", error.description);
                      }];
}

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == _emailTextField) {
        [textField resignFirstResponder];
        [_passwordTextField becomeFirstResponder];
    } else {
        [self logIn];
    }
    
    return YES;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    [self logIn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"OneUnitSegue"]) {
        UINavigationController *nav = [segue destinationViewController];
        UBUnitViewController *uuvc = (UBUnitViewController *)[nav topViewController];
        [uuvc setUnitDict:_unitDict];

    }
    
}

@end
