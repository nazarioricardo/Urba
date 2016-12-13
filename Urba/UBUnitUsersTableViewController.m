 //
//  UBUnitUsersTableViewController.m
//  Urba
//
//  Created by Ricardo Nazario on 12/11/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBUnitUsersTableViewController.h"
#import "UBUsersTableViewCell.h"
#import "ActivityView.h"

@import FirebaseDatabase;
@import FirebaseAuth;

@interface UBUnitUsersTableViewController () <UserCellDelegate>

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) FIRDatabaseReference *permissionsRef;
@property (strong, nonatomic) NSMutableArray *userArray;

@end

@implementation UBUnitUsersTableViewController

#pragma mark - IBActions

- (IBAction)donePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private

-(void)getUsers {
    
    ActivityView *spinner = [ActivityView loadSpinnerIntoView:self.view];
    
    NSString *currentUnitRef = [NSString stringWithFormat:@"units/%@/users", _unitId];
    
    _ref = [[[FIRDatabase database] reference] child:currentUnitRef];
    [_ref observeEventType:FIRDataEventTypeChildAdded
                               withBlock:^(FIRDataSnapshot *snapshot) {
                                   
                                   if (snapshot) {
                                       [spinner removeSpinner];
                                       //            for (FIRDataSnapshot *snap in snapshot.children) {
                                       NSDictionary <NSString *, NSDictionary *> *visitorDict = [NSDictionary dictionaryWithObjectsAndKeys:snapshot.key,@"id",snapshot.value,@"values", nil];
                                       
                                       if (![_userArray containsObject:visitorDict]) {
                                           
                                           [_userArray addObject:visitorDict];
                                           [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_userArray.count-1 inSection:0]] withRowAnimation: UITableViewRowAnimationTop];
                                           self.tableView.hidden = NO;
//                                           [self hideViewAnimated:_noGuestsLabel hide:YES];
                                       }
                                       
                                       //            }
                                   } else {
//                                       [self hideViewAnimated:_feedTable hide:YES];
//                                       [self hideViewAnimated:_noGuestsLabel hide:NO];
                                   }
                               }
                         withCancelBlock:^(NSError *error) {
                             [spinner removeSpinner];
                             [self alert:@"Error!" withMessage:error.description];
                         }];
    
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

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _userArray = [[NSMutableArray alloc] init];
    _permissionsRef = [[FIRDatabase database] reference];
    [self getUsers];
}

-(void)viewWillAppear:(BOOL)animated{
}

-(void)viewWillDisappear:(BOOL)animated {
    [_ref removeAllObservers];
    [_permissionsRef removeAllObservers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_userArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UBUsersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.delegate = self;

    // Unpack from results array
    NSDictionary<NSString *, NSDictionary *> *snapshotDict = _userArray[indexPath.row];
    NSString *name = [snapshotDict valueForKeyPath:@"values.name"];
    NSMutableString *permissions = [snapshotDict valueForKeyPath:@"values.permissions"];
    
    cell.userNameLabel.text = name;
    cell.permissionsStatusLabel.text = permissions;
    cell.userId = [snapshotDict valueForKeyPath:@"id"];
    
    
    if ([cell.permissionsStatusLabel.text isEqualToString:@"head"]) {
        cell.permissionsSwitch.hidden = YES;
    }
    
    if ([cell.permissionsStatusLabel.text isEqualToString:@"enabled"]) {
        [cell.permissionsSwitch setOn:YES];
    } else {
        [cell.permissionsSwitch setOn:NO];
    }

    return cell;
}

#pragma mark - User Unit Cell Delegate

-(void)toggleUserPermissions:(UBUsersTableViewCell *)cell withSwitch:(UISwitch *)toggleSwitch {
    
//    NSString *permissionsRefString = [NSString stringWithFormat:@"%@/permissions", cell.userId];
//    [_permissionsRef child:permissionsRefString];
    
    NSString *permissionsRefString = [NSString stringWithFormat:@"units/%@/users/%@/permissions", _unitId, cell.userId];
//    [_permissionsRef child:permissionsRefString];
    
    if ([toggleSwitch isOn]) {
        [_permissionsRef updateChildValues:[NSDictionary dictionaryWithObjectsAndKeys:@"enabled",permissionsRefString, nil]];
        cell.permissionsStatusLabel.text = @"enabled";
    } else {
        [_permissionsRef updateChildValues:[NSDictionary dictionaryWithObjectsAndKeys:@"disabled",permissionsRefString, nil]];
        cell.permissionsStatusLabel.text = @"disabled";

    }
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
