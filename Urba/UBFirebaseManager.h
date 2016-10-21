//
//  UBFirebaseManager.h
//  Urba
//
//  Created by Ricardo Nazario on 10/2/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FirebaseDatabase/FirebaseDatabase.h>

typedef void (^FirebaseHandler)(NSArray *results, NSError *error);

@interface UBFirebaseManager : NSObject

+(void)configureDatabase:(NSString *)refChild filteredBy:(NSString *)filter withValue:(NSString *)value withCompletionHandler:(FirebaseHandler) handler;

@end
