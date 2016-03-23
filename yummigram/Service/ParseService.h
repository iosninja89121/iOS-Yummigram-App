//
//  AppDelegate.h
//  ProtoDeviceMonitor
//
//  Created by User on 1/16/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <FacebookSDK/FacebookSDK.h>
#import "UserInfo.h"

@interface ParseService : NSObject

+ (id)sharedInstance;

- (void)loginWithUserName:(NSString *)strUserName
                 Password:(NSString *)strPassword
                   Result:(void (^)(NSString *))onResult;

- (void)loginWithFacebookPermission:(NSArray *)aryPermissions
                             Result:(void (^)(NSString *))onResult;

- (void)requestPasswordWithUserName:(NSString *)strUserName
                             Result:(void (^)(NSString *))onResult;

- (void)signUpWithUserInfo:(UserInfo *)userInfo
                    Result:(void (^)(NSString *))onResult;

- (void)updateProfileWithFirstName:(NSString *)firstName
                          LastName:(NSString *)lastName
                            Result:(void (^)(NSString *))onResult;

- (void)uploadProfileImageFile:(UIImage *)image
                        Result:(void (^)(NSString *))onResult
                       Persent:(void (^)(int))onPersent;

@end
