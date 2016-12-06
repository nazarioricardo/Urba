//
//  UBUnitViewController.m
//  Urba
//
//  Created by Ricardo Nazario on 11/23/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBUnitViewController.h"
#import "UBNilViewController.h"
#import "UBUnitSelectionViewController.h"
#import "UBGuestTableViewCell.h"
#import "ActivityView.h"
#import "FIRManager.h"

@interface UBUnitViewController ()

@property (weak, nonatomic) IBOutlet UITableView *feedTable;

@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *unitName;
@property (strong, nonatomic) NSString *unitId;
@property (strong, nonatomic) NSString *community;
@property (strong, nonatomic) NSString *communityId;
@property (strong, nonatomic) NSString *superUnit;
@property (strong, nonatomic) NSString *superUnitId;

@property (strong, nonatomic) NSMutableArray *feedArray;
@property (strong, nonatomic) NSMutableArray *requestsArray;


@end

@implementation UBUnitViewController

#pragma mark - IBActions

- (IBAction)addGuestPressed:(id)sender {
    
    [self addGuestController];
}

#pragma mark - Private

-(void)getGuests {
    
    [FIRManager getAllValuesFromNode:@"visitors"
                           orderedBy:@"unit-id"
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

-(void)addGuestController {
    
    UIAlertController *addView = [UIAlertController
                                    alertControllerWithTitle:NSLocalizedString(@"Add Guest", nil)
                                    message:@"What's your guest's name?"
                                    preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *add = [UIAlertAction actionWithTitle:@"Add"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   
                                                   UITextField *addTextField = addView.textFields.firstObject;
                                                   
                                                   if (![addTextField.text isEqualToString:@""]) {
                                                       
                                                       NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:addTextField.text, @"name", _unitName, @"unit", _unitId, @"unit-id", _community, @"community", _communityId, @"community-id",_superUnit,@"super-unit",_superUnitId,@"super-unit-id", nil];
                                                       
                                                       [addTextField resignFirstResponder];
                                                       
                                                       [FIRManager addToChildByAutoId:@"visitors" withPairs:dict];
                                                   }
                                                   
                                                  
                                               }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   [addView dismissViewControllerAnimated:YES
                                                                                 completion:nil];
                                               }];
    
    [addView addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = NSLocalizedString(@"Guest Name", @"GuestName");
     }];
    
    [addView addAction:add];
    [addView addAction:cancel];

    [self presentViewController:addView animated:YES completion:nil];
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

#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];    
    return YES;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - Table View Delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_feedArray count];
}


#pragma mark - Table View Data Source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UBGuestTableViewCell *cell = [_feedTable dequeueReusableCellWithIdentifier:@"GuestCell" forIndexPath:indexPath];
    
    // Unpack community from results array
    NSDictionary<NSString *, NSDictionary *> *snapshotDict = _feedArray[indexPath.row];
    NSString *name = [snapshotDict valueForKeyPath:@"values.name"];
    
    cell.nameLabel.text = [NSString stringWithFormat:@"%@", name];
    cell.statusLabel.text = [NSString stringWithFormat:@"suck it"];
    
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
    _communityId = [NSString stringWithFormat:@"%@", [_unitDict valueForKeyPath:@"values.community-id"]];
    _community = [NSString stringWithFormat:@"%@", [_unitDict valueForKeyPath:@"values.community"]];
    _superUnit = [NSString stringWithFormat:@"%@", [_unitDict valueForKeyPath:@"values.super-unit"]];
    _superUnitId = [NSString stringWithFormat:@"%@", [_unitDict valueForKeyPath:@"values.super-unit-id"]];
    
    NSLog(@"Unit id: %@", _unitId);
    [self getGuests];
    
    self.navigationItem.title = _address;
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
