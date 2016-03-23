//
//  AppDelegate.h
//  ProtoDeviceMonitor
//
//  Created by User on 1/16/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "ParseService.h"

@implementation ParseService

ParseService *sharedParseObj = nil;

+ (id)sharedInstance{
    
    if(!sharedParseObj)
    {
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            sharedParseObj = [[self alloc] init];
        });
    }
    
    return sharedParseObj;
}

- (void)loginWithUserName:(NSString *)strUserName
                 Password:(NSString *)strPassword
                   Result:(void (^)(NSString *))onResult
{
    [PFUser logInWithUsernameInBackground:strUserName
                                 password:strPassword
                                    block:^(PFUser *user, NSError *error) {
                                        if(error == nil)
                                        {
                                            [g_myInfo addInfoWithPFUser:user];
                                            [[DataStore instance] reset];
                                            onResult(nil);
                                        }
                                        else
                                            onResult([error.userInfo objectForKey:@"error"]);
                                    }];
}

- (void)loginWithFacebookPermission:(NSArray *)aryPermissions
                             Result:(void (^)(NSString *))onResult
{
    [PFFacebookUtils logInWithPermissions:aryPermissions
                                    block:^(PFUser *user, NSError *error) {
                                        if(error == nil && user != nil)
                                        {
                                            if(user.isNew)
                                            {
                                                
                                                FBRequest *request = [FBRequest requestForMe];
                                                [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                                    if (!error)
                                                    {
                                                        NSDictionary *data = (NSDictionary*)result;
                                                        NSString *fid = [data objectForKey:@"id"];
                                                        NSString *fb_token  = [[[FBSession activeSession] accessTokenData] accessToken];
                                                        
                                                        NSString *url = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", fid];
                                                        UIImage* myImage = [UIImage imageWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
                                                        NSData *imageData = UIImagePNGRepresentation(myImage);
                                                        PFFile *imgFile = [PFFile fileWithName:@"profile.png" data:imageData];
                                                        
                                                        [imgFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                                            if (!error) {
                                                                [user setObject:[data objectForKey:@"first_name"] forKey:pKeyFirstName];
                                                                [user setObject:[data objectForKey:@"last_name"] forKey:pKeyLastName];
                                                                
                                                                NSString *strGender = [data objectForKey:@"gender"];
                                                                BOOL isMale = [strGender isEqualToString:@"male"];
                                                        
                                                                [user setObject:[NSNumber numberWithBool:isMale] forKey:pKeyGender];
                                                                [user setObject:fid forKey:pKeyFBID];
                                                                [user setObject:fb_token forKey:pKeyFBToken];
                                                                [user setObject:imgFile forKey:pKeyPhoto];
                                                                [user setEmail:[data objectForKey:@"email"] != nil ? [data objectForKey:@"email"] : @""];
                                                                
                                                                user[pKeyNotifyComments] = [NSNumber numberWithBool:YES];
                                                                user[pKeyNotifyMessage]  = [NSNumber numberWithBool:YES];
                                                                user[pKeyNotifyLike]     = [NSNumber numberWithBool:NO];
                                                                user[pKeyNotifyFollow]   = [NSNumber numberWithBool:YES];
                                                                user[pKeyNotifyFavorite] = [NSNumber numberWithBool:YES];
                                                                
                                                                PFObject *pfObjFollow = [PFObject objectWithClassName:pClassFollow];
                                                                
                                                                pfObjFollow[pKeyFollower]  = [[NSMutableArray alloc] init];
                                                                pfObjFollow[pKeyFollowing] = [[NSMutableArray alloc] init];
                                                                
                                                                [pfObjFollow saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                                                    if(succeeded){
                                                                        user[pKeyFollowID] = pfObjFollow.objectId;
                                                                        
                                                                        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                                                                            if(error == nil)
                                                                            {
                                                                                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DEFAULT_USER_PHOTO_EFFECT];
                                                                                [[NSUserDefaults standardUserDefaults] synchronize];
                                                                                
                                                                                [g_myInfo addInfoWithPFUser:user];
                                                                                [[DataStore instance] reset];
                                                                                //                                                                        [self initUserDefaultsValue];
                                                                                onResult(nil);
                                                                            }
                                                                            else    //user save error
                                                                                onResult([error.userInfo objectForKey:@"error"]);
                                                                        }];
                                                                        
                                                                    }
                                                                }];

                                                            }else
                                                                onResult([error.userInfo objectForKey:@"error"]);
                                                        }];
                                                    }
                                                    else    //facebook request error
                                                        onResult([error.userInfo objectForKey:@"error"]);
                                                }];
                                            }
                                            else    //is not new user
                                            {
                                                [g_myInfo addInfoWithPFUser:user];
                                                [[DataStore instance] reset];
                                                onResult(nil);
                                            }
                                        }
                                        else    //facebook login error
                                            onResult(@"Failed to Facebook login");
                                    }];
}

- (void)requestPasswordWithUserName:(NSString *)strUserName
                             Result:(void (^)(NSString *))onResult
{
    [PFUser requestPasswordResetForEmailInBackground:strUserName
                                               block:^(BOOL succeeded, NSError *error) {
                                                   if(error == nil)
                                                       onResult(nil);
                                                   else
                                                       onResult([error.userInfo objectForKey:@"error"]);
                                               }];
}

- (void)signUpWithUserInfo:(UserInfo *)userInfo
                    Result:(void (^)(NSString *))onResult
{
    PFUser *user = [PFUser new];
    
    [user setObject:userInfo.strUserFirstName forKey:pKeyFirstName];
    [user setObject:userInfo.strUserLastName forKey:pKeyLastName];
    
    user.email = userInfo.strUserEmail;
    user.username = userInfo.strUserEmail;
    user.password = userInfo.strUserPassword;
    user[pKeyBirthday] = userInfo.birthDay;
    user[pKeyGender] = [NSNumber numberWithBool:userInfo.isMale];
    
    user[pKeyNotifyComments] = [NSNumber numberWithBool:YES];
    user[pKeyNotifyMessage]  = [NSNumber numberWithBool:YES];
    user[pKeyNotifyLike]     = [NSNumber numberWithBool:NO];
    user[pKeyNotifyFollow]   = [NSNumber numberWithBool:YES];
    user[pKeyNotifyFavorite] = [NSNumber numberWithBool:YES];
    
    PFObject *pfObjFollow = [PFObject objectWithClassName:pClassFollow];
    
    pfObjFollow[pKeyFollower]  = [[NSMutableArray alloc] init];
    pfObjFollow[pKeyFollowing] = [[NSMutableArray alloc] init];
    
    [pfObjFollow saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            user[pKeyFollowID] = pfObjFollow.objectId;
            
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(error == nil)
                {
                    [g_myInfo addInfoWithPFUser:user];
                    [[DataStore instance] reset];
                    
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DEFAULT_USER_PHOTO_EFFECT];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    onResult(nil);
                }
                else
                    onResult([error.userInfo objectForKey:@"error"]);
            }];

        }
    }];
}

- (void)updateProfileWithFirstName:(NSString *)firstName
                          LastName:(NSString *)lastName
                            Result:(void (^)(NSString *))onResult
{
    PFUser *user = [PFUser currentUser];
    [user setObject:firstName forKey:pKeyFirstName];
    [user setObject:lastName forKey:pKeyLastName];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error == nil)
        {
            onResult(nil);
        }
        else
            onResult([error.userInfo objectForKeyedSubscript:@"error"]);
    }];
}


- (void)uploadProfileImageFile:(UIImage *)image
                        Result:(void (^)(NSString *))onResult
                       Persent:(void (^)(int))onPersent;
{
    PFFile *imgFile = [PFFile fileWithName:@"profile.png" data:UIImagePNGRepresentation(image)];
    [imgFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error == nil)
        {
            PFUser *user = [PFUser currentUser];
            [user setObject:imgFile forKey:pKeyPhoto];
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(error == nil){
                   [g_myInfo addInfoWithPFUser:user];
                    UserInfo *userInfo = [[DataStore instance].userInfoMap objectForKey:g_myInfo.strUserObjID];
                    
                    [userInfo addInfoWithPFUser:user];
                    onResult(nil);
                }else
                    onResult([error.userInfo objectForKeyedSubscript:@"error"]);
            }];
        }
        else
            onResult([error.userInfo objectForKeyedSubscript:@"error"]);
        
    }
                         progressBlock:^(int percentDone) {
                             onPersent(percentDone);
                         }];
    
}

@end
