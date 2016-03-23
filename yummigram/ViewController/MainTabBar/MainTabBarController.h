//
//  MainTabBarController.h
//  yummigram
//
//  Created by User on 3/24/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MainTabBarController : UITabBarController<CLLocationManagerDelegate>
@property (nonatomic, strong) UIImageView *imgvNews;
@property (nonatomic, strong) UIImageView *imgvRecipe;
@property (nonatomic, strong) UIImageView *imgvCamera;
@property (nonatomic, strong) UIImageView *imgvFavorite;
@property (nonatomic, strong) UIImageView *imgvProfile;
@end
