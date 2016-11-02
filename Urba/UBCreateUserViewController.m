//
//  UBCreateUserViewController.m
//  Urba
//
//  Created by Ricardo Nazario on 9/12/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBCreateUserViewController.h"
#import "ActivityView.h"

@import Firebase;

@interface UBCreateUserViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;

-(void)createUser;

@end

@implementation UBCreateUserViewController

- (IBAction)donePressed:(id)sender {
    [self createUser];
}

- (IBAction)cancelPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private

- (void)createUser {
    
    if ([_emailTextField.text  isEqual: @""] || [_passwordTextField.text  isEqual: @""] || [_confirmPasswordTextField.text  isEqual: @""]) {
        
        NSLog(@"Please fill all fields");
        
    } else if (![_passwordTextField.text isEqualToString:_confirmPasswordTextField.text]) {
        
        // ERROR Password mismatch
        NSLog(@"Passwords didn't match! Please try again!");
    } else {
        
        ActivityView *spinner = [ActivityView loadSpinnerIntoView:self.view];
        
        [[FIRAuth auth] createUserWithEmail:_emailTextField.text
                                   password:_passwordTextField.text
                                 completion:^(FIRUser *user, NSError *error) {
                                     
                                     if (error) {
                                         
                                         [spinner removeSpinner];
                                         NSLog(@"%@", error.description);
                                     } else {
                                         
                                         NSLog(@"Successfuly created user.");
                                         [self dismissViewControllerAnimated:YES completion:nil];
                                     }
        }];
    }
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == _emailTextField) {
        [textField resignFirstResponder];
        [_passwordTextField becomeFirstResponder];
    } else if (textField == _passwordTextField) {
        [textField resignFirstResponder];
        [_confirmPasswordTextField becomeFirstResponder];
    } else {
        [self createUser];
    }
    
    return YES;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
