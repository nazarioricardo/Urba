//
//  UBUsersTableViewCell.h
//  Urba
//
//  Created by Ricardo Nazario on 12/12/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UBUsersTableViewCell;

@protocol UserCellDelegate <NSObject> //this delegate is fired each time you tap the cell

-(void)toggleUserPermissions:(UBUsersTableViewCell *)cell withSwitch:(UISwitch *)toggleSwitch;

@end

@interface UBUsersTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *permissionsStatusLabel;
@property (weak, nonatomic) IBOutlet UISwitch *permissionsSwitch;

@property (strong, nonatomic) NSString *userId;

@property(weak, nonatomic) id <UserCellDelegate> delegate;


@end
