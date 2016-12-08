//
//  UBGuestTableViewCell.m
//  Urba
//
//  Created by Ricardo Nazario on 12/6/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBGuestTableViewCell.h"
#import "FIRManager.h"

@implementation UBGuestTableViewCell

- (IBAction)confirmPressed:(id)sender {
}

- (IBAction)cancelPressed:(id)sender {
    [self removeGuest];
}

-(void)removeGuest {
    
    [FIRManager removeChild:[NSString stringWithFormat:@"visitors/%@", _visitorId]];
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
