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
    [_ref observeEventType:FIRDataEventTypeValue
                               withBlock:^(FIRDataSnapshot *snapshot) {
                                   
                                   if ([snapshot exists]) {
                                       
                                       [spinner removeSpinner];
                                       for (FIRDataSnapshot *snap in snapshot.children) {
                                           
                                           NSDictionary<NSString *, NSMutableDictionary *> *userDict = [NSDictionary dictionaryWithObjectsAndKeys:snap.key,@"id",snap.value,@"values", nil];
                                           
                                           if (![_userArray containsObject:userDict] && ![[userDict valueForKeyPath:@"values.name"] isEqualToString: [FIRAuth auth].currentUser.email]) {
                                               
                                               [_userArray addObject:userDict];
                                               
                                               [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_userArray.count-1 inSection:0]] withRowAnimation: UITableViewRowAnimationTop];
                                           }
                                       }
                                   } else {
                                       
                                       [self alert:@"Wait a minute..." withMessage:@"There are no other users for this unit!"];
                                       
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
    [self getUsers];
}

-(void)viewWillAppear:(BOOL)animated{
}

-(void)viewWillDisappear:(BOOL)animated {
    [_ref removeAllObservers];
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
    
    // Configure the cell...
    // Unpack from results array
    NSDictionary<NSString *, NSDictionary *> *snapshotDict = _userArray[indexPath.row];
    NSString *name = [snapshotDict valueForKeyPath:@"values.name"];
    NSMutableString *permissions = [snapshotDict valueForKeyPath:@"values.permissions"];
    
    cell.userNameLabel.text = name;
    cell.permissionsStatusLabel.text = permissions;
    cell.userId = [snapshotDict valueForKeyPath:@"id"];
    cell.delegate = self;
    
    if ([permissions isEqualToString:@"enabled"]) {
        [cell.permissionsSwitch setOn:YES];
    } else if ([permissions isEqualToString:@"disabled"]) {
        [cell.permissionsSwitch setOn:NO];
    } else {
        cell.permissionsSwitch.hidden = YES;
    }
    
    return cell;
}

#pragma mark - User Unit Cell Delegate

-(void)toggleUserPermissions:(UBUsersTableViewCell *)cell withSwitch:(UISwitch *)toggleSwitch {
        
    [_ref removeAllObservers];
    
    if (toggleSwitch.on) {
        [[_ref child:cell.userId] updateChildValues:[NSDictionary dictionaryWithObjectsAndKeys:@"enabled",@"permissions", nil]];
        cell.permissionsStatusLabel.text = @"enabled";
    } else {
        [[_ref child:cell.userId] updateChildValues:[NSDictionary dictionaryWithObjectsAndKeys:@"disabled",@"permissions", nil]];
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
