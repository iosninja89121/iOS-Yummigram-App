//
//  SettingForPushNotificationViewController.m
//  yummigram
//
//  Created by User on 5/25/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "SettingForPushNotificationViewController.h"

@interface SettingForPushNotificationViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *switchComments;
@property (weak, nonatomic) IBOutlet UISwitch *switchMessage;
@property (weak, nonatomic) IBOutlet UISwitch *switchLikes;
@property (weak, nonatomic) IBOutlet UISwitch *switchFollows;
@property (weak, nonatomic) IBOutlet UISwitch *switchFavorite;

@end

@implementation SettingForPushNotificationViewController
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)chnangeSwitchComments:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    
    currentUser[pKeyNotifyComments] = [NSNumber numberWithBool:[sender isOn]];
    [currentUser saveInBackground];
}

- (IBAction)changeSwitchMessage:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    
    currentUser[pKeyNotifyMessage] = [NSNumber numberWithBool:[sender isOn]];
    [currentUser saveInBackground];
}

- (IBAction)changeSwitchLikes:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    
    currentUser[pKeyNotifyLike] = [NSNumber numberWithBool:[sender isOn]];
    [currentUser saveInBackground];
}

- (IBAction)changeSwitchFollows:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    
    currentUser[pKeyNotifyFollow] = [NSNumber numberWithBool:[sender isOn]];
    [currentUser saveInBackground];
}
- (IBAction)changeSwitchFavorite:(id)sender {
    PFUser *currentUser = [PFUser currentUser];
    
    currentUser[pKeyNotifyFavorite] = [NSNumber numberWithBool:[sender isOn]];
    [currentUser saveInBackground];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    PFUser *currentUser = [PFUser currentUser];
    
    BOOL isNotifyComments = [currentUser[pKeyNotifyComments] boolValue];
    BOOL isNotifyMessage  = [currentUser[pKeyNotifyMessage] boolValue];
    BOOL isNotifyLike     = [currentUser[pKeyNotifyLike] boolValue];
    BOOL isNotifyFollow   = [currentUser[pKeyNotifyFollow] boolValue];
    BOOL isNotifyFavorite = [currentUser[pKeyNotifyFavorite] boolValue];
    
    [self.switchComments setOn:isNotifyComments];
    [self.switchMessage  setOn:isNotifyMessage];
    [self.switchLikes    setOn:isNotifyLike];
    [self.switchFollows  setOn:isNotifyFollow];
    [self.switchFavorite setOn:isNotifyFavorite];
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
