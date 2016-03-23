//
//  LoginViewController.m
//  yummigram
//
//  Created by User on 3/21/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *pswdTextField;

@end

@implementation LoginViewController
- (IBAction)onBackToHome:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onLoginWithInfo:(id)sender {
    [self dismissKeyboard];
    [self processFieldEntries];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.emailTextField.delegate = self;
    self.pswdTextField.delegate = self;
    
    NSString* strEmail = [[NSUserDefaults standardUserDefaults] stringForKey:DEFAULT_USER_EMAIL];
    NSString* strPassword = [[NSUserDefaults standardUserDefaults] stringForKey:DEFAULT_USER_PSWD];
    
    if(strEmail != nil && strEmail.length > 0){
        self.emailTextField.text = strEmail;
        self.pswdTextField.text = strPassword;
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}

- (void)processFieldEntries {
    // Get the username text, store it in the app delegate for now
    
    if (self.emailTextField.text.length < 1) {
        [SVProgressHUD showErrorWithStatus:@"Please, input your email"];
        return;
    }
    
    if (self.pswdTextField.text.length < 1) {
        [SVProgressHUD showErrorWithStatus:@"Please, input your password"];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"Logging In..." maskType:SVProgressHUDMaskTypeGradient];
    [[ParseService sharedInstance] loginWithUserName:self.emailTextField.text
                                            Password:self.pswdTextField.text
                                              Result:^(NSString *strError) {
                                                  if(strError == nil)
                                                  {
                                                      g_lastImageUpdateForNewsFeed = [NSDate date];
                                                      g_lastImageUpdateForRecipe = [NSDate date];
                                                      g_lastCommentUpdate = [NSDate date];
                                                      g_lastUserInfoUpdate = [NSDate date];
                                                      
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
//    [[NSUserDefaults standardUserDefaults] setValue:self.emailTextField.text forKey:DEFAULT_USER_EMAIL];
//    [[NSUserDefaults standardUserDefaults] setValue:self.pswdTextField.text  forKey:DEFAULT_USER_PSWD];
//    [[NSUserDefaults standardUserDefaults] synchronize];
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
    
    [[NSUserDefaults standardUserDefaults] setValue:self.emailTextField.text forKey:DEFAULT_USER_EMAIL];
    [[NSUserDefaults standardUserDefaults] setValue:self.pswdTextField.text  forKey:DEFAULT_USER_PSWD];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
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
  
                        [UIView setAnimationsEnabled:oldState];
                    }
                    completion:nil];
    
}

#pragma mark Keyboard

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailTextField) {
        [self.pswdTextField becomeFirstResponder];
    }
    
    if (textField == self.pswdTextField) {
        [self dismissKeyboard];
        [self processFieldEntries];
    }
    
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
