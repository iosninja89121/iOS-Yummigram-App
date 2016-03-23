//
//  AppDelegate.m
//  yummigram
//
//  Created by User on 3/20/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "AppDelegate.h"
#import "TestFairy.h"
#import "ProfileViewController.h"
#import "PostCommentViewController.h"
#import <ASIFormDataRequest.h>

UserInfo                                     *g_myInfo;
UserInfo                                     *g_otherInfo;
WallImage                                    *g_wallImage;
UITabBarController                           *g_tabController;
UIViewController                             *g_takePhotoCtrl;
UIImage                                      *g_originalImage;
NSDate                                       *g_lastImageUpdateForNewsFeed;
NSDate                                       *g_lastImageUpdateForRecipe;
NSDate                                       *g_lastImageUpdateForCategory;
NSDate                                       *g_lastImageUpdateForTag;
NSDate                                       *g_lastImageUpdateForSearch;
NSDate                                       *g_lastCommentUpdate;
NSDate                                       *g_lastUserInfoUpdate;
NSDate                                       *g_lastTotalMsgUpdate;
NSDate                                       *g_lastDetailMsgUpdate;
BOOL                                          g_isIPAD;
NSUInteger                                    g_moreHeight;
UIStoryboard                                 *g_storyboard;
NSUInteger                                    g_selectedTabBarItemIndex;
CGFloat                                       g_dH;

@interface AppDelegate ()
@property (nonatomic) BOOL isFromNotify;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //Initialize Parse.com
    [Parse setApplicationId:PARSE_APPLICATION_ID      clientKey:PARSE_CLIENT_KEY];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge |     UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
        
        
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }else{
        [application registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];


    
    //Initialize TestFairy
    [TestFairy begin:@"1c27fb5ccdee208ed4e6ce270a61075cc22bb386"];
    
//    AdobeUXAuthManager *mAdobeAuth = [[AdobeUXAuthManager alloc] init];
//    [mAdobeAuth setAuthenticationParametersWithClientID:@"3b5447a0-3eca-4206-adda-842c05a33270" withClientSecret:@"9adff13b78a94ade805787113d419a41"];
    
    [PFFacebookUtils initializeFacebook];
    
    g_tabController = nil;
    g_takePhotoCtrl = nil;
    g_myInfo = [[UserInfo alloc] init];
    
    if([PFUser currentUser] != nil){
        [g_myInfo addInfoWithPFUser:[PFUser currentUser]];
    }
    
    g_lastImageUpdateForNewsFeed = [NSDate date];
    g_lastImageUpdateForRecipe = [NSDate date];
    g_lastImageUpdateForCategory = [NSDate date];
    g_lastImageUpdateForTag    = [NSDate date];
    g_lastCommentUpdate = [NSDate date];
    g_lastUserInfoUpdate = [NSDate date];
    
    g_otherInfo = g_myInfo;
    
    g_storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    g_isIPAD = NO;
    g_moreHeight = 0;
    
    CGFloat fWidth  = [[UIScreen mainScreen] bounds].size.width;
    
    g_dH = fWidth - 320;
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        g_storyboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
        g_isIPAD = YES;
        g_moreHeight = 230;
    }
    
    self.isFromNotify = NO;
    
    if (launchOptions != nil)
    {
        NSDictionary* dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (dictionary != nil)
        {
            NSLog(@"Launched from push notification: %@", dictionary);
            [self runAppFromRemoteNotification:dictionary];
        }
    }
    
    [self setFirstScreen];
    
    return YES;
}

- (void)runAppFromRemoteNotification:(NSDictionary*)notifyDic
{
    NSString   *strMode  = [notifyDic objectForKey:pnMode];
    
    if([strMode isEqualToString:PN_MESSAGE]){
        [[NSNotificationCenter defaultCenter] postNotificationName:N_MessageUpdated object:nil];
    }else{
        NotifyType nType = [(NSNumber *)[notifyDic objectForKey:pnNotifyType] integerValue];
        NSString *strImageObjId = [notifyDic objectForKey:pnImageId];
        NSString *strOtherUserObjId = [notifyDic objectForKey:pnUserObjId];
        
        NotifyPost *notifyPost = [[NotifyPost alloc] init];
        
        notifyPost.nType = nType;
        notifyPost.strOtherUserObjId = strOtherUserObjId;
        notifyPost.strImageObjId = strImageObjId;
        notifyPost.createdDate = [NSDate date];
        
        [[DataStore instance].notifyPosts insertObject:notifyPost atIndex:0];
        
        self.isFromNotify = YES;
    }

}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    
    [currentInstallation saveInBackground];
    
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSString   *strMode  = [userInfo objectForKey:pnMode];
    
    if([strMode isEqualToString:PN_MESSAGE]){
        [[NSNotificationCenter defaultCenter] postNotificationName:N_MessageUpdated object:nil];
    }else{
        NotifyType nType = [(NSNumber *)[userInfo objectForKey:pnNotifyType] integerValue];
        NSString *strImageObjId = [userInfo objectForKey:pnImageId];
        NSString *strOtherUserObjId = [userInfo objectForKey:pnUserObjId];
        
        NotifyPost *notifyPost = [[NotifyPost alloc] init];
        
        notifyPost.nType = nType;
        notifyPost.strOtherUserObjId = strOtherUserObjId;
        notifyPost.strImageObjId = strImageObjId;
        notifyPost.createdDate = [NSDate date];
        
        [[DataStore instance].notifyPosts insertObject:notifyPost atIndex:0];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:N_NotifyUpdated object:nil];
    }
    
    completionHandler(UIBackgroundFetchResultNewData);
}


- (BOOL)application:(UIApplication *)application  openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication   annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

+ (WallImage *) getImageDataFrom:(PFObject *)wallImageObj{
    WallImage *wallImageTmp = [[DataStore instance].wallImageMap objectForKey:wallImageObj.objectId];
    
    if(wallImageTmp == nil){
        wallImageTmp = [[WallImage alloc] init];
        [wallImageTmp addInfoWithPFObject:wallImageObj];
        
        [[DataStore instance].wallImagePFObjectMap setObject:wallImageObj forKey:wallImageTmp.strImageObjId];
        [[DataStore instance].wallImageMap setObject:wallImageTmp forKey:wallImageTmp.strImageObjId];
    }
    
    return wallImageTmp;
}

+ (WallImage *) getImageDataWith:(NSString *)strImageObjID{
    WallImage *wallImageTmp = [[DataStore instance].wallImageMap objectForKey:strImageObjID];
    
    if(wallImageTmp == nil){
        PFQuery *wallImageQuery = [PFQuery queryWithClassName:pClassWallImageOther];
        
        PFObject *pfWallImage = [wallImageQuery getObjectWithId:strImageObjID];
        
        wallImageTmp = [AppDelegate getImageDataFrom:pfWallImage];
    }
    
    return wallImageTmp;
}

+ (UserInfo *)  getUserInfoFrom:(NSString *)strUserObjId{
    UserInfo *userInfo = [[DataStore instance].userInfoMap objectForKey:strUserObjId];
    
    if(userInfo == nil){
        PFQuery *userQuery = [PFUser query];
        
        PFUser *pfUserObj = (PFUser *)[userQuery getObjectWithId:strUserObjId];
        
        userInfo = [[UserInfo alloc] init];
        
        [userInfo addInfoWithPFUser:pfUserObj];
        
        [[DataStore instance].userInfoMap setObject:userInfo forKey:userInfo.strUserObjID];
        [[DataStore instance].userInfoPFObjectMap setObject:pfUserObj forKey:userInfo.strUserObjID];
    }
    return userInfo;
}

+ (PFObject *)  getFollowPFObjectFrom:(NSString *)strFollowObjID{
    PFObject *pfObj = [[DataStore instance].followPFObjectMap objectForKey:strFollowObjID];
    
    if(pfObj == nil){
        PFQuery *followQuery = [PFQuery queryWithClassName:pClassFollow];
        
        pfObj = [followQuery getObjectWithId:strFollowObjID];
        
        [[DataStore instance].followPFObjectMap setObject:pfObj forKey:strFollowObjID];
    }
    
    return pfObj;
}

- (void)  getWallImagesForNewsFeed{
    
    PFQuery *imageQuery = [PFQuery queryWithClassName:pClassWallImageOther];
    
    [imageQuery orderByDescending:PKeyCreatedAt];
    [imageQuery whereKey:PKeyCreatedAt lessThanOrEqualTo:g_lastImageUpdateForNewsFeed];
    imageQuery.limit = LIMIT_NUMBER_GRID;
    
    [imageQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            NSLog(@"Objects error: %@", error.localizedDescription);
        } else {
            
            [objects enumerateObjectsUsingBlock:^(PFObject *wallImageObject, NSUInteger idx, BOOL *stop) {
                
                WallImage *wallImage = [AppDelegate getImageDataFrom:wallImageObject];
                [[DataStore instance].wallImagesForNewsFeed addObject:wallImage];
            }];
        }
        
        [self getWallImagesForRecipe];
        
    }];
}

- (void) getWallImagesForRecipe{
    
    PFQuery *imageQuery = [PFQuery queryWithClassName:pClassWallImageOther];
    
    [imageQuery orderByDescending:PKeyCreatedAt];
    [imageQuery whereKey:PKeyCreatedAt lessThanOrEqualTo:g_lastImageUpdateForRecipe];
    [imageQuery whereKey:pKeyIsRecipe equalTo:@(1)];
    imageQuery.limit = LIMIT_NUMBER_GRID;
    
    [imageQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            NSLog(@"Objects error: %@", error.localizedDescription);
        } else {
            
            [objects enumerateObjectsUsingBlock:^(PFObject *wallImageObject, NSUInteger idx, BOOL *stop) {
                
                WallImage *wallImage = [AppDelegate getImageDataFrom:wallImageObject];
                [[DataStore instance].wallImagesForRecipe addObject:wallImage];
            }];
        }
        
        [self getWallImagesForFavorite];
        
    }];
}

- (void) getWallImagesForFavorite{
    PFQuery *imageQuery = [PFQuery queryWithClassName:pClassWallImageOther];
    
    [imageQuery orderByDescending:PKeyCreatedAt];
    [imageQuery whereKey:pKeyObjId containedIn:g_myInfo.arrFavorites];
    imageQuery.limit = LIMIT_NUMBER_GRID;
    
    [imageQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            NSLog(@"Objects error: %@", error.localizedDescription);
        } else {
            
            [objects enumerateObjectsUsingBlock:^(PFObject *wallImageObject, NSUInteger idx, BOOL *stop) {
                
                WallImage *wallImage = [AppDelegate getImageDataFrom:wallImageObject];
                [[DataStore instance].wallImagesForFavorites addObject:wallImage];
            }];
        }
        
        [self getWallImagesForMyOwn];
        
    }];
}

- (void) getWallImagesForMyOwn{
    PFQuery *imageQuery = [PFQuery queryWithClassName:pClassWallImageOther];
    
    [imageQuery orderByDescending:PKeyCreatedAt];
    [imageQuery whereKey:pKeyObjId containedIn:g_myInfo.arrWallImages];
    imageQuery.limit = LIMIT_NUMBER_GRID;
    
    [imageQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            NSLog(@"Objects error: %@", error.localizedDescription);
        } else {
            
            [objects enumerateObjectsUsingBlock:^(PFObject *wallImageObject, NSUInteger idx, BOOL *stop) {
                
                WallImage *wallImage = [AppDelegate getImageDataFrom:wallImageObject];
                [[DataStore instance].wallImagesForMyOwn addObject:wallImage];
            }];
        }
        
        UITabBarController *tabCtrl = (UITabBarController *)[g_storyboard instantiateViewControllerWithIdentifier:MAIN_TAB_BAR_CONTROLLER];
        
        if(self.isFromNotify){
            UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:tabCtrl];
            
            navCtrl.navigationBarHidden = YES;
            
            NotifyPost *notifyPost = [[DataStore instance].notifyPosts objectAtIndex:0];
            
            if(notifyPost.nType == notifyFollowing){
                ProfileViewController *profileViewCtrl = (ProfileViewController *)[g_storyboard instantiateViewControllerWithIdentifier:PROFILE_VIEW_CONTROLLER];
                
                profileViewCtrl.strUserObjID = notifyPost.strOtherUserObjId;
                
                [navCtrl addChildViewController:profileViewCtrl];

            }else{
                WallImage *wallImage = [[DataStore instance].wallImageMap objectForKey:notifyPost.strImageObjId];
                
                if(wallImage == nil) {
                    PFQuery *wallImageQuery = [PFQuery queryWithClassName:pClassWallImageOther];
                    PFObject *wallImageObj = [wallImageQuery getObjectWithId:notifyPost.strImageObjId];
                    
                    wallImage = [AppDelegate getImageDataFrom:wallImageObj];
                }
                
                PostCommentViewController *commentViewCtrl = (PostCommentViewController *)[g_storyboard instantiateViewControllerWithIdentifier:POST_COMMENT_VIEW_CONTROLLER];
                commentViewCtrl.wallImage = wallImage;
                
                [navCtrl addChildViewController:commentViewCtrl];
            }
            
            [[appDelegate window] setRootViewController:navCtrl];
        }else{
            [[appDelegate window] setRootViewController:tabCtrl];
        }
        
    }];
}

+ (void)  getWallImagesForNewsFeed:(id<CommsDelegate>) delegate limit:(NSInteger)nLimit{
    
    PFQuery *imageQuery = [PFQuery queryWithClassName:pClassWallImageOther];
    
    [imageQuery orderByDescending:PKeyCreatedAt];
    [imageQuery whereKey:PKeyCreatedAt lessThanOrEqualTo:g_lastImageUpdateForNewsFeed];
    imageQuery.skip = [DataStore instance].wallImagesForNewsFeed.count;
    imageQuery.limit = nLimit;
    
    [imageQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            NSLog(@"Objects error: %@", error.localizedDescription);
        } else {
            
            [objects enumerateObjectsUsingBlock:^(PFObject *wallImageObject, NSUInteger idx, BOOL *stop) {
                
                WallImage *wallImage = [AppDelegate getImageDataFrom:wallImageObject];
                [[DataStore instance].wallImagesForNewsFeed addObject:wallImage];
            }];
        }
        
        if ([delegate respondsToSelector:@selector(didGetWallImageForNewsFeed)]) {
            [delegate didGetWallImageForNewsFeed];
        }
        
    }];
}

+ (void) getWallImagesForRecipe:(id<CommsDelegate>) delegate  limit:(NSInteger) nLimit{
    
    PFQuery *imageQuery = [PFQuery queryWithClassName:pClassWallImageOther];
    
    [imageQuery orderByDescending:PKeyCreatedAt];
    [imageQuery whereKey:PKeyCreatedAt lessThanOrEqualTo:g_lastImageUpdateForRecipe];
    [imageQuery whereKey:pKeyIsRecipe equalTo:@(1)];
    imageQuery.skip = [DataStore instance].wallImagesForRecipe.count;
    imageQuery.limit = nLimit;
    
    [imageQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            NSLog(@"Objects error: %@", error.localizedDescription);
        } else {
            
            [objects enumerateObjectsUsingBlock:^(PFObject *wallImageObject, NSUInteger idx, BOOL *stop) {
                
                WallImage *wallImage = [AppDelegate getImageDataFrom:wallImageObject];
                [[DataStore instance].wallImagesForRecipe addObject:wallImage];
            }];
        }
        
        if ([delegate respondsToSelector:@selector(didGetWallImageForRecipe)]) {
            [delegate didGetWallImageForRecipe];
        }
    
    }];
}

+ (void) getWallImagesForFavorite:(id<CommsDelegate>) delegate  limit:(NSInteger) nLimit{
    NSMutableArray *arrTmp = [[NSMutableArray alloc] init];
    
    for(NSString *strObjId in g_myInfo.arrFavorites){
        WallImage *wallImage = [[DataStore instance].wallImageMap objectForKey:strObjId];
        
        if(wallImage != nil) continue;
        
        [arrTmp addObject:strObjId];
    }
    
    PFQuery *imageQuery = [PFQuery queryWithClassName:pClassWallImageOther];
    
    [imageQuery orderByDescending:PKeyCreatedAt];
    [imageQuery whereKey:pKeyObjId containedIn:arrTmp];
    imageQuery.limit = nLimit;
    
    [imageQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            NSLog(@"Objects error: %@", error.localizedDescription);
        } else {
            
            [objects enumerateObjectsUsingBlock:^(PFObject *wallImageObject, NSUInteger idx, BOOL *stop) {
                
                WallImage *wallImage = [AppDelegate getImageDataFrom:wallImageObject];
                [[DataStore instance].wallImagesForFavorites addObject:wallImage];
            }];
        }
        
        if ([delegate respondsToSelector:@selector(didGetWallImageForFavorites)]) {
            [delegate didGetWallImageForFavorites];
        }
        
    }];
}

+ (void) getWallImagesForMyOwn:(id<CommsDelegate>) delegate  limit:(NSInteger) nLimit{
    NSMutableArray *arrTmp = [[NSMutableArray alloc] init];
    
    for(NSString *strObjId in g_otherInfo.arrWallImages){
        WallImage *wallImage = [[DataStore instance].wallImageMap objectForKey:strObjId];
        
        if(wallImage != nil) continue;
        
        [arrTmp addObject:strObjId];
    }
    
    PFQuery *imageQuery = [PFQuery queryWithClassName:pClassWallImageOther];
    
    [imageQuery orderByDescending:PKeyCreatedAt];
    [imageQuery whereKey:pKeyObjId containedIn:arrTmp];
    imageQuery.limit = nLimit;
    
    [imageQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            NSLog(@"Objects error: %@", error.localizedDescription);
        } else {
            
            [objects enumerateObjectsUsingBlock:^(PFObject *wallImageObject, NSUInteger idx, BOOL *stop) {
                
                WallImage *wallImage = [AppDelegate getImageDataFrom:wallImageObject];
                [[DataStore instance].wallImagesForMyOwn addObject:wallImage];
            }];
        }
        
        if ([delegate respondsToSelector:@selector(didGetWallImageForMyOwn)]) {
            [delegate didGetWallImageForMyOwn];
        }
        
    }];
}

+ (void)  getCommments:(id<CommsDelegate>) delegate limit:(NSInteger) nLimit{
    PFQuery *commentQuery = [PFQuery queryWithClassName:pClassWallImageComments];
    
    [commentQuery orderByDescending:PKeyCreatedAt];
    [commentQuery whereKey:PKeyCreatedAt lessThanOrEqualTo:g_lastCommentUpdate];
    [commentQuery whereKey:pKeyImageObjId equalTo:g_wallImage.strImageObjId];
    
    commentQuery.skip = [DataStore instance].comments.count;
    commentQuery.limit = nLimit;
    
    [commentQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
       
        if(error){
            NSLog(@"Objects error: %@", error.localizedDescription);
        } else {
            [objects enumerateObjectsUsingBlock:^(PFObject *commentObject, NSUInteger idx, BOOL *stop) {
                WallImageComment *wallImageComment = [WallImageComment initWithObject:commentObject];
                
                [[DataStore instance].comments addObject:wallImageComment];
            }];
        }
        
        if([delegate respondsToSelector:@selector(didGetComments)]){
            [delegate didGetComments];
        }
        
    }];
    
}

+ (void)  getTotalMsg:(id<CommsDelegate>) delegate{
    PFQuery *firstQuery = [PFQuery queryWithClassName:pClassTotalMsg];
    [firstQuery whereKey:pKeyFirstUser equalTo:g_myInfo.strUserObjID];
    
    PFQuery *secondQuery = [PFQuery queryWithClassName:pClassTotalMsg];
    [secondQuery whereKey:pKeySecondUser equalTo:g_myInfo.strUserObjID];
    
    PFQuery *compoundQuery = [PFQuery orQueryWithSubqueries:@[firstQuery, secondQuery]];

    [compoundQuery orderByDescending:pKeyUpdatedAt];
    [compoundQuery whereKey:pKeyUpdatedAt lessThanOrEqualTo:g_lastTotalMsgUpdate];
    
    compoundQuery.skip = [DataStore instance].totalMsg.count;
    
    compoundQuery.limit = 10;
    
    [compoundQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Objects error: %@", error.localizedDescription);
        } else {
            [objects enumerateObjectsUsingBlock:^(PFObject *totalMsgObject, NSUInteger idx, BOOL *stop) {
                TotalMsg *totalMsg = [TotalMsg initWithObject:totalMsgObject];
                
                [[DataStore instance].totalMsg addObject:totalMsg];
                [[DataStore instance].totalMsgPFObjectMap setObject:totalMsgObject forKey:totalMsg.strObjId];
            }];
        }
        
        if([delegate respondsToSelector:@selector(didGetTotalMsg)]){
            [delegate didGetTotalMsg];
        }
    }];
}

+ (void)  getDetailMsg:(id<CommsDelegate>) delegate compoundKey:(NSString *) strCompoundKey{
    PFQuery *queryDetailMsg = [PFQuery queryWithClassName:pClassDetailMsg];
    
    [queryDetailMsg orderByDescending:PKeyCreatedAt];
    [queryDetailMsg whereKey:pKeyCompoundUser equalTo:strCompoundKey];
    [queryDetailMsg whereKey:PKeyCreatedAt lessThanOrEqualTo:g_lastDetailMsgUpdate];
    queryDetailMsg.skip = [DataStore instance].detailMsg.count;
    queryDetailMsg.limit = 8;
    
    [queryDetailMsg findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Objects error: %@", error.localizedDescription);
        } else {
            [objects enumerateObjectsUsingBlock:^(PFObject *detailMsgObject, NSUInteger idx, BOOL *stop) {
                DetailMsg *detailMsg = [DetailMsg initWithObject:detailMsgObject];
                
                [[DataStore instance].detailMsg insertObject:detailMsg atIndex:0];
            }];
        }
        
        if([delegate respondsToSelector:@selector(didGetDetailMsg)]){
            [delegate didGetDetailMsg];
        }
    }];
}

+ (void)  getNotifyPosts:(id<CommsDelegate>) delegate{
    PFQuery *queryNotifyPost = [PFQuery queryWithClassName:pClassNotifyPost];
    
    [queryNotifyPost orderByDescending:PKeyCreatedAt];
    [queryNotifyPost whereKey:pKeyUserObjId equalTo:g_myInfo.strUserObjID];
    queryNotifyPost.skip = [DataStore instance].notifyPosts.count;
    queryNotifyPost.limit = 10;
    
    [queryNotifyPost findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Objects error: %@", error.localizedDescription);
        } else {
            [objects enumerateObjectsUsingBlock:^(PFObject *notifyObj, NSUInteger idx, BOOL *stop) {
                NotifyPost *notifyPost = [NotifyPost initWithObject:notifyObj];
                
                [[DataStore instance].notifyPosts addObject:notifyPost];
                [[DataStore instance].userNotifyPostPFObjectMap setObject:notifyObj forKey:notifyPost.strObjId];
            }];
        }
        
        if([delegate respondsToSelector:@selector(didGetNotifyPosts)]){
            [delegate didGetNotifyPosts];
        }
    }];
}

+ (void)  getWallImageForCategory:(id<CommsDelegate>) delegate category:(NSString *) strCategory limit:(NSInteger) nLimit{
    PFQuery *imageQuery = [PFQuery queryWithClassName:pClassWallImageOther];
    
    [imageQuery orderByDescending:PKeyCreatedAt];
    [imageQuery whereKey:PKeyCreatedAt lessThanOrEqualTo:g_lastImageUpdateForCategory];
    [imageQuery whereKey:pKeyCategory  equalTo:strCategory];
    [imageQuery whereKey:pKeyIsRecipe equalTo:@(1)];
    imageQuery.skip = [DataStore instance].wallImagesForCategory.count;
    imageQuery.limit = nLimit;
    
    [imageQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            NSLog(@"Objects error: %@", error.localizedDescription);
        } else {
            
            [objects enumerateObjectsUsingBlock:^(PFObject *wallImageObject, NSUInteger idx, BOOL *stop) {
                
                WallImage *wallImage = [AppDelegate getImageDataFrom:wallImageObject];
                [[DataStore instance].wallImagesForCategory addObject:wallImage];
            }];
        }
        
        if ([delegate respondsToSelector:@selector(didGetWallImageForCategory)]) {
            [delegate didGetWallImageForCategory];
        }
        
    }];
}

+ (void)  getWallImageForTag:(id<CommsDelegate>) delegate tag:(NSString *) strTag limit:(NSInteger) nLimit{
    PFQuery *imageQuery = [PFQuery queryWithClassName:pClassWallImageOther];
    
    [imageQuery orderByDescending:PKeyCreatedAt];
    [imageQuery whereKey:PKeyCreatedAt lessThanOrEqualTo:g_lastImageUpdateForTag];
    [imageQuery whereKey:pKeyTag  containsAllObjectsInArray:@[strTag]];
    imageQuery.skip = [DataStore instance].wallImagesForTag.count;
    imageQuery.limit = nLimit;
    
    [imageQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            NSLog(@"Objects error: %@", error.localizedDescription);
        } else {
            
            [objects enumerateObjectsUsingBlock:^(PFObject *wallImageObject, NSUInteger idx, BOOL *stop) {
                
                WallImage *wallImage = [AppDelegate getImageDataFrom:wallImageObject];
                [[DataStore instance].wallImagesForTag addObject:wallImage];
            }];
        }
        
        if ([delegate respondsToSelector:@selector(didGetWallImageForTag)]) {
            [delegate didGetWallImageForTag];
        }
        
    }];
}

+ (void)  getWallImageForSearchOfNewsFeed:(id<CommsDelegate>) delegate searchText:(NSString *) strSearch limit:(NSInteger) nLimit{
    PFQuery *firstQuery = [PFQuery queryWithClassName:pClassWallImageOther];
    [firstQuery whereKey:pKeySelfComment containsString:strSearch];
    
    PFQuery *secondQuery = [PFQuery queryWithClassName:pClassWallImageOther];
    [secondQuery whereKey:pKeyRecipe containsString:strSearch];
    
    PFQuery *compoundQuery = [PFQuery orQueryWithSubqueries:@[firstQuery, secondQuery]];
    
    [compoundQuery orderByDescending:PKeyCreatedAt];
    [compoundQuery whereKey:PKeyCreatedAt lessThanOrEqualTo:g_lastImageUpdateForSearch];
    
    compoundQuery.skip = [DataStore instance].wallImagesForSearch.count;
    compoundQuery.limit = nLimit;
    
    [compoundQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            NSLog(@"Objects error: %@", error.localizedDescription);
        } else {
            
            [objects enumerateObjectsUsingBlock:^(PFObject *wallImageObject, NSUInteger idx, BOOL *stop) {
                
                WallImage *wallImage = [AppDelegate getImageDataFrom:wallImageObject];
                [[DataStore instance].wallImagesForSearch addObject:wallImage];
            }];
        }
        
        if ([delegate respondsToSelector:@selector(didGetWallImageForSearch)]) {
            [delegate didGetWallImageForSearch];
        }
        
    }];
}

+ (void)  getWallImageForSearchOfRecipe:(id<CommsDelegate>) delegate searchText:(NSString *) strSearch limit:(NSInteger) nLimit{
    PFQuery *firstQuery = [PFQuery queryWithClassName:pClassWallImageOther];
    [firstQuery whereKey:pKeySelfComment containsString:strSearch];
    
    PFQuery *secondQuery = [PFQuery queryWithClassName:pClassWallImageOther];
    [secondQuery whereKey:pKeyRecipe containsString:strSearch];
    
    PFQuery *compoundQuery = [PFQuery orQueryWithSubqueries:@[firstQuery, secondQuery]];
    
    [compoundQuery orderByDescending:PKeyCreatedAt];
    [compoundQuery whereKey:PKeyCreatedAt lessThanOrEqualTo:g_lastImageUpdateForSearch];
    [compoundQuery whereKey:pKeyIsRecipe equalTo:@(1)];
    
    compoundQuery.skip = [DataStore instance].wallImagesForSearch.count;
    compoundQuery.limit = nLimit;
    
    [compoundQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            NSLog(@"Objects error: %@", error.localizedDescription);
        } else {
            
            [objects enumerateObjectsUsingBlock:^(PFObject *wallImageObject, NSUInteger idx, BOOL *stop) {
                
                WallImage *wallImage = [AppDelegate getImageDataFrom:wallImageObject];
                [[DataStore instance].wallImagesForSearch addObject:wallImage];
            }];
        }
        
        if ([delegate respondsToSelector:@selector(didGetWallImageForSearch)]) {
            [delegate didGetWallImageForSearch];
        }
        
    }];
}

+ (void)  getWallImageForSearchOfFavorite:(id<CommsDelegate>) delegate searchText:(NSString *) strSearch limit:(NSInteger) nLimit{
    
    NSMutableArray *arrTmp = [g_myInfo.arrFavorites mutableCopy];
    
    for(WallImage *wallImage in [DataStore instance].wallImagesForSearch){
        if([arrTmp containsObject:wallImage.strImageObjId]){
            [arrTmp removeObject:wallImage.strImageObjId];
        }
    }
    
    PFQuery *firstQuery = [PFQuery queryWithClassName:pClassWallImageOther];
    [firstQuery whereKey:pKeySelfComment containsString:strSearch];
    
    PFQuery *secondQuery = [PFQuery queryWithClassName:pClassWallImageOther];
    [secondQuery whereKey:pKeyRecipe containsString:strSearch];
    
    PFQuery *compoundQuery = [PFQuery orQueryWithSubqueries:@[firstQuery, secondQuery]];
    
    [compoundQuery orderByDescending:PKeyCreatedAt];
    [compoundQuery whereKey:PKeyCreatedAt lessThanOrEqualTo:g_lastImageUpdateForSearch];
    [compoundQuery whereKey:pKeyObjId containedIn:arrTmp];
    
    compoundQuery.skip = [DataStore instance].wallImagesForSearch.count;
    compoundQuery.limit = nLimit;
    
    [compoundQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            NSLog(@"Objects error: %@", error.localizedDescription);
        } else {
            
            [objects enumerateObjectsUsingBlock:^(PFObject *wallImageObject, NSUInteger idx, BOOL *stop) {
                
                WallImage *wallImage = [AppDelegate getImageDataFrom:wallImageObject];
                [[DataStore instance].wallImagesForSearch addObject:wallImage];
            }];
        }
        
        if ([delegate respondsToSelector:@selector(didGetWallImageForSearch)]) {
            [delegate didGetWallImageForSearch];
        }
        
    }];
    
    [DataStore instance].wallImagesForFavorites = [[NSMutableArray alloc] initWithArray:[[DataStore instance].wallImagesForFavorites sortedArrayUsingComparator:^NSComparisonResult(WallImage *obj1, WallImage *obj2) {
        
        return [obj2.createdDate compare:obj1.createdDate];
    }]];
}


+ (void)  loadMoreForNewsFeed:(id<CommsDelegate>) delegate{
    
    PFQuery *imageQuery = [PFQuery queryWithClassName:pClassWallImageOther];
    
    [imageQuery orderByAscending:PKeyCreatedAt];
    [imageQuery whereKey:PKeyCreatedAt greaterThan:g_lastImageUpdateForNewsFeed];
    imageQuery.limit = LIMIT_NUMBER_LIST;
    
    [imageQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            NSLog(@"Objects error: %@", error.localizedDescription);
        } else {
            
            [objects enumerateObjectsUsingBlock:^(PFObject *wallImageObject, NSUInteger idx, BOOL *stop) {
                
                WallImage *wallImage = [AppDelegate getImageDataFrom:wallImageObject];
                [[DataStore instance].wallImagesForNewsFeed insertObject:wallImage atIndex:0];
                
                if ([wallImageObject.createdAt compare:g_lastImageUpdateForNewsFeed] == NSOrderedDescending) {
                    g_lastImageUpdateForNewsFeed = wallImageObject.createdAt;
                }
            }];
        }
        
        if ([delegate respondsToSelector:@selector(didLoadMoreForNewsFeed)]) {
            [delegate didLoadMoreForNewsFeed];
        }
        
    }];
}

+ (void)  loadMoreForRecipe:(id<CommsDelegate>) delegate{
    PFQuery *imageQuery = [PFQuery queryWithClassName:pClassWallImageOther];
    
    [imageQuery orderByAscending:PKeyCreatedAt];
    [imageQuery whereKey:PKeyCreatedAt greaterThan:g_lastImageUpdateForRecipe];
    [imageQuery whereKey:pKeyIsRecipe equalTo:@(1)];
    imageQuery.limit = LIMIT_NUMBER_LIST;
    
    [imageQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            NSLog(@"Objects error: %@", error.localizedDescription);
        } else {
            
            [objects enumerateObjectsUsingBlock:^(PFObject *wallImageObject, NSUInteger idx, BOOL *stop) {
                
                WallImage *wallImage = [AppDelegate getImageDataFrom:wallImageObject];
                [[DataStore instance].wallImagesForRecipe insertObject:wallImage atIndex:0];
                
                if ([wallImageObject.createdAt compare:g_lastImageUpdateForRecipe] == NSOrderedDescending) {
                    g_lastImageUpdateForRecipe = wallImageObject.createdAt;
                }
            }];
        }
        
        if ([delegate respondsToSelector:@selector(didLoadMoreForRecipe)]) {
            [delegate didLoadMoreForRecipe];
        }
        
    }];
}

+ (void)  loadMoreForCategory:(id) delegate category:(NSString *) strCategory limit:(NSInteger) nLimit{
    PFQuery *imageQuery = [PFQuery queryWithClassName:pClassWallImageOther];
    
    [imageQuery orderByAscending:PKeyCreatedAt];
    [imageQuery whereKey:PKeyCreatedAt greaterThan:g_lastImageUpdateForCategory];
    [imageQuery whereKey:pKeyCategory equalTo:strCategory];
    [imageQuery whereKey:pKeyIsRecipe equalTo:@(1)];
    imageQuery.limit = nLimit;
    
    [imageQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            NSLog(@"Objects error: %@", error.localizedDescription);
        } else {
            
            [objects enumerateObjectsUsingBlock:^(PFObject *wallImageObject, NSUInteger idx, BOOL *stop) {
                
                WallImage *wallImage = [AppDelegate getImageDataFrom:wallImageObject];
                [[DataStore instance].wallImagesForCategory insertObject:wallImage atIndex:0];
                
                if ([wallImageObject.createdAt compare:g_lastImageUpdateForCategory] == NSOrderedDescending) {
                    g_lastImageUpdateForCategory = wallImageObject.createdAt;
                }
            }];
        }
        
        if ([delegate respondsToSelector:@selector(didLoadMoreForCategory)]) {
            [delegate didLoadMoreForCategory];
        }
        
    }];

}

+ (void)  loadMoreForTag:(id) delegate tag:(NSString *) strTag limit:(NSInteger) nLimit{
    PFQuery *imageQuery = [PFQuery queryWithClassName:pClassWallImageOther];
    
    [imageQuery orderByAscending:PKeyCreatedAt];
    [imageQuery whereKey:PKeyCreatedAt greaterThan:g_lastImageUpdateForTag];
    [imageQuery whereKey:pKeyTag containsAllObjectsInArray:@[strTag]];
    imageQuery.limit = nLimit;
    
    [imageQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            NSLog(@"Objects error: %@", error.localizedDescription);
        } else {
            
            [objects enumerateObjectsUsingBlock:^(PFObject *wallImageObject, NSUInteger idx, BOOL *stop) {
                
                WallImage *wallImage = [AppDelegate getImageDataFrom:wallImageObject];
                [[DataStore instance].wallImagesForTag insertObject:wallImage atIndex:0];
                
                if ([wallImageObject.createdAt compare:g_lastImageUpdateForTag] == NSOrderedDescending) {
                    g_lastImageUpdateForTag = wallImageObject.createdAt;
                }
            }];
        }
        
        if ([delegate respondsToSelector:@selector(didLoadMoreForTag)]) {
            [delegate didLoadMoreForTag];
        }
        
    }];
}


- (void)setFirstScreen
{
    UINavigationController *welcomeNavCtrl = (UINavigationController*)[g_storyboard instantiateViewControllerWithIdentifier:WELCOME_NAV_CONTROLLER];
    UIViewController       *splashViewCtrl = (UIViewController *)[g_storyboard instantiateViewControllerWithIdentifier:SPLASH_VIEW_CONTROLLER];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:DEFAULT_USER_LOGGED])
    {
        [self.window setRootViewController:splashViewCtrl];
        
        [self getWallImagesForNewsFeed];
    }
    else
    {
        [self.window setRootViewController:welcomeNavCtrl];
    }
}

+ (UIImage *)squareImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    
    double ratio;
    double delta;
    CGPoint offset;
    
    //make a new square size, that is the resized imaged width
    CGSize sz = CGSizeMake(newSize.width, newSize.width);
    
    //figure out if the picture is landscape or portrait, then
    //calculate scale factor and offset
    if (image.size.width > image.size.height) {
        ratio = newSize.width / image.size.width;
        delta = (ratio*image.size.width - ratio*image.size.height);
        offset = CGPointMake(delta/2, 0);
    } else {
        ratio = newSize.width / image.size.height;
        delta = (ratio*image.size.height - ratio*image.size.width);
        offset = CGPointMake(0, delta/2);
    }
    
    //make the final clipping rect based on the calculated values
    CGRect clipRect = CGRectMake(-offset.x, -offset.y,
                                 (ratio * image.size.width) + delta,
                                 (ratio * image.size.height) + delta);
    
    
    //start a new context, with scale factor 0.0 so retina displays get
    //high quality image
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(sz, YES, 0.0);
    } else {
        UIGraphicsBeginImageContext(sz);
    }
    UIRectClip(clipRect);
    [image drawInRect:clipRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (NSString*)getTime:(NSDate*)time {
    if (time != nil) {
        NSTimeInterval distanceBetweenDates = [[NSDate date] timeIntervalSinceDate:time];
        if (distanceBetweenDates < 60) {
            double secondsInAnHour = 1;
            NSInteger second = distanceBetweenDates / secondsInAnHour;
            return [NSString stringWithFormat:@"%lds ago",(long)second];
        } else {
            if (distanceBetweenDates < 3600) {
                double secondsInAnHour = 60;
                NSInteger Minutes = distanceBetweenDates / secondsInAnHour;
                return [NSString stringWithFormat:@"%ldm ago",(long)Minutes];
            } else {
                if (distanceBetweenDates < 3600*24) {
                    double secondsInAnHour = 3600;
                    NSInteger hours = distanceBetweenDates / secondsInAnHour;
                    return [NSString stringWithFormat:@"%ldh ago",(long)hours];
                } else {
                    double secondsInAnHour = 3600*24;
                    NSInteger hoursBetweenDates = distanceBetweenDates / secondsInAnHour;
                    if (hoursBetweenDates > 365) {
                        NSInteger year = hoursBetweenDates/365;
                        return [NSString stringWithFormat:@"%ldy ago",(long)year];
                    } else{
                        return [NSString stringWithFormat:@"%ldd ago",(long)hoursBetweenDates];
                    }
                }
            }
        }
    }
    
    return nil;
}

+ (NSString *) getKeyString:(NSString *)strObjId1 secondObjectID:(NSString *)strObjId2{
    NSString *strKey = @"";
    
    if([strObjId1 compare:strObjId2] == NSOrderedAscending)
        strKey = [NSString stringWithFormat:@"%@-%@", strObjId1, strObjId2];
    else
        strKey = [NSString stringWithFormat:@"%@-%@", strObjId2, strObjId1];
    
    return strKey;
}

+ (NSMutableArray *) getTagsFromComment:(NSString *) strComment{
    NSMutableArray *arrAns = [[NSMutableArray alloc] init];
    
    NSArray *arrTmp = [strComment componentsSeparatedByString:@"#"];
    
    for(NSInteger idx  = 0; idx < arrTmp.count; idx ++){
        if(idx == 0) continue;
        
        NSString *strSnippet = [arrTmp objectAtIndex:idx];
        
        NSArray *arrTmpOther = [strSnippet componentsSeparatedByString:@" "];
        NSString *strElement = [arrTmpOther objectAtIndex:0];
        
        if(strElement.length == 1) continue;
        
        strElement = [NSString stringWithFormat:@"#%@", strElement.lowercaseString];
        
        [arrAns addObject:strElement];
    }
    
    return arrAns;
}

+(void) postImageToFB:(UIImage *) image comments:(NSString *) strComments
{
    
    NSData* imageData = UIImageJPEGRepresentation(image, 90);
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"https://graph.facebook.com/me/photos"]];
    [request addPostValue:g_myInfo.strFacebookToken forKey:@"access_token"];
    
    [request addPostValue:strComments forKey:@"message"];
    [request addData:imageData forKey:@"source"];
    
    [request setDelegate:self];
    [request startAsynchronous];
}

+ (void) postNotifyWithImage:(WallImage *)wallImage notificationType:(NotifyType) notifyType {
    if([wallImage.strUserObjId isEqualToString:g_myInfo.strUserObjID]) return;
    
    UserInfo *otherUserInfo = [AppDelegate getUserInfoFrom:wallImage.strUserObjId];
    
    BOOL isNotifyComment  = otherUserInfo.canNotifyComment;
    BOOL isNotifyLike     = otherUserInfo.canNotifyLike;
    BOOL isNotifyFavorite = otherUserInfo.canNotifyFavorite;
    
    if(!isNotifyComment && notifyType == notifyComment) return;
    if(!isNotifyLike && notifyType == notifyLiked) return;
    if(!isNotifyFavorite && notifyType == notifyAddFavorite) return;
    
    //Avoid multiple notify like / favorite
    if(notifyType == notifyLiked || notifyType == notifyAddFavorite){
        PFQuery *queryNotify = [PFQuery queryWithClassName:pClassNotifyPost];
        
        [queryNotify whereKey:pKeyImageObjId equalTo:wallImage.strImageObjId];
        [queryNotify whereKey:pKeyOtherUserObjId equalTo:g_myInfo.strUserObjID];
        [queryNotify whereKey:pKeyNotifyType equalTo:[[NSNumber alloc] initWithInteger:notifyType]];
        
        NSInteger nCount = [queryNotify countObjects];
        
        if(nCount > 0) return;
    }
    
    PFObject *notifyObject = [PFObject objectWithClassName:pClassNotifyPost];
    
    notifyObject[pKeyUserObjId] = wallImage.strUserObjId;
    notifyObject[pKeyNotifyType] = [[NSNumber alloc] initWithInteger:notifyType];
    notifyObject[pKeyOtherUserObjId] = g_myInfo.strUserObjID;
    notifyObject[pKeyImageObjId] = wallImage.strImageObjId;
    
    [notifyObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            // Build the actual push notification target query
            PFQuery *query = [PFInstallation query];
            
            [query whereKey:pKeyUserObjId equalTo:wallImage.strUserObjId];
            
            NSString *strFullName = [NSString stringWithFormat:@"%@ %@", g_myInfo.strUserFirstName, g_myInfo.strUserLastName];
            
            NSString *strAlert = @"";
            
            if(notifyType == notifyLiked){
                strAlert = [NSString stringWithFormat:@"%@ liked your post", strFullName];
            }else if(notifyType == notifyAddFavorite){
                strAlert = [NSString stringWithFormat:@"%@ added your post as a favorite", strFullName];
            }else if(notifyType == notifyComment){
                strAlert = [NSString stringWithFormat:@"%@ commented your post", strFullName];
            }else if(notifyType == notifyRequestRecipe){
                strAlert = [NSString stringWithFormat:@"%@ rquested the recipe of your post", strFullName];
            }
            
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                  PN_NOTIFY,                                        pnMode,
                                  PN_INCREMENT,                                     pnBadge,
                                  strAlert,                                         pnAlert,
                                  [[NSNumber alloc] initWithInteger:notifyType],    pnNotifyType,
                                  wallImage.strImageObjId,                          pnImageId,
                                  g_myInfo.strUserObjID,                            pnUserObjId,
                                  @"Notify_1.wav",                                  @"sound",
                                  nil];
            
            // Send the notification.
            PFPush *push = [[PFPush alloc] init];
            
            [push setQuery:query];
            [push setData:data];
            
            [push sendPushInBackground];
        }
    }];
}


+ (float) getRealWidthFrom:(float)height content:(NSString *)content fontname:(NSString *)fontname fontsize:(float)fontsize
{
    UIFont *textFont = [UIFont fontWithName:fontname size:fontsize];
    
    
    return [AppDelegate getRealWidthFrom:height content:content font:textFont];
}

+ (float) getRealWidthFrom:(float)height content:(NSString *)content font:(UIFont *)font
{
    CGSize size = CGSizeMake(320, height);
    CGSize textSize = [content sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    
    return textSize.width;
}

+ (float) getRealHeightFrom:(float)width content:(NSString *)content fontname:(NSString *)fontname fontsize:(float)fontsize
{
    UIFont *textFont = [UIFont fontWithName:fontname size:fontsize];
    
    return [AppDelegate getRealHeightFrom:width content:content font:textFont];
}


+ (float) getRealHeightFrom:(float)width content:(NSString *)content font:(UIFont *)font
{
    CGSize size = CGSizeMake(width, 1000);
    CGSize textSize = [content sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    
    return textSize.height;
}


@end
