//
//  UBSuperUnitTableViewController.m
//  Urba
//
//  Created by Ricardo Nazario on 10/22/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBSuperUnitTableViewController.h"

@import Firebase;

@interface UBSuperUnitTableViewController () {
    FIRDatabaseHandle _refHandle;
}

@property (strong, nonatomic) NSMutableArray<FIRDataSnapshot *> *results;
@property (strong, nonatomic) FIRDatabaseReference *ref;

@property (weak, nonatomic) NSString *communityId;

@end

@implementation UBSuperUnitTableViewController

- (void)getSuperUnits {
    
    //    [self shouldAnimateIndicator:YES];
    
    FIRDatabaseQuery *query;
    
    _ref = [[FIRDatabase database] reference];
    _ref = [_ref child:@"super-units"];
    
    _results = nil;
    _results = [[NSMutableArray alloc] init];

    query = [[_ref queryOrderedByChild:@"community"] queryEqualToValue:_communityId];
    
    _refHandle = [query observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        [_results addObject:snapshot];
        [[self tableView] insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_results.count-1 inSection:0]]
                               withRowAnimation: UITableViewRowAnimationLeft];
        //        [self shouldAnimateIndicator:NO];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    
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
    return [_results count];;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"superCell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    // Unpack community from Firebase DataSnapshot
    FIRDataSnapshot *currentSnapshot = _results[indexPath.row];
    NSDictionary<NSString *, NSString *> *snapshotDict = currentSnapshot.value;
    NSString *name = snapshotDict[@"name"];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", name];
    
    return cell;
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
