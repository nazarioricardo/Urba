//
//  UBGuestTableViewCell.m
//  Urba
//
//  Created by Ricardo Nazario on 12/6/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBGuestTableViewCell.h"

@implementation UBGuestTableViewCell

- (IBAction)confirmPressed:(id)sender {
}

- (IBAction)cancelPressed:(id)sender {
    
    if([self.delegate respondsToSelector:@selector(cancelGuest:)])
    {
        [self.delegate cancelGuest:self];
        //or u can send the whole cell itself
        //for example for passing the cell itself
        //[self.delegate touchedTheCell:self]; //while at the defining the delegate u must change the sender type to - (void)touchedTheCell:(CellTypeOne *)myCell; if it shows any error  in the defining of the delegate add "@class CellTypeOne;" above the defying the delegate
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
