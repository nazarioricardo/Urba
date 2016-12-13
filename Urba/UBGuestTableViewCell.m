//
//  UBGuestTableViewCell.m
//  Urba
//
//  Created by Ricardo Nazario on 12/6/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBGuestTableViewCell.h"
#import "UBRequestsTableViewCell.h"

@implementation UBGuestTableViewCell

- (IBAction)confirmPressed:(id)sender {
    
    if([_delegate respondsToSelector:@selector(cancelGuest:)]) {
        [_delegate confirmGuest:self];
    }
}

- (IBAction)cancelPressed:(id)sender {
    
    if([_delegate respondsToSelector:@selector(cancelGuest:)]) {
        [_delegate cancelGuest:self];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [_delegate listenToStatus:self];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
