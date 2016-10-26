//
//  UBHomeViewController.m
//  Urba
//
//  Created by Ricardo Nazario on 9/28/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBHomeViewController.h"

NSString *const findHomeSegue = @"FindHomeSegue";

@interface UBHomeViewController ()

@property (weak, nonatomic) IBOutlet UILabel *unitLabel;
@property (weak, nonatomic) IBOutlet UILabel *superLabel;
@property (weak, nonatomic) IBOutlet UILabel *communityLabel;

@end

@implementation UBHomeViewController

- (IBAction)addHomePressed:(id)sender {
    
    [self performSegueWithIdentifier:findHomeSegue sender:self];
}

-(void)viewWillAppear:(BOOL)animated {
    
    NSLog(@"%@ %@ %@ was selected", _unitName, _superUnitName, _communityName);
    if (_unitName) {
        NSString *unit = [NSString stringWithFormat:@"%@", _unitName];
        NSString *superUnit = [NSString stringWithFormat:@"%@", _superUnitName];
        NSString *community = [NSString stringWithFormat:@"%@", _communityName];
        
        [_unitLabel setText:unit];
        [_superLabel setText:superUnit];
        [_communityLabel setText:community];
    }
    
}

-(void)viewDidAppear:(BOOL)animated {
    NSLog(@"View did appear");
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
    // Get the new view controller using [segue destinationViewController].
    
    if ([segue.identifier isEqualToString:findHomeSegue])
    {
        UINavigationController *nvc = [segue destinationViewController];
        UBFindCommunityViewController *fcvc = (UBFindCommunityViewController *)[nvc topViewController];
        fcvc.homeViewController = self;
    }
    // Pass the selected object to the new view controller.
}

@end
