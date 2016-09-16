//
//  FireBaseController.m
//  Urba
//
//  Created by Ricardo Nazario on 9/12/16.
//  Copyright © 2016 Ricardo Nazario. All rights reserved.
//

#import "FireBaseController.h"

@import Firebase;

@implementation FireBaseController

+(void)createUser:(NSString *)email withPassword:(NSString *)password {
    
    [[FIRAuth auth] createUserWithEmail:email
                               password:password
                             completion:^(FIRUser *user, NSError *error) {
                                 
                                 if (error) {
                                     NSLog(@"Error creating user");
                                 } else {
                                     NSLog(@"Success! User created");
                                 }
                                 
                            }];
     
     
    
}

@end
