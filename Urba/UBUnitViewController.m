//
//  UBUnitViewController.m
//  Urba
//
//  Created by Ricardo Nazario on 11/23/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBUnitViewController.h"
#import "UBNilViewController.h"
#import "UBUnitSelectionViewController.h"
#import "UBGuestTableViewCell.h"
#import "ActivityView.h"

@import FirebaseDatabase;
@import FirebaseAuth;

@interface UBUnitViewController () <GuestCellDelegate> {
    FIRDatabaseHandle _refHandle;
}

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) FIRDatabaseReference *statusRef;

@property (weak, nonatomic) IBOutlet UITableView *feedTable;
@property (weak, nonatomic) IBOutlet UILabel *noGuestsLabel;

@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *unitName;
@property (strong, nonatomic) NSString *unitId;
@property (strong, nonatomic) NSString *community;
@property (strong, nonatomic) NSString *communityId;
@property (strong, nonatomic) NSString *superUnit;
@property (strong, nonatomic) NSString *superUnitId;

@property (strong, nonatomic) NSMutableArray *feedArray;

@end

@implementation UBUnitViewController

#pragma mark - IBActions

- (IBAction)addGuestPressed:(id)sender {
    
    [self addGuestController];
}

#pragma mark - Private

-(void)getGuests {
    
    _ref = [[[FIRDatabase database] reference] child:@"visitors"];
    FIRDatabaseQuery *query = [[_ref queryOrderedByChild:@"unit-id"] queryEqualToValue:_unitId];
    
    [query observeEventType:FIRDataEventTypeChildAdded
                               withBlock:^(FIRDataSnapshot *snapshot) {
        
                                   if ([snapshot exists]) {
                                       
                                       if (![_feedArray containsObject:snapshot]) {
                                           
                                           if (![_feedArray count]) {
                                               [_feedArray addObject:snapshot];
                                               [_feedTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_feedArray.count-1 inSection:0]] withRowAnimation: UITableViewRowAnimationNone];
                                               [self hideViewAnimated:_noGuestsLabel hide:YES];
                                               [self hideViewAnimated:_feedTable hide:NO];
                                           } else {
                                               [_feedArray addObject:snapshot];
                                               [_feedTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_feedArray.count-1 inSection:0]] withRowAnimation: UITableViewRowAnimationTop];
                                           }
                                       }
                                   }
                               }
                         withCancelBlock:^(NSError *error) {
                             [self alert:@"Error!" withMessage:error.description];
    }];
    
    [query observeEventType:FIRDataEventTypeChildRemoved
                  withBlock:^(FIRDataSnapshot *snapshot) {
                    
                      NSMutableArray *deleteArray = [[NSMutableArray alloc] init];
                      
                      for (FIRDataSnapshot *snap in _feedArray) {
                          if ([snapshot.key isEqualToString:snap.key]) {
                              
                              [deleteArray addObject:[NSNumber numberWithInteger:[_feedArray indexOfObject:snap] ]];
                          }
                      }
                      
                      [_feedTable beginUpdates];
                      for (NSNumber *num in deleteArray) {
                          
                          if ([_feedArray count] == 1) {
                              [_feedArray removeObjectAtIndex:[num integerValue]];
                              [_feedTable deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[num integerValue] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                              [self hideViewAnimated:_feedTable hide:YES];
                              [self hideViewAnimated:_noGuestsLabel hide:NO];
                          } else {
                              [_feedArray removeObjectAtIndex:[num integerValue]];
                              [_feedTable deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[num integerValue] inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
                          }
                      }
                      [_feedTable endUpdates];
                  }];
}

-(void)addGuestController {
    
    UIAlertController *addView = [UIAlertController
                                    alertControllerWithTitle:NSLocalizedString(@"Add Guest", nil)
                                    message:@"What's your guest's name?"
                                    preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *add = [UIAlertAction actionWithTitle:@"Add"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   
                                                   UITextField *addTextField = addView.textFields.firstObject;
                                                   
                                                   if (![addTextField.text isEqualToString:@""]) {
                                                       
                                                       NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:addTextField.text, @"name", _unitName, @"unit", _unitId, @"unit-id", _community, @"community", _communityId, @"community-id",_superUnit,@"super-unit",_superUnitId,@"super-unit-id",@"On the way",@"status", nil];
                                                       
                                                       [addTextField resignFirstResponder];
                                                       
                                                       [[_ref childByAutoId] setValue:dict];
                                                   }
                                               }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   [addView dismissViewControllerAnimated:YES
                                                                                 completion:nil];
                                               }];
    
    [addView addTextFieldWithConfigurationHandler:^(UITextField *textField) {
         textField.placeholder = NSLocalizedString(@"Guest Name", @"GuestName");
     }];
    
    [addView addAction:add];
    [addView addAction:cancel];
    [self presentViewController:addView animated:YES completion:nil];
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
                    completion:nil];
}

-(void)toggleLabelAndTable {
    
    if (![_feedTable isHidden]) {
        [self hideViewAnimated:_feedTable hide:YES];
        [self hideViewAnimated:_noGuestsLabel hide:NO];
    } else {
        [self hideViewAnimated:_feedTable hide:NO];
        [self hideViewAnimated:_noGuestsLabel hide:YES];
    }
}

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];    
    return YES;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - Table View Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {    
    return [_feedArray count];
}

#pragma mark - Table View Data Source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UBGuestTableViewCell *cell = [_feedTable dequeueReusableCellWithIdentifier:@"GuestCell" forIndexPath:indexPath];
    cell.delegate = self;
    // Unpack visitor from feed array
    FIRDataSnapshot *snapshot = _feedArray[indexPath.row];
    NSDictionary <NSString *, NSDictionary *> *visitorDict = [NSDictionary dictionaryWithObjectsAndKeys:snapshot.key,@"id",snapshot.value,@"values", nil];
    
    NSLog(@"CELL VALUE: %@", visitorDict);
    NSString *name = [visitorDict valueForKeyPath:@"values.name"];
    cell.nameLabel.text = [NSString stringWithFormat:@"%@", name];
    cell.visitorId = [visitorDict valueForKeyPath:@"id"];
    cell.statusLabel.text = [visitorDict valueForKeyPath:@"values.status"];
    [self listenToStatus:cell];
    
    return cell;
}

#pragma mark - Cell Delegate

- (void)cancelGuest:(UBGuestTableViewCell *)cell {
    
    [[_ref child:cell.visitorId] removeValue];
}

- (void)confirmGuest:(UBGuestTableViewCell *)cell {
    
    [[_ref child:cell.visitorId] removeValue];
}

-(void)listenToStatus:(UBGuestTableViewCell *)cell {
    
    NSString *statusRefString = [NSString stringWithFormat:@"visitors/%@/status", cell.visitorId];
        
    [_statusRef child:statusRefString];
    [_statusRef observeEventType:FIRDataEventTypeChildChanged withBlock:^(FIRDataSnapshot *snapshot) {
        
        NSString *keyPath = [NSString stringWithFormat:@"%@.status", cell.visitorId];
        NSString *status = [snapshot.value valueForKeyPath:keyPath];
        
        cell.statusLabel.text = status;
        
    } withCancelBlock:^(NSError *error) {
        if (error) {
            cell.statusLabel.text = @"There has been an error";
        }
    }];
    
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _feedArray = [[NSMutableArray alloc] init];
    
    NSLog(@"UNIT DICT:%@", _unitDict);
    
    NSString *name = [_unitDict valueForKeyPath:@"values.name"];
    NSString *superUnit = [_unitDict valueForKeyPath:@"values.super-unit"];
    _address = [NSString stringWithFormat:@"%@ %@", name, superUnit];
    _statusRef = [[FIRDatabase database] reference];
    
    _unitId = [NSString stringWithFormat:@"%@", [_unitDict valueForKey:@"id"]];
    _unitName = [NSString stringWithFormat:@"%@", [_unitDict valueForKeyPath:@"values.name"]];
    _communityId = [NSString stringWithFormat:@"%@", [_unitDict valueForKeyPath:@"values.community-id"]];
    _community = [NSString stringWithFormat:@"%@", [_unitDict valueForKeyPath:@"values.community"]];
    _superUnit = [NSString stringWithFormat:@"%@", [_unitDict valueForKeyPath:@"values.super-unit"]];
    _superUnitId = [NSString stringWithFormat:@"%@", [_unitDict valueForKeyPath:@"values.super-unit-id"]];
    
    NSLog(@"Unit id: %@", _unitId);
    [self getGuests];
    
    _feedTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

-(void)viewWillAppear:(BOOL)animated {
    self.navigationItem.title = _address;
    if (![_feedArray count]) {
        _noGuestsLabel.hidden = NO;
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
