//
//  UBRequestsTableViewCell.h
//  Urba
//
//  Created by Ricardo Nazario on 12/7/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UBRequestsTableViewCell;

@protocol RequestCellDelegate <NSObject> //this delegate is fired each time you tap the cell

-(void)denyRequest:(UBRequestsTableViewCell *)cell;
-(void)acceptRequest:(UBRequestsTableViewCell *)cell;

@end

@interface UBRequestsTableViewCell : UITableViewCell

@property(weak, nonatomic) id <RequestCellDelegate> delegate; //defining the delegate

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (strong, nonatomic) NSString *requestId;
@property (strong, nonatomic) NSString *fromId;
@property (strong, nonatomic) NSString *fromName;

- (IBAction)acceptPressed:(id)sender;
- (IBAction)denyPressed:(id)sender;

@end
