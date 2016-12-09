//
//  UBRequestsTableViewCell.m
//  Urba
//
//  Created by Ricardo Nazario on 12/7/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBRequestsTableViewCell.h"

@implementation UBRequestsTableViewCell

- (IBAction)acceptPressed:(id)sender {
    
    if([_delegate respondsToSelector:@selector(acceptRequest:)]) {
        [_delegate acceptRequest:self];
    }
}

- (IBAction)denyPressed:(id)sender {
    
    if([_delegate respondsToSelector:@selector(denyRequest:)]) {
        [_delegate denyRequest:self];
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
