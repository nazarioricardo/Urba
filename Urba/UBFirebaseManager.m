//
//  UBFirebaseManager.m
//  Urba
//
//  Created by Ricardo Nazario on 10/2/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "UBFirebaseManager.h"

@implementation UBFirebaseManager 

+ (void)configureDatabase:(NSString *)refChild filteredBy:(NSString *)filter withValue:(NSString *)value withCompletionHandler:(FirebaseHandler)handler {
    
    NSMutableArray<FIRDataSnapshot *> *results;
    FIRDatabaseHandle refHandle;
    FIRDatabaseReference *ref;

    ref = [[FIRDatabase database] reference];
    results = nil;
    results = [[NSMutableArray alloc] init];
    
    
    if (filter) {
        ref = [ref child:refChild];
        
        FIRDatabaseQuery *query = [[ref queryOrderedByChild:filter] queryEqualToValue:value];
        
        refHandle = [query observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
            [results addObject:snapshot];
        } withCancelBlock:^(NSError *error) {
            
            NSLog(@"%@", error.localizedDescription);
        }];
    } else {
        
        ref = [ref child:refChild];
        
        refHandle = [ref observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
            [results addObject:snapshot];
        } withCancelBlock:^(NSError *error) {
            
            NSLog(@"%@", error.localizedDescription);
        }];
    }
}

@end
