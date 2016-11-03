//
//  UBSuperUnitTableViewController.m
//  Urba
//
//  Created by Ricardo Nazario on 10/22/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBSuperUnitTableViewController.h"
#import "UBHomeViewController.h"
#import "UBFIRDatabaseManager.h"
#import "ActivityView.h"

NSString *const unitSegue = @"UnitSegue";

@interface UBSuperUnitTableViewController ()

@property (strong, nonatomic) NSMutableArray *results;
@property (weak, nonatomic) NSString *communityId;
@property (weak, nonatomic) NSString *selectedSuper;
@property (weak, nonatomic) NSString *selectedName;
@property (weak, nonatomic) NSString *selectedKey;

@end

@implementation UBSuperUnitTableViewController

- (void)getSuperUnits {
    
    ActivityView *spinner = [ActivityView loadSpinnerIntoView:self.view];
    
    [UBFIRDatabaseManager getAllValuesFromNode:@"super-units"
                                     orderedBy:@"community"
                                    filteredBy:_communityId
                            withSuccessHandler:^(NSArray *results) {
                                
                                _results = [NSMutableArray arrayWithArray:results];
                                
                                //                                [_communityTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_results.count-1 inSection:0]] withRowAnimation: UITableViewRowAnimationLeft];
                                [self.tableView reloadData];
                                
                                [spinner removeSpinner];
                            }
                                orErrorHandler:^(NSError *error) {
                                    
                                    [spinner removeSpinner];
                                    NSLog(@"Error: %@", error.description);
                                }];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSLog(@"The community: %@", _communityName);
    NSLog(@"The key: %@", _communityKey);
    _communityId = [NSString stringWithFormat:@"%@-%@", _communityName, _communityKey];
    [self getSuperUnits];
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
    return [_results count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"superCell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    // Unpack from results array
    NSDictionary<NSString *, NSString *> *snapshotDict = _results[indexPath.row];
    NSString *name = [snapshotDict objectForKey:@"name"];
    
    NSLog(@"Dictionary: %@\nName: %@", snapshotDict, name);
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", name];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    NSDictionary *currentSnapshot = _results[indexPath.row];
    
    _selectedKey = currentSnapshot[@"key"];
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    
    if ([segue.identifier isEqualToString:unitSegue]) {
        
        UBFindUnitTableViewController *uvc = [segue destinationViewController];
            
        NSLog(@"The super-unit name: %@", _selectedName);
        
        // Pass the selected object to the new view controller.
        
        [uvc setHomeViewController:_homeViewController];
        [uvc setCommunityName:_communityName];
        [uvc setCommunityKey:_communityKey];
        [uvc setSuperUnitName:_selectedName];
        [uvc setSuperUnitKey:_selectedKey];
    }
}

@end
