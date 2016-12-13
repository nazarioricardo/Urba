//
//  UBUnitManagementViewController.h
//  Urba
//
//  Created by Ricardo Nazario on 11/23/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UBUnitViewController : UIViewController <UITextViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) NSDictionary<NSString *, NSDictionary *> *unitDict;

@end
