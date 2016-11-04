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

@property (weak, nonatomic) NSString *superUnitId;
@property (weak, nonatomic) NSString *selectedSuper;
@property (weak, nonatomic) NSString *selectedName;
@property (weak, nonatomic) NSString *selectedKey;

@end

@implementation UBFindUnitTableViewController

#pragma mark - IBActions

- (void)getUnits {
    
    ActivityView *spinner = [ActivityView loadSpinnerIntoView:self.view];
    
    [UBFIRDatabaseManager getAllValuesFromNode:@"units"
                                     orderedBy:@"super-unit"
                                    filteredBy:_superUnitId
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

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSLog(@"The super-unit: %@", _superUnitName);
    NSLog(@"The key: %@", _superUnitKey);
    _superUnitId = [NSString stringWithFormat:@"%@-%@", _superUnitName, _superUnitKey];
    [self getUnits];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    NSDictionary<NSString *, NSString *> *snapshotDict = _results[indexPath.row];
    NSString *name = [snapshotDict objectForKey:@"name"];
    
    NSLog(@"Dictionary: %@\nName: %@", snapshotDict, name);
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", name];
    
    return cell;
}

#pragma mark - Table View Methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *currentSnapshot = _results[indexPath.row];
    
    NSString *key = currentSnapshot[@"key"];
    
    NSString *name = currentSnapshot[@"name"];
    
//    NSString *user = [UBFIRDatabaseManager getCurrentUser];
    
    [_homeViewController setUnitName:name];
    [_homeViewController setUnitKey:key];
    [_homeViewController setSuperUnitName:_superUnitName];
    [_homeViewController setSuperUnitKey:_superUnitKey];
    [_homeViewController setCommunityName:_communityName];
    [_homeViewController setCommunityKey:_communityKey];
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
