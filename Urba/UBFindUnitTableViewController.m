//
//  UBFindUnitTableViewController.m
//  Urba
//
//  Created by Ricardo Nazario on 10/25/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBFindUnitTableViewController.h"
#import "UBUnitViewController.h"
#import "ActivityView.h"

@import FirebaseDatabase;
@import FirebaseAuth;

@interface UBFindUnitTableViewController () {
    FIRDatabaseHandle _refHandle;
}
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSMutableArray *results;
@property (weak, nonatomic) NSString *selectedSuper;
@property (weak, nonatomic) NSString *selectedName;
@property (weak, nonatomic) NSString *selectedKey;

@end

@implementation UBFindUnitTableViewController

#pragma mark - Private

- (void)getUnits {
    
    ActivityView *spinner = [ActivityView loadSpinnerIntoView:self.view];
    
    _ref = [[[FIRDatabase database] reference] child:@"units"];
    FIRDatabaseQuery *query = [[_ref queryOrderedByChild:@"super-unit-id"] queryEqualToValue:_superUnitId];
    
    _refHandle = [query observeEventType:FIRDataEventTypeValue
                               withBlock:^(FIRDataSnapshot *snapshot) {
                                   
                                   if ([snapshot exists]) {
                                       
                                       [spinner removeSpinner];
                                       for (FIRDataSnapshot *snap in snapshot.children) {
                                           
                                           NSDictionary<NSString *, NSDictionary *> *superUnitDict = [NSDictionary dictionaryWithObjectsAndKeys:snap.key,@"id",snap.value,@"values", nil];
                                           
                                           if (![_results containsObject:superUnitDict]) {
                                               
                                               [_results addObject:superUnitDict];
                                               
                                               [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_results.count-1 inSection:0]] withRowAnimation: UITableViewRowAnimationTop];
                                           }
                                       }
                                   } else {
                                       
                                       [self alert:@"Wait a minute..." withMessage:@"There aren't any streets here! Try contacting your community administrator to get this fixed."];
                                       
                                   }
                               }
                         withCancelBlock:^(NSError *error) {
                             [spinner removeSpinner];
                             [self alert:@"Error!" withMessage:error.description];
                         }];
}

- (void)sendRequestToUser:(NSString *)unitUser withId:(NSString *)unitUserId {
    
    NSString *userId = [FIRAuth auth].currentUser.uid;
    NSString *userName = [FIRAuth auth].currentUser.email;
    
    NSLog(@"Selected unit key: %@", _selectedKey);
    NSLog(@"User Id: %@", userId);
    
    NSDictionary *unitDict = [NSDictionary dictionaryWithObjectsAndKeys:_selectedName,@"name",_selectedKey,@"id", _superUnitName, @"owner", nil];
    NSDictionary *fromDict = [NSDictionary dictionaryWithObjectsAndKeys: userName,@"name", userId, @"id", nil];
    NSDictionary *toDict;
    NSString *message;
    NSDictionary *requestDict;
    
    if (unitUserId) {
        message = [NSString stringWithFormat:@"You've sent a verification request to the resident(s) at %@, %@",  _selectedName, _superUnitName];
        requestDict = [NSDictionary dictionaryWithObjectsAndKeys: fromDict, @"from", unitDict, @"unit", nil];
    } else {
        toDict = [NSDictionary dictionaryWithObjectsAndKeys:_adminName,@"name",_adminId,@"id", nil];
        message = [NSString stringWithFormat:@"You've sent a verification request to a community admin for the unit %@, %@",  _selectedName, _superUnitName];
        requestDict = [NSDictionary dictionaryWithObjectsAndKeys:toDict, @"to", fromDict, @"from", unitDict, @"unit", nil];
    }
    
    
    
    NSLog(@"%@", unitDict);
    
    FIRDatabaseReference *requestRef = [[[[FIRDatabase database] reference] child:@"requests"] childByAutoId];
    [requestRef setValue:requestDict];
    [requestRef removeAllObservers];
    [self alert:@"Success!" withMessage:message];
    
}

-(void)alert:(NSString *)title withMessage:(NSString *)message {
    
    UIAlertController *alertView = [UIAlertController
                                    alertControllerWithTitle:NSLocalizedString(title, nil)
                                    message:message
                                    preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Okay"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   [alertView dismissViewControllerAnimated:YES
                                                                                 completion:nil];
                                                   [self dismissViewControllerAnimated:YES
                                                                            completion:nil];
                                               }];
    [alertView addAction:ok];
    [self presentViewController:alertView animated:YES completion:nil];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_results count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"unitCell" forIndexPath:indexPath];
    
    // Unpack from results array
    NSDictionary<NSString *, NSDictionary *> *snapshotDict = _results[indexPath.row];
    NSString *name = [snapshotDict valueForKeyPath:@"values.name"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", name];
    
    return cell;
}

#pragma mark - Table View Methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *currentSnapshot = _results[indexPath.row];
    _selectedKey = [currentSnapshot valueForKey:@"id"];
    _selectedName = [currentSnapshot valueForKeyPath:@"values.name"];
    
    NSLog(@"User Values: %@", [currentSnapshot valueForKeyPath:@"values.users"]);
    
    if (![currentSnapshot valueForKeyPath:@"values.users"]) {
        [self sendRequestToUser:nil withId:nil];
    } else {
        
        NSArray *userArray = [currentSnapshot valueForKeyPath:@"values.users"];
        
        for (NSString *userId in userArray) {
            NSLog(@"User Id: %@", userId);
            
            [self sendRequestToUser:nil withId:userId];
        }
        
    }
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    NSLog(@"Admin Name: %@", _adminName);
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _results = [[NSMutableArray alloc] init];
    [self getUnits];
}

-(void)viewWillAppear:(BOOL)animated {
    
}

-(void)viewDidDisappear:(BOOL)animated {
    [_ref removeAllObservers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
