//
//  Define.h
//  yummigram
//
//  Created by User on 3/21/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#ifndef yummigram_Define_h
#define yummigram_Define_h

typedef NS_ENUM(NSInteger, PhoneEmailMode)
{
    modePhone = 1,
    modeEmail
};

typedef NS_ENUM(NSInteger, ViewMode)
{
    viewPhoto = 0,
    viewFollower,
    viewFollowing,
    viewEveryone
};

typedef NS_ENUM(NSInteger, NotifyType)
{
    notifyFollowing = 0,
    notifyLiked,
    notifyComment,
    notifyAddFavorite,
    notifyRequestRecipe
};


//*****************Parse Keys**************
#define PARSE_APPLICATION_ID                        @"m4qAyLcZpdsTgzFb5GsXn0uGq2wqh0pF1j0VbDnw"
#define PARSE_CLIENT_KEY                            @"yNRWV4629dmXvVNjj0Ov0zyu7PuifK7tM9IdGo3q"

//*****************Adobe Keys**************
#define kAdobeAPIKey                                @"9adff13b78a94ade805787113d419a41"
#define kAdobeSecret                                @"3b5447a0-3eca-4206-adda-842c05a33270"

//*****************Parse.com Table **************
#define pKeyFirstName                               @"FirstName"
#define pKeyLastName                                @"LastName"
#define pKeyFBID                                    @"fbID"
#define pKeyFBToken                                 @"fbToken"
#define pKeyPhoto                                   @"photo"
#define pKeyGender                                  @"gender"
#define pKeyBirthday                                @"birthday"
#define pKeyNotifyComments                          @"notifyComments"
#define pKeyNotifyMessage                           @"notifyMessage"
#define pKeyNotifyLike                              @"notifyLike"
#define pKeyNotifyFollow                            @"notifyFollow"
#define pKeyNotifyFavorite                          @"notifyFavorite"
#define pKeyWallImages                              @"wallImages"
#define pKeyFollowID                                @"followID"

#define pClassWallImageOther                        @"WallImageOther"

#define pKeyImage                                   @"image"
#define pKeyUserFBId                                @"UserFBID"
#define pKeyUserObjId                               @"UserObjId"
#define pKeyUserFullName                            @"UserFullName"
#define pKeyRecipe                                  @"Recipe"
#define pKeyIngredients                             @"Ingredients"
#define pKeyDirections                              @"Directions"
#define pKeySelfComment                             @"SelfComment"
#define pKeyLikes                                   @"Likes"
#define pKeyFavorites                               @"Favorites"
#define pKeyIsRecipe                                @"isRecipe"
#define PKeyCreatedAt                               @"createdAt"
#define pKeyUpdatedAt                               @"updatedAt"
#define pKeyCategory                                @"category"
#define pKeyTag                                     @"tag"
#define pKeyCity                                    @"city"
#define pKeyCountry                                 @"country"
#define pKeyRequestRecipe                           @"requestRecipe"

#define pClassWallImageComments                     @"WallImageComments"

#define pKeyComments                                @"Comments"
#define pKeyImageObjId                              @"ImageObjId"

#define pClassNotifyPost                            @"NotifyPost"

#define pKeyNotifyType                              @"notifyType"
#define pKeyOtherUserObjId                          @"OtherUserObjId"

#define pClassTotalMsg                              @"TotalMsg"

#define pKeyFirstUser                               @"firstUser"
#define pKeySecondUser                              @"secondUser"
#define pKeyLastUser                                @"lastUser"
#define pKeyLastMsg                                 @"lastMsg"
#define pKeyViewed                                  @"Viewed"
#define pClassDetailMsg                             @"DetailMsg"

#define pKeyCompoundUser                            @"compoundUser"
#define pKeyMainUser                                @"mainUser"
#define pKeyMsg                                     @"msg"

#define pKeyObjId                                   @"objectId"

#define pClassFollow                                @"Follow"

#define pKeyFollowing                               @"following"
#define pKeyFollower                                @"follower"

//*****************Push Notification **************
#define pnAps                           @"aps"
#define pnMode                          @"mode"
#define pnBadge                         @"badge"
#define pnAlert                         @"alert"
#define pnNotifyType                    @"notifyType"
#define pnImageId                       @"imgID"
#define pnUserObjId                     @"userObjID"

#define PN_NOTIFY                       @"notify"
#define PN_MESSAGE                      @"message"
#define PN_INCREMENT                    @"Increment"

//*****************NSUserDefaults **************
#define DEFAULT_USER_LOGGED                         @"UserDefaultAlreadyLogged"
#define DEFAULT_USER_EMAIL                          @"UserDefaultEmail"
#define DEFAULT_USER_PSWD                           @"UserDefaultPassword"
#define DEFAULT_INIT_STATION                        @"UserDefaultInitStation"
#define DEFAULT_USER_NOTIFY_COMMENTS                @"UserDefaultNotifyComments"
#define DEFAULT_USER_NOTIFY_MESSAGES                @"UserDefaultNotifyMessages"
#define DEFAULT_USER_NOTIFY_LIKE_PHOTO              @"UserDefaultNotifyLikePhoto"
#define DEFAULT_USER_NOTIFY_FOLLOW                  @"UserDefaultNotifyFollow"
#define DEFAULT_USER_PHOTO_EFFECT                   @"UserDefaultNotifyPhotoEffect"

//*****************UI View Controllers**************

#define MAIN_TAB_BAR_CONTROLLER                        @"MainTabBarController"
#define TAKE_PHOTO_VIEW_CONTROLLER                     @"TakePhotoViewController"
#define SHARE_PHOTO_VIEW_CONTROLLER                    @"SharePhotoViewController"
#define RECIPE_DETAIL_VIEW_CONTROLLER                  @"RecipeDetailViewController"
#define ADD_COMMENT_VIEW_CONTROLLER                    @"AddCommentViewController"
#define IMAGE_PREVIEW_CONTROLLER                       @"ImagePreviewController"
#define PROFILE_VIEW_CONTROLLER                        @"ProfileViewController"
#define SETTING_VIEW_CONTROLLER                        @"SettingViewController"
#define WELCOME_NAV_CONTROLLER                         @"WelcomeNavigationController"
#define CONTACTS_VIEW_CONTROLLER                       @"ContactsViewController"
#define EDIT_CONTENT_VIEW_CONTROLLER                   @"EditContentViewController"
#define SPLASH_VIEW_CONTROLLER                         @"SplashViewController"
#define PROFILE_PHOTO_VIEW_CONTROLLER                  @"ProfilePhotoViewController"
#define FOLLOW_USER_VIEW_CONTROLLER                    @"FollowUserViewController"
#define POST_COMMENT_VIEW_CONTROLLER                   @"PostCommentViewController"
#define NOTIFICATION_VIEW_CONTROLLER                   @"NotificationViewController"
#define CHAT_VIEW_CONTROLLER                           @"ChatViewController"
#define NEW_CHAT_VIEW_CONTROLLER                       @"NewChatViewController"
#define SETTING_FOR_PUSH_NOTIFICATION_VIEW_CONTROLLER  @"SettingForPushNotificationViewController"
#define SETTING_FOR_PHOTO_EFFECTS_VIEW_CONTROLLER      @"SettingForPhotoEffectsViewController"
#define  EDIT_COMMENT_VIEW_CONTROLLER                  @"EditCommentViewController"
#define EDIT_RECIPE_VIEW_CONTROLLER                    @"EditRecipeViewController"
#define TAG_VIEW_CONTROLLER                            @"TagViewController"
#define SEARCH_RESULT_VIEW_CONTROLLER                  @"SearchResultViewController"

//*****************UI Table View Cell**************
#define WALL_IMAGE_CELL_FOR_SELF                       @"WallImageCellForSelf"
#define WALL_IMAGE_CELL                                @"WallImageCell"
#define TITLE_CELL                                     @"TitleCell"
#define DESCRIPTION_CELL                               @"DescriptionCell"
#define USER_CELL                                      @"UserCell"
#define COMMENT_CELL                                   @"CommentCell"
#define SHOW_MORE_CELL                                 @"ShowMoreCell"
#define EDITBOX_CELL                                   @"EditBoxCell"
#define HEADER_CELL                                    @"HeaderCell"
#define SETTING_CELL                                   @"SettingCell"
#define FRIEND_CELL                                    @"FriendCell"
#define PHONE_DETAIL_CELL                              @"PhoneDetailCell"
#define VIEW_MORE_CELL                                 @"ViewMoreCell"
#define NONE_CELL                                      @"NoneCell"
#define CHAT_ME_GENERAL_CELL                           @"ChatMeGeneralCell"
#define CHAT_ME_LAST_CELL                              @"ChatMeLastCell"
#define CHAT_OTHER_GERNERAL_CELL                       @"ChatOtherGeneralCell"
#define CHAT_OTHER_LAST_CELL                           @"ChatOtherLastCell"
#define VIEW_MODE_CELL                                 @"ViewModeCell"

//*****************UI Collection View Cell**************
#define COLLECTION_CELL                                @"CollectionCell"

//*****************Dictionary String**************
#define DIC_USER_ID                                    @"userID"
#define DIC_IMAGE_ID                                   @"imageID"
#define DIC_NOTIFY_CAT                                 @"notifyCat"
#define DIC_ME                                         @"me"
#define DIC_SPEECH                                     @"speech"

//*****************Constant String**************
#define STRING_HINT_COMMENT                            @"Add comments"
#define STRING_HINT_RECIPE_NAME                        @"Add recipe name"
#define STRING_HINT_INGREDIENTS                        @"Add ingrediaents"
#define STRING_HINT_DIRECTIONS                         @"Add directions"
#define STRING_SEARCH_TABLE                            @"search"
#define STRING_ORIGIN_TABLE                            @"origin"


//*****************Notification center String**************
#define N_ImageUploaded                                @"N_ImageUploaded"
#define N_ImageDataChanged                             @"N_ImageDataChanged"
#define N_PhotoUpdated                                 @"N_PhotoUpdated"
#define N_MessageUpdated                               @"N_MessageUpdated"
#define N_NotifyUpdated                                @"N_NotifyUpdated"
#define N_MessageViewed                                @"N_MessageViewed"
#define N_NotifyViewed                                 @"N_NotifyViewed"
#define N_RefreshAtFavorite                            @"N_RefreshAtFavorite"
#define N_RefreshAtNewsFeed                            @"N_RefreshAtNewsFeed"
#define N_RefreshAtRecipe                              @"N_RefreshAtRecipe"

#define SG_PHONE_DETAIL                                @"seguePhoneDetail"

#define LIMIT_NUMBER_GRID                              6
#define LIMIT_NUMBER_LIST                              3
#define MAX_IMAGE_SIZE                                 20000
#endif
