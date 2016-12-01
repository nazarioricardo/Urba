//
//  UBFIRDatabaseManager.h
//  
//
//  Created by Ricardo Nazario on 10/29/16.
//
//

#import <Foundation/Foundation.h>

typedef void(^FIRSuccessHandler)(NSArray *results);
typedef void(^FIRErrorHandler)(NSError *error);

@interface UBFIRDatabaseManager : NSObject

+(void)getAllValuesFromNode:(NSString *)node withSuccessHandler:(FIRSuccessHandler)successHandler orErrorHandler:(FIRErrorHandler)errorHandler;
+(void)getAllValuesFromNode:(NSString *)node orderedBy:(NSString *)orderBy filteredBy:(NSString *)filter withSuccessHandler:(FIRSuccessHandler)successHandler orErrorHandler:(FIRErrorHandler)errorHandler;

+(void)addToChild:(NSString *)child withId:(NSString *)identifier withPairs:(NSDictionary *)dictionary;
+(void)addToChildByAutoId:(NSString *)child withPairs:(NSDictionary *)dictionary;

+(NSString *)getCurrentUser;
+(NSString *)getCurrentUserEmail;

@end
