//
//  FIRManager.h
//  
//
//  Created by Ricardo Nazario on 10/29/16.
//
//

#import "FIRManager.h"

@import Firebase;

@implementation FIRManager

#pragma mark - Database

+ (FIRDatabaseReference *)databaseRef {
    return [[FIRDatabase database] reference];
}

+(void)stopObserving {
    FIRDatabaseReference *ref = [self databaseRef];
    [ref removeAllObservers];
    NSLog(@"OBSERVERS REMOVED");
}

+ (void)getAllValuesFromNode:(NSString *)node withSuccessHandler:(FIRSuccessHandler)successHandler orErrorHandler:(FIRErrorHandler)errorHandler {
    
    FIRDatabaseHandle refHandle;
    FIRDatabaseReference *ref = [self databaseRef];
    ref = [ref child:node];
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    refHandle = [ref observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        
        [results addObject:snapshot];
        
        if (successHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                successHandler ([self mapResults:results]);
            });
            [ref removeObserverWithHandle:refHandle];
        }
    } withCancelBlock:^(NSError *error) {
        
        if (errorHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                errorHandler (error);
            });
            [ref removeObserverWithHandle:refHandle];
        }
    }];
}

+(void)getAllValuesFromNode:(NSString *)node orderedBy:(NSString *)orderBy filteredBy:(NSString *)filter withSuccessHandler:(FIRSuccessHandler)successHandler orErrorHandler:(FIRErrorHandler)errorHandler {
    
    FIRDatabaseHandle refHandle;
    FIRDatabaseReference *ref = [self databaseRef];
    ref = [ref child:node];
    FIRDatabaseQuery *query;
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    query = [[ref queryOrderedByChild:orderBy] queryEqualToValue:filter];

    refHandle = [query observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        
        if ([snapshot exists]) {
            for (FIRDataSnapshot *snap in snapshot.children) {
                
                [results addObject:snap];
            }
        }
        
        if (successHandler) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                successHandler ([self mapResults:results]);
            });
//            [ref removeAllObservers];
        }
    } withCancelBlock:^(NSError *error) {
        
        if (errorHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                errorHandler (error);
            });
        }
    }];
}

+(void)addToChild:(NSString *)child withId:(NSString *)identifier withPairs:(NSDictionary *)dictionary; {
    
    FIRDatabaseReference *ref = [self databaseRef];
    ref = [[ref child:child] child:identifier];
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        NSString *keyString = key;
        NSString *value = obj;
        
        [[ref child:keyString] setValue:value];
    }];
}

+(void)addToChildByAutoId:(NSString *)child withPairs:(NSDictionary *)dictionary {
    
    FIRDatabaseReference *ref = [self databaseRef];
    
    ref = [[ref child:child] childByAutoId];
    [ref setValue:dictionary];
}

+(void)removeChild:(NSString *)child {

    FIRDatabaseReference *ref = [self databaseRef];
    
    ref = [ref child:child];
    [ref removeValue];
}

#pragma mark - Auth

+(NSString *)getCurrentUser {
    return [FIRAuth auth].currentUser.uid;
}

+(NSString *)getCurrentUserEmail {
    return [FIRAuth auth].currentUser.email;
}

+(void)logIn:(NSString *)email withPassword:(NSString *)password withHandler:(FIRAuthHandler)authHandler {
    
    [[FIRAuth auth] signInWithEmail:email
                           password:password
                         completion:^(FIRUser *user, NSError *error) {
                             
                             if (error) {
                                 authHandler(NO,error);
                             } else {
                                 authHandler(YES,nil);
                             }
    }];
}

+(void)createUser:(NSString *)email withPassword:(NSString *)password withHandler:(FIRAuthHandler)authHandler {
    
    [[FIRAuth auth] createUserWithEmail:email
                               password:password
                             completion:^(FIRUser *user, NSError *error) {
                                 
                                 if (error) {
                                     authHandler(NO,error);
                                 } else {
                                     authHandler(YES,nil);
                                 }
    }];
}

#pragma mark - Private

+ (NSArray *)mapResults:(NSArray *)results {
    
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      
        FIRDataSnapshot *snapshot = obj;
        
        NSMutableDictionary <NSString *, NSString *> *childDict;
        
        NSMutableArray *childKeyArr = [[NSMutableArray alloc] init];
        NSMutableArray *childValArr = [[NSMutableArray alloc] init];
        
        for (FIRDataSnapshot *child in snapshot.children.allObjects) {
            NSString *key = child.key;
            NSString *value = child.value;
            
            [childKeyArr addObject:key];
            [childValArr addObject:value];
        }
        
        childDict = [NSMutableDictionary dictionaryWithObjects:childValArr forKeys:childKeyArr];
        
        NSDictionary <NSString *, NSArray *> *snapDict = [NSDictionary dictionaryWithObjectsAndKeys: snapshot.key, @"id", childDict, @"values", nil];
        
        [temp addObject: snapDict];
    }];
    
    return [NSArray arrayWithArray:temp];
}

@end
