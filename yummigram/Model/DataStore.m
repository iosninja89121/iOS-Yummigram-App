//
//  DataStore.m
//  FBParse
//
//  Created by Toby Stephens on 14/07/2013.
//  Copyright (c) 2013 Toby Stephens. All rights reserved.
//

#import "DataStore.h"

@implementation WallImage

- (id)init
{
    self = [super init];
    
    if(self)
    {
        _image = @"";
        _strImageObjId    = @"";
        _strUserObjId     = @"";
        _strUserFBId      = @"";
        _strUserFullName  = @"";
        _strRecipe        = @"";
        _strIngredients   = @"";
        _strDirections    = @"";
        _strSelfComments  = @"";
        _createdDate      = [NSDate date];
        _arrComments      = [[NSMutableArray alloc] init];
        _strCategory      = @"";
        _arrTag           = [[NSMutableArray alloc] init];
        _strCity          = @"";
        _strCountry       = @"";
        _liked            = NO;
        _favorited        = NO;
        _commented        = NO;
        _nNumberLikes     = 0;
        _nNumberRecipeRequests = 0;
    }
    
    return self;
}

- (void) addInfoWithPFObject:(PFObject *)pObj{
    
    _image           = pObj[pKeyImage];
    
    _strImageObjId   = pObj.objectId;
    _strUserObjId    = pObj[pKeyUserObjId];
    _strUserFBId     = pObj[pKeyUserFBId];
    _strUserFullName = pObj[pKeyUserFullName];
    _strRecipe       = pObj[pKeyRecipe] == nil ? @"" : pObj[pKeyRecipe];
    _strIngredients  = pObj[pKeyIngredients] == nil ? @"" : pObj[pKeyIngredients];
    _strDirections   = pObj[pKeyDirections] == nil ? @"" : pObj[pKeyDirections];
    _strSelfComments = pObj[pKeySelfComment] == nil ? @"" : pObj[pKeySelfComment];
    _createdDate     = pObj.createdAt;
    _arrComments     = pObj[pKeyComments] == nil ? [[NSMutableArray alloc] init] : pObj[pKeyComments];
    _strCategory     = pObj[pKeyCategory] == nil ? @"" : pObj[pKeyCategory];
    _arrTag          = pObj[pKeyTag] == nil ?      [[NSMutableArray alloc] init] : pObj[pKeyTag];
    _strCity         = pObj[pKeyCity] == nil? @"" : pObj[pKeyCity];
    _strCountry      = pObj[pKeyCountry] == nil ? @"" : pObj[pKeyCountry];
    _nNumberRecipeRequests = [(NSNumber *)pObj[pKeyRequestRecipe] integerValue];

    NSArray *likedArray = pObj[pKeyLikes];
    
    _liked = [likedArray containsObject:g_myInfo.strUserObjID];
    _favorited = [g_myInfo.arrFavorites containsObject:_strImageObjId];
    
    _nNumberLikes     = likedArray.count;
    
    PFQuery *queryComment = [PFQuery queryWithClassName:pClassWallImageComments];
    
    [queryComment whereKey:@"objectId" containedIn:_arrComments];
    [queryComment whereKey:pKeyUserObjId equalTo:g_myInfo.strUserObjID];
    
    NSInteger nCount = [queryComment countObjects];
    
    _commented = (nCount == 0);
}
@end

@implementation WallImageComment
+ (instancetype) initWithObject:(PFObject *)pObj{
    WallImageComment *wallImageComment = [[WallImageComment alloc] init];
    
    wallImageComment.strComment    = pObj[pKeyComments];
    wallImageComment.strUserObjId  = pObj[pKeyUserObjId];
    wallImageComment.strUserFBId   = pObj[pKeyUserFBId];
    wallImageComment.strImageObjId = pObj[pKeyImageObjId];
    wallImageComment.createdDate   = pObj.updatedAt;
    
    return wallImageComment;
}
@end

@implementation NotifyPost
+ (instancetype) initWithObject:(PFObject *)pObj{
    NotifyPost *notifyPost = [[NotifyPost alloc] init];
    
    notifyPost.strObjId = pObj.objectId;
    notifyPost.nType = [(NSNumber *)pObj[pKeyNotifyType] integerValue];
    notifyPost.strOtherUserObjId = pObj[pKeyOtherUserObjId];
    notifyPost.strImageObjId = pObj[pKeyImageObjId];
    notifyPost.createdDate = pObj.updatedAt;
    notifyPost.viewed = [pObj[pKeyViewed] boolValue];
    
    return notifyPost;
}
@end

@implementation TotalMsg
+ (instancetype) initWithObject:(PFObject *)pObj{
    TotalMsg *msgPost = [[TotalMsg alloc] init];
    
    msgPost.strObjId = pObj.objectId;
    
    NSString *strFirstUserObjId  = pObj[pKeyFirstUser];
    NSString *strSecondUserObjId = pObj[pKeySecondUser];
    NSString *strLastUserObjId   = pObj[pKeyLastUser];
    
    msgPost.isFromMe = [strLastUserObjId isEqualToString:g_myInfo.strUserObjID];
    msgPost.viewed = [pObj[pKeyViewed] boolValue];
    msgPost.strOtherUserObjId = ([strFirstUserObjId isEqualToString:g_myInfo.strUserObjID]) ? strSecondUserObjId : strFirstUserObjId;
    msgPost.updatedDate = pObj.updatedAt;
    msgPost.strMessage = pObj[pKeyLastMsg];
    
    return msgPost;
}
@end

@implementation DetailMsg
+ (instancetype) initWithObject:(PFObject *)pObj{
    DetailMsg *msgPost = [[DetailMsg alloc] init];
    
    NSString *strMainUserObjId  = pObj[pKeyMainUser];
    
    msgPost.strMessage = pObj[pKeyMsg];
    msgPost.isFromMe = [strMainUserObjId isEqualToString:g_myInfo.strUserObjID];
    msgPost.createdDate = pObj.updatedAt;
    
    return msgPost;
}
@end

@implementation DataStore

static DataStore *instance = nil;
+ (DataStore *) instance
{
    @synchronized (self) {
        if (instance == nil) {
            instance = [[DataStore alloc] init];
        }
    }
    return instance;
}

- (id) init
{
    self = [super init];
    if (self) {
        _strCountry = @"";
        _strCity    = @"";
        
        _wallImagesForNewsFeed= [[NSMutableArray alloc] init];
        _wallImagesForRecipe  = [[NSMutableArray alloc] init];
        _wallImagesForFavorites = [[NSMutableArray alloc] init];
        _wallImagesForMyOwn   = [[NSMutableArray alloc] init];
        _notifyPosts          = [[NSMutableArray alloc] init];
        _wallImageMap         = [[NSMutableDictionary alloc] init];
        _wallImagePFObjectMap = [[NSMutableDictionary alloc] init];
        _userInfoMap          = [[NSMutableDictionary alloc] init];
        _userInfoPFObjectMap  = [[NSMutableDictionary alloc] init];
        _comments = [[NSMutableArray alloc] init];
        _userNotifyPostPFObjectMap = [[NSMutableDictionary alloc] init];
        _totalMsg = [[NSMutableArray alloc] init];
        _totalMsgPFObjectMap = [[NSMutableDictionary alloc] init];
        _detailMsg = [[NSMutableArray alloc] init];
        _followPFObjectMap = [[NSMutableDictionary alloc] init];
        _wallImagesForCategory = [[NSMutableArray alloc] init];
        _wallImagesForTag = [[NSMutableArray alloc] init];
        _wallImagesForSearch = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void) reset
{
    _strCountry = @"";
    _strCity    = @"";
    
    [_wallImagesForNewsFeed removeAllObjects];
    [_wallImagesForRecipe removeAllObjects];
    [_wallImagesForFavorites removeAllObjects];
    [_wallImagesForMyOwn removeAllObjects];
    [_wallImageMap removeAllObjects];
    [_wallImagePFObjectMap removeAllObjects];
    [_userInfoMap removeAllObjects];
    [_userInfoPFObjectMap removeAllObjects];
    [_notifyPosts removeAllObjects];
    [_comments removeAllObjects];
    [_userNotifyPostPFObjectMap removeAllObjects];
    [_totalMsg removeAllObjects];
    [_totalMsgPFObjectMap removeAllObjects];
    [_detailMsg removeAllObjects];
    [_followPFObjectMap removeAllObjects];
    [_wallImagesForCategory removeAllObjects];
    [_wallImagesForTag removeAllObjects];
    [_wallImagesForSearch removeAllObjects];
}

@end

