//
//  UBRequestsTableViewCell.h
//  Urba
//
//  Created by Ricardo Nazario on 12/7/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UBRequestsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end
