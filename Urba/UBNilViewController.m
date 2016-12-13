//
//  UBNilViewController.m
//  
//
//  Created by Ricardo Nazario on 12/2/16.
//
//

#import "UBNilViewController.h"
#import "UBUnitSelectionViewController.h"
#import "ActivityView.h"

@interface UBNilViewController ()

@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondLabel;
@property (weak, nonatomic) IBOutlet UIButton *addHomeButton;

@end

@implementation UBNilViewController

- (void)getUnits {
    
//    ActivityView *spinner = [ActivityView loadSpinnerIntoView:self.view];
    
//    [FIRManager getAllValuesFromNode:@"units"
//                           orderedBy:@"user/id"
//                          filteredBy:[FIRManager getCurrentUser]
//                  withSuccessHandler:^(NSArray *results) {
//                      
//                      if (![results count]) {
//                          
//                          [FIRManager getAllValuesFromNode:@"requests"
//                                                 orderedBy:@"from/id"
//                                                filteredBy:[FIRManager getCurrentUser]
//                                        withSuccessHandler:^(NSArray *results) {
//                                            
//                                            if ([results count]) {
//                                                
//                                                _mainLabel.text = @"Waiting for verification!";
//                                                _secondLabel.text = @"In the meantime,you can contact your community's administrator to speed up your verification, and check out our website to learn about our features.";
//                                                _secondLabel.hidden = NO;
//                                                _addHomeButton.hidden = YES;
//                                                NSLog(@"You have a request pending.");
//                                                [spinner removeSpinner];
//                                            } else {
//                                                [spinner removeSpinner];
//                                            }
//                                        }
//                                            orErrorHandler:^(NSError *error) {
//                                                
//                                                NSLog(@"Error: %@", error.description);
//                                            }];
//                      } else if ([results count] >= 1) {
//                          
//                          NSString *storyboardName = @"Main";
//                          UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
//                          UINavigationController *navBar = [storyboard instantiateViewControllerWithIdentifier:@"UnitListNav"];
////                          UBUnitSelectionViewController *usvc = [storyboard instantiateViewControllerWithIdentifier:@"Unit List"];
//                          [self presentViewController:navBar animated:YES completion:nil];
//                      
//                      } else {
//                          
//                          NSString *storyboardName = @"Main";
//                          UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
//                          UINavigationController *navBar = [storyboard instantiateViewControllerWithIdentifier:@"UnitNav"];
//                          [self presentViewController:navBar animated:YES completion:nil];
//                          
//                      }
//                  }
//                      orErrorHandler:^(NSError *error) {
//                          
//                          NSLog(@"Error: %@", error.description);
//                      }];
}

-(void)viewWillAppear:(BOOL)animated {
    _secondLabel.hidden = YES;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
