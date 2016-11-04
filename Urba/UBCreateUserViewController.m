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

@property (weak, nonatomic) IBOutlet UITextField *emailTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextfield;

-(void)createUser;

@end

@implementation UBCreateUserViewController

#pragma IBActions

- (IBAction)donePressed:(id)sender {
    
    if ([_emailTextfield.text  isEqual: @""] && [_passwordTextfield.text  isEqual: @""] && [_confirmPasswordTextfield.text  isEqual: @""]) {
        
        NSLog(@"Please fill all blank fields");
    
    } else if (_passwordTextfield.text != _confirmPasswordTextfield.text) {
        
        // ERROR Password mismatch
        NSLog(@"Passwords didn't match! Please try again!");
    } else {

        [self createUser];
    }
}

- (IBAction)cancelPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private

- (void)createUser {
    
    ActivityView *spinner = [ActivityView loadSpinnerIntoView:self.view];
    
    [[FIRAuth auth] createUserWithEmail:_emailTextfield.text
                               password:_passwordTextfield.text
                             completion:^(FIRUser *user, NSError *error) {
                                 
                                 if (error) {
                                     [spinner removeSpinner];
                                     NSLog(@"%@", error.description);
                                 } else {
                                     NSLog(@"User created!");
                                     [self dismissViewControllerAnimated:YES completion:nil];
                                 }
                             }];
    
}

#pragma Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == _emailTextfield) {
        
        [textField resignFirstResponder];
        [_passwordTextfield becomeFirstResponder];
    } else if (textField == _passwordTextfield) {
        
        [textField resignFirstResponder];
        [_confirmPasswordTextfield becomeFirstResponder];

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
