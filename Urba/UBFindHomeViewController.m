//
//  UBFindHomeViewController.m
//  Urba
//
//  Created by Ricardo Nazario on 9/28/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBFindHomeViewController.h"
#import "UBHomeViewController.h"
#import "UBFirebaseManager.h"

@interface UBFindHomeViewController () <UITableViewDataSource, UITableViewDelegate> {
    FIRDatabaseHandle _refHandle;
}

@property (weak, nonatomic) IBOutlet UITableView *communityTable;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *indicatorBackground;

@property (strong, nonatomic) NSMutableArray<FIRDataSnapshot *> *results;
@property (strong, nonatomic) FIRDatabaseReference *ref;

@property (weak, nonatomic) UBHomeViewController *hvc;

@property (nonatomic) NSString *selectedCommunityName;
@property (nonatomic) NSString *selectedCommunityKey;
@property (nonatomic) NSString *selectedSuperName;
@property (nonatomic) NSString *selectedSuperKey;
@property (nonatomic) NSString *selectedUnitName;
@property (nonatomic) NSString *selectedUnitKey;
@property (nonatomic) NSString *filter;
@property (nonatomic) NSString *currentCategory;


- (void)configureDatabase:(NSString *)refChild filteredBy:(NSString *)filter withValue:(NSString *)value;
- (void)shouldAnimateIndicator:(BOOL)animate;
- (void)toggleHideView:(UIView *)view;

@end

@implementation UBFindHomeViewController

#pragma mark - IBActions

- (IBAction)cancelPressed:(id)sender {
    
    _results = nil;
    
    [_communityTable reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _communityTable.numberOfSections)] withRowAnimation:UITableViewRowAnimationFade];
    
    if ([_currentCategory isEqualToString:@"super-units"]) {
        [self configureDatabase:@"communities" filteredBy:nil withValue:nil];
    } else if ([_currentCategory isEqualToString:@"units"]) {
        [self configureDatabase:@"super-units" filteredBy:@"community" withValue:_selectedCommunityName];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Private

- (void)configureDatabase:(NSString *)refChild filteredBy:(NSString *)filter withValue:(NSString *)value {
    
    [self shouldAnimateIndicator:YES];
    
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
        [_communityTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_results.count-1 inSection:0]]
                               withRowAnimation: UITableViewRowAnimationLeft];
        [self shouldAnimateIndicator:NO];
    }];
    

    _currentCategory = (NSString *)[_ref key];
    NSLog(@"The current category is %@", _currentCategory);
}

- (void)shouldAnimateIndicator:(BOOL)animate {
    if (animate) {
        _activityIndicator.hidden = NO;
        _indicatorBackground.hidden = NO;
        [_activityIndicator startAnimating];
    } else {
        _activityIndicator.hidden = YES;
        _indicatorBackground.hidden = YES;
        [_activityIndicator stopAnimating];
    }
    self.view.userInteractionEnabled = !animate;
}

- (void)toggleHideView:(UIView *)view {
    
    if (![view isHidden]) {
        
        [UIView transitionWithView:view
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            view.hidden = YES;
                        }
                        completion:NULL];
    } else {
        
        [UIView transitionWithView:view
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            view.hidden = NO;
                        }
                        completion:NULL];
    }
}

#pragma mark - Life Cycle

-(void)viewWillAppear:(BOOL)animated {
    [self configureDatabase:@"communities" filteredBy:nil withValue:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"View Loaded");
        
    _indicatorBackground.layer.masksToBounds = YES;
    _indicatorBackground.layer.cornerRadius = 20;

    [_communityTable registerClass:UITableViewCell.self forCellReuseIdentifier:@"cell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [_communityTable dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
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
    _results = nil;
    
    [_communityTable reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _communityTable.numberOfSections)] withRowAnimation:UITableViewRowAnimationRight];
    [_communityTable reloadData];
    
    NSLog(@"The selection is %@", selection);
    NSString *query = [NSString stringWithFormat:@"%@-%@", selection, currentSnapKey];
    
    if ([_currentCategory isEqualToString:@"communities"]) {
        
        _selectedCommunityName = selection;
        _selectedCommunityKey = currentSnapKey;
        NSLog(@"The community is %@ with the key %@", _selectedCommunityName, _selectedCommunityKey);
        [self configureDatabase:@"super-units" filteredBy:@"community" withValue:query];
    } else if ([_currentCategory isEqualToString:@"super-units"]) {
    
        _selectedSuperName = selection;
        _selectedSuperKey = currentSnapKey;
        NSLog(@"The super-unit is %@ with the key %@", _selectedSuperName, _selectedSuperKey);
        [self configureDatabase:@"units" filteredBy:@"super-unit" withValue:query];
    } else {
        _hvc.unitName = selection;
        _selectedUnitName = selection;
        _selectedUnitKey = currentSnapKey;
        NSLog(@"The unit is %@ with the key %@",_selectedUnitName, _selectedUnitKey);
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Navigation

/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    
    UBHomeViewController *hvc = [segue sourceViewController];

    hvc.unitName = _selectedUnitName;
    // Pass the selected object to the new view controller.
}
*/

@end
