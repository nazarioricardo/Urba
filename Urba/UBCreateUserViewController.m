//
//  UBCreateUserViewController.m
//  Urba
//
//  Created by Ricardo Nazario on 9/12/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBCreateUserViewController.h"
#import "FIRManager.h"
#import "ActivityView.h"

@interface UBCreateUserViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;

@end

@implementation UBCreateUserViewController

#pragma IBActions

- (IBAction)donePressed:(id)sender {
    [self createUser];
}

- (IBAction)cancelPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private

- (void)createUser {
    
    if ([_emailTextField.text  isEqual: @""] || [_passwordTextField.text  isEqual: @""] || [_confirmPasswordTextField.text  isEqual: @""]) {
        
        [self alert:@"Error!" withMessage:@"Please fill in all blank fields"];
        
    } else if (![_passwordTextField.text isEqualToString:_confirmPasswordTextField.text]) {
        
        [self alert:@"Error!" withMessage:@"Passwords did not match!"];
    } else {

    ActivityView *spinner = [ActivityView loadSpinnerIntoView:self.view];
    
        [FIRManager createUser:_emailTextField.text withPassword:_passwordTextField.text withHandler:^(BOOL success, NSError *error) {
            
            if (error) {
                [spinner removeSpinner];
                [self alert:@"Error!" withMessage:error.description];
            } else {
                [spinner removeSpinner];
                [self alert:@"Success!" withMessage:@"User created."];
            }
            
        }];
    }
    
}

-(void)alert:(NSString *)title withMessage:(NSString *)message {
    
    UIAlertController *alertView = [UIAlertController
                                    alertControllerWithTitle:NSLocalizedString(title, nil)
                                    message:message
                                    preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Okay"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   [alertView dismissViewControllerAnimated:YES
                                                                                 completion:nil];
                                                   if ([title isEqualToString:@"Success!"]) {
                                                       [self dismissViewControllerAnimated:YES completion:nil];
                                                   }
                                               }];
    [alertView addAction:ok];
    [self presentViewController:alertView animated:YES completion:nil];
}

#pragma mark - Text Field Delegate

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

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
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
