//
//  UBNilViewController.m
//  
//
//  Created by Ricardo Nazario on 12/2/16.
//
//

#import "UBNilViewController.h"
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

- (void)checkForRequests {
    
//    ActivityView *spinner = [ActivityView loadSpinnerIntoView:self.view];
    
    [_requestQuery observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        
        if ([snapshot exists]) {
            
            NSLog(@"REQUEST EXISTS: %@", snapshot);
            
            _mainLabel.text = @"Waiting for verification! When verified, you will be redirected to the proper screen";
            _secondLabel.text = @"In the meantime, you can contact your community's administrator, or a resident in your household to speed up your verification.";
            _secondLabel.hidden = NO;
            _addHomeButton.hidden = YES;
            [self requestRemoved];
//            [spinner removeSpinner];
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
        [query observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
            
            NSLog(@"CHECKING IF YOU HAVE BEEN ADDED TO A HOUSE");
            
            if ([snapshot exists]) {
                
                NSLog(@"SNAP: %@", snapshot);
                
                for (FIRDataSnapshot *snap in snapshot.children) {
                    _unitDict = [NSDictionary dictionaryWithObjectsAndKeys:snap.key, @"id", snap.value, @"values", nil];
                    [self performSegueWithIdentifier:@"VerifiedSegue" sender:self];
                }
                
                NSLog(@"UNIT DICT: %@", _unitDict);
                
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
        UBTabViewController *tab = [segue destinationViewController];
        [tab setUnitDict:_unitDict];
    }
}

@end
