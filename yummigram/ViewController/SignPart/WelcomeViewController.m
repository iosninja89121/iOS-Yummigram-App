//
//  WelcomeViewController.m
//  yummigram
//
//  Created by User on 3/21/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "WelcomeViewController.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onLoginWithFacebook:(id)sender {
    NSArray *aryPermissions = @[@"public_profile", @"email", @"user_friends", @"publish_actions"];
    
    [SVProgressHUD showWithStatus:@"Logging In..." maskType:SVProgressHUDMaskTypeGradient];
    [[ParseService sharedInstance] loginWithFacebookPermission:aryPermissions
                                                        Result:^(NSString *strError) {
                                                            if(strError == nil)
                                                            {
                                                                g_lastUserInfoUpdate = [NSDate date];
                                                                g_lastImageUpdateForNewsFeed = [NSDate date];
                                                                g_lastImageUpdateForRecipe = [NSDate date];
                                                                g_lastCommentUpdate = [NSDate date];
                                                                
                                                                [AppDelegate getWallImagesForNewsFeed:self limit:3];
                                                                
                                                            }
                                                            else
                                                            {
                                                                [SVProgressHUD showErrorWithStatus:strError];
                                                            }
                                                        }];

}

//- (void) didGetUserInfo{
//    [AppDelegate getWallImages:self];
//}
//
//- (void) didGetImages{
//    [AppDelegate getComments:self];
//}
//
//- (void) didGetComments{
//    [AppDelegate getNotifications:self];
//}
//
//- (void) didGetNotifications{
//    [AppDelegate getChats:self];
//}
//
//- (void) didGetChat{
//    [SVProgressHUD dismiss];
//    
//    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
//    
//    currentInstallation[pKeyUserObjId] = g_myInfo.strUserObjID;
//    
//    [currentInstallation saveInBackground];
//    
//    [self processAppTransition];
//}

- (void) didGetWallImageForNewsFeed{
    [AppDelegate getWallImagesForRecipe:self limit:LIMIT_NUMBER_GRID];
}

- (void) didGetWallImageForRecipe{
    [AppDelegate getWallImagesForFavorite:self limit:LIMIT_NUMBER_GRID];
}

- (void) didGetWallImageForFavorites{
    [AppDelegate getWallImagesForMyOwn:self limit:LIMIT_NUMBER_GRID];
}

- (void) didGetWallImageForMyOwn{
    [SVProgressHUD dismiss];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    currentInstallation[pKeyUserObjId] = g_myInfo.strUserObjID;
    
    [currentInstallation saveInBackground];
    
    [self processAppTransition];
}

- (void)processAppTransition
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DEFAULT_USER_LOGGED];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UITabBarController *ctrl = (UITabBarController *)[self.storyboard instantiateViewControllerWithIdentifier:MAIN_TAB_BAR_CONTROLLER];
    
    [UIView transitionWithView:[appDelegate window]
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^(void){
                        BOOL oldState = [UIView areAnimationsEnabled];
                        [UIView setAnimationsEnabled:NO];
                        [[appDelegate window] setRootViewController:ctrl];
//                        [[appDelegate window] setRootViewController:g_sideMenuController];
                        [UIView setAnimationsEnabled:oldState];
                    }
                    completion:nil];
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
