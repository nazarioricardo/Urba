//
//  UBFindSuperUnitViewController.m
//  Urba
//
//  Created by Ricardo Nazario on 10/21/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBFindSuperUnitViewController.h"

@import Firebase;

@interface UBFindSuperUnitViewController () <UITableViewDataSource, UITableViewDelegate> {
    FIRDatabaseHandle _refHandle;
}

@property (strong, nonatomic) NSMutableArray<FIRDataSnapshot *> *results;
@property (strong, nonatomic) FIRDatabaseReference *ref;

@end

@implementation UBFindSuperUnitViewController

- (void)configureDatabase:(NSString *)refChild filteredBy:(NSString *)filter withValue:(NSString *)value {
    
//    [self shouldAnimateIndicator:YES];
    
    FIRDatabaseQuery *query;
    
    _ref = [[FIRDatabase database] reference];
    _ref = [_ref child:refChild];
    
    _results = nil;
    _results = [[NSMutableArray alloc] init];
    
    if (filter) {
        query = [[_ref queryOrderedByChild:filter] queryEqualToValue:value];
    } else {
        query = _ref;
    }
    
    _refHandle = [query observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        [_results addObject:snapshot];
        [_superUnitTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_results.count-1 inSection:0]]
                               withRowAnimation: UITableViewRowAnimationLeft];
//        [self shouldAnimateIndicator:NO];
    }];
    
    
    _currentCategory = (NSString *)[_ref key];
    NSLog(@"The current category is %@", _currentCategory);
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
