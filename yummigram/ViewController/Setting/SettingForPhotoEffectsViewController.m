//
//  SettingForPhotoEffectsViewController.m
//  yummigram
//
//  Created by User on 5/25/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "SettingForPhotoEffectsViewController.h"

@interface SettingForPhotoEffectsViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *switchPhotoEffects;

@end

@implementation SettingForPhotoEffectsViewController
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)swtichPhotoEffectsChanged:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:DEFAULT_USER_PHOTO_EFFECT];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.switchPhotoEffects setOn:[[NSUserDefaults standardUserDefaults] boolForKey:DEFAULT_USER_PHOTO_EFFECT]];
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
