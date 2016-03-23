//
//  ProfileViewController.m
//  yummigram
//
//  Created by User on 5/11/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "ProfileViewController.h"
#import "RecipeDetailViewController.h"
#import "PostCommentViewController.h"
#import "MainTabBarController.h"
#import "NewChatViewController.h"
#import "EditCommentViewController.h"
#import "EditRecipeViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <Social/Social.h>
#import "TagViewController.h"

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIImageView *imgvProfile;
@property (weak, nonatomic) IBOutlet UIButton *btnFullName;
@property (weak, nonatomic) IBOutlet UIButton *btnPhotoNums;
@property (weak, nonatomic) IBOutlet UIButton *btnFollowerNums;
@property (weak, nonatomic) IBOutlet UIButton *btnFollowingNums;

@property (weak, nonatomic) IBOutlet UITableView *tblProfile;
@property (weak, nonatomic) IBOutlet UICollectionView *myCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *btnSendMessage;
@property (weak, nonatomic) IBOutlet UIButton *btnFollow;
@property (weak, nonatomic) IBOutlet UIButton *btnSetting;

@property (nonatomic, strong) UIActivityIndicatorView  *indicatorFooter;
@property (nonatomic, strong) UIActivityIndicatorView  *indicatorFooterOfCollection;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mUserNameTopConstraint;



@property (nonatomic) BOOL isSelf;
@property (nonatomic) BOOL isFollowingThis;
@property (nonatomic) BOOL isGridView;
@property (nonatomic) ViewMode viewMode;

@property (nonatomic) NSMutableArray *arrCurData;

@property (weak, nonatomic) UIButton *btnGridViewForCollection;
@property (weak, nonatomic) UIButton *btnListViewForCollection;
@property (weak, nonatomic) UIButton *btnGridViewForTableView;
@property (weak, nonatomic) UIButton *btnListViewForTableView;

@property (weak, nonatomic) UIImageView *imgvGridViewForCollection;
@property (weak, nonatomic) UIImageView *imgvListViewForCollection;
@property (weak, nonatomic) UIImageView *imgvGridViewForTableView;
@property (weak, nonatomic) UIImageView *imgvListViewForTableView;

@property (nonatomic) UserInfo   *selfUserInfo;

@property (nonatomic) NSInteger nSelIndex;
@end

@implementation ProfileViewController
- (IBAction)onPhotoNumButton:(id)sender {
    [self.btnPhotoNums setBackgroundImage:[UIImage imageNamed:@"three_tabs_1_active"] forState:UIControlStateNormal];
    [self.btnFollowerNums setBackgroundImage:[UIImage imageNamed:@"three_tabs_2"] forState:UIControlStateNormal];
    [self.btnFollowingNums setBackgroundImage:[UIImage imageNamed:@"three_tabs_3"] forState:UIControlStateNormal];
    
    self.viewMode = viewPhoto;
    [self onGridView:nil];

    [self.tblProfile reloadData];
}

- (IBAction)onFollowerNumButton:(id)sender {
    [self.btnPhotoNums setBackgroundImage:[UIImage imageNamed:@"three_tabs_1"] forState:UIControlStateNormal];
    [self.btnFollowerNums setBackgroundImage:[UIImage imageNamed:@"three_tabs_2_active"] forState:UIControlStateNormal];
    [self.btnFollowingNums setBackgroundImage:[UIImage imageNamed:@"three_tabs_3"] forState:UIControlStateNormal];
    
    [self onListView:nil];
    self.viewMode = viewFollower;
    [self.myCollectionView setHidden:YES];
    
    [self.tblProfile reloadData];
}
- (IBAction)onFollowingNumButton:(id)sender {
    [self.btnPhotoNums setBackgroundImage:[UIImage imageNamed:@"three_tabs_1"] forState:UIControlStateNormal];
    [self.btnFollowerNums setBackgroundImage:[UIImage imageNamed:@"three_tabs_2"] forState:UIControlStateNormal];
    [self.btnFollowingNums setBackgroundImage:[UIImage imageNamed:@"three_tabs_3_active"] forState:UIControlStateNormal];
    
    [self onListView:nil];
    self.viewMode = viewFollowing;
    [self.myCollectionView setHidden:YES];
    
    [self.tblProfile reloadData];
}
- (void) onGridView:(id)sender {
    [self.imgvGridViewForCollection setImage:[UIImage imageNamed:@"photos_table_view_active"]];
    [self.imgvListViewForCollection setImage:[UIImage imageNamed:@"photos_list_view"]];
    
    [self.myCollectionView setHidden:NO];
    [self.tblProfile setHidden:YES];
    
    self.isGridView = YES;
}

- (void) onListView:(id)sender {
    [self.imgvGridViewForTableView setImage:[UIImage imageNamed:@"photos_table_view"]];
    [self.imgvListViewForTableView setImage:[UIImage imageNamed:@"photos_list_view_active"]];
    
    [self.myCollectionView setHidden:YES];
    [self.tblProfile setHidden:NO];
    
    self.isGridView = NO;
}

- (IBAction)onSetting:(id)sender {
   UIViewController *settingViewCtrl = (UIViewController *)[self.storyboard instantiateViewControllerWithIdentifier:SETTING_VIEW_CONTROLLER];
    
    [self.navigationController pushViewController:settingViewCtrl animated:YES];
}

- (IBAction)onBack:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSendMessage:(id)sender {
    NewChatViewController *newChatViewCtrl = (NewChatViewController *)[self.storyboard instantiateViewControllerWithIdentifier:NEW_CHAT_VIEW_CONTROLLER];
    
    newChatViewCtrl.strOtherUserObjId = self.strUserObjID;
    
    [self.navigationController pushViewController:newChatViewCtrl animated:YES];
}

- (IBAction)onFollow:(id)sender {
    self.isFollowingThis = !self.isFollowingThis;
    
    UserInfo *myselfUserInfo = [[DataStore instance].userInfoMap objectForKey:g_myInfo.strUserObjID];
    UserInfo *otherUserInfo  = [[DataStore instance].userInfoMap objectForKey:self.strUserObjID];
    
    if(self.isFollowingThis){
        [self.btnFollow setBackgroundImage:[UIImage imageNamed:@"follow_button_active"] forState:UIControlStateNormal];
        [self.btnFollow setTitle:@"FOLLOWING" forState:UIControlStateNormal];
        
        [myselfUserInfo.arrFollowing addObject:self.strUserObjID];
        [otherUserInfo.arrFollower addObject:g_myInfo.strUserObjID];
        
        PFUser *otherPFUser = [[DataStore instance].userInfoPFObjectMap objectForKey:self.strUserObjID];
        
        BOOL isNotifyFollow = [otherPFUser[pKeyNotifyFollow] boolValue];
        
        if(!isNotifyFollow) return;
        
        PFObject *notifyObject = [PFObject objectWithClassName:pClassNotifyPost];
        
        notifyObject[pKeyUserObjId] = self.strUserObjID;
        notifyObject[pKeyNotifyType] = [[NSNumber alloc] initWithInteger:notifyFollowing];
        notifyObject[pKeyOtherUserObjId] = g_myInfo.strUserObjID;
        notifyObject[pKeyImageObjId] = @"";
        
        [notifyObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(succeeded){
                // Build the actual push notification target query
                PFQuery *query = [PFInstallation query];
                
                [query whereKey:pKeyUserObjId equalTo:self.strUserObjID];
                
                NSString *strFullName = [NSString stringWithFormat:@"%@ %@", g_myInfo.strUserFirstName, g_myInfo.strUserLastName];
                NSString *strAlert = [NSString stringWithFormat:@"%@ started following you", strFullName];;
                
                NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                      PN_NOTIFY,                                        pnMode,
                                      PN_INCREMENT,                                     pnBadge,
                                      strAlert,                                         pnAlert,
                                      [[NSNumber alloc] initWithInteger:notifyFollowing],    pnNotifyType,
                                      @"",                                              pnImageId,
                                      g_myInfo.strUserObjID,                            pnUserObjId,
                                      @"Notify_1.wav",                                  @"sound",
                                      nil];
                
                // Send the notification.
                PFPush *push = [[PFPush alloc] init];
                
                [push setQuery:query];
                [push setData:data];
                
                [push sendPushInBackground];
            }
        }];
        
    }else{
        [self.btnFollow setBackgroundImage:[UIImage imageNamed:@"follow_button"] forState:UIControlStateNormal];
        [self.btnFollow setTitle:@"FOLLOW" forState:UIControlStateNormal];
        
        self.btnFollow.layer.masksToBounds = YES;
        self.btnFollow.layer.borderWidth = 1;
        self.btnFollow.layer.borderColor = [[UIColor colorWithRed:(101/255.0) green:(177/255.0) blue:(69/255.0) alpha:1] CGColor];

        [myselfUserInfo.arrFollowing removeObject:self.strUserObjID];
        [otherUserInfo.arrFollower removeObject:g_myInfo.strUserObjID];
    }
    
    PFObject *pfObjFollowMySelf = [AppDelegate getFollowPFObjectFrom:g_myInfo.strFollowObjID];
    
    pfObjFollowMySelf[pKeyFollowing] = myselfUserInfo.arrFollowing;
    
    [pfObjFollowMySelf saveInBackground];
    
    PFObject *pfObjFollowOther  = [AppDelegate getFollowPFObjectFrom:otherUserInfo.strFollowObjID];
    
    pfObjFollowOther[pKeyFollower] = otherUserInfo.arrFollower;
    
    [pfObjFollowOther saveInBackground];
    
    [self initUI];
    [self loadData];
}

- (void) imageDataChanged:(NSNotification *)notification
{
    [self.tblProfile reloadData];
    [self.myCollectionView reloadData];
}

- (void) onChangePhoto:(UIGestureRecognizer *)gestureRecognizer {
    if(!self.isSelf) return;
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void) loadData{
    
    [self.arrCurData removeAllObjects];
    
    for(NSString *strObj in self.selfUserInfo.arrWallImages){
        WallImage *wallImage = [[DataStore instance].wallImageMap objectForKey:strObj];
        
        if(wallImage == nil) continue;
        
        [self.arrCurData addObject:wallImage];
    }
    
    [DataStore instance].wallImagesForMyOwn = [[NSMutableArray alloc] initWithArray:[self.arrCurData sortedArrayUsingComparator:^NSComparisonResult(WallImage *obj1, WallImage *obj2) {
        
        return [obj2.createdDate compare:obj1.createdDate];
    }]];

    self.arrCurData = [[DataStore instance].wallImagesForMyOwn mutableCopy];
    
    [self.tblProfile reloadData];
    [self.myCollectionView reloadData];
    
    [self.indicatorFooter stopAnimating];
    [self.indicatorFooterOfCollection stopAnimating];
}

- (void) initUI{
    
    UserInfo *userInfo = [[DataStore instance].userInfoMap objectForKey:self.strUserObjID];
    
    NSString *strFullName  = [NSString stringWithFormat:@"%@ %@", userInfo.strUserFirstName, userInfo.strUserLastName];
    NSString *strPhotos    = [NSString stringWithFormat:@"%ld Photos", (unsigned long)userInfo.arrWallImages.count];
    NSString *strFollowers = [NSString stringWithFormat:@"%ld Followers", (unsigned long)userInfo.arrFollower.count];
    NSString *strFollowing = [NSString stringWithFormat:@"%ld Following", (unsigned long)userInfo.arrFollowing.count];
    
    self.imgvProfile.image = userInfo.imgPhoto;
    [self.btnFullName setTitle:strFullName forState:UIControlStateNormal];
    
    [self.btnPhotoNums setTitle:strPhotos forState:UIControlStateNormal];
    [self.btnFollowerNums setTitle:strFollowers forState:UIControlStateNormal];
    [self.btnFollowingNums setTitle:strFollowing forState:UIControlStateNormal];
    
    ////
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onChangePhoto:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    
    [self.imgvProfile addGestureRecognizer:singleTap];
    [self.imgvProfile setUserInteractionEnabled:YES];

}

- (void) onViewRecipeClick:(id) sender{
    UIView *senderView = (UIView *)sender;
    
    NSInteger nIdx = [senderView.accessibilityIdentifier integerValue];
    
    WallImage *wallImage = [self.arrCurData objectAtIndex:nIdx];
    RecipeDetailViewController *detailViewCtrl = (RecipeDetailViewController *)[self.storyboard instantiateViewControllerWithIdentifier:RECIPE_DETAIL_VIEW_CONTROLLER];

    detailViewCtrl.wallImage = wallImage;
    
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:detailViewCtrl];
    
    navCtrl.navigationBar.hidden = YES;
    
    [self.navigationController presentViewController:navCtrl animated:YES completion:nil];
}

- (void) onDropMenu:(id) sender{
    
    UIView *view = (UIView *)sender;
    
    NSInteger nIdx = [view.accessibilityIdentifier integerValue];
    
    self.nSelIndex = nIdx;
    
    WallImage *wallImage = [self.arrCurData objectAtIndex:nIdx];
    
    NSString *strTitleForRecipe = @"Edit Recipe";
    
    if(wallImage.strRecipe.length == 0) strTitleForRecipe = @"Add Recipe";
    
    NSArray *arrData = @[@"Edit Comments", strTitleForRecipe, @"Delete"];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    for (NSString *item in arrData) {
        [actionSheet addButtonWithTitle:item];
    }
    
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
    
    [actionSheet showInView:self.view];
    
}

- (void) onOtherProfile:(NSString *) strUserObjID{
    ProfileViewController *profileViewCtrl = (ProfileViewController *)[self.storyboard instantiateViewControllerWithIdentifier:PROFILE_VIEW_CONTROLLER];
    
    profileViewCtrl.strUserObjID = strUserObjID;
    
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:profileViewCtrl];
    
    navCtrl.navigationBar.hidden = YES;
    
    [self.navigationController presentViewController:navCtrl animated:YES completion:nil];
}

- (void) onLikeClick:(id) sender{
    UIView *senderView = (UIView *)sender;
    
    NSInteger nIdx = [senderView.accessibilityIdentifier integerValue];
    
    WallImage *wallImage = [self.arrCurData objectAtIndex:nIdx];
    
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
    
    NSInteger nIdx = [senderView.accessibilityIdentifier integerValue];
    
    WallImage *wallImage = [self.arrCurData objectAtIndex:nIdx];
    PostCommentViewController *commentViewCtrl = (PostCommentViewController *)[self.storyboard instantiateViewControllerWithIdentifier:POST_COMMENT_VIEW_CONTROLLER];
    
    commentViewCtrl.wallImage = wallImage;
    
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:commentViewCtrl];
    
    navCtrl.navigationBar.hidden = YES;
    
    [self.navigationController presentViewController:navCtrl animated:YES completion:nil];
}

- (void) onRequestRecipe:(id) sender{
    
    UIView *senderView = (UIView *)sender;
    
    NSInteger nIdx = [senderView.accessibilityIdentifier integerValue];
    
    WallImage *wallImage = [self.arrCurData objectAtIndex:nIdx];
    
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
    
    NSInteger nIdx = [senderView.accessibilityIdentifier integerValue];
    
    WallImage *wallImage = [self.arrCurData objectAtIndex:nIdx];
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

- (void) onFavoriteClick:(id) sender{
    UIView *senderView = (UIView *)sender;
    
    NSInteger nIdx = [senderView.accessibilityIdentifier integerValue];
    
    WallImage *wallImage = [self.arrCurData objectAtIndex:nIdx];
    
    wallImage.favorited = !wallImage.favorited;
    
    PFUser *currentUser = [PFUser currentUser];
    
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

- (void) onTagButtonClick:(id) sender{
    UIButton *btnTag = (UIButton *)sender;
    
    TagViewController *tagVC = (TagViewController *)[self.storyboard instantiateViewControllerWithIdentifier:TAG_VIEW_CONTROLLER];
    
    tagVC.strTag = btnTag.titleLabel.text;
    
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:tagVC];
    
    navCtrl.navigationBar.hidden = YES;
    
    [self.navigationController presentViewController:navCtrl animated:YES completion:nil];
}

- (void) viewWillAppear:(BOOL)animated{
    MainTabBarController *mainTabCtrl = (MainTabBarController *)g_tabController;
    
    [mainTabCtrl.view bringSubviewToFront:mainTabCtrl.imgvProfile];
    
    [self initUI];
    [self loadData];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tblProfile.delegate = self;
    self.tblProfile.dataSource = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imageDataChanged:)
                                                 name:N_ImageDataChanged
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(photoUpdated:)
                                                 name:N_PhotoUpdated
                                               object:nil];

    BOOL hiddened = NO;
    
    if(self.strUserObjID == nil || self.strUserObjID.length == 0){
        hiddened = YES;
        self.strUserObjID = g_myInfo.strUserObjID;
    }
    
    if([self.strUserObjID isEqualToString:g_myInfo.strUserObjID])
        self.isSelf = YES;
    else
        self.isSelf = NO;
    
    self.isFollowingThis = NO;
    
    [self.btnBack setHidden:hiddened];
    
    if(self.isSelf){
        [self.btnSendMessage setHidden:YES];
        [self.btnFollow setHidden:YES];
        
        g_otherInfo = g_myInfo;
        self.selfUserInfo = g_myInfo;
        
        self.mUserNameTopConstraint.constant = -10;
    }else{
        
        self.mUserNameTopConstraint.constant = 5;
        
        UserInfo *otherInfo = [AppDelegate getUserInfoFrom:self.strUserObjID];
        g_otherInfo = otherInfo;
        self.selfUserInfo = otherInfo;
        
        [[DataStore instance].wallImagesForMyOwn removeAllObjects];
        
        [AppDelegate getWallImagesForMyOwn:self limit:LIMIT_NUMBER_GRID];
        
        [self.btnSendMessage setHidden:NO];
        [self.btnFollow setHidden:NO];
        [self.btnSetting setHidden:YES];
        
        UserInfo *myInfo = [[DataStore instance].userInfoMap objectForKey:g_myInfo.strUserObjID];
        
        if([myInfo.arrFollowing containsObject:self.strUserObjID]){
            self.isFollowingThis = YES;
            
            [self.btnFollow setBackgroundImage:[UIImage imageNamed:@"follow_button_active"] forState:UIControlStateNormal];
            
            [self.btnFollow setTitle:@"FOLLOWING" forState:UIControlStateNormal];
            
        }else{
            [self.btnFollow setBackgroundImage:[UIImage imageNamed:@"follow_button"] forState:UIControlStateNormal];
            
            [self.btnFollow setTitle:@"FOLLOW" forState:UIControlStateNormal];
            
            [self.btnFollow setTitleColor:[UIColor colorWithRed:(101/255.0) green:(177/255.0) blue:(69/255.0) alpha:1] forState:UIControlStateNormal];
            
            self.btnFollow.layer.masksToBounds = YES;
            self.btnFollow.layer.borderWidth = 1;
            self.btnFollow.layer.borderColor = [[UIColor colorWithRed:(101/255.0) green:(177/255.0) blue:(69/255.0) alpha:1] CGColor];

        }
    }
    
    [self initializeRefreshControlForFooter];
    
    self.arrCurData = [[NSMutableArray alloc] init];
    self.viewMode = viewPhoto;
    self.isGridView = YES;
    [self.tblProfile setHidden:YES];
    
    [self loadData];
    [self initUI];
    [self setupCollectionView];
}

- (void) initializeRefreshControlForFooter{
    self.indicatorFooter = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tblProfile.frame), 44)];
    [self.indicatorFooter setColor:[UIColor blackColor]];
    [self.indicatorFooter stopAnimating];
    [self.tblProfile setTableFooterView:self.indicatorFooter];
}

- (void) didGetWallImageForMyOwn{
    [self loadData];
}

- (void) photoUpdated:(NSNotification *)notification
{
    [self loadData];
    [self initUI];
    [self setupCollectionView];
}

-(void)setupCollectionView {
    CGFloat width_CollectionCell = self.view.frame.size.width - 28;
    
    UICollectionViewFlowLayout *collectionFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [collectionFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [collectionFlowLayout setMinimumInteritemSpacing:10.0f];
    [collectionFlowLayout setMinimumLineSpacing:10.0f];
    [collectionFlowLayout setItemSize:CGSizeMake(width_CollectionCell / 2, width_CollectionCell / 2)];
    [collectionFlowLayout setHeaderReferenceSize:CGSizeMake(width_CollectionCell  + 6, 44)];
    
    [self.myCollectionView setPagingEnabled:YES];
    [self.myCollectionView setCollectionViewLayout:collectionFlowLayout];
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


- (void) editComment{
     EditCommentViewController *editCommentVC = (EditCommentViewController *)[self.storyboard instantiateViewControllerWithIdentifier:EDIT_COMMENT_VIEW_CONTROLLER];
    
    editCommentVC.wallImage = [self.arrCurData objectAtIndex:self.nSelIndex];
    [self presentViewController:editCommentVC animated:YES completion:nil];
    
}

- (void) editRecipe{
    EditRecipeViewController *editRecipeVC = (EditRecipeViewController *)[self.storyboard instantiateViewControllerWithIdentifier:EDIT_RECIPE_VIEW_CONTROLLER];
    
    editRecipeVC.wallImage = [self.arrCurData objectAtIndex:self.nSelIndex];
    [self presentViewController:editRecipeVC animated:YES completion:nil];
}

- (void) deleteWallImage{
    WallImage *wallImage = [self.arrCurData objectAtIndex:self.nSelIndex];
    NSString *strImageObjId = wallImage.strImageObjId;
    
    [g_myInfo.arrWallImages removeObject:strImageObjId];
    
    PFUser *currentUser = [PFUser currentUser];
    
    currentUser[pKeyWallImages] = g_myInfo.arrWallImages;
    
    [currentUser saveInBackground];
    
    [self.arrCurData removeObject:wallImage];
    [[DataStore instance].wallImagesForMyOwn removeObject:wallImage];
    [[DataStore instance].wallImagesForNewsFeed removeObject:wallImage];
    [[DataStore instance].wallImagesForRecipe removeObject:wallImage];
    [[DataStore instance].wallImagesForFavorites removeObject:wallImage];
    [[DataStore instance].wallImagesForCategory removeObject:wallImage];
    [[DataStore instance].wallImagesForTag removeObject:wallImage];
    
    PFObject *pfObj = [[DataStore instance].wallImagePFObjectMap objectForKey:strImageObjId];
    
    [pfObj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            [[DataStore instance].wallImagePFObjectMap removeObjectForKey:strImageObjId];
            
            PFQuery *commentQuery = [PFQuery queryWithClassName:pClassWallImageComments];
            [commentQuery orderByAscending:@"createdAt"];
            [commentQuery whereKey:pKeyImageObjId equalTo:strImageObjId];
            [commentQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                if (error) {
                    NSLog(@"Objects error: %@", error.localizedDescription);
                    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                } else {
                    
                    [PFObject deleteAll:objects];
                    
                    [[DataStore instance].wallImagePFObjectMap removeObjectForKey:strImageObjId];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:N_ImageUploaded object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:N_ImageDataChanged object:nil];
                }
                
            }];
            
            [self initUI];
            [self loadData];
        }
    }];
}

- (void) loadNextData{
    g_otherInfo = self.selfUserInfo;
    [DataStore instance].wallImagesForMyOwn = [self.arrCurData mutableCopy];
    
    if(self.isGridView)
        [AppDelegate getWallImagesForMyOwn:self limit:LIMIT_NUMBER_GRID];
    else
        [AppDelegate getWallImagesForMyOwn:self limit:LIMIT_NUMBER_LIST];
}

#pragma mark NIAttributedLabelDelegate

- (void)attributedLabel:(NIAttributedLabel *)attributedLabel didSelectTextCheckingResult:(NSTextCheckingResult *)result atPoint:(CGPoint)point
{
    NSString *strTag = [result.URL absoluteString];
    
    TagViewController *tagVC = (TagViewController *)[self.storyboard instantiateViewControllerWithIdentifier:TAG_VIEW_CONTROLLER];
    
    tagVC.strTag = strTag;
    
    [self.navigationController pushViewController:tagVC animated:YES];
}


#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *imgPhoto = info[UIImagePickerControllerEditedImage];
    
    CGFloat compression = 1.0f;
    CGFloat maxCompression = 0.01f;
    
    NSData *imageData = UIImageJPEGRepresentation(imgPhoto, compression);
    
    while([imageData length] > MAX_IMAGE_SIZE / 16 && compression > maxCompression){
        compression -= 0.01;
        imageData = UIImageJPEGRepresentation(imgPhoto, compression);
    }
    
    imgPhoto = [UIImage imageWithData:imageData];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    [[ParseService sharedInstance] uploadProfileImageFile:imgPhoto
                                                   Result:^(NSString *strError) {
                                                       if(strError == nil)
                                                       {
                                                           [SVProgressHUD dismiss];
                                                           [[NSNotificationCenter defaultCenter] postNotificationName:N_PhotoUpdated object:nil];
                                                           
                                                           [[NSNotificationCenter defaultCenter] postNotificationName:N_ImageDataChanged object:nil];
                                                       }
                                                       else
                                                       {
                                                           [SVProgressHUD showErrorWithStatus:strError];
                                                       }
                                                   }
                                                  Persent:^(int nPercent) {
                                                      [SVProgressHUD showProgress:(float)nPercent / 100.f status:@"Uploading..." maskType:SVProgressHUDMaskTypeGradient];
                                                  }];
    
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

#pragma mark - Action sheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex == 0) [self editComment];
    if(buttonIndex == 1) [self editRecipe];
    if(buttonIndex == 2) [self deleteWallImage];
    
}

#pragma mark - Collection view data source and delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(self.arrCurData.count > 0){
        self.myCollectionView.backgroundView = nil;
    }
    else{
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"No data is currently available. Please pull down to refresh.";
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
        [messageLabel sizeToFit];
        
        self.myCollectionView.backgroundView = messageLabel;
    }
    
    return self.arrCurData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:COLLECTION_CELL forIndexPath:indexPath];
    WallImage *wallImage = [self.arrCurData objectAtIndex:indexPath.row];

    UIImageView *imgView = (UIImageView *)[cell.contentView viewWithTag:2];
    
    [imgView setImageWithURL:[NSURL URLWithString:wallImage.image] placeholderImage:nil];
    
    UIButton *btnDrop = (UIButton *)[cell.contentView viewWithTag:1];
    
    if(self.isSelf){
        btnDrop.accessibilityIdentifier = @(indexPath.row).stringValue;
        
        [btnDrop       addTarget:self action:@selector(onDropMenu:) forControlEvents:UIControlEventTouchUpInside];
        
    }else{
        [btnDrop setHidden:YES];
    }
    
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    
    messageLabel.text = @"No data is currently available. Please pull down to refresh.";
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.numberOfLines = 0;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
    [messageLabel sizeToFit];
    
    // Return the number of sections.
    if(self.viewMode == viewFollowing){
        UserInfo *userInfo = [[DataStore instance].userInfoMap objectForKey:self.strUserObjID];
        
        if(userInfo.arrFollowing.count > 0){
            self.tblProfile.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            self.tblProfile.backgroundView = nil;
        }
        else{
            self.tblProfile.backgroundView = messageLabel;
            self.tblProfile.separatorStyle = UITableViewCellSeparatorStyleNone;
        }
        
        return userInfo.arrFollowing.count;
    }
    
    if(self.viewMode == viewFollower){
        UserInfo *userInfo = [[DataStore instance].userInfoMap objectForKey:self.strUserObjID];
        
        if(userInfo.arrFollower.count > 0){
            self.tblProfile.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            self.tblProfile.backgroundView = nil;
        }
        else{
            self.tblProfile.backgroundView = messageLabel;
            self.tblProfile.separatorStyle = UITableViewCellSeparatorStyleNone;
        }
        
        return userInfo.arrFollower.count;
    }
    
    if(self.arrCurData.count > 0){
        self.tblProfile.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tblProfile.backgroundView = nil;
    }
    else{
        self.tblProfile.backgroundView = messageLabel;
        self.tblProfile.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    return self.arrCurData.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    UserInfo *userInfo = [[DataStore instance].userInfoMap objectForKey:self.strUserObjID];
    
    if(self.viewMode == viewPhoto){
        if(indexPath.section == 0){
            cell = [tableView dequeueReusableCellWithIdentifier:VIEW_MODE_CELL forIndexPath:indexPath];
            
            self.btnGridViewForTableView = (UIButton *)[cell.contentView viewWithTag:1];
            self.btnListViewForTableView = (UIButton *)[cell.contentView viewWithTag:2];
            self.imgvGridViewForTableView = (UIImageView *)[cell.contentView viewWithTag:3];
            self.imgvListViewForTableView = (UIImageView *)[cell.contentView viewWithTag:4];
            
            [self.btnGridViewForTableView   addTarget:self action:@selector(onGridView:) forControlEvents:UIControlEventTouchUpInside];
            [self.btnListViewForTableView   addTarget:self action:@selector(onListView:) forControlEvents:UIControlEventTouchUpInside];
            
            return cell;
        }
        
        NSInteger nIdx = indexPath.section - 1;
        
        WallImage *wallImage = [self.arrCurData objectAtIndex:nIdx];
        
        if(self.isSelf){
            cell = [tableView dequeueReusableCellWithIdentifier:WALL_IMAGE_CELL_FOR_SELF forIndexPath:indexPath];
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:WALL_IMAGE_CELL forIndexPath:indexPath];
        }
        
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
        UILabel     *lblRecipeRequets = (UILabel *)[cell.contentView viewWithTag:14];
        
        UIImageView *imgViewLike      = (UIImageView *)[cell.contentView viewWithTag:15];
        UIImageView *imgViewComment   = (UIImageView *)[cell.contentView viewWithTag:16];
        UIImageView *imgViewFavorite  = (UIImageView *)[cell.contentView viewWithTag:17];
        
        UILabel     *lblLike          = (UILabel *)[cell.contentView viewWithTag:18];
        UILabel     *lblComment       = (UILabel *)[cell.contentView viewWithTag:19];
        
        UserInfo *userInfo = [[DataStore instance].userInfoMap objectForKey:wallImage.strUserObjId];
        
        imgViewUserPhoto.image = userInfo.imgPhoto;
        [btnFullName setTitle:wallImage.strUserFullName forState:UIControlStateNormal];
        lblTime.text = [AppDelegate getTime:wallImage.createdDate];
        
        if(wallImage.strRecipe.length > 0){
            [btnRecipe setHidden:NO];
            [btnRecipRequest setHidden:YES];
        }else{
            [btnRecipe setHidden:YES];
            
            if(self.isSelf){
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
        
        if(self.isSelf){
            if(wallImage.strRecipe.length > 0)
                [lblRecipeRequets setHidden:YES];
            else{
                if(wallImage.nNumberRecipeRequests == 0){
                    [lblRecipeRequets setHidden:YES];
                }else{
                    [lblRecipeRequets setHidden:NO];
                    
                    [lblRecipeRequets setText:[NSString stringWithFormat:@"Recipe Requests: %@", @(wallImage.nNumberRecipeRequests).stringValue]];
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
        
        btnRecipe.accessibilityIdentifier        = @(nIdx).stringValue;
        btnDrop.accessibilityIdentifier          = @(nIdx).stringValue;
        btnLikes.accessibilityIdentifier         = @(nIdx).stringValue;
        btnComments.accessibilityIdentifier      = @(nIdx).stringValue;
        btnFavorite.accessibilityIdentifier      = @(nIdx).stringValue;
        btnRecipRequest.accessibilityIdentifier  = @(nIdx).stringValue;
        btnShareFacebook.accessibilityIdentifier = @(nIdx).stringValue;
        
        if(!self.isSelf) [btnDrop setHidden:YES];
        
        [btnRecipe     addTarget:self action:@selector(onViewRecipeClick:) forControlEvents:UIControlEventTouchUpInside];
        [btnDrop       addTarget:self action:@selector(onDropMenu:) forControlEvents:UIControlEventTouchUpInside];
        [btnLikes      addTarget:self action:@selector(onLikeClick:) forControlEvents:UIControlEventTouchUpInside];
        [btnComments   addTarget:self action:@selector(onCommentClick:) forControlEvents:UIControlEventTouchUpInside];
        [btnFavorite   addTarget:self action:@selector(onFavoriteClick:) forControlEvents:UIControlEventTouchUpInside];
        [btnRecipRequest   addTarget:self action:@selector(onRequestRecipe:) forControlEvents:UIControlEventTouchUpInside];
        [btnShareFacebook   addTarget:self action:@selector(onShareFacebook:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if(self.viewMode == viewFollowing){
        cell = [tableView dequeueReusableCellWithIdentifier:USER_CELL forIndexPath:indexPath];
        
        
        NSString *strUserObjID = [userInfo.arrFollowing objectAtIndex:indexPath.section];
        UserInfo *itemUserInfo = [AppDelegate getUserInfoFrom:strUserObjID];
        
        // Configure the cell...
        UIImageView *imgViewUserPhoto = (UIImageView *)[cell.contentView viewWithTag:1];
        UILabel     *lblUserName    = (UILabel *)[cell.contentView viewWithTag:2];
        UILabel     *lblPosts = (UILabel *)[cell.contentView viewWithTag:3];
        UILabel     *lblFollowers = (UILabel *)[cell.contentView viewWithTag:4];
        UILabel     *lblFollowing = (UILabel *)[cell.contentView viewWithTag:5];
        
        imgViewUserPhoto.image = itemUserInfo.imgPhoto;
        lblUserName.text = [NSString stringWithFormat:@"%@ %@", itemUserInfo.strUserFirstName, itemUserInfo.strUserLastName];
        lblPosts.text = [NSString stringWithFormat:@"%ld Posts", itemUserInfo.arrWallImages.count];
        lblFollowers.text = [NSString stringWithFormat:@"%ld Followers", itemUserInfo.arrFollower.count];
        lblFollowing.text = [NSString stringWithFormat:@"%ld Following", itemUserInfo.arrFollowing.count];
    }
    
    if(self.viewMode == viewFollower){
        cell = [tableView dequeueReusableCellWithIdentifier:USER_CELL forIndexPath:indexPath];
        
        
        NSString *strUserObjID = [userInfo.arrFollower objectAtIndex:indexPath.section];
        UserInfo *itemUserInfo = [AppDelegate getUserInfoFrom:strUserObjID];
        
        // Configure the cell...
        UIImageView *imgViewUserPhoto = (UIImageView *)[cell.contentView viewWithTag:1];
        UILabel     *lblUserName    = (UILabel *)[cell.contentView viewWithTag:2];
        UILabel     *lblPosts = (UILabel *)[cell.contentView viewWithTag:3];
        UILabel     *lblFollowers = (UILabel *)[cell.contentView viewWithTag:4];
        UILabel     *lblFollowing = (UILabel *)[cell.contentView viewWithTag:5];

        
        imgViewUserPhoto.image = itemUserInfo.imgPhoto;
        lblUserName.text = [NSString stringWithFormat:@"%@ %@", itemUserInfo.strUserFirstName, itemUserInfo.strUserLastName];
        lblPosts.text = [NSString stringWithFormat:@"%ld Posts", itemUserInfo.arrWallImages.count];
        lblFollowers.text = [NSString stringWithFormat:@"%ld Followers", itemUserInfo.arrFollower.count];
        lblFollowing.text = [NSString stringWithFormat:@"%ld Following", itemUserInfo.arrFollowing.count];
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 60;
    
    if(self.viewMode == viewPhoto){
        
        if(indexPath.section == 0){
            return 44;
        }
        
        NSInteger nIdx = indexPath.section - 1;
        
        WallImage *wallImage = [self.arrCurData objectAtIndex:nIdx];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:WALL_IMAGE_CELL];
        
        UILabel     *lblSelfComment   = (UILabel *)[cell.contentView viewWithTag:6];
        
        CGFloat heightX = [AppDelegate getRealHeightFrom:lblSelfComment.frame.size.width content:wallImage.strSelfComments fontname:lblSelfComment.font.fontName fontsize:lblSelfComment.font.pointSize];
        
        if(wallImage.strSelfComments.length == 0) heightX = 0;
        
        height = 435 + heightX + g_moreHeight + g_dH;
    }
    
    return height;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.viewMode == viewPhoto){
        if(indexPath.section == 0) return nil;
        
        NSInteger nIdx = indexPath.section - 1;
        
        WallImage *wallImage = [self.arrCurData objectAtIndex:nIdx];
        
        PostCommentViewController *commentViewCtrl = (PostCommentViewController *)[self.storyboard instantiateViewControllerWithIdentifier:POST_COMMENT_VIEW_CONTROLLER];
        
        commentViewCtrl.wallImage = wallImage;
        
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:commentViewCtrl];
        
        navCtrl.navigationBar.hidden = YES;
        
        [self.navigationController presentViewController:navCtrl animated:YES completion:nil];
        
        return nil;
    }
    
    NSString *strUserObjID = @"";
    UserInfo *userInfo = [[DataStore instance].userInfoMap objectForKey:self.strUserObjID];
    
    if(self.viewMode == viewFollower)
        strUserObjID = [userInfo.arrFollower objectAtIndex:indexPath.section];
    else
        strUserObjID = [userInfo.arrFollowing objectAtIndex:indexPath.section];
    
    [self onOtherProfile:strUserObjID];
    
    return nil;
}

-(void)scrollViewDidScroll: (UIScrollView*)scrollView
{
    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    NSInteger y = scrollView.contentOffset.y;
    
    if (maximumOffset < y && ![self.indicatorFooter isAnimating]) {
        [self loadNextData];
        [self.indicatorFooter startAnimating];
        [self.indicatorFooterOfCollection startAnimating];
        
        return;
    }

}

//- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
//    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
//    
//    if (maximumOffset <= targetContentOffset->y) {
//        [self loadNextData];
//        [self.indicatorFooter startAnimating];
//    }
//}

@end
