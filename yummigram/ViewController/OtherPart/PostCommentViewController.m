//
//  PostCommentViewController.m
//  yummigram
//
//  Created by User on 5/10/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "PostCommentViewController.h"
#import "ProfileViewController.h"
#import "RecipeDetailViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <Social/Social.h>
#import "TagViewController.h"

@interface PostCommentViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tblPost;
@property (weak, nonatomic) IBOutlet UITextField *tfComment;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nContentViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nContnetViewWidth;
@end

@implementation PostCommentViewController
- (IBAction)onBack:(id)sender {
    UINavigationController *navCtrl = self.navigationController;
    
    if(navCtrl == nil){
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [navCtrl dismissViewControllerAnimated:YES completion:nil];
        [navCtrl popViewControllerAnimated:YES];
    }

}

- (IBAction)onPost:(id)sender {
    
    [self.tfComment resignFirstResponder];
    NSString *strComment = self.tfComment.text;
    
    if(strComment.length > 0) [self postComment:strComment];
    
    self.tfComment.text = @"";

}

- (void) goProfile {
    ProfileViewController *profileViewCtrl = (ProfileViewController *)[self.storyboard instantiateViewControllerWithIdentifier:PROFILE_VIEW_CONTROLLER];
    
    profileViewCtrl.strUserObjID = self.wallImage.strUserObjId;
    
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:profileViewCtrl];
    
    navCtrl.navigationBar.hidden = YES;
    
    [self presentViewController:navCtrl animated:YES completion:nil];
}

- (void) postComment:(NSString *)strComment{
    PFObject *commentObj = [PFObject objectWithClassName:pClassWallImageComments];
    
    commentObj[pKeyComments]   = strComment;
    commentObj[pKeyUserObjId]  = g_myInfo.strUserObjID;
    commentObj[pKeyUserFBId]   = g_myInfo.strFacebookID;
    commentObj[pKeyImageObjId] = self.wallImage.strImageObjId;
    
    [SVProgressHUD showWithStatus:@"Wait..." maskType:SVProgressHUDMaskTypeGradient];
    
    [commentObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            [SVProgressHUD dismiss];
            WallImageComment *wallComment = [WallImageComment initWithObject:commentObj];
            
            [[DataStore instance].comments insertObject:wallComment atIndex:0];
            
            self.wallImage.commented = YES;
            
            
            
            g_lastCommentUpdate = commentObj.createdAt;
            
            [self.wallImage.arrComments addObject:commentObj.objectId];
            
            PFObject *pfWallImage = [[DataStore instance].wallImagePFObjectMap objectForKey:self.wallImage.strImageObjId];
            
            [pfWallImage addUniqueObject:commentObj.objectId forKey:pKeyComments];
            
            [pfWallImage saveInBackground];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:N_ImageDataChanged object:nil];
            
            [AppDelegate postNotifyWithImage:self.wallImage notificationType:notifyComment];

        }else{
            [SVProgressHUD showErrorWithStatus:[error.userInfo objectForKey:@"error" ]];
        }
    }];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tblPost.dataSource = self;
    self.tblPost.delegate = self;
    self.tfComment.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imageDataChanged:)
                                                 name:N_ImageDataChanged
                                               object:nil];
    
    CGFloat fWidth  = [[UIScreen mainScreen] bounds].size.width;
    CGFloat fHeight = [[UIScreen mainScreen] bounds].size.height;
    
    self.nContnetViewWidth.constant = fWidth;
    self.nContentViewHeight.constant = fHeight - 44;
    
    self.tblPost.layer.cornerRadius = 5;
    self.tblPost.layer.masksToBounds = YES;
    self.tblPost.layer.borderWidth = 1;
    self.tblPost.layer.borderColor = [[UIColor colorWithRed:(229/255.0) green:(216/255.0) blue:(209/255.0) alpha:1] CGColor];
    
    self.tfComment.layer.cornerRadius = 1;
    self.tfComment.layer.masksToBounds = YES;
    self.tfComment.layer.borderWidth = 1;
    self.tfComment.layer.borderColor = [[UIColor colorWithRed:(229/255.0) green:(216/255.0) blue:(209/255.0) alpha:1] CGColor];
    
    g_lastCommentUpdate = [NSDate date];
    g_wallImage = self.wallImage;
    [[DataStore instance].comments removeAllObjects];
    [AppDelegate getCommments:self limit:2];
}

- (void) imageDataChanged:(NSNotification *)notification
{
    [self.tblPost reloadData];
}

- (void) onSelfProfile{
    
    ProfileViewController *profileViewCtrl = (ProfileViewController *)[self.storyboard instantiateViewControllerWithIdentifier:PROFILE_VIEW_CONTROLLER];
    
    profileViewCtrl.strUserObjID = self.wallImage.strUserObjId;
    
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:profileViewCtrl];
    
    navCtrl.navigationBar.hidden = YES;
    
    [self.navigationController presentViewController:navCtrl animated:YES completion:nil];
}

- (void) onTagButtonClick:(id) sender{
    UIButton *btnTag = (UIButton *)sender;
    
    TagViewController *tagVC = (TagViewController *)[self.storyboard instantiateViewControllerWithIdentifier:TAG_VIEW_CONTROLLER];
    
    tagVC.strTag = btnTag.titleLabel.text;
    
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:tagVC];
    
    navCtrl.navigationBar.hidden = YES;
    
    [self.navigationController presentViewController:navCtrl animated:YES completion:nil];}

- (void) onOtherProfile:(id) sender{
    UIView *senderView = (UIView *)sender;
    int nIdx = [senderView.accessibilityIdentifier intValue];
    
    WallImageComment *comment = [[DataStore instance].comments objectAtIndex:nIdx];
    
    ProfileViewController *profileViewCtrl = (ProfileViewController *)[self.storyboard instantiateViewControllerWithIdentifier:PROFILE_VIEW_CONTROLLER];
    
    profileViewCtrl.strUserObjID = comment.strUserObjId;
    
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:profileViewCtrl];
    
    navCtrl.navigationBar.hidden = YES;
    
    [self.navigationController presentViewController:navCtrl animated:YES completion:nil];
    
}

- (void) onViewRecipeClick{
    
    RecipeDetailViewController *detailViewCtrl = (RecipeDetailViewController *)[self.storyboard instantiateViewControllerWithIdentifier:RECIPE_DETAIL_VIEW_CONTROLLER];
    detailViewCtrl.wallImage = self.wallImage;
    
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:detailViewCtrl];
    
    navCtrl.navigationBar.hidden = YES;
    
    [self presentViewController:navCtrl animated:YES completion:nil];
}

- (void) onRequestRecipe:(id) sender{
    
    UIView *senderView = (UIView *)sender;
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:self.wallImage.strImageObjId]) return;
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:self.wallImage.strImageObjId];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UIView *superView = [senderView superview];
    UIButton *btnRequestRecipe = (UIButton *)[superView viewWithTag:9];
    
    [btnRequestRecipe setBackgroundImage:[UIImage imageNamed:@"bg_btn_red"] forState:UIControlStateNormal];
    [btnRequestRecipe setTitle:@"RECIPE REQUESTED" forState:UIControlStateNormal];
    [btnRequestRecipe setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.wallImage.nNumberRecipeRequests ++;
    
    PFObject *wallImageObj = [[DataStore instance].wallImagePFObjectMap objectForKey:self.wallImage.strImageObjId];
    
    wallImageObj[pKeyRequestRecipe] = [NSNumber numberWithInteger:self.wallImage.nNumberRecipeRequests];
    
    [wallImageObj saveInBackground];
    
    [AppDelegate postNotifyWithImage:self.wallImage notificationType:notifyRequestRecipe];
}

- (void) onShareFacebook:(id) sender{
    
    NSString *strRealComments = @"";
    
    if(self.wallImage.strRecipe.length > 0){
        strRealComments = [NSString stringWithFormat:@"%@ RECIPE -> www.yummigram.com/recipeid\n%@", self.wallImage.strRecipe, self.wallImage.strSelfComments];
    }else{
        strRealComments = [NSString stringWithFormat:@"%@\nShared via Yummigram -> www.yummigram.com", self.wallImage.strSelfComments];
    }
    
    NSURL *imageURL = [NSURL URLWithString:self.wallImage.image];
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

- (void) onLikeClick{
    
    PFObject *pfObj = [[DataStore instance].wallImagePFObjectMap objectForKey:self.wallImage.strImageObjId];
    
    self.wallImage.liked = !self.wallImage.liked;
    
    if(self.wallImage.liked){
        [pfObj addUniqueObject:g_myInfo.strUserObjID forKey:pKeyLikes];
        self.wallImage.nNumberLikes ++;
        
        [AppDelegate postNotifyWithImage:self.wallImage notificationType:notifyLiked];
        
    }else{
        [pfObj removeObject:g_myInfo.strUserObjID forKey:pKeyLikes];
        self.wallImage.nNumberLikes --;
    }
    
    [pfObj saveInBackground];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:N_ImageDataChanged object:nil];
}

- (void) onFavoriteClick{
    
    PFUser *currentUser = [PFUser currentUser];
    
    self.wallImage.favorited = !self.wallImage.favorited;
    
    if(self.wallImage.favorited){
        
        [currentUser addUniqueObject:self.wallImage.strImageObjId forKey:pKeyFavorites];
        [AppDelegate postNotifyWithImage:self.wallImage notificationType:notifyAddFavorite];
    }else{
        [currentUser removeObject:self.wallImage.strImageObjId forKey:pKeyFavorites];
    }
    
    [currentUser saveInBackground];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:N_ImageDataChanged object:nil];
}

- (void)imageViewTapped:(UIGestureRecognizer *)gestureRecognizer {
    UIView *view = [gestureRecognizer view];
    
    if([view.accessibilityIdentifier isEqualToString:@"self"])
        [self onSelfProfile];
    else
        [self onOtherProfile:view];
}

- (void) onDropMenu{
    NSMutableArray *shareList =[[NSMutableArray alloc] initWithObjects:@"Follow", @"Unfollow", nil];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    for (NSString *item in shareList) {
        [actionSheet addButtonWithTitle:item];
    }
    
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
    
    [actionSheet showInView:self.view];
    
}

- (void) didGetComments{
    [self.tblPost reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    NSString *strComment = textField.text;
    
    if(strComment.length > 0) [self postComment:strComment];
    
    textField.text = @"";
    
    return  YES;
}

#pragma mark NIAttributedLabelDelegate

- (void)attributedLabel:(NIAttributedLabel *)attributedLabel didSelectTextCheckingResult:(NSTextCheckingResult *)result atPoint:(CGPoint)point
{
    NSString *strTag = [result.URL absoluteString];
    
    TagViewController *tagVC = (TagViewController *)[self.storyboard instantiateViewControllerWithIdentifier:TAG_VIEW_CONTROLLER];
    
    tagVC.strTag = strTag;
    
    [self.navigationController pushViewController:tagVC animated:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger p = 0;
    
    if([DataStore instance].comments.count < self.wallImage.arrComments.count) p = 1;
    
    return 1 + [DataStore instance].comments.count + p;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    /*********  Common Header Content  ******************/
    
    if(indexPath.row == 0){
        cell = [tableView dequeueReusableCellWithIdentifier:WALL_IMAGE_CELL forIndexPath:indexPath];
        
        // Configure the cell...
        UIImageView *imgViewUserPhoto = (UIImageView *)[cell.contentView viewWithTag:1];
        UIButton    *btnFullName      = (UIButton *)[cell.contentView viewWithTag:2];
        UILabel     *lblTime          = (UILabel *)[cell.contentView viewWithTag:3];
        UIButton    *btnRecipe        = (UIButton *)[cell.contentView viewWithTag:4];
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
        
        UserInfo *userInfo = [AppDelegate getUserInfoFrom:self.wallImage.strUserObjId];
        
        imgViewUserPhoto.image = userInfo.imgPhoto;
        [btnFullName setTitle:self.wallImage.strUserFullName forState:UIControlStateNormal];
        lblTime.text = [AppDelegate getTime:self.wallImage.createdDate];
        
        if(self.wallImage.strRecipe.length > 0){
            [btnRecipe setHidden:NO];
        }else{
            [btnRecipe setHidden:YES];
        }
        
        lblSelfComment.delegate = self;
        lblSelfComment.text = self.wallImage.strSelfComments;
        lblSelfComment.linkColor = [UIColor colorWithRed:(133/255.0) green:(18/255.0) blue:(57/255.0) alpha:1];
        
        NSString *strLowerCaseSelfComment = [self.wallImage.strSelfComments lowercaseString];
        
        for(NSString *strTag in self.wallImage.arrTag){
            NSRange range = [strLowerCaseSelfComment rangeOfString:strTag];
            [lblSelfComment addLink:[NSURL URLWithString:strTag] range:range];
        }
        
        [imgViewWall setImageWithURL:[NSURL URLWithString:self.wallImage.image] placeholderImage:nil];
        
        [lblLike setText:@(self.wallImage.nNumberLikes).stringValue];
        [lblComment setText:@(self.wallImage.arrComments.count).stringValue];
        
        [btnRecipRequest setHidden:YES];
        
        if(self.wallImage.liked)
            [imgViewLike setImage:[UIImage imageNamed:@"post_icons_heart_fill"]];
        else
            [imgViewLike setImage:[UIImage imageNamed:@"post_icons_heart"]];
        
        if(self.wallImage.commented)
            [imgViewComment setImage:[UIImage imageNamed:@"post_icons_comment_fill"]];
        else
            [imgViewComment setImage:[UIImage imageNamed:@"post_icons_comment"]];
        
        if(self.wallImage.favorited)
            [imgViewFavorite setImage:[UIImage imageNamed:@"post_icons_star_fill"]];
        else
            [imgViewFavorite setImage:[UIImage imageNamed:@"post_icons_star"]];
        
        [btnFullName   addTarget:self action:@selector(onSelfProfile) forControlEvents:UIControlEventTouchUpInside];
        [btnRecipe     addTarget:self action:@selector(onViewRecipeClick) forControlEvents:UIControlEventTouchUpInside];
//        [btnDrop       addTarget:self action:@selector(onDropMenu) forControlEvents:UIControlEventTouchUpInside];
        
        [btnLikes      addTarget:self action:@selector(onLikeClick) forControlEvents:UIControlEventTouchUpInside];
//        [btnComments   addTarget:self action:@selector(onCommentClick:) forControlEvents:UIControlEventTouchUpInside];
        [btnFavorite   addTarget:self action:@selector(onFavoriteClick) forControlEvents:UIControlEventTouchUpInside];
        [btnRecipRequest   addTarget:self action:@selector(onRequestRecipe:) forControlEvents:UIControlEventTouchUpInside];
        [btnShareFacebook   addTarget:self action:@selector(onShareFacebook:) forControlEvents:UIControlEventTouchUpInside];
        
        imgViewUserPhoto.accessibilityIdentifier = @"self";
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped:)];
        singleTap.numberOfTapsRequired = 1;
        singleTap.numberOfTouchesRequired = 1;
        
        [imgViewUserPhoto addGestureRecognizer:singleTap];
        [imgViewUserPhoto setUserInteractionEnabled:YES];
        
    }
    
    if(indexPath.row > 0 && indexPath.row <= [DataStore instance].comments.count){
        cell = [tableView dequeueReusableCellWithIdentifier:COMMENT_CELL];
        
        UIImageView *imgViewUserPhoto = (UIImageView *)[cell.contentView viewWithTag:1];
        UIButton    *btnFullName      = (UIButton *)[cell.contentView viewWithTag:2];
        UILabel     *lblTime          = (UILabel *)[cell.contentView viewWithTag:3];
        UILabel     *lblSelfComment   = (UILabel *)[cell.contentView viewWithTag:6];
        
        WallImageComment *comment = [[DataStore instance].comments objectAtIndex:indexPath.row - 1];
        UserInfo *userInfo = [AppDelegate getUserInfoFrom:comment.strUserObjId];
        
        imgViewUserPhoto.image = userInfo.imgPhoto;
        
        NSString *strUserFullName = [NSString stringWithFormat:@"%@ %@", userInfo.strUserFirstName, userInfo.strUserLastName];
        
        [btnFullName setTitle:strUserFullName forState:UIControlStateNormal];
        lblTime.text = [AppDelegate getTime:comment.createdDate];
        lblSelfComment.text = comment.strComment;
        
        imgViewUserPhoto.accessibilityIdentifier = @(indexPath.row - 1).stringValue;
        btnFullName.accessibilityIdentifier = @(indexPath.row - 1).stringValue;
        
        [btnFullName   addTarget:self action:@selector(onOtherProfile:) forControlEvents:UIControlEventTouchUpInside];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped:)];
        singleTap.numberOfTapsRequired = 1;
        singleTap.numberOfTouchesRequired = 1;
        
        [imgViewUserPhoto addGestureRecognizer:singleTap];
        [imgViewUserPhoto setUserInteractionEnabled:YES];
    }
    
    if(indexPath.row == [DataStore instance].comments.count + 1){
        cell = [tableView dequeueReusableCellWithIdentifier:SHOW_MORE_CELL];
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 50;
    
    UITableViewCell *cell = nil;
    
    if(indexPath.row == 0){
        cell = [tableView dequeueReusableCellWithIdentifier:WALL_IMAGE_CELL];
        
        UILabel     *lblSelfComment   = (UILabel *)[cell.contentView viewWithTag:6];
        
        CGFloat heightX = [AppDelegate getRealHeightFrom:lblSelfComment.frame.size.width content:self.wallImage.strSelfComments fontname:lblSelfComment.font.fontName fontsize:lblSelfComment.font.pointSize];
        
        if(self.wallImage.strSelfComments.length == 0) heightX = 0;
        
        height = 405 + heightX + g_moreHeight + g_dH;
        
    }
    
    if(indexPath.row > 0 && indexPath.row <= [DataStore instance].comments.count){
        cell = [tableView dequeueReusableCellWithIdentifier:COMMENT_CELL];
        
        UILabel     *lblComment   = (UILabel *)[cell.contentView viewWithTag:6];
        WallImageComment *comment = [[DataStore instance].comments objectAtIndex:indexPath.row - 1];
        NSString    *strComment   = comment.strComment;
        
        CGFloat heightX = [AppDelegate getRealHeightFrom:lblComment.frame.size.width content:strComment fontname:lblComment.font.fontName fontsize:lblComment.font.pointSize];
        
        if(strComment.length == 0) heightX = 0;
        
        height = 60 + heightX;

    }
    
    return height;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row == [DataStore instance].comments.count + 1){
        [AppDelegate getCommments:self limit:4];
    }
    
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
