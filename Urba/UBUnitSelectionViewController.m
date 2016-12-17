//
//  UBUnitSelectionViewController.m
//  Urba
//
//  Created by Ricardo Nazario on 9/28/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBUnitSelectionViewController.h"
#import "UBTabViewController.h"
#import "Constants.h"
#import "ActivityView.h"

@import FirebaseDatabase;
@import FirebaseAuth;

@interface UBUnitSelectionViewController ()

@property (strong, nonatomic) FIRDatabaseReference *ref;

@property (weak, nonatomic) IBOutlet UITableView *unitsTable;
@property (strong, nonatomic) NSMutableArray *unitsArray;
@property (weak, nonatomic) NSDictionary <NSString *, NSDictionary *> *unitDict;

@end

@implementation UBUnitSelectionViewController

#pragma mark - IBActions

- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private

- (void)getUnits {
    
    ActivityView *spinner = [ActivityView loadSpinnerIntoView:self.view];
    
    NSString *unitRef = [NSString stringWithFormat:@"users/%@/name", [FIRAuth auth].currentUser.uid];
    
    _ref = [[[FIRDatabase database] reference] child:@"units"];
    FIRDatabaseQuery *query = [[_ref queryOrderedByChild:unitRef] queryEqualToValue:[FIRAuth auth].currentUser.email];
    
    [query observeEventType:FIRDataEventTypeValue
                               withBlock:^(FIRDataSnapshot *snapshot) {
                                   
                                   if ([snapshot exists]) {
                                       
                                       [spinner removeSpinner];
                                       for (FIRDataSnapshot *snap in snapshot.children) {
                                           
                                           NSDictionary<NSString *, NSDictionary *> *superUnitDict = [NSDictionary dictionaryWithObjectsAndKeys:snap.key,@"id",snap.value,@"values", nil];
                                           
                                           if (![_unitsArray containsObject:superUnitDict]) {
                                               
                                               [_unitsArray addObject:superUnitDict];
                                               
                                               [_unitsTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_unitsArray.count-1 inSection:0]] withRowAnimation: UITableViewRowAnimationTop];
                                           }
                                       }
                                   }
                               }
                         withCancelBlock:^(NSError *error) {
                             [spinner removeSpinner];
                             [self alert:@"Error!" withMessage:error.description];
                         }];
}

-(void)alert:(NSString *)title withMessage:(NSString *)errorMsg {
    
    UIAlertController *alertView = [UIAlertController
                                    alertControllerWithTitle:NSLocalizedString(title, nil)
                                    message:errorMsg
                                    preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Okay"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   [alertView dismissViewControllerAnimated:YES
                                                                                 completion:nil];
                                                   [self dismissViewControllerAnimated:YES completion:nil];
                                               }];
    [alertView addAction:ok];
    [self presentViewController:alertView animated:YES completion:nil];
    
}

#pragma mark - Table View Data Source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_unitsArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [_unitsTable dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSDictionary<NSString *, NSDictionary *> *snapshotDict = _unitsArray[indexPath.row];
    NSString *unit = [snapshotDict valueForKeyPath:@"values.name"];
    NSString *superUnit = [snapshotDict valueForKeyPath:@"values.super-unit"];
    NSString *address = [NSString stringWithFormat:@"%@ %@", unit, superUnit];

    cell.textLabel.text = [NSString stringWithFormat:@"%@", address];
    
    return cell;
}

#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    _unitDict = _unitsArray[indexPath.row];
    
    NSString *storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    UBTabViewController *tvc = [storyboard instantiateViewControllerWithIdentifier:@"TabBar"];
    [tvc setUnitDict:_unitDict];
    [self presentViewController:tvc animated:YES completion:nil];
}

#pragma mark - Life Cycle

-(void)viewWillAppear:(BOOL)animated {
    _unitsArray = [[NSMutableArray alloc] init];
    [self getUnits];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (_justLogged) {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

-(void)viewDidDisappear:(BOOL)animated {
    [_ref removeAllObservers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}
*/
@end
