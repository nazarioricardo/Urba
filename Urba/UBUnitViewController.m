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
#import "ActivityView.h"
#import "FIRManager.h"

@interface UBUnitViewController ()

@property (weak, nonatomic) IBOutlet UITextField *tempVisitorTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *permVisitorTextField;

@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *unitName;
@property (strong, nonatomic) NSString *unitId;
@property (strong, nonatomic) NSString *community;
@property (strong, nonatomic) NSString *communityId;
@property (strong, nonatomic) NSString *superUnit;
@property (strong, nonatomic) NSString *superUnitId;


@end

@implementation UBUnitViewController

#pragma mark - IBActions

- (IBAction)tempVisitorPressed:(id)sender {
    
    if (![_tempVisitorTextField.text isEqualToString:@""]) {
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:_tempVisitorTextField.text, @"name", _unitName, @"unit", _unitId, @"unit-id", _community, @"community", _communityId, @"community-id",_superUnit,@"super-unit",_superUnitId,@"super-unit-id", nil];
        
        [_tempVisitorTextField resignFirstResponder];
        
        [FIRManager addToChildByAutoId:@"visitors" withPairs:dict];
    }
    
}

- (IBAction)permVisitorPressed:(id)sender {

}

- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private


#pragma mark - Text Field Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];    
    return YES;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - Table View Delegate

#pragma mark - Table View Data Source


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
