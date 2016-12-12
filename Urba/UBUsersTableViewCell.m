//
//  UBUsersTableViewCell.m
//  Urba
//
//  Created by Ricardo Nazario on 12/12/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBUsersTableViewCell.h"

@implementation UBUsersTableViewCell

- (IBAction)switchPressed:(id)sender {
    
    if([_delegate respondsToSelector:@selector(toggleUserPermissions:withSwitch:)]) {
        [_delegate toggleUserPermissions:self withSwitch:(UISwitch *)sender];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
