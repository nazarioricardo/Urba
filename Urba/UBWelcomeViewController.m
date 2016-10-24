//
//  ViewController.m
//  Urba
//
//  Created by Ricardo Nazario on 9/12/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBWelcomeViewController.h"

@import Firebase;

@interface UBWelcomeViewController () 

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;

@end

@implementation UBWelcomeViewController


- (IBAction)logInPressed:(id)sender {

    [self logIn];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == _emailTextField) {
        [textField resignFirstResponder];
        [_passwordTextfield becomeFirstResponder];
    } else {
        [self logIn];
    }
    
    return YES;
}

- (void)logIn {
    
    [[FIRAuth auth] signInWithEmail:@"nazarioricardo@gmail.com"
                           password:@"iamricky"
                         completion:^(FIRUser *user, NSError *error) {
                             
                             if (error) {
                                 
                                 NSLog(@"There has been an error!\n %@", error.description);
                             } else {
                                 
                                 NSLog(@"Logged in as %@", user.email);
                                 [self performSegueWithIdentifier:@"LogInSegue" sender:self];
                             }
                         }];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self logIn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
