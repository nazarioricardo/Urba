//
//  UBNilViewController.m
//  
//
//  Created by Ricardo Nazario on 12/2/16.
//
//

#import "UBNilViewController.h"
#import "UBWelcomeViewController.h"
#import "UBTabViewController.h"
#import "ActivityView.h"

@import FirebaseDatabase;
@import FirebaseAuth;

@interface UBNilViewController ()

@property (strong, nonatomic) FIRDatabaseReference *requestRef;
@property (strong, nonatomic) FIRDatabaseReference *unitRef;
@property (strong, nonatomic) FIRDatabaseQuery *requestQuery;

@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondLabel;
@property (weak, nonatomic) IBOutlet UIButton *addHomeButton;

@property (strong, nonatomic) NSDictionary *unitDict;

@end

@implementation UBNilViewController

- (IBAction)signOutPressed:(id)sender {
    
    NSError *signOutError;
    BOOL status = [[FIRAuth auth] signOut:&signOutError];
    if (!status) {
        NSLog(@"Sign out error: %@", signOutError);
        return;
    }
    
    // After sign out, go to log in screen
    NSString *storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    UBWelcomeViewController *uwvc = [storyboard instantiateViewControllerWithIdentifier:@"Welcome"];
    [self presentViewController:uwvc animated:YES completion:nil];
}

- (void)checkForRequests {
    
    [_requestQuery observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        
        if ([snapshot exists]) {
            
            NSLog(@"REQUEST EXISTS: %@", snapshot);
            
            _mainLabel.text = @"Waiting for verification! When verified, you will be redirected to the proper screen";
            _secondLabel.text = @"In the meantime, you can contact your community's administrator, or a resident in your household to speed up your verification.";
            _secondLabel.hidden = NO;
            _addHomeButton.hidden = YES;
            [self requestRemoved];
        }
    } withCancelBlock:^(NSError *error) {
        [self alert:error.description];
    }];
}

// Check if verification was accepted or rejected by checking if user exists in a unit.
-(void)requestRemoved {
    
    [_requestQuery observeEventType:FIRDataEventTypeChildRemoved withBlock:^(FIRDataSnapshot *snapshot) {
        
        NSString *unitRefString = [NSString stringWithFormat:@"users/%@/name", [FIRAuth auth].currentUser.uid];
        _unitRef = [[[FIRDatabase database] reference] child:@"units"];
        FIRDatabaseQuery *query = [[_unitRef queryOrderedByChild:unitRefString] queryEqualToValue:[FIRAuth auth].currentUser.email];
        
        [query observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
            
            // Check if unit exists in unit
            if ([snapshot exists]) {
            
                // If YES move to main view
                for (FIRDataSnapshot *snap in snapshot.children) {
                    _unitDict = [NSDictionary dictionaryWithObjectsAndKeys:snap.key, @"id", snap.value, @"values", nil];
                    [self performSegueWithIdentifier:@"VerifiedSegue" sender:self];
                }
            } else {
                
                // If NO stay in current
                _mainLabel.text = @"Sorry! You have failed to be verified.";
                _secondLabel.text = @"If you are certain you chose the right address, contact your community administrator to find out why you weren't verified";
                _secondLabel.hidden = NO;
                _addHomeButton.hidden = NO;
            }
        }];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

-(void)viewWillAppear:(BOOL)animated {
    _secondLabel.hidden = YES;
    _requestRef = [[[FIRDatabase database] reference] child:@"requests"];
    _requestQuery = [[_requestRef queryOrderedByChild:@"from/id"] queryEqualToValue:[FIRAuth auth].currentUser.uid];
    [self checkForRequests];
    [self requestRemoved];
}

-(void)viewDidDisappear:(BOOL)animated {
    [_unitRef removeAllObservers];
    [_requestRef removeAllObservers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"VerifiedSegue"]) {
        UBTabViewController *tab = [segue destinationViewController];
        [tab setUnitDict:_unitDict];
    }
}

@end
