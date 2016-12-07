//
//  UBUnitRequestsViewController.m
//  Urba
//
//  Created by Ricardo Nazario on 12/6/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBUnitRequestsViewController.h"
#import "UBRequestsTableViewCell.h"
#import "FIRManager.h"

@interface UBUnitRequestsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *feedTable;

@property (strong, nonatomic) NSMutableArray *feedArray;
@property (strong, nonatomic) NSString *unitName;
@property (strong, nonatomic) NSString *unitId;
@property (strong, nonatomic) NSString *address;

@end

@implementation UBUnitRequestsViewController

#pragma mark - Private

-(void)getRequests {
    
    [FIRManager getAllValuesFromNode:@"requests"
                           orderedBy:@"unit/id"
                          filteredBy:_unitId
                  withSuccessHandler:^(NSArray *results) {
                      
                      NSLog(@"VISITORS: %@", results);
                      
                      _feedArray = [NSMutableArray arrayWithArray:results];
                      [_feedTable reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _feedTable.numberOfSections)] withRowAnimation:UITableViewRowAnimationFade];
                  }
                      orErrorHandler:^(NSError *error) {
                          
                          [self alert:@"Error!" withMessage:error.description];
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

#pragma mark - Table View Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_feedArray count];
}

#pragma mark - Table View Data Source

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UBRequestsTableViewCell *cell = [_feedTable dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Unpack community from results array
    NSDictionary<NSString *, NSDictionary *> *snapshotDict = _feedArray[indexPath.row];
    NSString *name = [snapshotDict valueForKeyPath:@"values.from.name"];
    
    cell.nameLabel.text = [NSString stringWithFormat:@"%@", name];
    
    return cell;

    
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *name = [_unitDict valueForKeyPath:@"values.name"];
    NSString *superUnit = [_unitDict valueForKeyPath:@"values.super-unit"];
    _address = [NSString stringWithFormat:@"%@ %@", name, superUnit];
    
    _unitId = [NSString stringWithFormat:@"%@", [_unitDict valueForKey:@"id"]];
    _unitName = [NSString stringWithFormat:@"%@", [_unitDict valueForKeyPath:@"values.name"]];
    
    self.navigationItem.title = _address;
    
    _feedTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self getRequests];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
