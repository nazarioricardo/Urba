//
//  UBFindCommunityViewController.m
//  Urba
//
//  Created by Ricardo Nazario on 10/21/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBFindCommunityViewController.h"
#import "UBHomeViewController.h"
#import "UBFIRDatabaseManager.h"
#import "Constants.h"
#import "ActivityView.h"

@interface UBFindCommunityViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *communityTable;

@property (strong, nonatomic) NSMutableArray *results;
@property (weak, nonatomic) NSString *selectedCommunity;
@property (weak, nonatomic) NSString *selectedName;
@property (weak, nonatomic) NSString *selectedKey;
@property (weak, nonatomic) NSString *adminId;

@end

@implementation UBFindCommunityViewController

#pragma mark - IBActions

- (IBAction)cancelPressed:(id)sender {
    
    [_results removeAllObjects];
    _results = nil;
    [_communityTable reloadData];

    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private

- (void)getCommunities {
    
    ActivityView *spinner = [ActivityView loadSpinnerIntoView:self.view];
    
    [_results removeAllObjects];
    [_communityTable reloadData];
    
    [UBFIRDatabaseManager getAllValuesFromNode:@"communities"
                            withSuccessHandler:^(NSArray *results) {
                                
                                _results = [NSMutableArray arrayWithArray:results];
                                
//                                [_communityTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_results.count-1 inSection:0]] withRowAnimation: UITableViewRowAnimationLeft];
                                [_communityTable reloadData];

                                [spinner removeSpinner];
                            }
                                orErrorHandler:^(NSError *error) {
                                    
                                    [spinner removeSpinner];
                                    NSLog(@"Error: %@", error.description);
                                }];
}

#pragma mark - Table View Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [_communityTable dequeueReusableCellWithIdentifier:@"communityCell" forIndexPath:indexPath];
    
    // Unpack community from results array
    NSDictionary<NSString *, NSDictionary *> *snapshotDict = _results[indexPath.row];
    NSString *name = [snapshotDict valueForKeyPath:@"values.name"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", name];
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_results count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark - Text Field Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    NSDictionary *selectedSnapshot = _results[indexPath.row];
    
    _selectedKey = [selectedSnapshot valueForKey:@"id"];
    _adminId = [selectedSnapshot valueForKeyPath:@"values.admin-id"];
    _selectedName = selectedCell.textLabel.text;

    _selectedCommunity = [NSString stringWithFormat:@"%@-%@", _selectedName, _selectedKey];
    
    NSLog(@"The selection is %@", _selectedCommunity);
    
    [self performSegueWithIdentifier:superUnitSegue sender:self];
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
    
    if ([segue.identifier isEqualToString:superUnitSegue]) {
        
        UBSuperUnitTableViewController *suvc = [segue destinationViewController];
            
        // Pass the selected object to the new view controller.
        
        [suvc setHomeViewController:_homeViewController];
        [suvc setCommunityName:_selectedName];
        [suvc setCommunityKey:_selectedKey];
        [suvc setAdminId:_adminId];
    }
}


@end
