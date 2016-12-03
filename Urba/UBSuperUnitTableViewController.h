//
//  UBSuperUnitTableViewController.h
//  Urba
//
//  Created by Ricardo Nazario on 10/22/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UBFindUnitTableViewController.h"

@class UBHomeViewController;

@interface UBSuperUnitTableViewController : UITableViewController

@property (weak, nonatomic) NSString *communityName;
@property (weak, nonatomic) NSString *communityKey;
@property (weak, nonatomic) NSString *adminId;
@property (weak, nonatomic) NSString *adminName;

@end
