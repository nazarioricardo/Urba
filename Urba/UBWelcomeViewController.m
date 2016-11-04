//
//  ViewController.m
//  Urba
//
//  Created by Ricardo Nazario on 9/12/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBWelcomeViewController.h"
#import "ActivityView.h"

@import Firebase;

@interface UBWelcomeViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

<<<<<<< HEAD
- (void)logIn;

=======
>>>>>>> firdbmanager
@end

@implementation UBWelcomeViewController

#pragma mark - IBActions
<<<<<<< HEAD

=======
>>>>>>> firdbmanager

- (IBAction)logInPressed:(id)sender {

    [self logIn];
}

#pragma mark - Private

- (void)logIn {
    
    ActivityView *spinner = [ActivityView loadSpinnerIntoView:self.view];
    
    [[FIRAuth auth] signInWithEmail:@"nazarioricardo@gmail.com"
                           password:@"iamricky"
                         completion:^(FIRUser *user, NSError *error) {
                             
                             if (error) {
                                 
                                 [spinner removeSpinner];
                                 NSLog(@"There has been an error!\n %@", error.description);
                                 
                                 // TODO : SHOW ERROR ALERT
                             } else {
                                 NSLog(@"Logged in as %@", user.email);
                                 [self performSegueWithIdentifier:@"LogInSegue" sender:self];
                             }
                         }];
}

<<<<<<< HEAD
#pragma mark -Text Field Delegate
=======
#pragma mark - Text Field Delegate
>>>>>>> firdbmanager

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == _emailTextField) {
<<<<<<< HEAD
        [textField resignFirstResponder];
        [_passwordTextField becomeFirstResponder];
=======
        
        [textField resignFirstResponder];
        [_passwordTextfield becomeFirstResponder];
>>>>>>> firdbmanager
    } else {
        [self logIn];
    }
    
    return YES;
}

<<<<<<< HEAD
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - Life Cycle
=======
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma Life Cycle
>>>>>>> firdbmanager

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    [self logIn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
