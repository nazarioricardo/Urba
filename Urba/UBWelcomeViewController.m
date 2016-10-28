//
//  ViewController.m
//  Urba
//
//  Created by Ricardo Nazario on 9/12/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBWelcomeViewController.h"
#import "ActivityView.h"

NSString *const activityView = @"ActivityView";

@import Firebase;

@interface UBWelcomeViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;

//@property (weak, nonatomic) UBActivityViewController *activityView;

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
    
    ActivityView *spinner = [ActivityView loadSpinnerIntoView:self.view];
    
    [[FIRAuth auth] signInWithEmail:@"nazarioricardo@gmail.com"
                           password:@"iamricky"
                         completion:^(FIRUser *user, NSError *error) {
                             
                             if (error) {
                                 
                                 NSLog(@"There has been an error!\n %@", error.description);
                                 
                             } else {
                                 [spinner removeSpinner];
                                 NSLog(@"Logged in as %@", user.email);
                                 [self performSegueWithIdentifier:@"LogInSegue" sender:self];
                             }
                         }];
}

//- (void)presentActivityView {
//    
//    self.activityView = [self.storyboard instantiateViewControllerWithIdentifier:activityView];
//    
//    // Change the size of page view controller
//    self.activityView.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
//    
//    [self addChildViewController:_activityView];
//    [self.view addSubview:_activityView.view];
//    [self.activityView didMoveToParentViewController:self];
//    
//}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

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
