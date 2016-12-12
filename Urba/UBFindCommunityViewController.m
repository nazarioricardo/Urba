//
//  UBFindCommunityViewController.m
//  Urba
//
//  Created by Ricardo Nazario on 10/21/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBFindCommunityViewController.h"
#import "UBUnitSelectionViewController.h"
#import "Constants.h"
#import "ActivityView.h"

@import FirebaseDatabase;

@interface UBFindCommunityViewController () <UITableViewDataSource, UITableViewDelegate> {
    FIRDatabaseHandle _refHandle;
}

@property (weak, nonatomic) IBOutlet UITableView *communityTable;

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSMutableArray *results;
@property (weak, nonatomic) NSString *selectedCommunity;
@property (weak, nonatomic) NSString *selectedName;
@property (weak, nonatomic) NSString *selectedKey;
@property (weak, nonatomic) NSString *adminId;
@property (weak, nonatomic) NSString *adminName;

@end

@implementation UBFindCommunityViewController

#pragma mark - IBActions

- (IBAction)cancelPressed:(id)sender {

    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private

- (void)getCommunities {
    
    ActivityView *spinner = [ActivityView loadSpinnerIntoView:self.view];
    
    _ref = [[[FIRDatabase database] reference] child:@"communities"];
    [_ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        
        if ([snapshot exists]) {
            
            [spinner removeSpinner];
            for (FIRDataSnapshot *snap in snapshot.children) {
                
                NSDictionary<NSString *, NSDictionary *> *communityDict = [NSDictionary dictionaryWithObjectsAndKeys:snap.key,@"id",snap.value,@"values", nil];
                NSLog(@"DICTIONARY: %@", communityDict);
                
                if (![_results containsObject:communityDict]) {
                    
                    [_results addObject:communityDict];
                    [_communityTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_results.count-1 inSection:0]] withRowAnimation: UITableViewRowAnimationTop];
                }
            }
        }
    } withCancelBlock:^(NSError *error) {
        
        [spinner removeSpinner];
        if (error) {
            [self alert:@"Error!" withMessage:error.description];
        }
    }];
}

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

#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    NSDictionary *selectedSnapshot = _results[indexPath.row];
    
    _selectedKey = [selectedSnapshot valueForKey:@"id"];
    _adminId = [selectedSnapshot valueForKeyPath:@"values.admin-id"];
    _adminName = [selectedSnapshot valueForKeyPath:@"values.admin-email"];
    _selectedName = selectedCell.textLabel.text;

    _selectedCommunity = [NSString stringWithFormat:@"%@-%@", _selectedName, _selectedKey];
    
    NSLog(@"The selection is %@", _selectedCommunity);
    
    [self performSegueWithIdentifier:superUnitSegue sender:self];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _communityTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _results = [[NSMutableArray alloc] init];
    [self getCommunities];
}

-(void)viewWillAppear:(BOOL)animated {
}

- (void)viewDidDisappear:(BOOL)animated {
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
    
    if ([segue.identifier isEqualToString:superUnitSegue]) {
        
        UBSuperUnitTableViewController *suvc = [segue destinationViewController];
            
        // Pass the selected object to the new view controller.
        
        [suvc setCommunityName:_selectedName];
        [suvc setCommunityId:_selectedKey];
        [suvc setAdminId:_adminId];
        [suvc setAdminName:_adminName];
    }
}


@end
