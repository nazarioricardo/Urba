//
//  UBSuperUnitTableViewController.m
//  Urba
//
//  Created by Ricardo Nazario on 10/22/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBSuperUnitTableViewController.h"
#import "UBUnitViewController.h"
#import "Constants.h"
#import "ActivityView.h"

@import FirebaseDatabase;

@interface UBSuperUnitTableViewController () {
    FIRDatabaseHandle _refHandle;
}

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSMutableArray *results;
@property (weak, nonatomic) NSString *selectedSuper;
@property (weak, nonatomic) NSString *selectedName;
@property (weak, nonatomic) NSString *selectedKey;

@end

@implementation UBSuperUnitTableViewController

#pragma IBActions

- (void)getSuperUnits {
    
    ActivityView *spinner = [ActivityView loadSpinnerIntoView:self.view];
    
    _ref = [[[FIRDatabase database] reference] child:@"super-units"];
    FIRDatabaseQuery *query = [[_ref queryOrderedByChild:@"community-id"] queryEqualToValue:_communityId];
    
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

#pragma mark - Private 

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

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_results count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"superCell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    // Unpack from results array
    NSDictionary<NSString *, NSDictionary *> *snapshotDict = _results[indexPath.row];
    NSString *name = [snapshotDict valueForKeyPath:@"values.name"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", name];
    
    return cell;
}

#pragma mark - Text Field Methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    NSDictionary *selectedSnapshot = _results[indexPath.row];
    
    _selectedKey = [selectedSnapshot valueForKey:@"id"];
    _selectedName = selectedCell.textLabel.text;
    
    _selectedSuper = [NSString stringWithFormat:@"%@-%@", _selectedName, _selectedKey];
 
    [self performSegueWithIdentifier:unitSegue sender:self];
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

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _results = [[NSMutableArray alloc] init];
    [self getSuperUnits];
    
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, 20)];
    view.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:190.0/255.0 blue:58.0/255.0 alpha:1];
    [self.view addSubview:view];
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



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    
    if ([segue.identifier isEqualToString:unitSegue]) {
        
        UBFindUnitTableViewController *uvc = [segue destinationViewController];
                
        // Pass the selected object to the new view controller.
        
        [uvc setCommunityName:_communityName];
        [uvc setCommunityKey:_communityId];
        [uvc setSuperUnitName:_selectedName];
        [uvc setSuperUnitId:_selectedKey];
        [uvc setAdminId:_adminId];
        [uvc setAdminName:_adminName];
    }
}

@end
