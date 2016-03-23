//
//  DataStore.h
//  FBParse
//
//  Created by Toby Stephens on 14/07/2013.
//  Copyright (c) 2013 Toby Stephens. All rights reserved.
//

@interface WallImage : NSObject
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSString *strImageObjId;
@property (nonatomic, strong) NSString *strUserObjId;
@property (nonatomic, strong) NSString *strUserFBId;
@property (nonatomic, strong) NSString *strUserFullName;
@property (nonatomic, strong) NSString *strRecipe;
@property (nonatomic, strong) NSString *strIngredients;
@property (nonatomic, strong) NSString *strDirections;
@property (nonatomic, strong) NSString *strSelfComments;
@property (nonatomic, strong) NSDate   *createdDate;
@property (nonatomic, strong) NSMutableArray *arrComments;
@property (nonatomic, strong) NSString *strCategory;
@property (nonatomic, strong) NSMutableArray *arrTag;
@property (nonatomic, strong) NSString *strCity;
@property (nonatomic, strong) NSString *strCountry;
@property (nonatomic) BOOL liked;
@property (nonatomic) BOOL favorited;
@property (nonatomic) BOOL commented;
@property (nonatomic) NSInteger nNumberLikes;
@property (nonatomic) NSInteger nNumberRecipeRequests;

- (void) addInfoWithPFObject:(PFObject *)pObj;

@end

@interface WallImageComment : NSObject
@property (nonatomic, strong) NSString *strComment;
@property (nonatomic, strong) NSString *strUserObjId;
@property (nonatomic, strong) NSString *strUserFBId;
@property (nonatomic, strong) NSString *strImageObjId;
@property (nonatomic, strong) NSDate   *createdDate;

+ (instancetype) initWithObject:(PFObject *)pObj;

@end

@interface NotifyPost : NSObject
@property (nonatomic) NotifyType nType;
@property (nonatomic, strong) NSString *strObjId;
@property (nonatomic, strong) NSString *strOtherUserObjId;
@property (nonatomic, strong) NSString *strImageObjId;
@property (nonatomic, strong) NSDate   *createdDate;
@property (nonatomic) BOOL              viewed;

+ (instancetype) initWithObject:(PFObject *)pObj;
@end

@interface TotalMsg : NSObject
@property (nonatomic, strong) NSString *strObjId;
@property (nonatomic) BOOL isFromMe;
@property (nonatomic) BOOL viewed;
@property (nonatomic, strong) NSString *strOtherUserObjId;
@property (nonatomic, strong) NSString *strMessage;
@property (nonatomic, strong) NSDate   *updatedDate;

+ (instancetype) initWithObject:(PFObject *)pObj;
@end

@interface DetailMsg : NSObject
@property (nonatomic) BOOL isFromMe;
@property (nonatomic, strong) NSString *strMessage;
@property (nonatomic, strong) NSDate   *createdDate;

+ (instancetype) initWithObject:(PFObject *)pObj;
@end

@interface DataStore : NSObject

@property (nonatomic, strong) NSString *strCountry;
@property (nonatomic, strong) NSString *strCity;

@property (nonatomic, strong) NSMutableArray *wallImagesForNewsFeed;
@property (nonatomic, strong) NSMutableArray *wallImagesForRecipe;
@property (nonatomic, strong) NSMutableArray *wallImagesForFavorites;
@property (nonatomic, strong) NSMutableArray *wallImagesForMyOwn;
@property (nonatomic, strong) NSMutableArray *notifyPosts;
@property (nonatomic, strong) NSMutableDictionary *userNotifyPostPFObjectMap;
@property (nonatomic, strong) NSMutableDictionary *wallImageMap;
@property (nonatomic, strong) NSMutableDictionary *wallImagePFObjectMap;
@property (nonatomic, strong) NSMutableDictionary *userInfoMap;
@property (nonatomic, strong) NSMutableDictionary *userInfoPFObjectMap;
@property (nonatomic, strong) NSMutableArray   *comments;
@property (nonatomic, strong) NSMutableArray      *totalMsg;
@property (nonatomic, strong) NSMutableDictionary *totalMsgPFObjectMap;
@property (nonatomic, strong) NSMutableArray      *detailMsg;
@property (nonatomic, strong) NSMutableDictionary *followPFObjectMap;
@property (nonatomic, strong) NSMutableArray  *wallImagesForCategory;
@property (nonatomic, strong) NSMutableArray  *wallImagesForTag;
@property (nonatomic, strong) NSMutableArray  *wallImagesForSearch;

+ (DataStore *) instance;
- (void) reset;

@end
