//
//  FireBaseController.h
//  Urba
//
//  Created by Ricardo Nazario on 9/12/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FireBaseController : NSObject

+(void)createUser:(NSString *)email withPassword:(NSString *)password;

@end
