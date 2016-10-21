//
//  UBCreateUserViewController.m
//  Urba
//
//  Created by Ricardo Nazario on 9/12/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBCreateUserViewController.h"

@interface UBCreateUserViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;

-(void)uploadUser;

@end

@implementation UBCreateUserViewController

- (IBAction)donePressed:(id)sender {
}

- (IBAction)cancelPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private

- (void)uploadUser {
    
    if ([_emailTextField.text  isEqual: @""] && [_passwordTextField.text  isEqual: @""] && [_confirmPasswordTextField.text  isEqual: @""]) {
        
        NSLog(@"Please fill all blank fields");
        
    } else if (_passwordTextField.text != _confirmPasswordTextField.text) {
        
        // ERROR Password mismatch
        NSLog(@"Passwords didn't match! Please try again!");
    } else {
     
        NSLog(@"User created");
    }
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
