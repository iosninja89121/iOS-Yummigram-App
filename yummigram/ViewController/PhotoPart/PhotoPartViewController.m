//
//  PhotoPartViewController.m
//  yummigram
//
//  Created by User on 3/24/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "PhotoPartViewController.h"
#import "TakePhotoViewController.h"
#import "MainTabBarController.h"
#import "NewsFeedViewController.h"

@interface PhotoPartViewController ()

@end

@implementation PhotoPartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    TakePhotoViewController *take = (TakePhotoViewController *)[self.storyboard instantiateViewControllerWithIdentifier:TAKE_PHOTO_VIEW_CONTROLLER];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:take];
    
    nav.navigationBarHidden = YES;
    
    [self presentViewController:nav animated:NO completion:^{
        
        for ( UINavigationController *controller in g_tabController.viewControllers) {
            
            if ( [[controller.childViewControllers objectAtIndex:0] isKindOfClass:[NewsFeedViewController class]]) {
                
                [g_tabController setSelectedViewController:controller];
                
                break;
            }
        }
        
    }];

}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

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
