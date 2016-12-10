//
//  UBUnitRequestsViewController.m
//  Urba
//
//  Created by Ricardo Nazario on 12/6/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBUnitRequestsViewController.h"
#import "UBRequestsTableViewCell.h"
#import "FIRManager.h"

@import FirebaseDatabase;

@interface UBUnitRequestsViewController () <RequestCellDelegate> {
    FIRDatabaseHandle _refHandle;
}

@property (strong, nonatomic) FIRDatabaseReference *ref;

@property (weak, nonatomic) IBOutlet UITableView *feedTable;
@property (weak, nonatomic) IBOutlet UILabel *noRequestsLabel;

@property (strong, nonatomic) NSMutableArray *feedArray;
@property (strong, nonatomic) NSString *unitName;
@property (strong, nonatomic) NSString *unitId;
@property (strong, nonatomic) NSString *address;

@end

@implementation UBUnitRequestsViewController

#pragma mark - Private

-(void)getRequests {
    
    _ref = [[[FIRDatabase database] reference] child:@"requests"];
    FIRDatabaseQuery *query = [[_ref queryOrderedByChild:@"unit/id"] queryEqualToValue:_unitId];
    
    _refHandle = [query observeEventType:FIRDataEventTypeValue
                               withBlock:^(FIRDataSnapshot *snapshot) {
                                   
                                   if ([snapshot exists]) {
                                       for (FIRDataSnapshot *snap in snapshot.children) {
                                           
                                           NSLog(@"Snap: %@", snap);
                                           
                                           NSDictionary<NSString *, NSDictionary *> *requestDict = [NSDictionary dictionaryWithObjectsAndKeys:snap.key,@"id",snap.value,@"values", nil];
                                           
                                           if (![_feedArray containsObject:requestDict]) {
                                               
                                               [_feedArray addObject:requestDict];
                                               
                                               NSLog(@"DICTIONARY: %@", requestDict);
                                               [_feedTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_feedArray.count-1 inSection:0]] withRowAnimation: UITableViewRowAnimationTop];
                                               _feedTable.hidden = NO;
                                               [self hideViewAnimated:_noRequestsLabel hide:YES];
                                           }
                                       }
                                   } else {
                                       
                                       [self hideViewAnimated:_feedTable hide:YES];
                                       [self hideViewAnimated:_noRequestsLabel hide:NO];
                                       
                                   }
                               }
                         withCancelBlock:^(NSError *error) {
                             
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
                                               }];
    [alertView addAction:ok];
    [self presentViewController:alertView animated:YES completion:nil];
}

-(void)hideViewAnimated:(UIView *)view hide:(BOOL)hidden {
    
    [UIView transitionWithView:view
                      duration:.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        view.hidden = hidden;
                    }
                    completion:NULL];
}


#pragma mark - Table View Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_feedArray count];
}

#pragma mark - Table View Data Source

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UBRequestsTableViewCell *cell = [_feedTable dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Unpack community from results array
    NSDictionary<NSString *, NSDictionary *> *snapshotDict = _feedArray[indexPath.row];
    NSString *name = [snapshotDict valueForKeyPath:@"values.from.name"];
    
    cell.nameLabel.text = [NSString stringWithFormat:@"%@", name];
    cell.requestId = [snapshotDict valueForKeyPath:@"id"];
    cell.fromId = [snapshotDict valueForKeyPath:@"values.from.id"];
    cell.fromName = name;
    cell.delegate = self;
    
    return cell;
}

#pragma mark - Request Cell Delegate

-(void)acceptRequest:(UBRequestsTableViewCell *)cell {
    
    NSString *fromId = cell.fromId;
    NSString *fromName = cell.fromName;
    NSLog(@"From id: %@\nFrom Name: %@", fromId, fromName);
    
    FIRDatabaseReference *usersRef = [[[[[[FIRDatabase database] reference] child:@"units"] child: _unitId]child:@"users"] child: fromId];
    [[usersRef child: @"name"] setValue: fromName];;
    
    _ref = [[[FIRDatabase database] reference] child:@"requests"];
    NSIndexPath *indexPath = [_feedTable indexPathForCell:cell];
    [_ref removeAllObservers];
    [[_ref child:cell.requestId] removeValue];
    [_feedTable beginUpdates];
    [_feedArray removeObjectAtIndex:indexPath.row];
    if ([_feedArray count] == 1) {
        [_feedTable deleteSections:[NSIndexSet indexSet] withRowAnimation:UITableViewRowAnimationBottom];
    }
    [_feedTable deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
    [_feedTable endUpdates];
    [self getRequests];
    
}

-(void)denyRequest:(UBRequestsTableViewCell *)cell {
    
    NSIndexPath *indexPath = [_feedTable indexPathForCell:cell];
    [_ref removeAllObservers];
    [[_ref child:cell.requestId] removeValue];
    [_feedTable beginUpdates];
    [_feedArray removeObjectAtIndex:indexPath.row];
    if ([_feedArray count] == 1) {
        [_feedTable deleteSections:[NSIndexSet indexSet] withRowAnimation:UITableViewRowAnimationBottom];
    }
    [_feedTable deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
    [_feedTable endUpdates];
    [self getRequests];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _noRequestsLabel.hidden = YES;
    _feedArray = [[NSMutableArray alloc] init];
    
    NSString *name = [_unitDict valueForKeyPath:@"values.name"];
    NSString *superUnit = [_unitDict valueForKeyPath:@"values.super-unit"];
    _address = [NSString stringWithFormat:@"%@ %@", name, superUnit];
    
    _unitId = [NSString stringWithFormat:@"%@", [_unitDict valueForKey:@"id"]];
    _unitName = [NSString stringWithFormat:@"%@", [_unitDict valueForKeyPath:@"values.name"]];
    
    _feedTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

-(void)viewWillAppear:(BOOL)animated {
    [self getRequests];
    self.navigationItem.title = _address;
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
