//
//  UBFindUnitTableViewController.m
//  Urba
//
//  Created by Ricardo Nazario on 10/25/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBFindUnitTableViewController.h"
#import "UBHomeViewController.h"
#import "UBFIRDatabaseManager.h"
#import "ActivityView.h"

@interface UBFindUnitTableViewController ()

@property (strong, nonatomic) NSMutableArray *results;
@property (weak, nonatomic) NSString *selectedSuper;
@property (weak, nonatomic) NSString *selectedName;
@property (weak, nonatomic) NSString *selectedKey;

@end

@implementation UBFindUnitTableViewController

#pragma mark - IBActions

- (void)getUnits {
    
    ActivityView *spinner = [ActivityView loadSpinnerIntoView:self.view];
    
    [UBFIRDatabaseManager getAllValuesFromNode:@"units"
                                     orderedBy:@"super-unit-id"
                                    filteredBy:_superUnitKey
                            withSuccessHandler:^(NSArray *results) {
                                
                                if (![results count]) {
                                    
                                    [spinner removeSpinner];
                                    NSLog(@"Snapshot doesn't exist");
                                    
                                } else {
                                    
                                    _results = [NSMutableArray arrayWithArray:results];
                                    
                                    //                                [_communityTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_results.count-1 inSection:0]] withRowAnimation: UITableViewRowAnimationLeft];
                                    
                                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.tableView.numberOfSections)] withRowAnimation:UITableViewRowAnimationFade];
                                    [spinner removeSpinner];
                                    
                                }
                            }
                                orErrorHandler:^(NSError *error) {
                                    
                                    [spinner removeSpinner];
                                    NSLog(@"Error: %@", error.description);
                                }];
}

- (void)sendRequest {
    
    NSString *userId = [UBFIRDatabaseManager getCurrentUser];
    
    NSLog(@"Selected unit key: %@", _selectedKey);
    NSLog(@"User Id: %@", userId);
    
    NSDictionary *unitDict = [NSDictionary dictionaryWithObjectsAndKeys:_selectedName,@"name",_selectedKey,@"id", _superUnitName, @"owner", nil];
    NSDictionary *fromDict = [NSDictionary dictionaryWithObjectsAndKeys: [UBFIRDatabaseManager getCurrentUserEmail],@"name", [UBFIRDatabaseManager getCurrentUser], @"id", nil];
    NSDictionary *toDict = [NSDictionary dictionaryWithObjectsAndKeys:_adminName,@"name",_adminId,@"id", nil];
    
    NSDictionary *requestDict = [NSDictionary dictionaryWithObjectsAndKeys:toDict, @"to", fromDict, @"from", unitDict, @"unit", nil];
    
    NSLog(@"%@", unitDict);
    
    [UBFIRDatabaseManager addToChildByAutoId:@"requests" withPairs:requestDict];
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
    
    // Configure the cell...
    
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
    
    [self sendRequest];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    NSLog(@"Admin Name: %@", _adminName);
    [self getUnits];
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
