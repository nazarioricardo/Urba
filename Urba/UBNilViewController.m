//
//  UBNilViewController.m
//  
//
//  Created by Ricardo Nazario on 12/2/16.
//
//

#import "UBNilViewController.h"
#import "UBUnitSelectionViewController.h"
#import "UBUnitViewController.h"
#import "UBUnitRequestsViewController.h"
#import "UBSettingsViewController.h"
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

- (void)checkForRequests {
    
//    ActivityView *spinner = [ActivityView loadSpinnerIntoView:self.view];
    
    [_requestQuery observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        
        if ([snapshot exists]) {
            
            NSLog(@"REQUEST EXISTS: %@", snapshot);
            
            _mainLabel.text = @"Waiting for verification! When verified, you will be redirected to the proper screen";
            _secondLabel.text = @"In the meantime,you can contact your community's administrator, or a resident in your household to speed up your verification, and check out our website to learn about our features.";
            _secondLabel.hidden = NO;
            _addHomeButton.hidden = YES;
            [self requestRemoved];
//            [spinner removeSpinner];
        } else {
            
            NSLog(@"REQUEST DOESN'T EXIST");
            
            _unitRef = [[[FIRDatabase database] reference] child:@"units"];
            FIRDatabaseQuery *query = [[_unitRef queryOrderedByChild:@"users"] queryEqualToValue:[FIRAuth auth].currentUser.uid];
            [query observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
                
                NSLog(@"CHECKING IF USER IS ADDED TO HOUSEHOLD");
                if ([snapshot exists]) {
                    
                    NSLog(@"SNAPSHOT EXISTS: %@", snapshot);
                    
                    _unitDict = [NSDictionary dictionaryWithObjectsAndKeys:snapshot.key, @"id", snapshot.value, @"values", nil];
                    [self performSegueWithIdentifier:@"VerifiedSegue" sender:self];
                }
            }];
        }
    } withCancelBlock:^(NSError *error) {
        [self alert:error.description];
    }];
}

-(void)requestRemoved {
    
    [_requestQuery observeEventType:FIRDataEventTypeChildRemoved withBlock:^(FIRDataSnapshot *snapshot) {
        
        NSLog(@"REQUEST HAS BEEN REMOVED");
    
        NSString *unitRefString = [NSString stringWithFormat:@"users/%@/name", [FIRAuth auth].currentUser.uid];
        _unitRef = [[[FIRDatabase database] reference] child:@"units"];
        FIRDatabaseQuery *query = [[_unitRef queryOrderedByChild:unitRefString] queryEqualToValue:[FIRAuth auth].currentUser.email];
        
        NSLog(@"Query: %@", query);
        [query observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
            
            NSLog(@"CHECKING IF YOU HAVE BEEN ADDED TO A HOUSE");
            
            if ([snapshot exists]) {
                
                NSLog(@"SNAP: %@", snapshot);
                
                _unitDict = [NSDictionary dictionaryWithObjectsAndKeys:snapshot.key, @"id", snapshot.value, @"values", nil];
                
                NSLog(@"UNIT DICT: %@", _unitDict);
                
                [self performSegueWithIdentifier:@"VerifiedSegue" sender:self];
            } else {
                _mainLabel.text = @"Sorry! You have failed to be verified.";
                _secondLabel.text = @"If you are certain you chose the right address, contact your community administrator to find out why you weren't verified";
                _secondLabel.hidden = NO;
                _addHomeButton.hidden = NO;
            }
        }];
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
