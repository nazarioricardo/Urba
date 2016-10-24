//
//  UBFindCommunityViewController.m
//  Urba
//
//  Created by Ricardo Nazario on 10/21/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBFindCommunityViewController.h"
#import "UBSuperUnitTableViewController.h"

@import Firebase;

@interface UBFindCommunityViewController () <UITableViewDataSource, UITableViewDelegate> {
    FIRDatabaseHandle _refHandle;
}

@property (weak, nonatomic) IBOutlet UITableView *communityTable;

@property (strong, nonatomic) NSMutableArray<FIRDataSnapshot *> *results;
@property (strong, nonatomic) FIRDatabaseReference *ref;

@property (weak, nonatomic) NSString *selectedCommunity;

@end

@implementation UBFindCommunityViewController

- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)getCommunities {
    
//    [self shouldAnimateIndicator:YES];
    
    _ref = [[FIRDatabase database] reference];
    _ref = [_ref child:@"communities"];
    
    _results = nil;
    _results = [[NSMutableArray alloc] init];
    
    _refHandle = [_ref observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        [_results addObject:snapshot];
        [_communityTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_results.count-1 inSection:0]]
                               withRowAnimation: UITableViewRowAnimationLeft];
//        [self shouldAnimateIndicator:NO];
    }];
}

#pragma mark - Table View Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [_communityTable dequeueReusableCellWithIdentifier:@"communityCell" forIndexPath:indexPath];
    
    // Unpack community from Firebase DataSnapshot
    FIRDataSnapshot *currentSnapshot = _results[indexPath.row];
    NSDictionary<NSString *, NSString *> *snapshotDict = currentSnapshot.value;
    NSString *name = snapshotDict[@"name"];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", name];
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_results count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    FIRDataSnapshot *currentSnapshot = _results[indexPath.row];
    
    NSString *currentSnapKey = currentSnapshot.key;
    NSString *selection = [NSString stringWithFormat:@"%@", selectedCell.textLabel.text];
    //    NSString *selection = selectedCell.textLabel.text;
//    _results = nil;
    
//    [_communityTable reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _communityTable.numberOfSections)] withRowAnimation:UITableViewRowAnimationRight];
//    [_communityTable reloadData];
    
    _selectedCommunity = [NSString stringWithFormat:@"%@-%@", selection, currentSnapKey];
    
    NSLog(@"The selection is %@", _selectedCommunity);
    
    [self performSegueWithIdentifier:@"superUnitSegue" sender:self];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self getCommunities];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    
    if ([segue.identifier isEqualToString:@"superUnitSegue"]) {
        
        UBSuperUnitTableViewController *suvc = [segue destinationViewController];
        
        NSIndexPath *path = [_communityTable indexPathForSelectedRow];
        
        FIRDataSnapshot *currentSnapshot = _results[path.row];
        NSDictionary<NSString *, NSString *> *snapshotDict = currentSnapshot.value;
        
        NSString *name = snapshotDict[@"name"];
        NSString *key = currentSnapshot.key;
        
        NSLog(@"The community name: %@", name);
        
        // Pass the selected object to the new view controller.
        
        [suvc setCommunityName:name];
        [suvc setCommunityKey:key];
    }
    
}


@end
