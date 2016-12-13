//
//  UBUnitSelectionViewController.m
//  Urba
//
//  Created by Ricardo Nazario on 9/28/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBUnitSelectionViewController.h"
#import "UBUnitViewController.h"
#import "Constants.h"
#import "ActivityView.h"

@interface UBUnitSelectionViewController ()

@property (weak, nonatomic) IBOutlet UITableView *unitsTable;
@property (strong, nonatomic) NSMutableArray *unitsArray;
@property (weak, nonatomic) NSDictionary <NSString *, NSDictionary *> *unitDict;

@end

@implementation UBUnitSelectionViewController

#pragma mark - IBActions

- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private

- (void)getUnits {
    
    ActivityView *spinner = [ActivityView loadSpinnerIntoView:self.view];
    
//    NSString *unitRef = [NSString stringWithFormat:@"users/%@/name", [FIRManager getCurrentUser]];
    
//    [FIRManager getAllValuesFromNode:@"units"
//                           orderedBy:unitRef
//                          filteredBy:[FIRManager getCurrentUser]
//                  withSuccessHandler:^(NSArray *results) {
//                                
//                                _unitsArray = [NSMutableArray arrayWithArray:results];
//                                
//                                if ([results count] <= 1) {
//                                    
//                                    [spinner removeSpinner];
//                                    [self alert:@"Wait a minute..." withMessage:@"You only have one registered household! If this is wrong, try reloading the page, or make sure you don't have any unverified requests."];
//                                } else {
//                                    
//                                    [spinner removeSpinner];
//                                    [_unitsTable reloadData];
//                                }
//                            }
//                                orErrorHandler:^(NSError *error) {
//                                    [spinner removeSpinner];
//                                    [self alert:@"Error!" withMessage:error.description];
//                                }];
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
                                                   [self dismissViewControllerAnimated:YES completion:nil];
                                               }];
    [alertView addAction:ok];
    [self presentViewController:alertView animated:YES completion:nil];
    
}

#pragma mark - Table View Data Source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_unitsArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [_unitsTable dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSDictionary<NSString *, NSDictionary *> *snapshotDict = _unitsArray[indexPath.row];
    NSString *unit = [snapshotDict valueForKeyPath:@"values.name"];
    NSString *superUnit = [snapshotDict valueForKeyPath:@"values.super-unit"];
    NSString *address = [NSString stringWithFormat:@"%@ %@", unit, superUnit];

    cell.textLabel.text = [NSString stringWithFormat:@"%@", address];
    
    return cell;
}

#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    _unitDict = _unitsArray[indexPath.row];
    
    [self performSegueWithIdentifier:unitManageSegue sender:self];
}

#pragma mark - Life Cycle

-(void)viewWillAppear:(BOOL)animated {
    [self getUnits];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:unitManageSegue]) {
        
        UINavigationController *nvc = [segue destinationViewController];
        UBUnitViewController *uuvc = (UBUnitViewController *)[nvc topViewController];
        [uuvc setUnitDict:_unitDict];
    }
}

@end
