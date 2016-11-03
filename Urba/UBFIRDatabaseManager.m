//
//  UBFIRDatabaseManager.m
//  
//
//  Created by Ricardo Nazario on 10/29/16.
//
//

#import "UBFIRDatabaseManager.h"

@import Firebase;

@interface UBFIRDatabaseManager ()

@property (nonatomic) FIRDatabaseHandle refHandle;

@end

@implementation UBFIRDatabaseManager

+ (FIRDatabaseReference *)databaseRef {
    return [[FIRDatabase database] reference];
}

+ (void)getAllValuesFromNode:(NSString *)node withSuccessHandler:(FIRSuccessHandler)successHandler orErrorHandler:(FIRErrorHandler)errorHandler {
    
    FIRDatabaseReference *ref = [self databaseRef];
    ref = [ref child:node];
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    [ref observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        
        [results addObject:snapshot];
        
        if (successHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                successHandler ([self mapResults:results]);
            });
        }
        
    } withCancelBlock:^(NSError *error) {
        
        if (errorHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                errorHandler (error);
            });
        }
        
        NSLog(@"%@", error.description);

        // TODO: SHOW ERROR ALERT
    }];
}

+ (NSArray *)mapResults:(NSArray *)results {
    
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      
        FIRDataSnapshot *snapshot = obj;
        
        NSLog(@"Key: %@\nValue: %@", snapshot.key, snapshot.value);
        
        NSDictionary <NSString *, NSString *> *snapshotDict = snapshot.value;
        [temp addObject: snapshotDict];
    }];
    
    return [NSArray arrayWithArray:temp];
}

@end
