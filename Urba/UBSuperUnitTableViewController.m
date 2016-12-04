//
//  UBSuperUnitTableViewController.m
//  Urba
//
//  Created by Ricardo Nazario on 10/22/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBSuperUnitTableViewController.h"
#import "UBUnitViewController.h"
#import "FIRManager.h"
#import "Constants.h"
#import "ActivityView.h"

@interface UBSuperUnitTableViewController ()

@property (strong, nonatomic) NSMutableArray *results;
@property (weak, nonatomic) NSString *communityId;
@property (weak, nonatomic) NSString *selectedSuper;
@property (weak, nonatomic) NSString *selectedName;
@property (weak, nonatomic) NSString *selectedKey;

@end

@implementation UBSuperUnitTableViewController

#pragma IBActions

- (void)getSuperUnits {
    
    ActivityView *spinner = [ActivityView loadSpinnerIntoView:self.view];
    
    [FIRManager getAllValuesFromNode:@"super-units"
                                     orderedBy:@"community-id"
                                    filteredBy:_communityKey
                            withSuccessHandler:^(NSArray *results) {
                                
                                _results = [NSMutableArray arrayWithArray:results];
                                
                                if (![results count]) {
                                    
                                    [spinner removeSpinner];
                                    [self alert:@"Wait a minute..." withMessage:@"There aren't any streets here! Try contacting your community administrator to get this fixed."];
                                } else {
                                    
                                    //                                [_communityTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_results.count-1 inSection:0]] withRowAnimation: UITableViewRowAnimationLeft];
                                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.tableView.numberOfSections)] withRowAnimation:UITableViewRowAnimationFade];
                                    [spinner removeSpinner];
                                }
                            }
                                orErrorHandler:^(NSError *error) {
                                    
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
    
    NSLog(@"The admin name: %@", _adminName);
    _communityId = [NSString stringWithFormat:@"%@-%@", _communityName, _communityKey];
    [self getSuperUnits];
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
        [uvc setCommunityKey:_communityKey];
        [uvc setSuperUnitName:_selectedName];
        [uvc setSuperUnitKey:_selectedKey];
        [uvc setAdminId:_adminId];
        [uvc setAdminName:_adminName];
    }
}

@end
