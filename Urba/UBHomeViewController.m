//
//  UBHomeViewController.m
//  Urba
//
//  Created by Ricardo Nazario on 9/28/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBHomeViewController.h"
#import "ActivityView.h"

@import Firebase;

NSString *const findHomeSegue = @"FindHomeSegue";

@interface UBHomeViewController ()

@property (weak, nonatomic) IBOutlet UILabel *unitLabel;
@property (weak, nonatomic) IBOutlet UILabel *superLabel;
@property (weak, nonatomic) IBOutlet UILabel *communityLabel;

@property (strong, nonatomic) NSMutableArray *userUnitsArray;
@property (strong, nonatomic) NSString *currentUserId;
@property (strong, nonatomic) NSMutableArray<FIRDataSnapshot *> *results;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (nonatomic) FIRDatabaseHandle refHandle;

@end

@implementation UBHomeViewController

#pragma mark - IBActions

- (IBAction)addHomePressed:(id)sender {
    
    [self performSegueWithIdentifier:findHomeSegue sender:self];
}

<<<<<<< HEAD
#pragma mark - Private

- (void)getUnits {
    
    ActivityView *spinner = [ActivityView loadSpinnerIntoView:self.view];
    
    FIRDatabaseQuery *query;
    
    _ref = [[FIRDatabase database] reference];
    _ref = [_ref child:@"units"];
    
    _results = nil;
    _results = [[NSMutableArray alloc] init];
    
    query = [[_ref queryOrderedByChild:@"user"] queryEqualToValue:_currentUserId];
    
    _refHandle = [query observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        
        if (!snapshot) {
            NSLog(@"No households!");
        } else {
            [_results addObject:snapshot];
        }
        
        [spinner removeSpinner];
        
    } withCancelBlock:^(NSError *error) {
        
        [spinner removeSpinner];
        NSLog(@"%@", error.description);
    }];
}

#pragma mark - Life Cycle
=======
#pragma Life Cycle
>>>>>>> firdbmanager

-(void)viewWillAppear:(BOOL)animated {
    
    NSLog(@"%@ %@ %@ was selected", _unitName, _superUnitName, _communityName);
    if (_unitName) {
        NSString *unit = [NSString stringWithFormat:@"%@", _unitName];
        NSString *superUnit = [NSString stringWithFormat:@"%@", _superUnitName];
        NSString *community = [NSString stringWithFormat:@"%@", _communityName];
        
        NSDictionary<NSString *, NSString *> *unitDict = [[NSDictionary alloc] initWithObjectsAndKeys:_unitKey, _unitName, nil];
        NSDictionary<NSString *, NSString *> *superUnitDict = [[NSDictionary alloc] initWithObjectsAndKeys:_superUnitKey, _superUnitName, nil];
        NSDictionary<NSString *, NSString *> *communityDict = [[NSDictionary alloc] initWithObjectsAndKeys:_communityKey, _communityName, nil];
        
        NSArray *unitArray = [[NSArray alloc] initWithObjects:unitDict, superUnitDict, communityDict, nil];
        
        [_userUnitsArray addObject:unitArray];
        
        NSLog(@"The array: %@", _userUnitsArray);
        
        [_unitLabel setText:unit];
        [_superLabel setText:superUnit];
        [_communityLabel setText:community];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    NSLog(@"View did appear");
}

- (void)viewDidLoad {
    _userUnitsArray = [[NSMutableArray alloc] init];
    _currentUserId = [FIRAuth auth].currentUser.uid;
//    [self getUnits];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    
    if ([segue.identifier isEqualToString:findHomeSegue])
    {
        UINavigationController *nvc = [segue destinationViewController];
        UBFindCommunityViewController *fcvc = (UBFindCommunityViewController *)[nvc topViewController];
        fcvc.homeViewController = self;
    }
    // Pass the selected object to the new view controller.
}

@end
