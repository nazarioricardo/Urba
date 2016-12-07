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
#import "UBSettingsViewController.h"
#import "UBUnitRequestsViewController.h"
#import "UBUnitSelectionViewController.h"
#import "FIRManager.h"
#import "ActivityView.h"

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
    
    [FIRManager logIn:_emailTextField.text withPassword:_passwordTextField.text withHandler:^(BOOL success, NSError *error) {
        
        if (error) {
            [spinner removeSpinner];
            [self alert:error.description];
        } else {
            
            [self getUnits];
        }
        
    }];
}

- (void)getUnits {
    
    NSString *unitRef = [NSString stringWithFormat:@"users/%@/name", [FIRManager getCurrentUser]];
    
    [FIRManager getAllValuesFromNode:@"units"
                           orderedBy:unitRef
                          filteredBy:[FIRManager getCurrentUserEmail]
                  withSuccessHandler:^(NSArray *results) {
                      
                      if (![results count]) {
                          
                          NSString *storyboardName = @"Main";
                          UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
                          UBNilViewController *unvc = [storyboard instantiateViewControllerWithIdentifier:@"No House"];
                          [self presentViewController:unvc animated:YES completion:nil];
                          
                      } else if ([results count] > 1){
                          
                          [self performSegueWithIdentifier:@"ManyUnitsSegue" sender:self];
                      } else {
                          
                          _unitDict = results[0];
                          [self performSegueWithIdentifier:@"OneUnitSegue" sender:self];
                      }
                  }
                      orErrorHandler:^(NSError *error) {
                          
                          [self alert:error.description];
                      }];
}

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
        UITabBarController *tab = [segue destinationViewController];
        UINavigationController *navOne = [tab.viewControllers objectAtIndex:0];
        UBUnitViewController *uuvc = (UBUnitViewController *)[navOne topViewController];
        UINavigationController *navTwo = [tab.viewControllers objectAtIndex:1];
        UBUnitRequestsViewController *urvc = (UBUnitRequestsViewController *)[navTwo topViewController];
        UINavigationController *navThree = [tab.viewControllers objectAtIndex:2];
        UBSettingsViewController *usvc = (UBSettingsViewController *)[navThree topViewController];
        
        
        [uuvc setUnitDict:_unitDict];
        [urvc setUnitDict:_unitDict];
        [usvc setUnitDict:_unitDict];
    }
}

@end
