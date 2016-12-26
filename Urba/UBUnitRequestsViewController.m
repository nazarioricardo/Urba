//
//  UBUnitRequestsViewController.m
//  Urba
//
//  Created by Ricardo Nazario on 12/6/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBUnitRequestsViewController.h"
#import "UBNilViewController.h"
#import "UBRequestsTableViewCell.h"
#import "ActivityView.h"

@import FirebaseDatabase;
@import FirebaseAuth;


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
    
    _refHandle = [query observeEventType:FIRDataEventTypeChildAdded
                               withBlock:^(FIRDataSnapshot *snapshot) {
                                   
                                   if ([snapshot exists]) {
                                       
                                       if (![_feedArray containsObject:snapshot]) {
                                           if (![_feedArray count]) {
                                               [_feedArray addObject:snapshot];
                                               [_feedTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_feedArray.count-1 inSection:0]] withRowAnimation: UITableViewRowAnimationNone];
                                               [self hideViewAnimated:_noRequestsLabel hide:YES];
                                               [self hideViewAnimated:_feedTable hide:NO];
                                           } else {
                                               [_feedArray addObject:snapshot];
                                               [_feedTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_feedArray.count-1 inSection:0]] withRowAnimation: UITableViewRowAnimationTop];
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
    
    [query observeEventType:FIRDataEventTypeChildRemoved
                  withBlock:^(FIRDataSnapshot *snapshot) {
                      
                      
                      NSLog(@"DELETED SNAP: %@",snapshot.key);
                      NSMutableArray *deleteArray = [[NSMutableArray alloc] init];
                      
                      for (FIRDataSnapshot *snap in _feedArray) {
                          if ([snapshot.key isEqualToString:snap.key]) {
                              
                              [deleteArray addObject:[NSNumber numberWithInteger:[_feedArray indexOfObject:snap]]];
                          }
                      }
                      
                      [_feedTable beginUpdates];
                      for (NSNumber *num in deleteArray) {
                          
                          if ([_feedArray count] == 1) {
                              [_feedArray removeObjectAtIndex:[num integerValue]];
                              [_feedTable deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[num integerValue] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                              [self hideViewAnimated:_feedTable hide:YES];
                              [self hideViewAnimated:_noRequestsLabel hide:NO];
                          } else {
                              [_feedArray removeObjectAtIndex:[num integerValue]];
                              [_feedTable deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[num integerValue] inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
                          }
                      }
                      [_feedTable endUpdates];
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
    cell.delegate = self;
    // Unpack community from results array
    // Unpack visitor from feed array
    FIRDataSnapshot *snapshot = _feedArray[indexPath.row];
    NSDictionary <NSString *, NSDictionary *> *visitorDict = [NSDictionary dictionaryWithObjectsAndKeys:snapshot.key,@"id",snapshot.value,@"values", nil];
    
    NSLog(@"CELL VALUE: %@", visitorDict);
    NSString *name = [visitorDict valueForKeyPath:@"values.from.name"];
    cell.nameLabel.text = name;
    cell.fromName = name;
    cell.fromId = [visitorDict valueForKeyPath:@"values.from.id"];
    cell.requestId = [visitorDict valueForKeyPath:@"id"];
    
    return cell;
}

#pragma mark - Request Cell Delegate

-(void)acceptRequest:(UBRequestsTableViewCell *)cell {
    
    NSString *fromId = cell.fromId;
    NSString *fromName = cell.fromName;
    NSLog(@"From id: %@\nFrom Name: %@", fromId, fromName);
    
    FIRDatabaseReference *usersRef = [[[[[[FIRDatabase database] reference] child:@"units"] child: _unitId]child:@"users"] child: fromId];
    [[usersRef child: @"name"] setValue: fromName];
    [[usersRef child:@"permissions"] setValue:@"enabled"];
    
    [[_ref child:cell.requestId] removeValue];
}

-(void)denyRequest:(UBRequestsTableViewCell *)cell {
    
    [[_ref child:cell.requestId] removeValue];
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
    [self getRequests];
}

-(void)viewWillAppear:(BOOL)animated {
    self.navigationItem.title = _address;
    if (![_feedArray count]) {
        _noRequestsLabel.hidden = NO;
        _feedTable.hidden = YES;
    }
}

-(void)viewDidDisappear:(BOOL)animated {
//    [_ref removeAllObservers];
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
