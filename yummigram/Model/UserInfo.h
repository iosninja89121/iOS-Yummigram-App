//
//  UserInfo.h
//  ProtoDeviceMonitor
//
//  Created by User on 1/16/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject

@property (nonatomic, retain) NSString          *strUserFirstName;
@property (nonatomic, retain) NSString          *strUserLastName;
@property (nonatomic, retain) NSString          *strUserEmail;
@property (nonatomic, retain) NSString          *strUserPassword;
@property (nonatomic, retain) NSString          *strFacebookID;
@property (nonatomic, retain) NSString          *strFacebookToken;
@property (nonatomic, retain) NSString          *strUserObjID;
@property (nonatomic)         BOOL              isMale;
@property (nonatomic, retain) NSDate            *birthDay;
@property (nonatomic, retain) UIImage           *imgPhoto;
@property (nonatomic, strong) NSMutableArray    *arrFollowing;
@property (nonatomic, strong) NSMutableArray    *arrFollower;
@property (nonatomic, strong) NSMutableArray    *arrFavorites;
@property (nonatomic, strong) NSMutableArray    *arrWallImages;
@property (nonatomic, strong) NSString          *strFollowObjID;
@property (nonatomic) BOOL                      canNotifyComment;
@property (nonatomic) BOOL                      canNotifyLike;
@property (nonatomic) BOOL                      canNotifyFavorite;
@property (nonatomic) BOOL                      canNotifyMessage;
@property (nonatomic) BOOL                      canNotifyFollow;

- (void)addInfoWithPFUser:(PFUser *)user;

+ (instancetype)initWithFirstName:(NSString *)firstName
                         lastName:(NSString *)lastName
                        userEmail:(NSString *)userEmail
                     userPassword:(NSString *)userPassword
                           gender:(BOOL) isMale
                         birthday:(NSDate *)birthDay;


- (BOOL)isNewUser;

@end
