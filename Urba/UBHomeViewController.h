//
//  UBHomeViewController.h
//  Urba
//
//  Created by Ricardo Nazario on 9/28/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UBFindCommunityViewController.h"

@interface UBHomeViewController : UIViewController

@property (weak, nonatomic) NSMutableArray *unitArray;

@property (nonatomic) NSString *communityName;
@property (nonatomic) NSString *communityKey;
@property (nonatomic) NSString *superUnitName;
@property (nonatomic) NSString *superUnitKey;
@property (nonatomic) NSString *unitName;
@property (nonatomic) NSString *unitKey;


@end
