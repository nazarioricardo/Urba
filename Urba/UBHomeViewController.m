//
//  UBHomeViewController.m
//  Urba
//
//  Created by Ricardo Nazario on 9/28/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBHomeViewController.h"
#import "UBFIRDatabaseManager.h"
#import "Constants.h"
#import "ActivityView.h"

@interface UBHomeViewController ()

@property (weak, nonatomic) IBOutlet UITableView *unitsTable;
@property (strong, nonatomic) NSMutableArray *unitsArray;

@end

@implementation UBHomeViewController

#pragma mark - IBActions

- (IBAction)addHomePressed:(id)sender {
    
    [self performSegueWithIdentifier:findHomeSegue sender:self];
}

#pragma mark - Private

- (void)getUnits {
    
    [UBFIRDatabaseManager getAllValuesFromNode:@"units"
                                     orderedBy:@"user/id"
                                    filteredBy:[UBFIRDatabaseManager getCurrentUser]
                            withSuccessHandler:^(NSArray *results) {
                                
                                _unitsArray = [NSMutableArray arrayWithArray:results];
                                [_unitsTable reloadData];
                                NSLog(@"Units: %@", _unitsArray);
                        
                            }
                                orErrorHandler:^(NSError *error) {
                                    
                                    NSLog(@"Error: %@", error.description);
                                }];
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
    NSString *owner = [snapshotDict valueForKeyPath:@"values.owner-name"];
    NSString *address = [NSString stringWithFormat:@"%@ %@", unit, owner];

    cell.textLabel.text = [NSString stringWithFormat:@"%@", address];
    
    return cell;
}

#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
