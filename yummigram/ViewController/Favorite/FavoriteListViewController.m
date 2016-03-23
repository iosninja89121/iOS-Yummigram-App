//
//  NewsFeedViewController.m
//  yummigram
//
//  Created by User on 4/22/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "FavoriteListViewController.h"
#import "ProfileViewController.h"
#import "RecipeDetailViewController.h"
#import "SuccontPullToRefreshView.h"
#import "UIViewController+SuccontPullToRefresh.h"
#import "PostCommentViewController.h"
#import "MainTabBarController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <Social/Social.h>
#import "TagViewController.h"
#import "SearchResultViewController.h"

@interface FavoriteListViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tblFavorite;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *btnChat;
@property (weak, nonatomic) IBOutlet UIButton *btnNotify;

@property (weak, nonatomic) IBOutlet UICollectionView *favoriteCollectionView;

//@property (nonatomic, strong) CustomBadge *badge;

@property (nonatomic, strong) NSMutableArray *arrFavoriteList;
@property (nonatomic, strong) NSMutableArray *arrCurData;

@property (nonatomic, strong) SuccontPullToRefreshView *pullToRefreshView;
@property (nonatomic, strong) UIActivityIndicatorView  *indicatorFooter;
@property (nonatomic, strong) UIActivityIndicatorView  *indicatorFooterOfCollection;

@property (weak, nonatomic) UIButton *btnGridViewForCollection;
@property (weak, nonatomic) UIButton *btnListViewForCollection;
@property (weak, nonatomic) UIButton *btnGridViewForTableView;
@property (weak, nonatomic) UIButton *btnListViewForTableView;

@property (weak, nonatomic) UIImageView *imgvGridViewForCollection;
@property (weak, nonatomic) UIImageView *imgvListViewForCollection;
@property (weak, nonatomic) UIImageView *imgvGridViewForTableView;
@property (weak, nonatomic) UIImageView *imgvListViewForTableView;

@property (strong, nonatomic) NSMutableArray *arrFilteredData;

@property (nonatomic)         BOOL     isSearching;
@property (nonatomic)         BOOL     isGridView;
@end

@implementation FavoriteListViewController

- (void) onGridView:(id)sender {
    
    [self.imgvGridViewForCollection setImage:[UIImage imageNamed:@"photos_table_view_active"]];
    [self.imgvListViewForCollection setImage:[UIImage imageNamed:@"photos_list_view"]];
    
    [self.favoriteCollectionView setHidden:NO];
    [self.tblFavorite setHidden:YES];
    
    self.isGridView = YES;
}

- (void) onListView:(id)sender {
    [self.imgvGridViewForTableView setImage:[UIImage imageNamed:@"photos_table_view"]];
    [self.imgvListViewForTableView setImage:[UIImage imageNamed:@"photos_list_view_active"]];
    
    [self.favoriteCollectionView setHidden:YES];
    [self.tblFavorite setHidden:NO];
    
    self.isGridView = NO;
}
- (IBAction)onChat:(id)sender {
    UIViewController *chatViewCtrl = (UIViewController *)[self.storyboard instantiateViewControllerWithIdentifier:CHAT_VIEW_CONTROLLER];
    
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:chatViewCtrl];
    
    navCtrl.navigationBar.hidden = YES;
    
    [self.navigationController presentViewController:navCtrl animated:YES completion:nil];
}

- (IBAction)onAlarm:(id)sender {
    UIViewController *notifyViewCtrl = (UIViewController *)[self.storyboard instantiateViewControllerWithIdentifier:NOTIFICATION_VIEW_CONTROLLER];
    
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:notifyViewCtrl];
    
    navCtrl.navigationBar.hidden = YES;
    
    [self.navigationController presentViewController:navCtrl animated:YES completion:nil];
}

- (void) viewWillAppear:(BOOL)animated{
    MainTabBarController *mainTabCtrl = (MainTabBarController *)g_tabController;
    
    [mainTabCtrl.view bringSubviewToFront:mainTabCtrl.imgvFavorite];
    
    NSLog(@"favorite screen appears");
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tblFavorite.delegate = self;
    self.tblFavorite.dataSource = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imageDataChanged:)
                                                 name:N_ImageDataChanged
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshData:)
                                                 name:N_RefreshAtFavorite
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(messageUpdated:)
                                                 name:N_MessageUpdated
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(messageViewed:)
                                                 name:N_MessageViewed
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notifyUpdated:)
                                                 name:N_NotifyUpdated
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notifyViewed:)
                                                 name:N_NotifyViewed
                                               object:nil];

    
    self.arrFavoriteList = [[NSMutableArray alloc] init];
    
    self.isSearching = NO;
    self.isGridView = YES;
    
    [self loadData];
    
    self.arrFilteredData = [NSMutableArray arrayWithCapacity:[self.arrFavoriteList count]];
    
    [self initializeRefreshControlForHeader];
    [self initializeRefreshControlForFooter];
    
    [self setupCollectionView];
    
    UITextField *txfSearchField = [_searchBar valueForKey:@"_searchField"];
    txfSearchField.backgroundColor = [UIColor clearColor];
    
    [self.tblFavorite setHidden:YES];
}

- (void) initializeRefreshControlForHeader{
    self.pullToRefreshView = [[SuccontPullToRefreshView alloc] initWithFrame:CGRectMake(0, -50, self.view.bounds.size.width, 50)];
    self.pullToRefreshView.backgroundColor = [UIColor clearColor];
    self.pullToRefreshView.statusLabel.backgroundColor = [UIColor clearColor];
    self.pullToRefreshView.statusLabel.textColor = [UIColor blackColor];
    self.pullToRefreshView.statusLabel.font = [UIFont fontWithName:@"Roboto-Bold" size:15];
    self.pullToRefreshView.reloadImageView.image = [UIImage imageNamed:@"PullToRefresh"];
    
    [self.tblFavorite addSubview:self.pullToRefreshView];
}

- (void) initializeRefreshControlForFooter{
    self.indicatorFooter = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tblFavorite.frame), 44)];
    [self.indicatorFooter setColor:[UIColor blackColor]];
    [self.indicatorFooter stopAnimating];
    [self.tblFavorite setTableFooterView:self.indicatorFooter];
}


- (void) loadData{
    
    [[DataStore instance].wallImagesForFavorites removeAllObjects];
    
    for(NSString *strObjId in g_myInfo.arrFavorites){
        WallImage *wallImage = [[DataStore instance].wallImageMap objectForKey:strObjId];
        
        if(wallImage == nil) continue;
        
        [[DataStore instance].wallImagesForFavorites addObject:wallImage];
    }
    
    [DataStore instance].wallImagesForFavorites = [[NSMutableArray alloc] initWithArray:[[DataStore instance].wallImagesForFavorites sortedArrayUsingComparator:^NSComparisonResult(WallImage *obj1, WallImage *obj2) {
        
        return [obj2.createdDate compare:obj1.createdDate];
    }]];
    
    self.arrFavoriteList = [DataStore instance].wallImagesForFavorites;
    self.arrCurData = self.arrFavoriteList;
    
    [self.tblFavorite reloadData];
    NSLog(@"collection view reload");
    [self.favoriteCollectionView reloadData];
    
    [self.indicatorFooter stopAnimating];
    [self.indicatorFooterOfCollection stopAnimating];
}

-(void)setupCollectionView {
    CGFloat width_CollectionCell = self.view.frame.size.width - 28;
    
    UICollectionViewFlowLayout *collectionFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [collectionFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [collectionFlowLayout setMinimumInteritemSpacing:10.0f];
    [collectionFlowLayout setMinimumLineSpacing:10.0f];
    [collectionFlowLayout setItemSize:CGSizeMake(width_CollectionCell / 2, width_CollectionCell / 2)];
    [collectionFlowLayout setHeaderReferenceSize:CGSizeMake(width_CollectionCell  + 6, 44)];
    [collectionFlowLayout setFooterReferenceSize:CGSizeMake(width_CollectionCell  + 6, 44)];
    [self.favoriteCollectionView setPagingEnabled:YES];
    [self.favoriteCollectionView setCollectionViewLayout:collectionFlowLayout];
}

- (void) refreshImageWall:(UIRefreshControl *)refreshControl
{
    if (refreshControl) {
        [refreshControl setEnabled:NO];
        [refreshControl endRefreshing];
    }
    
    //    [self.tblFavorite.pullToRefreshView stopAnimating];
    
//    [SVProgressHUD showWithStatus:@"Load more..." maskType:SVProgressHUDMaskTypeGradient];
//    [AppDelegate getUserInfo:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refreshData:(NSNotification *)notification
{
    if(self.arrCurData.count == 0) return;
    if(self.isSearching && self.arrFilteredData.count == 0) return;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tblFavorite scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
//    [AppDelegate getUserInfo:self];
}

- (void) imageDataChanged:(NSNotification *)notification
{
    [self loadData];
}

- (void) messageUpdated:(NSNotification *)notification
{
    [self.btnChat setImage:[UIImage imageNamed:@"chat_icon"] forState:UIControlStateNormal];
}

- (void) messageViewed:(NSNotification *)notification
{
    [self.btnChat setImage:[UIImage imageNamed:@"chat_icon_default"] forState:UIControlStateNormal];
}

- (void) notifyUpdated:(NSNotification *)notification
{
//    [self.badge autoBadgeSizeWithString:@(g_badgeNumber).stringValue];
//    
//    CGPoint point = CGPointMake(self.btnNotify.frame.origin.x + 25, self.btnNotify.frame.origin.y + 5);
//    CGSize size = CGSizeMake(self.badge.frame.size.width, self.badge.frame.size.height);
//    CGRect rect = CGRectMake(point.x, point.y, size.width, size.height);
//    
//    [self.badge setFrame:rect];
//    
//    [self.badge setHidden:NO];
    
    [self.btnNotify setImage:[UIImage imageNamed:@"alarm_icon"] forState:UIControlStateNormal];
}

- (void) notifyViewed:(NSNotification *)notification
{
//    [self.badge setHidden:YES];
    
    [self.btnNotify setImage:[UIImage imageNamed:@"alarm_icon_default"] forState:UIControlStateNormal];
}

- (void) didGetWallImageForFavorites{
    [self loadData];
}

- (void) didGetWallImageForSearchOfFavorite{
    
    self.arrFilteredData = [[DataStore instance].wallImagesForSearch mutableCopy];
    
    [self.tblFavorite reloadData];
    [self.indicatorFooter stopAnimating];
    [self.indicatorFooterOfCollection stopAnimating];
}

- (void) didLoadMoreForFavorites{
    [self loadData];
}

- (void) onRequestRecipe:(id) sender{
    
    UIView *senderView = (UIView *)sender;
    
    NSArray *arrSegment = [senderView.accessibilityIdentifier componentsSeparatedByString:@":"];
    
    NSString *strTableType = [arrSegment objectAtIndex:0];
    NSInteger nIdx = [[arrSegment objectAtIndex:1] integerValue];
    
    WallImage *wallImage = nil;
    
    if([strTableType isEqualToString:STRING_ORIGIN_TABLE])
        wallImage = [self.arrCurData objectAtIndex:nIdx];
    else
        wallImage = [self.arrFilteredData objectAtIndex:nIdx];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:wallImage.strImageObjId]) return;
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:wallImage.strImageObjId];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UIView *superView = [senderView superview];
    UIButton *btnRequestRecipe = (UIButton *)[superView viewWithTag:9];
    
    [btnRequestRecipe setBackgroundImage:[UIImage imageNamed:@"bg_btn_red"] forState:UIControlStateNormal];
    [btnRequestRecipe setTitle:@"RECIPE REQUESTED" forState:UIControlStateNormal];
    [btnRequestRecipe setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    wallImage.nNumberRecipeRequests ++;
    
    PFObject *wallImageObj = [[DataStore instance].wallImagePFObjectMap objectForKey:wallImage.strImageObjId];
    
    wallImageObj[pKeyRequestRecipe] = [NSNumber numberWithInteger:wallImage.nNumberRecipeRequests];
    
    [wallImageObj saveInBackground];
    
    [AppDelegate postNotifyWithImage:wallImage notificationType:notifyRequestRecipe];
}

- (void) onShareFacebook:(id) sender{
    
    UIView *senderView = (UIView *)sender;
    
    NSArray *arrComponents = [senderView.accessibilityIdentifier componentsSeparatedByString:@":"];
    
    NSString *strTableType = [arrComponents objectAtIndex:0];
    NSInteger nIdx = [[arrComponents objectAtIndex:1] integerValue];
    
    WallImage *wallImage = nil;
    
    if([strTableType isEqualToString:STRING_ORIGIN_TABLE]){
        wallImage = [self.arrCurData objectAtIndex:nIdx];
    }else{
        wallImage = [self.arrFilteredData objectAtIndex:nIdx];
    }
    
    NSString *strRealComments = @"";
    
    if(wallImage.strRecipe.length > 0){
        strRealComments = [NSString stringWithFormat:@"%@ RECIPE -> www.yummigram.com/recipeid\n%@", wallImage.strRecipe, wallImage.strSelfComments];
    }else{
        strRealComments = [NSString stringWithFormat:@"%@\nShared via Yummigram -> www.yummigram.com", wallImage.strSelfComments];
    }
    
    NSURL *imageURL = [NSURL URLWithString:wallImage.image];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    UIImage *image = [UIImage imageWithData:imageData];
    
    SLComposeViewController *composeController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    [composeController setInitialText:strRealComments];
    [composeController addImage:image];
    
    [self presentViewController:composeController animated:YES completion:nil];
    
    
    SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
        if (result == SLComposeViewControllerResultCancelled) {
            [SVProgressHUD showSuccessWithStatus:@"Sharing photo has been cancelled."];
        } else
        {
            [SVProgressHUD showSuccessWithStatus:@"This photo has been shared successfully."];
        }
        
    };
    
    composeController.completionHandler = myBlock;
}

- (void) onTagButtonClick:(id) sender{
    UIButton *btnTag = (UIButton *)sender;
    
    TagViewController *tagVC = (TagViewController *)[self.storyboard instantiateViewControllerWithIdentifier:TAG_VIEW_CONTROLLER];
    
    tagVC.strTag = btnTag.titleLabel.text;
    
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:tagVC];
    
    navCtrl.navigationBar.hidden = YES;
    
    [self.navigationController presentViewController:navCtrl animated:YES completion:nil];
}

- (void) onViewRecipeClick:(id) sender{
    UIView *senderView = (UIView *)sender;
    
    NSArray *arrSegment = [senderView.accessibilityIdentifier componentsSeparatedByString:@":"];
    
    NSString *strTableType = [arrSegment objectAtIndex:0];
    NSInteger nIdx = [[arrSegment objectAtIndex:1] integerValue];
    
    WallImage *wallImage = nil;
    
    if([strTableType isEqualToString:STRING_ORIGIN_TABLE])
        wallImage = [self.arrCurData objectAtIndex:nIdx];
    else
        wallImage = [self.arrFilteredData objectAtIndex:nIdx];
    
    RecipeDetailViewController *detailViewCtrl = (RecipeDetailViewController *)[self.storyboard instantiateViewControllerWithIdentifier:RECIPE_DETAIL_VIEW_CONTROLLER];
    detailViewCtrl.wallImage = wallImage;
    
    
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:detailViewCtrl];
    
    navCtrl.navigationBar.hidden = YES;
    
    [self.navigationController presentViewController:navCtrl animated:YES completion:nil];
}

- (void) onOtherProfile:(id) sender{
    UIView *senderView = (UIView *)sender;
    
    NSArray *arrComponents = [senderView.accessibilityIdentifier componentsSeparatedByString:@":"];
    
    NSString *strTableType = [arrComponents objectAtIndex:0];
    NSInteger nIdx = [[arrComponents objectAtIndex:1] integerValue];
    
    WallImage *wallImage = nil;
    
    if([strTableType isEqualToString:STRING_ORIGIN_TABLE]){
        wallImage = [self.arrCurData objectAtIndex:nIdx];
    }else{
        wallImage = [self.arrFilteredData objectAtIndex:nIdx];
    }
    
    ProfileViewController *profileViewCtrl = (ProfileViewController *)[self.storyboard instantiateViewControllerWithIdentifier:PROFILE_VIEW_CONTROLLER];
    
    profileViewCtrl.strUserObjID = wallImage.strUserObjId;
    
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:profileViewCtrl];
    
    navCtrl.navigationBar.hidden = YES;
    
    [self.navigationController presentViewController:navCtrl animated:YES completion:nil];
    
}

- (void) onLikeClick:(id) sender{
    UIView *senderView = (UIView *)sender;
    
    NSArray *arrSegment = [senderView.accessibilityIdentifier componentsSeparatedByString:@":"];
    
    NSString *strTableType = [arrSegment objectAtIndex:0];
    NSInteger nIdx = [[arrSegment objectAtIndex:1] integerValue];
    
    WallImage *wallImage = nil;
    
    if([strTableType isEqualToString:STRING_ORIGIN_TABLE])
        wallImage = [self.arrCurData objectAtIndex:nIdx];
    else
        wallImage = [self.arrFilteredData objectAtIndex:nIdx];
    
    PFObject *pfObj = [[DataStore instance].wallImagePFObjectMap objectForKey:wallImage.strImageObjId];
    
    wallImage.liked = !wallImage.liked;
    
    if(wallImage.liked){
        [pfObj addUniqueObject:g_myInfo.strUserObjID forKey:pKeyLikes];
        wallImage.nNumberLikes ++;
        
        [AppDelegate postNotifyWithImage:wallImage notificationType:notifyLiked];
        
    }else{
        [pfObj removeObject:g_myInfo.strUserObjID forKey:pKeyLikes];
        wallImage.nNumberLikes --;
    }
    
    [pfObj saveInBackground];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:N_ImageDataChanged object:nil];
}

- (void) onCommentClick:(id) sender{
    UIView *senderView = (UIView *)sender;
    
    NSArray *arrSegment = [senderView.accessibilityIdentifier componentsSeparatedByString:@":"];
    
    NSString *strTableType = [arrSegment objectAtIndex:0];
    NSInteger nIdx = [[arrSegment objectAtIndex:1] integerValue];
    
    WallImage *wallImage = nil;
    
    if([strTableType isEqualToString:STRING_ORIGIN_TABLE])
        wallImage = [self.arrCurData objectAtIndex:nIdx];
    else
        wallImage = [self.arrFilteredData objectAtIndex:nIdx];
    
    PostCommentViewController *commentViewCtrl = (PostCommentViewController *)[self.storyboard instantiateViewControllerWithIdentifier:POST_COMMENT_VIEW_CONTROLLER];
    
    commentViewCtrl.wallImage = wallImage;
    
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:commentViewCtrl];
    
    navCtrl.navigationBar.hidden = YES;
    
    [self.navigationController presentViewController:navCtrl animated:YES completion:nil];
}

- (void) onFavoriteClick:(id) sender{
    UIView *senderView = (UIView *)sender;
    
    NSArray *arrSegment = [senderView.accessibilityIdentifier componentsSeparatedByString:@":"];
    
    NSString *strTableType = [arrSegment objectAtIndex:0];
    NSInteger nIdx = [[arrSegment objectAtIndex:1] integerValue];
    
    WallImage *wallImage = nil;
    
    if([strTableType isEqualToString:STRING_ORIGIN_TABLE])
        wallImage = [self.arrCurData objectAtIndex:nIdx];
    else
        wallImage = [self.arrFilteredData objectAtIndex:nIdx];
    
    PFUser *currentUser = [PFUser currentUser];
    
    wallImage.favorited = !wallImage.favorited;
    
    if(wallImage.favorited){
        [g_myInfo.arrFavorites addObject:wallImage.strImageObjId];
        
        [currentUser addUniqueObject:wallImage.strImageObjId forKey:pKeyFavorites];
        [AppDelegate postNotifyWithImage:wallImage notificationType:notifyAddFavorite];
    }else{
        [g_myInfo.arrFavorites removeObject:wallImage.strImageObjId];
        
        [currentUser removeObject:wallImage.strImageObjId forKey:pKeyFavorites];
    }
    
    [currentUser saveInBackground];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:N_ImageDataChanged object:nil];
}

- (void) onFollow:(id) sender{
    UIButton *btnFollow = (UIButton *)sender;
    
    int nIdx = btnFollow.accessibilityIdentifier.intValue;
    NSString *strTitle = btnFollow.currentTitle;
    
    WallImage *wallImage = [self.arrCurData objectAtIndex:nIdx];
    
    if([strTitle isEqualToString:@"Follow User"]){
        UserInfo *otherUserInfo = [[DataStore instance].userInfoMap objectForKey:wallImage.strUserObjId];
        
        [otherUserInfo.arrFollower addObject:g_myInfo.strUserObjID];
        
        PFUser   *myselfPFUser  = [[DataStore instance].userInfoPFObjectMap objectForKey:g_myInfo.strUserObjID];
        UserInfo *myselfUserInfo = [[DataStore instance].userInfoMap objectForKey:g_myInfo.strUserObjID];
        
        [myselfUserInfo.arrFollowing addObject:wallImage.strUserObjId];
        [g_myInfo.arrFollowing addObject:wallImage.strUserObjId];
        
        myselfPFUser[pKeyFollowing] = myselfUserInfo.arrFollowing;
        
        [myselfPFUser saveInBackground];
        
    }else{
        
        PFUser   *myselfPFUser   = [[DataStore instance].userInfoPFObjectMap objectForKey:g_myInfo.strUserObjID];
        UserInfo *myselfUserInfo = [[DataStore instance].userInfoMap objectForKey:g_myInfo.strUserObjID];
        
        [myselfUserInfo.arrFollowing removeObject:wallImage.strUserObjId];
        [g_myInfo.arrFollowing removeObject:wallImage.strUserObjId];
        
        myselfPFUser[pKeyFollowing] = myselfUserInfo.arrFollowing;
        
        [myselfPFUser saveInBackground];
        
        UserInfo *otherUserInfo = [[DataStore instance].userInfoMap objectForKey:wallImage.strUserObjId];
        
        [otherUserInfo.arrFollower removeObject:g_myInfo.strUserObjID];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:N_ImageDataChanged object:nil];
}

- (void)imageViewTapped:(UIGestureRecognizer *)gestureRecognizer {
    UIView *view = [gestureRecognizer view];
    
    if(view.tag == 1){
        [self onOtherProfile:view];
    }else{
        NSArray *arrSegment = [view.accessibilityIdentifier componentsSeparatedByString:@":"];
        
        NSString *strTableType = [arrSegment objectAtIndex:0];
        NSInteger nIdx = [[arrSegment objectAtIndex:1] integerValue];
        
        WallImage *wallImage = nil;
        
        if([strTableType isEqualToString:STRING_ORIGIN_TABLE])
            wallImage = [self.arrCurData objectAtIndex:nIdx];
        else
            wallImage = [self.arrFilteredData objectAtIndex:nIdx];
        
        if(wallImage.strRecipe.length > 0)
            [self onViewRecipeClick:view];
        else
            [self onCommentClick:view];

    }
    
}

- (void) loadNextData{
    if(self.isSearching){
        [AppDelegate getWallImageForSearchOfFavorite:self searchText:self.searchBar.text limit:3];
    }else{
        if(self.isGridView)
            [AppDelegate getWallImagesForFavorite:self limit:LIMIT_NUMBER_GRID];
        else
            [AppDelegate getWallImagesForFavorite:self limit:LIMIT_NUMBER_LIST];
    }
}

#pragma mark NIAttributedLabelDelegate

- (void)attributedLabel:(NIAttributedLabel *)attributedLabel didSelectTextCheckingResult:(NSTextCheckingResult *)result atPoint:(CGPoint)point
{
    NSString *strTag = [result.URL absoluteString];
    
    TagViewController *tagVC = (TagViewController *)[self.storyboard instantiateViewControllerWithIdentifier:TAG_VIEW_CONTROLLER];
    
    tagVC.strTag = strTag;
    
    [self.navigationController pushViewController:tagVC animated:YES];
}


#pragma mark - Collection view data source and delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(self.arrCurData.count > 0){
        self.favoriteCollectionView.backgroundView = nil;
    }
    else{
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"No data is currently available. Please pull down to refresh.";
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
        [messageLabel sizeToFit];
        
        self.favoriteCollectionView.backgroundView = messageLabel;
    }
    
    return self.arrCurData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:COLLECTION_CELL forIndexPath:indexPath];
    WallImage *wallImage = [self.arrCurData objectAtIndex:indexPath.row];
    
    
    
    UIImageView *tmpImageView = [[UIImageView alloc] init];
    
    [tmpImageView setImageWithURL:[NSURL URLWithString:wallImage.image] placeholderImage:nil];

    
    cell.backgroundView = tmpImageView;
    
    UIButton *btnDrop = (UIButton *)[cell.contentView viewWithTag:1];
    
    [btnDrop setHidden:YES];
    
   
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CollectionHeaderCell" forIndexPath:indexPath];
        
        self.btnGridViewForCollection = (UIButton *)[headerView viewWithTag:1];
        self.btnListViewForCollection = (UIButton *)[headerView viewWithTag:2];
        self.imgvGridViewForCollection = (UIImageView *)[headerView viewWithTag:3];
        self.imgvListViewForCollection = (UIImageView *)[headerView viewWithTag:4];
        
        [self.btnGridViewForCollection   addTarget:self action:@selector(onGridView:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnListViewForCollection   addTarget:self action:@selector(onListView:) forControlEvents:UIControlEventTouchUpInside];
        
        reusableview = headerView;
    }else if(kind == UICollectionElementKindSectionFooter){
        UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"CollectionFooterCell" forIndexPath:indexPath];
        
        self.indicatorFooterOfCollection = (UIActivityIndicatorView *)[footerView viewWithTag:1];
        
        [self.indicatorFooterOfCollection stopAnimating];
        
        reusableview = footerView;
    }
    
    return reusableview;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    WallImage *wallImage = [self.arrCurData objectAtIndex:indexPath.row];
    
    PostCommentViewController *commentViewCtrl = (PostCommentViewController *)[self.storyboard instantiateViewControllerWithIdentifier:POST_COMMENT_VIEW_CONTROLLER];
    
    commentViewCtrl.wallImage = wallImage;
    
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:commentViewCtrl];
    
    navCtrl.navigationBar.hidden = YES;
    
    [self.navigationController presentViewController:navCtrl animated:YES completion:nil];
    
    
    return YES;
}

#pragma mark - UISearchBar Delegate Methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.arrFilteredData removeAllObjects];
    
    NSString *strSearch = searchBar.text;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF.strSelfComments contains[c] %@) OR (SELF.strRecipe contains[c] %@)", strSearch, strSearch];
    
    self.arrFilteredData = [NSMutableArray arrayWithArray:[self.arrCurData filteredArrayUsingPredicate:predicate]];
    
    [DataStore instance].wallImagesForSearch = [self.arrFilteredData mutableCopy];
    
    SearchResultViewController *searchVC = (SearchResultViewController *)[self.storyboard instantiateViewControllerWithIdentifier:SEARCH_RESULT_VIEW_CONTROLLER];
    
    searchVC.strSearch = strSearch;
    searchVC.nMode = 2;
    
    [self.navigationController pushViewController:searchVC animated:YES];

    self.searchDisplayController.active = NO;
}

#pragma mark -
#pragma mark PullToRefresh implementation
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    NSInteger y = scrollView.contentOffset.y;
    
    if (maximumOffset < y && ![self.indicatorFooter isAnimating]) {
        [self loadNextData];
        [self.indicatorFooter startAnimating];
        [self.indicatorFooterOfCollection startAnimating];
        return;
    }

    
    [self pullToRefreshView:self.pullToRefreshView shouldHandleScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self pullToRefreshView:self.pullToRefreshView shouldHandleScrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)pullToRefreshShouldLoadData:(SuccontPullToRefreshView *)aPullToRefresh {
    //    aPullToRefresh.loading = YES;
    [self performSelector:@selector(refreshImageWall:) withObject:nil afterDelay:0.0];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    
    NSInteger num = 0;
    
    if (self.isSearching)
    {
        num = [self.arrFilteredData count];
    }else{
        num = self.arrCurData.count;
    }
    
    if (num > 0) {
        
        self.tblFavorite.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        
        self.tblFavorite.backgroundView = nil;
        
        return num + 1;
        
    } else {
        
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"No data is currently available. Please pull down to refresh.";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
        [messageLabel sizeToFit];
        
        self.tblFavorite.backgroundView = messageLabel;
        self.tblFavorite.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:VIEW_MODE_CELL forIndexPath:indexPath];
        
        self.btnGridViewForTableView = (UIButton *)[cell.contentView viewWithTag:1];
        self.btnListViewForTableView = (UIButton *)[cell.contentView viewWithTag:2];
        self.imgvGridViewForTableView = (UIImageView *)[cell.contentView viewWithTag:3];
        self.imgvListViewForTableView = (UIImageView *)[cell.contentView viewWithTag:4];
        
        [self.btnGridViewForTableView   addTarget:self action:@selector(onGridView:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnListViewForTableView   addTarget:self action:@selector(onListView:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    
    NSInteger nIdx = indexPath.section - 1;
    
    WallImage       *wallImage = nil;
    NSString        *strTableType = STRING_ORIGIN_TABLE;
    
    if(self.isSearching){
        wallImage = [self.arrFilteredData objectAtIndex:nIdx];
        strTableType = STRING_SEARCH_TABLE;
    }else{
        wallImage = [self.arrCurData objectAtIndex:nIdx];
    }
    
    UITableViewCell *cell = [self.tblFavorite dequeueReusableCellWithIdentifier:WALL_IMAGE_CELL forIndexPath:indexPath];
    
    // Configure the cell...
    UIImageView *imgViewUserPhoto = (UIImageView *)[cell.contentView viewWithTag:1];
    UIButton    *btnFullName      = (UIButton *)[cell.contentView viewWithTag:2];
    UILabel     *lblTime          = (UILabel *)[cell.contentView viewWithTag:3];
    UIButton    *btnRecipe        = (UIButton *)[cell.contentView viewWithTag:4];
    UIButton    *btnDrop          = (UIButton *)[cell.contentView viewWithTag:5];
    NIAttributedLabel     *lblSelfComment   = (NIAttributedLabel *)[cell.contentView viewWithTag:6];
    UIImageView *imgViewWall      = (UIImageView *)[cell.contentView viewWithTag:7];

    UIButton    *btnRecipRequest  = (UIButton *)[cell.contentView viewWithTag:9];
    UIButton    *btnShareFacebook = (UIButton *)[cell.contentView viewWithTag:10];
    
    UIButton    *btnLikes         = (UIButton *)[cell.contentView viewWithTag:11];
    UIButton    *btnComments      = (UIButton *)[cell.contentView viewWithTag:12];
    UIButton    *btnFavorite      = (UIButton *)[cell.contentView viewWithTag:13];
    
    UIImageView *imgViewLike      = (UIImageView *)[cell.contentView viewWithTag:15];
    UIImageView *imgViewComment   = (UIImageView *)[cell.contentView viewWithTag:16];
    UIImageView *imgViewFavorite  = (UIImageView *)[cell.contentView viewWithTag:17];
    
    UILabel     *lblLike          = (UILabel *)[cell.contentView viewWithTag:18];
    UILabel     *lblComment       = (UILabel *)[cell.contentView viewWithTag:19];
    
    UserInfo *userInfo = [AppDelegate getUserInfoFrom:wallImage.strUserObjId];
    
    imgViewUserPhoto.image = userInfo.imgPhoto;
    [btnFullName setTitle:wallImage.strUserFullName forState:UIControlStateNormal];
    lblTime.text = [NSString stringWithFormat:@"%@ in %@, %@", [AppDelegate getTime:wallImage.createdDate], wallImage.strCity, wallImage.strCountry];
    
    if(wallImage.strRecipe.length > 0){
        [btnRecipe setHidden:NO];
        [btnRecipRequest setHidden:YES];
    }else{
        [btnRecipe setHidden:YES];
        
        if([wallImage.strUserObjId isEqualToString:g_myInfo.strUserObjID]){
            [btnRecipRequest setHidden:YES];
        }else{
            [btnRecipRequest setHidden:NO];
            
            if([[NSUserDefaults standardUserDefaults] boolForKey:wallImage.strImageObjId]){
                [btnRecipRequest setBackgroundImage:[UIImage imageNamed:@"bg_btn_red"] forState:UIControlStateNormal];
                [btnRecipRequest setTitle:@"RECIPE REQUESTED" forState:UIControlStateNormal];
                [btnRecipRequest setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }else{
                [btnRecipRequest setBackgroundImage:nil forState:UIControlStateNormal];
                [btnRecipRequest setTitle:@"RECIPE REQUEST" forState:UIControlStateNormal];
                [btnRecipRequest setTitleColor:[UIColor colorWithRed:(151/255.0) green:(11/255.0) blue:(55/255.0) alpha:1] forState:UIControlStateNormal];
                
                btnRecipRequest.layer.masksToBounds = YES;
                btnRecipRequest.layer.borderWidth = 1;
                btnRecipRequest.layer.borderColor = [[UIColor colorWithRed:(151/255.0) green:(11/255.0) blue:(55/255.0) alpha:1] CGColor];
            }
        }
    }
    
    lblSelfComment.delegate = self;
    lblSelfComment.text = wallImage.strSelfComments;
    lblSelfComment.linkColor = [UIColor colorWithRed:(133/255.0) green:(18/255.0) blue:(57/255.0) alpha:1];
    
    NSString *strLowerCaseSelfComment = [wallImage.strSelfComments lowercaseString];
    
    for(NSString *strTag in wallImage.arrTag){
        NSRange range = [strLowerCaseSelfComment rangeOfString:strTag];
        [lblSelfComment addLink:[NSURL URLWithString:strTag] range:range];
    }

    [imgViewWall setImageWithURL:[NSURL URLWithString:wallImage.image] placeholderImage:nil];
    
    [lblLike setText:@(wallImage.nNumberLikes).stringValue];
    [lblComment setText:@(wallImage.arrComments.count).stringValue];

    
    if(wallImage.liked)
        [imgViewLike setImage:[UIImage imageNamed:@"post_icons_heart_fill"]];
    else
        [imgViewLike setImage:[UIImage imageNamed:@"post_icons_heart"]];
    
    if(wallImage.commented)
        [imgViewComment setImage:[UIImage imageNamed:@"post_icons_comment_fill"]];
    else
        [imgViewComment setImage:[UIImage imageNamed:@"post_icons_comment"]];
    
    if(wallImage.favorited)
        [imgViewFavorite setImage:[UIImage imageNamed:@"post_icons_star_fill"]];
    else
        [imgViewFavorite setImage:[UIImage imageNamed:@"post_icons_star"]];
    
    [btnDrop setHidden:YES];
    
    imgViewUserPhoto.accessibilityIdentifier = [NSString stringWithFormat:@"%@:%@", strTableType, @(nIdx).stringValue];
    imgViewWall.accessibilityIdentifier      = [NSString stringWithFormat:@"%@:%@", strTableType, @(nIdx).stringValue];
    btnFullName.accessibilityIdentifier      = [NSString stringWithFormat:@"%@:%@", strTableType, @(nIdx).stringValue];
    btnRecipe.accessibilityIdentifier        = [NSString stringWithFormat:@"%@:%@", strTableType, @(nIdx).stringValue];
    btnDrop.accessibilityIdentifier          = [NSString stringWithFormat:@"%@:%@", strTableType, @(nIdx).stringValue];
    btnLikes.accessibilityIdentifier         = [NSString stringWithFormat:@"%@:%@", strTableType, @(nIdx).stringValue];
    btnComments.accessibilityIdentifier      = [NSString stringWithFormat:@"%@:%@", strTableType, @(nIdx).stringValue];
    btnFavorite.accessibilityIdentifier      = [NSString stringWithFormat:@"%@:%@", strTableType, @(nIdx).stringValue];
    btnRecipRequest.accessibilityIdentifier  = [NSString stringWithFormat:@"%@:%@", strTableType, @(nIdx).stringValue];
    btnShareFacebook.accessibilityIdentifier = [NSString stringWithFormat:@"%@:%@", strTableType, @(nIdx).stringValue];
    
    [btnFullName   addTarget:self action:@selector(onOtherProfile:) forControlEvents:UIControlEventTouchUpInside];
    [btnRecipe     addTarget:self action:@selector(onViewRecipeClick:) forControlEvents:UIControlEventTouchUpInside];
    //    [btnDrop       addTarget:self action:@selector(onDropMenu:) forControlEvents:UIControlEventTouchUpInside];
    [btnLikes      addTarget:self action:@selector(onLikeClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnComments   addTarget:self action:@selector(onCommentClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnFavorite   addTarget:self action:@selector(onFavoriteClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnRecipRequest   addTarget:self action:@selector(onRequestRecipe:) forControlEvents:UIControlEventTouchUpInside];
    [btnShareFacebook   addTarget:self action:@selector(onShareFacebook:) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    
    [imgViewUserPhoto addGestureRecognizer:singleTap];
    [imgViewUserPhoto setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer *singleOtherTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped:)];
    singleOtherTap.numberOfTapsRequired = 1;
    singleOtherTap.numberOfTouchesRequired = 1;
    
    [imgViewWall addGestureRecognizer:singleOtherTap];
    [imgViewWall setUserInteractionEnabled:YES];
    
    return cell;

}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat height = 0;
    
    if(indexPath.section == 0){
        return 44;
    }
    
    NSInteger nIdx = indexPath.section - 1;
    
    WallImage       *wallImage = nil;
    
    if(self.isSearching){
        wallImage = [self.arrFilteredData objectAtIndex:nIdx];
    }else{
        wallImage = [self.arrCurData objectAtIndex:nIdx];
    }
    
    UITableViewCell *cell = [self.tblFavorite dequeueReusableCellWithIdentifier:WALL_IMAGE_CELL];
    
    UILabel     *lblSelfComment   = (UILabel *)[cell.contentView viewWithTag:6];
    
    CGFloat heightX = [AppDelegate getRealHeightFrom:lblSelfComment.frame.size.width content:wallImage.strSelfComments fontname:lblSelfComment.font.fontName fontsize:lblSelfComment.font.pointSize];
    
    if(wallImage.strSelfComments.length == 0) heightX = 0;
    
    height = 435 + heightX + g_moreHeight + g_dH;
    
    return height;

}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
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
