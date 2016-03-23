//
//  AppDelegate.h
//  yummigram
//
//  Created by User on 3/20/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SVProgressHUD.h>

extern UserInfo                                     *g_myInfo;
extern UserInfo                                     *g_otherInfo;
extern WallImage                                    *g_wallImage;
extern UITabBarController                           *g_tabController;
extern UIViewController                             *g_takePhotoCtrl;
extern UIImage                                      *g_originalImage;
extern NSData                                       *g_mediaData;
extern NSDate                                       *g_lastImageUpdateForNewsFeed;
extern NSDate                                       *g_lastImageUpdateForRecipe;
extern NSDate                                       *g_lastImageUpdateForCategory;
extern NSDate                                       *g_lastImageUpdateForTag;
extern NSDate                                       *g_lastImageUpdateForSearch;
extern NSDate                                       *g_lastCommentUpdate;
extern NSDate                                       *g_lastUserInfoUpdate;
extern NSDate                                       *g_lastTotalMsgUpdate;
extern NSDate                                       *g_lastDetailMsgUpdate;
extern BOOL                                          g_isIPAD;
extern NSUInteger                                    g_moreHeight;
extern NSUInteger                                    g_selectedTabBarItemIndex;
extern UIStoryboard                                 *g_storyboard;
extern CGFloat                                       g_dH;

@protocol CommsDelegate <NSObject>
@optional

- (void) didGetWallImageForNewsFeed;
- (void) didGetWallImageForRecipe;
- (void) didGetWallImageForFavorites;
- (void) didGetWallImageForMyOwn;
- (void) didGetComments;
- (void) didGetTotalMsg;
- (void) didGetDetailMsg;
- (void) didGetNotifyPosts;
- (void) didGetWallImageForCategory;
- (void) didGetWallImageForTag;
- (void) didGetWallImageForSearchOfNewsFeed;
- (void) didGetWallImageForSearchOfRecipe;
- (void) didGetWallImageForSearchOfFavorite;
- (void) didGetWallImageForSearch;

- (void) didLoadMoreForNewsFeed;
- (void) didLoadMoreForRecipe;
- (void) didLoadMoreForCategory;
- (void) didLoadMoreForTag;

@end


@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;

+ (UIImage *)squareImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

+ (void) postImageToFB:(UIImage *)image comments:(NSString *)strComments;

+ (void) postNotifyWithImage:(WallImage *)wallImage notificationType:(NotifyType) notifyType;
+ (NSString *) getTime:(NSDate*)time;
+ (NSString *) getKeyString:(NSString *)strObjId1 secondObjectID:(NSString *)strObjId2;
+ (NSMutableArray *) getTagsFromComment:(NSString *) strComment;

+ (float) getRealWidthFrom:(float)height content:(NSString *)content font:(UIFont *)font;
+ (float) getRealWidthFrom:(float)height content:(NSString *)content fontname:(NSString *)fontname fontsize:(float)fontsize;

+ (float) getRealHeightFrom:(float)width content:(NSString *)content font:(UIFont *)font;
+ (float) getRealHeightFrom:(float)width content:(NSString *)content fontname:(NSString *)fontname fontsize:(float)fontsize;

+ (WallImage *) getImageDataFrom:(PFObject *)wallImageObj;
+ (WallImage *) getImageDataWith:(NSString *)strImageObjID;
+ (UserInfo *)  getUserInfoFrom:(NSString *)strUserObjId;
+ (PFObject *)  getFollowPFObjectFrom:(NSString *)strFollowObjID;

+ (void)  getWallImagesForNewsFeed:(id) delegate limit:(NSInteger) nLimit;
+ (void)  getWallImagesForRecipe:(id) delegate limit:(NSInteger) nLimit;
+ (void)  getWallImagesForFavorite:(id) delegate limit:(NSInteger) nLimit;
+ (void)  getWallImagesForMyOwn:(id) delegate limit:(NSInteger) nLimit;
+ (void)  getCommments:(id) delegate limit:(NSInteger) nLimit;
+ (void)  getTotalMsg:(id) delegate;
+ (void)  getDetailMsg:(id) delegate compoundKey:(NSString *) strCompoundKey;
+ (void)  getNotifyPosts:(id) delegate;
+ (void)  getWallImageForCategory:(id) delegate category:(NSString *) strCategory limit:(NSInteger) nLimit;
+ (void)  getWallImageForTag:(id) delegate tag:(NSString *) strTag limit:(NSInteger) nLimit;
+ (void)  getWallImageForSearchOfNewsFeed:(id) delegate searchText:(NSString *) strSearch limit:(NSInteger) nLimit;
+ (void)  getWallImageForSearchOfRecipe:(id) delegate searchText:(NSString *) strSearch limit:(NSInteger) nLimit;
+ (void)  getWallImageForSearchOfFavorite:(id) delegate searchText:(NSString *) strSearch limit:(NSInteger) nLimit;

+ (void)  loadMoreForNewsFeed:(id) delegate;
+ (void)  loadMoreForRecipe:(id) delegate;
+ (void)  loadMoreForCategory:(id) delegate category:(NSString *) strCategory limit:(NSInteger) nLimit;
+ (void)  loadMoreForTag:(id) delegate tag:(NSString *) strTag limit:(NSInteger) nLimit;
@end

