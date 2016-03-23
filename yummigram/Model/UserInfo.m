//
//  UserInfo.m
//  ProtoDeviceMonitor
//
//  Created by User on 1/16/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo

@synthesize             strUserFirstName;
@synthesize             strUserLastName;
@synthesize             strUserEmail;
@synthesize             strUserPassword;
@synthesize             strFacebookID;
@synthesize             strFacebookToken;
@synthesize             strUserObjID;
@synthesize             imgPhoto;
@synthesize             isMale;
@synthesize             birthDay;
@synthesize             arrFollower;
@synthesize             arrFollowing;
@synthesize             arrFavorites;
@synthesize             arrWallImages;
@synthesize             strFollowObjID;
@synthesize             canNotifyComment;
@synthesize             canNotifyFavorite;
@synthesize             canNotifyLike;
@synthesize             canNotifyFollow;
@synthesize             canNotifyMessage;

- (id)init
{
    self = [super init];
    if(self)
    {
        strUserFirstName       = @"";
        strUserLastName        = @"";
        strUserEmail           = @"";
        strUserPassword        = @"";
        strFacebookID          = @"";
        strFacebookToken       = @"";
        strUserObjID           = @"";
        imgPhoto               = nil;
        isMale                 = YES;
        birthDay               = nil;
        arrFollowing           = [[NSMutableArray alloc] init];
        arrFollower            = [[NSMutableArray alloc] init];
        arrFavorites           = [[NSMutableArray alloc] init];
        arrWallImages          = [[NSMutableArray alloc] init];
        strFollowObjID         = @"";
        canNotifyLike          = YES;
        canNotifyFavorite      = YES;
        canNotifyComment       = YES;
        canNotifyMessage       = YES;
        canNotifyFollow        = YES;
    }
    
    return self;
}

- (void)addInfoWithPFUser:(PFUser *)user
{
    strUserFirstName = [user objectForKey:pKeyFirstName] == nil ? @"" : [user objectForKey:pKeyFirstName];
    strUserLastName  = [user objectForKey:pKeyLastName] == nil ? @"" : [user objectForKey:pKeyLastName];
    strFacebookID    = [user objectForKey:pKeyFBID] == nil ? @"" : [user objectForKey:pKeyFBID];
    strFacebookToken = [user objectForKey:pKeyFBToken] == nil ? @"" : [user objectForKey:pKeyFBToken];
    strUserEmail     = user.email == nil ? @"" : user.email;
    strUserObjID     = user.objectId;
    isMale           = [user objectForKey:pKeyGender] == nil ? YES  : [[user objectForKey:pKeyGender] boolValue] ;
    birthDay         = [user objectForKey:pKeyBirthday] == nil ? [NSDate date] : [user objectForKey:pKeyBirthday];
    
    canNotifyComment  = [(NSNumber *)user[pKeyNotifyComments] boolValue];
    canNotifyFavorite = [(NSNumber *)user[pKeyNotifyFavorite] boolValue];
    canNotifyLike     = [(NSNumber *)user[pKeyNotifyLike] boolValue];
    canNotifyFollow   = [(NSNumber *)user[pKeyNotifyFollow] boolValue];
    canNotifyMessage  = [(NSNumber *)user[pKeyNotifyMessage] boolValue];
    
    if(user[pKeyPhoto] == nil)
        imgPhoto = [UIImage imageNamed:@"btn_profile.png"];
    else{
        imgPhoto = [UIImage imageWithData:[(PFFile *)user[pKeyPhoto] getData]];
    }
    
    arrFavorites  = user[pKeyFavorites]  == nil ? [[NSMutableArray alloc] init] : user[pKeyFavorites];
    arrWallImages = user[pKeyWallImages] == nil ? [[NSMutableArray alloc] init] : user[pKeyWallImages];
    
    strFollowObjID = user[pKeyFollowID];
    
    PFObject *objFollow = [AppDelegate getFollowPFObjectFrom:strFollowObjID];
    
    arrFollowing  = objFollow[pKeyFollowing]  == nil ? [[NSMutableArray alloc] init] : objFollow[pKeyFollowing];
    arrFollower   = objFollow[pKeyFollower]   == nil ? [[NSMutableArray alloc] init] : objFollow[pKeyFollower];
}

+ (instancetype)initWithFirstName:(NSString *)firstName
                         lastName:(NSString *)lastName
                        userEmail:(NSString *)userEmail
                     userPassword:(NSString *)userPassword
                           gender:(BOOL) isMale
                         birthday:(NSDate *)birthDay
{
    UserInfo *userInfo = [[UserInfo alloc] init];
    
    userInfo.strUserFirstName = firstName;
    userInfo.strUserLastName  = lastName;
    userInfo.strUserPassword  = userPassword;
    userInfo.strUserEmail     = userEmail;
    userInfo.isMale = isMale;
    userInfo.birthDay = birthDay;
    userInfo.strFacebookID    = @"";
    userInfo.strFacebookToken = @"";
    userInfo.strUserObjID     = @"";
    userInfo.imgPhoto         = nil;
    userInfo.arrFollower      = [[NSMutableArray alloc] init];
    userInfo.arrFollowing     = [[NSMutableArray alloc] init];
    userInfo.arrFavorites     = [[NSMutableArray alloc] init];
    userInfo.arrWallImages    = [[NSMutableArray alloc] init];
    
    userInfo.canNotifyComment  = YES;
    userInfo.canNotifyFavorite = YES;
    userInfo.canNotifyLike     = YES;
    userInfo.canNotifyFollow   = YES;
    userInfo.canNotifyMessage  = YES;
    
    return userInfo;
}

- (BOOL)isNewUser
{
    return [PFUser currentUser].isNew;
}

@end
