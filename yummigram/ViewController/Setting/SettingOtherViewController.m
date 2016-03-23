//
//  SettingOtherViewController.m
//  yummigram
//
//  Created by User on 5/25/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "SettingOtherViewController.h"

@interface SettingOtherViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *switchComments;
@property (weak, nonatomic) IBOutlet UISwitch *switchMessage;
@property (weak, nonatomic) IBOutlet UISwitch *switchLike;
@property (weak, nonatomic) IBOutlet UISwitch *switchFollow;
@property (weak, nonatomic) IBOutlet UISwitch *switchFavorite;
@property (weak, nonatomic) IBOutlet UISwitch *switchPhoto;
@property (weak, nonatomic) IBOutlet UIScrollView *myScrollView;

@end

@implementation SettingOtherViewController
- (IBAction)onChangeSwitchComment:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    
    currentUser[pKeyNotifyComments] = [NSNumber numberWithBool:[sender isOn]];
    [currentUser saveInBackground];
}

- (IBAction)onChangeSwitchMessage:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    
    currentUser[pKeyNotifyMessage] = [NSNumber numberWithBool:[sender isOn]];
    [currentUser saveInBackground];
}

- (IBAction)onChangeSwitchLike:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    
    currentUser[pKeyNotifyLike] = [NSNumber numberWithBool:[sender isOn]];
    [currentUser saveInBackground];
}

- (IBAction)onChangeSwitchFollow:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    
    currentUser[pKeyNotifyFollow] = [NSNumber numberWithBool:[sender isOn]];
    [currentUser saveInBackground];
}

- (IBAction)onChangeSwitchFavorite:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    
    currentUser[pKeyNotifyFavorite] = [NSNumber numberWithBool:[sender isOn]];
    [currentUser saveInBackground];
}

- (IBAction)onChangeSwitchPhoto:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:DEFAULT_USER_PHOTO_EFFECT];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onLogout:(id)sender {
    [PFUser logOut];
    
    [[DataStore instance] reset];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:DEFAULT_USER_LOGGED];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UIViewController *ctrl = (UIViewController *)[self.storyboard instantiateViewControllerWithIdentifier:WELCOME_NAV_CONTROLLER];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.switchComments.transform = CGAffineTransformMakeScale(0.75, 0.75);
    self.switchMessage.transform = CGAffineTransformMakeScale(0.75, 0.75);
    self.switchLike.transform = CGAffineTransformMakeScale(0.75, 0.75);
    self.switchFollow.transform = CGAffineTransformMakeScale(0.75, 0.75);
    self.switchFavorite.transform = CGAffineTransformMakeScale(0.75, 0.75);
    self.switchPhoto.transform = CGAffineTransformMakeScale(0.75, 0.75);
    
    PFUser *currentUser = [PFUser currentUser];
    
    BOOL isNotifyComments = [currentUser[pKeyNotifyComments] boolValue];
    BOOL isNotifyMessage  = [currentUser[pKeyNotifyMessage] boolValue];
    BOOL isNotifyLike     = [currentUser[pKeyNotifyLike] boolValue];
    BOOL isNotifyFollow   = [currentUser[pKeyNotifyFollow] boolValue];
    BOOL isNotifyFavorite = [currentUser[pKeyNotifyFavorite] boolValue];
    
    [self.switchComments setOn:isNotifyComments];
    [self.switchMessage  setOn:isNotifyMessage];
    [self.switchLike    setOn:isNotifyLike];
    [self.switchFollow  setOn:isNotifyFollow];
    [self.switchFavorite setOn:isNotifyFavorite];
    
    [self.switchPhoto setOn:[[NSUserDefaults standardUserDefaults] boolForKey:DEFAULT_USER_PHOTO_EFFECT]];
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
