//
//  TagViewController.m
//  yummigram
//
//  Created by User on 6/15/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "TagViewController.h"
#import "SuccontPullToRefreshView.h"
#import "UIViewController+SuccontPullToRefresh.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "ProfileViewController.h"
#import "RecipeDetailViewController.h"
#import "PostCommentViewController.h"
#import <Social/Social.h>

@interface TagViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lblHeaderTitle;
@property (weak, nonatomic) IBOutlet UITableView *tblTag;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewFavorite;

@property (nonatomic, strong) SuccontPullToRefreshView *pullToRefreshView;
@property (nonatomic, strong) UIActivityIndicatorView  *indicatorFooter;
@property (nonatomic, strong) UIActivityIndicatorView  *indicatorFooterOfCollection;

@property (nonatomic, strong) NSMutableArray *arrData;

@property (weak, nonatomic) UIButton *btnGridViewForCollection;
@property (weak, nonatomic) UIButton *btnListViewForCollection;
@property (weak, nonatomic) UIButton *btnGridViewForTableView;
@property (weak, nonatomic) UIButton *btnListViewForTableView;

@property (weak, nonatomic) UIImageView *imgvGridViewForCollection;
@property (weak, nonatomic) UIImageView *imgvListViewForCollection;
@property (weak, nonatomic) UIImageView *imgvGridViewForTableView;
@property (weak, nonatomic) UIImageView *imgvListViewForTableView;

@property (nonatomic)       BOOL      isGridView;

@end

@implementation TagViewController

- (void) onGridView:(id)sender {
    
    [self.imgvGridViewForCollection setImage:[UIImage imageNamed:@"photos_table_view_active"]];
    [self.imgvListViewForCollection setImage:[UIImage imageNamed:@"photos_list_view"]];
    
    [self.collectionViewFavorite setHidden:NO];
    [self.tblTag setHidden:YES];
    
    self.isGridView = YES;
}

- (void) onListView:(id)sender {
    [self.imgvGridViewForTableView setImage:[UIImage imageNamed:@"photos_table_view"]];
    [self.imgvListViewForTableView setImage:[UIImage imageNamed:@"photos_list_view_active"]];
    
    [self.collectionViewFavorite setHidden:YES];
    [self.tblTag setHidden:NO];
    
    self.isGridView = NO;
}

- (IBAction)onBack:(id)sender {
    UINavigationController *navCtrl = self.navigationController;
    
    if(navCtrl == nil){
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [navCtrl dismissViewControllerAnimated:YES completion:nil];
        [navCtrl popViewControllerAnimated:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tblTag.delegate = self;
    self.tblTag.dataSource = self;
    
    self.arrData = [[NSMutableArray alloc] init];
    
    [self initializeRefreshControlForHeader];
    [self initializeRefreshControlForFooter];
    
    [self setupCollectionView];
    
    g_lastImageUpdateForTag = [NSDate date];
    
    [[DataStore instance].wallImagesForTag removeAllObjects];
    [AppDelegate getWallImageForTag:self tag:self.strTag limit:LIMIT_NUMBER_GRID];
    
    self.lblHeaderTitle.text =[NSString stringWithFormat:@"Tag: %@", self.strTag];
    
    self.isGridView = NO;
    
    [self.collectionViewFavorite setHidden:YES];
}

-(void)setupCollectionView {
    CGFloat width_CollectionCell = self.view.frame.size.width - 28;
    
    UICollectionViewFlowLayout *collectionFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [collectionFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [collectionFlowLayout setMinimumInteritemSpacing:10.0f];
    [collectionFlowLayout setMinimumLineSpacing:10.0f];
    [collectionFlowLayout setItemSize:CGSizeMake(width_CollectionCell / 2, width_CollectionCell / 2)];
    [collectionFlowLayout setHeaderReferenceSize:CGSizeMake(width_CollectionCell  + 6, 44)];
    
    [self.collectionViewFavorite setPagingEnabled:YES];
    [self.collectionViewFavorite setCollectionViewLayout:collectionFlowLayout];
}

- (void) initializeRefreshControlForHeader{
    self.pullToRefreshView = [[SuccontPullToRefreshView alloc] initWithFrame:CGRectMake(0, -50, self.view.bounds.size.width, 50)];
    self.pullToRefreshView.backgroundColor = [UIColor clearColor];
    self.pullToRefreshView.statusLabel.backgroundColor = [UIColor clearColor];
    self.pullToRefreshView.statusLabel.textColor = [UIColor blackColor];
    self.pullToRefreshView.statusLabel.font = [UIFont fontWithName:@"Roboto-Bold" size:15];
    self.pullToRefreshView.reloadImageView.image = [UIImage imageNamed:@"PullToRefresh"];
    
    [self.tblTag addSubview:self.pullToRefreshView];
}

- (void) initializeRefreshControlForFooter{
    self.indicatorFooter = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tblTag.frame), 44)];
    [self.indicatorFooter setColor:[UIColor blackColor]];
    [self.indicatorFooter stopAnimating];
    [self.tblTag setTableFooterView:self.indicatorFooter];
    
}

- (void) refreshImageWall:(UIRefreshControl *)refreshControl
{
    if (refreshControl) {
        [refreshControl setEnabled:NO];
        [refreshControl endRefreshing];
    }
    
    [AppDelegate loadMoreForTag:self tag:self.strTag limit:3];
}

- (void) loadNextData{
    if(self.isGridView)
        [AppDelegate getWallImageForTag:self tag:self.strTag limit:LIMIT_NUMBER_GRID];
    else
        [AppDelegate getWallImageForTag:self tag:self.strTag limit:LIMIT_NUMBER_LIST];
}

- (void) didGetWallImageForTag{
    self.lblHeaderTitle.text =[NSString stringWithFormat:@"Tag: %@", self.strTag];
    
    self.arrData = [DataStore instance].wallImagesForTag;
    [self.tblTag reloadData];
    [self.collectionViewFavorite reloadData];
    [self.indicatorFooter stopAnimating];
    [self.indicatorFooterOfCollection stopAnimating];
}

- (void) didLoadMoreForTag{
    self.arrData = [DataStore instance].wallImagesForTag;
    [self.tblTag reloadData];
}

- (void) onOtherProfile:(id) sender{
    UIView *senderView = (UIView *)sender;
    NSInteger nIdx = [senderView.accessibilityIdentifier integerValue];
    WallImage *wallImage = [self.arrData objectAtIndex:nIdx];
    
    ProfileViewController *profileViewCtrl = (ProfileViewController *)[self.storyboard instantiateViewControllerWithIdentifier:PROFILE_VIEW_CONTROLLER];
    
    profileViewCtrl.strUserObjID = wallImage.strUserObjId;
    
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:profileViewCtrl];
    
    navCtrl.navigationBar.hidden = YES;
    
    [self.navigationController presentViewController:navCtrl animated:YES completion:nil];
    
}

- (void) onViewRecipeClick:(id) sender{
    UIView *senderView = (UIView *)sender;
    NSInteger nIdx = [senderView.accessibilityIdentifier integerValue];
    WallImage *wallImage = [self.arrData objectAtIndex:nIdx];
    
    RecipeDetailViewController *detailViewCtrl = (RecipeDetailViewController *)[self.storyboard instantiateViewControllerWithIdentifier:RECIPE_DETAIL_VIEW_CONTROLLER];
    detailViewCtrl.wallImage = wallImage;
    
    
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:detailViewCtrl];
    
    navCtrl.navigationBar.hidden = YES;
    
    [self.navigationController presentViewController:navCtrl animated:YES completion:nil];
}

- (void) onLikeClick:(id) sender{
    UIView *senderView = (UIView *)sender;
    NSInteger nIdx = [senderView.accessibilityIdentifier integerValue];
    WallImage *wallImage = [self.arrData objectAtIndex:nIdx];
    
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
    WallImage *wallImage = [self.arrData objectAtIndex:nIdx];
    
    PostCommentViewController *commentViewCtrl = (PostCommentViewController *)[self.storyboard instantiateViewControllerWithIdentifier:POST_COMMENT_VIEW_CONTROLLER];
    
    commentViewCtrl.wallImage = wallImage;
    
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:commentViewCtrl];
    
    navCtrl.navigationBar.hidden = YES;
    
    [self.navigationController presentViewController:navCtrl animated:YES completion:nil];
}

- (void) onFavoriteClick:(id) sender{
    UIView *senderView = (UIView *)sender;
    NSInteger nIdx = [senderView.accessibilityIdentifier integerValue];
    WallImage *wallImage = [self.arrData objectAtIndex:nIdx];
    
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

- (void) onRequestRecipe:(id) sender{
    UIView *senderView = (UIView *)sender;
    NSInteger nIdx = [senderView.accessibilityIdentifier integerValue];
    WallImage *wallImage = [self.arrData objectAtIndex:nIdx];
    
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
    WallImage *wallImage = [self.arrData objectAtIndex:nIdx];
    
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
    
    [SVProgressHUD showInfoWithStatus:btnTag.titleLabel.text];
}


- (void)imageViewTapped:(UIGestureRecognizer *)gestureRecognizer {
    UIView *view = [gestureRecognizer view];
    
    if(view.tag == 1){
        [self onOtherProfile:view];
    }else{
        
        NSInteger nIdx = [view.accessibilityIdentifier integerValue];
        WallImage *wallImage = [self.arrData objectAtIndex:nIdx];
        
        if(wallImage.strRecipe.length > 0)
            [self onViewRecipeClick:view];
        else
            [self onCommentClick:view];
    }
    
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

#pragma mark NIAttributedLabelDelegate

- (void)attributedLabel:(NIAttributedLabel *)attributedLabel didSelectTextCheckingResult:(NSTextCheckingResult *)result atPoint:(CGPoint)point
{
    NSString *strTag = [result.URL absoluteString];
    
    self.strTag = strTag;
    
    g_lastImageUpdateForTag = [NSDate date];
    
    [[DataStore instance].wallImagesForTag removeAllObjects];
    [AppDelegate getWallImageForTag:self tag:self.strTag limit:4];
}

#pragma mark - Collection view data source and delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(self.arrData.count > 0){
        self.collectionViewFavorite.backgroundView = nil;
    }
    else{
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"No data is currently available. Please pull down to refresh.";
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
        [messageLabel sizeToFit];
        
        self.collectionViewFavorite.backgroundView = messageLabel;
    }
    
    return self.arrData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:COLLECTION_CELL forIndexPath:indexPath];
    WallImage *wallImage = [self.arrData objectAtIndex:indexPath.row];
    
    
    
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
    
    WallImage *wallImage = [self.arrData objectAtIndex:indexPath.row];
    
    PostCommentViewController *commentViewCtrl = (PostCommentViewController *)[self.storyboard instantiateViewControllerWithIdentifier:POST_COMMENT_VIEW_CONTROLLER];
    
    commentViewCtrl.wallImage = wallImage;
    
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:commentViewCtrl];
    
    navCtrl.navigationBar.hidden = YES;
    
    [self.navigationController presentViewController:navCtrl animated:YES completion:nil];
    
    
    return YES;
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
    NSInteger num = self.arrData.count;
    
    if (num > 0) {
        
        self.tblTag.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        
        self.tblTag.backgroundView = nil;
        
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
        
        self.tblTag.backgroundView = messageLabel;
        self.tblTag.separatorStyle = UITableViewCellSeparatorStyleNone;
        
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
    
    WallImage       *wallImage = [self.arrData objectAtIndex:nIdx];
    
    UITableViewCell *cell = [self.tblTag dequeueReusableCellWithIdentifier:WALL_IMAGE_CELL forIndexPath:indexPath];
    
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
    
    imgViewUserPhoto.accessibilityIdentifier = @(nIdx).stringValue;
    imgViewWall.accessibilityIdentifier      = @(nIdx).stringValue;
    btnFullName.accessibilityIdentifier      = @(nIdx).stringValue;
    btnRecipe.accessibilityIdentifier        = @(nIdx).stringValue;
    btnDrop.accessibilityIdentifier          = @(nIdx).stringValue;
    btnLikes.accessibilityIdentifier         = @(nIdx).stringValue;
    btnComments.accessibilityIdentifier      = @(nIdx).stringValue;
    btnFavorite.accessibilityIdentifier      = @(nIdx).stringValue;
    btnRecipRequest.accessibilityIdentifier  = @(nIdx).stringValue;
    btnShareFacebook.accessibilityIdentifier = @(nIdx).stringValue;
    
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
    
    WallImage       *wallImage = [self.arrData objectAtIndex:nIdx];
    
    UITableViewCell *cell = [self.tblTag dequeueReusableCellWithIdentifier:WALL_IMAGE_CELL];
    
    UILabel     *lblSelfComment   = (UILabel *)[cell.contentView viewWithTag:6];
    
    CGFloat heightX = [AppDelegate getRealHeightFrom:lblSelfComment.frame.size.width content:wallImage.strSelfComments fontname:lblSelfComment.font.fontName fontsize:lblSelfComment.font.pointSize];
    
    if(wallImage.strSelfComments.length == 0) heightX = 0;
    
    height = 435 + heightX + g_moreHeight + g_dH;
    //    height += 80;
    return height;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}
@end
