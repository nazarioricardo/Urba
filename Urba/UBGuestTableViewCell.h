//
//  UBGuestTableViewCell.h
//  Urba
//
//  Created by Ricardo Nazario on 12/6/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UBUnitViewController.h"

@interface UBGuestTableViewCell : UITableViewCell

@property (weak, nonatomic) UBUnitViewController *uvc;

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) NSString *visitorId;

-(void)removeGuest;

@end
