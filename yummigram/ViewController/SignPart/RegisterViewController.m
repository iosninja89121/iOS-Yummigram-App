//
//  RegisterViewController.m
//  yummigram
//
//  Created by User on 3/21/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController ()

@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (weak, nonatomic) IBOutlet UITextField *birthdayTextField;
@property (weak, nonatomic) IBOutlet UIButton *btnMaleCheckBox;
@property (weak, nonatomic) IBOutlet UIButton *btnFemaleCheckBox;
@property (nonatomic)                BOOL     isMale;
@property (nonatomic, strong)        NSDate   *birthDay;
@end

@implementation RegisterViewController
- (IBAction)onBackToHome:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onSignup:(id)sender {
    [self dismissKeyboard];
    [self processFieldEntries];
}

- (IBAction)onMale:(id)sender {
    self.isMale = YES;
    
    [self.btnMaleCheckBox setImage:[UIImage imageNamed:@"cb_checked"] forState:UIControlStateNormal];
    [self.btnFemaleCheckBox setImage:[UIImage imageNamed:@"cb_unchecked"] forState:UIControlStateNormal];
}

- (IBAction)onFemale:(id)sender {
    self.isMale = NO;
    
    [self.btnMaleCheckBox setImage:[UIImage imageNamed:@"cb_unchecked"] forState:UIControlStateNormal];
    [self.btnFemaleCheckBox setImage:[UIImage imageNamed:@"cb_checked"] forState:UIControlStateNormal];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.firstNameTextField.delegate = self;
    self.lastNameTextField.delegate = self;
    self.emailTextField.delegate = self;
    self.pwdTextField.delegate = self;
    self.birthdayTextField.delegate = self;
    
    UIDatePicker *datePicker = [[UIDatePicker alloc]init];
    [datePicker setDate:[NSDate date]];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker addTarget:self action:@selector(setBirthday:) forControlEvents:UIControlEventValueChanged];
    [self.birthdayTextField setInputView:datePicker];
    
    self.isMale = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}

- (void) setBirthday:(id) sender{
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
   
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    
    self.birthdayTextField.text = [dateFormatter stringFromDate:datePicker.date];
    self.birthDay = datePicker.date;
}



#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.firstNameTextField) {
        [self.lastNameTextField becomeFirstResponder];
    }
    if (textField == self.lastNameTextField) {
        [self.emailTextField becomeFirstResponder];
    }
    if (textField == self.emailTextField) {
        [self.pwdTextField becomeFirstResponder];
    }
    if (textField == self.pwdTextField) {
        [self.pwdTextField resignFirstResponder];
        [self dismissKeyboard];
        [self processFieldEntries];
    }
    
    return YES;
}

#pragma mark Keyboard

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

#pragma mark -
#pragma mark Sign Up

- (void)processFieldEntries {
    // Check that we have a non-zero username and passwords.
    // Compare password and passwordAgain for equality
    // Throw up a dialog that tells them what they did wrong if they did it wrong.
    
    NSString *strFirstName = self.firstNameTextField.text;
    NSString *strLastName  = self.lastNameTextField.text;
    NSString *strEmail     = self.emailTextField.text;
    NSString *strPassword  = self.pwdTextField.text;
    NSString *strBirthDay  = self.birthdayTextField.text;
    
    if(strEmail.length == 0){
        [SVProgressHUD showErrorWithStatus:@"Please enter an email"];
        return;
    }
    
    if(![self NSStringIsValidEmail:strEmail]){
        [SVProgressHUD showErrorWithStatus:@"Please enter a valid email"];
        return;
    }
    
    if(strPassword.length < 6){
        [SVProgressHUD showErrorWithStatus:@"password length should be at least 6 characters long"];
        return;
    }
    
    if(strFirstName.length == 0){
        [SVProgressHUD showErrorWithStatus:@"Please enter a first name"];
        return;
    }
    
    if(strLastName.length == 0){
        [SVProgressHUD showErrorWithStatus:@"Please enter a last name"];
        return;
    }
    
    if(strBirthDay.length == 0){
        [SVProgressHUD showErrorWithStatus:@"Please enter the birthday"];
        return;
    }
    
    UserInfo *userInfo = [UserInfo initWithFirstName:strFirstName lastName:strLastName userEmail:strEmail userPassword:strPassword gender:self.isMale birthday:self.birthDay];
    
    [SVProgressHUD showWithStatus:@"Creating Account..." maskType:SVProgressHUDMaskTypeGradient];
    [[ParseService sharedInstance] signUpWithUserInfo:userInfo
                                               Result:^(NSString *strError) {
                                                   if(strError == nil)
                                                   {
                                                       g_lastImageUpdateForNewsFeed = [NSDate date];
                                                       g_lastImageUpdateForRecipe = [NSDate date];
                                                       g_lastUserInfoUpdate = [NSDate date];
                                                       g_lastCommentUpdate = [NSDate date];
                                                       
                                                       [AppDelegate getWallImagesForNewsFeed:self limit:3];
                                                       
                                                    }
                                                   else
                                                       [SVProgressHUD showErrorWithStatus:strError];
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
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DEFAULT_USER_NOTIFY_COMMENTS];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DEFAULT_USER_NOTIFY_MESSAGES];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:DEFAULT_USER_NOTIFY_LIKE_PHOTO];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DEFAULT_USER_NOTIFY_FOLLOW];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DEFAULT_USER_PHOTO_EFFECT];
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
