//
//  UBFindUnitTableViewController.h
//  Urba
//
//  Created by Ricardo Nazario on 10/25/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UBHomeViewController;

@interface UBFindUnitTableViewController : UITableViewController

@property (weak, nonatomic) NSString *communityName;
@property (weak, nonatomic) NSString *communityKey;
@property (weak, nonatomic) NSString *superUnitName;
@property (weak, nonatomic) NSString *superUnitKey;
@property (weak, nonatomic) NSString *adminId;
@property (weak, nonatomic) NSString *adminName;

@end
