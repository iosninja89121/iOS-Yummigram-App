//
//  MainTabBarController.m
//  yummigram
//
//  Created by User on 3/24/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "MainTabBarController.h"
#import <SVProgressHUD.h>

@interface MainTabBarController ()
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) CLPlacemark *placemark;
@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    self.geocoder = [[CLGeocoder alloc] init];
    
    if(self.locationManager == nil){
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        self.locationManager.delegate = self;
    }
    
    [self.locationManager requestWhenInUseAuthorization];
    
    [self.locationManager startUpdatingLocation];
    
    g_tabController = self;
    g_selectedTabBarItemIndex = 1;
    
    [[DataStore instance].userInfoMap setObject:g_myInfo forKey:g_myInfo.strUserObjID];
    [[DataStore instance].userInfoPFObjectMap setObject:[PFUser currentUser] forKey:g_myInfo.strUserObjID];
    
    g_otherInfo = g_myInfo;
    
    CGPoint center = self.tabBar.center;
    
    CGFloat fHeight = 70;
    
    center.y -= (fHeight - 50) / 2;
    
    if(!g_isIPAD){
        CGFloat fWidth  = [[UIScreen mainScreen] bounds].size.width;
        
        self.imgvNews = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tabbar_news"]];
        self.imgvNews.frame = CGRectMake(0, 0, fWidth, fHeight);
        self.imgvNews.center = center;
        
        [self.view addSubview:self.imgvNews];
        
        self.imgvRecipe = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tabbar_recipes"]];
        self.imgvRecipe.frame = CGRectMake(0, 0, fWidth, fHeight);
        self.imgvRecipe.center = center;
        
        [self.view addSubview:self.imgvRecipe];
        
        self.imgvCamera = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tabbar_photo"]];
        self.imgvCamera.frame = CGRectMake(0, 0, fWidth, fHeight);
        self.imgvCamera.center = center;
        
        [self.view addSubview:self.imgvCamera];
        
        self.imgvFavorite = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tabbar_favorites"]];
        self.imgvFavorite.frame = CGRectMake(0, 0, fWidth, fHeight);
        self.imgvFavorite.center = center;
        
        [self.view addSubview:self.imgvFavorite];
        
        self.imgvProfile = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tabbar_account"]];
        self.imgvProfile.frame = CGRectMake(0, 0, fWidth, fHeight);
        self.imgvProfile.center = center;
        
        [self.view addSubview:self.imgvProfile];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGRect)frameForTabInTabBar:(UITabBar*)tabBar withIndex:(NSUInteger)index
{
    NSMutableArray *tabBarItems = [NSMutableArray arrayWithCapacity:[tabBar.items count]];
    
    for (UIView *view in tabBar.subviews) {
        if ([view isKindOfClass:NSClassFromString(@"UITabBarButton")] && [view respondsToSelector:@selector(frame)]) {
            // check for the selector -frame to prevent crashes in the very unlikely case that in the future
            // objects thar don't implement -frame can be subViews of an UIView
            [tabBarItems addObject:view];
        }
    }
    if ([tabBarItems count] == 0) {
        // no tabBarItems means either no UITabBarButtons were in the subView, or none responded to -frame
        // return CGRectZero to indicate that we couldn't figure out the frame
        return CGRectZero;
    }
    
    // sort by origin.x of the frame because the items are not necessarily in the correct order
    [tabBarItems sortUsingComparator:^NSComparisonResult(UIView *view1, UIView *view2) {
        if (view1.frame.origin.x < view2.frame.origin.x) {
            return NSOrderedAscending;
        }
        if (view1.frame.origin.x > view2.frame.origin.x) {
            return NSOrderedDescending;
        }
        NSAssert(NO, @"%@ and %@ share the same origin.x. This should never happen and indicates a substantial change in the framework that renders this method useless.", view1, view2);
        return NSOrderedSame;
    }];
    
    CGRect frame = CGRectZero;
    if (index < [tabBarItems count]) {
        // viewController is in a regular tab
        UIView *tabView = tabBarItems[index];
        if ([tabView respondsToSelector:@selector(frame)]) {
            frame = tabView.frame;
        }
    }
    else {
        // our target viewController is inside the "more" tab
        UIView *tabView = [tabBarItems lastObject];
        if ([tabView respondsToSelector:@selector(frame)]) {
            frame = tabView.frame;
        }
    }
    
    return frame;
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    
    if(g_selectedTabBarItemIndex == item.tag){
        if(item.tag == 1){
            [[NSNotificationCenter defaultCenter] postNotificationName:N_RefreshAtNewsFeed object:nil];
        }else if(item.tag == 2){
            [[NSNotificationCenter defaultCenter] postNotificationName:N_RefreshAtRecipe object:nil];
        }else if(item.tag == 4){
            [[NSNotificationCenter defaultCenter] postNotificationName:N_RefreshAtFavorite object:nil];
        }
        
    }
    
    g_selectedTabBarItemIndex = item.tag;
}

#pragma mark CLLocationMangerDelegate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *newLocation = [locations lastObject];
    
    [self.geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if (error == nil && [placemarks count] >0) {
            self.placemark = [placemarks lastObject];
            
            NSDictionary *addressDictionary = self.placemark.addressDictionary;
            
            [DataStore instance].strCountry = [addressDictionary objectForKey:@"Country"];
            [DataStore instance].strCity    = [addressDictionary objectForKey:@"City"];
            
            NSLog(@"%@, %@", [DataStore instance].strCity, [DataStore instance].strCountry);
            
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    }];
    
    // Turn off the location manager to save power.
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Cannot find the location.");
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
