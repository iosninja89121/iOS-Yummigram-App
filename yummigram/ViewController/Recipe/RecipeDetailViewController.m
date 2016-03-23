//
//  RecipeDetailViewController.m
//  yummigram
//
//  Created by User on 4/2/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "RecipeDetailViewController.h"
#import "ProfileViewController.h"
#import "PostCommentViewController.h"
#import "TagViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <Social/Social.h>

@interface RecipeDetailViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tblDetail;
@end

@implementation RecipeDetailViewController
- (IBAction)onBack:(id)sender {
    UINavigationController *navCtrl = self.navigationController;
    
    if(navCtrl == nil){
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [navCtrl dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (void) goProfile {
    ProfileViewController *profileViewCtrl = (ProfileViewController *)[self.storyboard instantiateViewControllerWithIdentifier:PROFILE_VIEW_CONTROLLER];
    
    profileViewCtrl.strUserObjID = self.wallImage.strUserObjId;
    
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:profileViewCtrl];
    
    navCtrl.navigationBar.hidden = YES;
    
    [self presentViewController:navCtrl animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tblDetail.delegate = self;
    self.tblDetail.dataSource = self;
    
    self.tblDetail.layer.cornerRadius = 2;
    self.tblDetail.layer.masksToBounds = YES;
    self.tblDetail.layer.borderWidth = 1;
    self.tblDetail.layer.borderColor = [[UIColor colorWithRed:(229/255.0) green:(216/255.0) blue:(209/255.0) alpha:1] CGColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imageDataChanged:)
                                                 name:N_ImageDataChanged
                                               object:nil];

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

- (void) onTagButtonClick:(id) sender{
    UIButton *btnTag = (UIButton *)sender;
    
    TagViewController *tagVC = (TagViewController *)[self.storyboard instantiateViewControllerWithIdentifier:TAG_VIEW_CONTROLLER];
    
    tagVC.strTag = btnTag.titleLabel.text;
    
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:tagVC];
    
    navCtrl.navigationBar.hidden = YES;
    
    [self.navigationController presentViewController:navCtrl animated:YES completion:nil];
}

- (void) onCommentClick:(id) sender{
    
    PostCommentViewController *commentViewCtrl = (PostCommentViewController *)[self.storyboard instantiateViewControllerWithIdentifier:POST_COMMENT_VIEW_CONTROLLER];
    
    commentViewCtrl.wallImage = self.wallImage;
    
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:commentViewCtrl];
    
    navCtrl.navigationBar.hidden = YES;
    
    [self.navigationController presentViewController:navCtrl animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) imageDataChanged:(NSNotification *)notification
{
    [self.tblDetail reloadData];
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
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    /*********  Common Header Content  ******************/
    
    switch (indexPath.row) {
        case 0:{
            cell = [tableView dequeueReusableCellWithIdentifier:WALL_IMAGE_CELL forIndexPath:indexPath];
            
            // Configure the cell...
            UIImageView *imgViewUserPhoto = (UIImageView *)[cell.contentView viewWithTag:1];
            UIButton    *btnFullName      = (UIButton *)[cell.contentView viewWithTag:2];
            UILabel     *lblTime          = (UILabel *)[cell.contentView viewWithTag:3];
            NIAttributedLabel     *lblSelfComment   = (NIAttributedLabel *)[cell.contentView viewWithTag:6];
            UIImageView *imgViewWall      = (UIImageView *)[cell.contentView viewWithTag:7];
            UIButton    *btnShareFacebook = (UIButton *)[cell.contentView viewWithTag:10];

            UIButton    *btnLikes         = (UIButton *)[cell.contentView viewWithTag:11];
            UIButton    *btnComments      = (UIButton *)[cell.contentView viewWithTag:12];
            UIButton    *btnFavorite      = (UIButton *)[cell.contentView viewWithTag:13];
            
            UIImageView *imgViewLike      = (UIImageView *)[cell.contentView viewWithTag:15];
            UIImageView *imgViewComment   = (UIImageView *)[cell.contentView viewWithTag:16];
            UIImageView *imgViewFavorite  = (UIImageView *)[cell.contentView viewWithTag:17];
            
            UILabel     *lblLike          = (UILabel *)[cell.contentView viewWithTag:18];
            UILabel     *lblComment       = (UILabel *)[cell.contentView viewWithTag:19];

            
            UserInfo *userInfo = [[DataStore instance].userInfoMap objectForKey:self.wallImage.strUserObjId];
            
            imgViewUserPhoto.image = userInfo.imgPhoto;
            [btnFullName setTitle:self.wallImage.strUserFullName forState:UIControlStateNormal];
            lblTime.text = [AppDelegate getTime:self.wallImage.createdDate];
            
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
            
            [btnFullName   addTarget:self action:@selector(goProfile) forControlEvents:UIControlEventTouchUpInside];
            
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

            
            [btnLikes      addTarget:self action:@selector(onLikeClick) forControlEvents:UIControlEventTouchUpInside];
            [btnComments   addTarget:self action:@selector(onCommentClick:) forControlEvents:UIControlEventTouchUpInside];
            [btnFavorite   addTarget:self action:@selector(onFavoriteClick) forControlEvents:UIControlEventTouchUpInside];
            [btnShareFacebook   addTarget:self action:@selector(onShareFacebook:) forControlEvents:UIControlEventTouchUpInside];
            
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goProfile)];
            singleTap.numberOfTapsRequired = 1;
            singleTap.numberOfTouchesRequired = 1;
            
            [imgViewUserPhoto addGestureRecognizer:singleTap];
            [imgViewUserPhoto setUserInteractionEnabled:YES];
            
            break;
        }
        
        case 1:{
            cell = [tableView dequeueReusableCellWithIdentifier:TITLE_CELL];
            
            UILabel  *lblTitle  = (UILabel *)[cell.contentView viewWithTag:1];
            
            lblTitle.text = self.wallImage.strRecipe;
            
            break;
        }
            
        case 2:{
            cell = [tableView dequeueReusableCellWithIdentifier:DESCRIPTION_CELL];
            
            UILabel  *lblTitle       = (UILabel *)[cell.contentView viewWithTag:1];
            UILabel  *lblIngredients = (UILabel *)[cell.contentView viewWithTag:2];

            lblTitle.text = @"INGREDIENTS";
            lblIngredients.text = self.wallImage.strIngredients;
            
            break;
        }
        
        case 3:{
            cell = [tableView dequeueReusableCellWithIdentifier:DESCRIPTION_CELL];
            
            UILabel  *lblTitle       = (UILabel *)[cell.contentView viewWithTag:1];
            UILabel  *lblDescription = (UILabel *)[cell.contentView viewWithTag:2];
            
            lblTitle.text = @"DESCRIPTION";
            lblDescription.text = self.wallImage.strDirections;
            
            break;
        }
            
        default:
            break;
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 50;
    
    UITableViewCell *cell = nil;
    
    
    switch (indexPath.row) {
        case 0:{
            cell = [self.tblDetail dequeueReusableCellWithIdentifier:WALL_IMAGE_CELL];
            
            UILabel     *lblSelfComment   = (UILabel *)[cell.contentView viewWithTag:6];
            
            CGFloat heightX = [AppDelegate getRealHeightFrom:lblSelfComment.frame.size.width content:self.wallImage.strSelfComments fontname:lblSelfComment.font.fontName fontsize:lblSelfComment.font.pointSize];
            
            if(self.wallImage.strSelfComments.length == 0) heightX = 0;
            
            height = 435 + heightX + g_moreHeight + g_dH;
            
            break;
        }
            
        case 1:{
            cell = [tableView dequeueReusableCellWithIdentifier:TITLE_CELL];
            
            UILabel  *lblTitle  = (UILabel *)[cell.contentView viewWithTag:1];
            
            height = [AppDelegate getRealHeightFrom:lblTitle.frame.size.width content:self.wallImage.strRecipe fontname:lblTitle.font.fontName fontsize:lblTitle.font.pointSize] + 20;
            
            break;
        }
            
        case 2:{
            cell = [tableView dequeueReusableCellWithIdentifier:DESCRIPTION_CELL];
            
            UILabel  *lblIngredients = (UILabel *)[cell.contentView viewWithTag:2];
            
            height = [AppDelegate getRealHeightFrom:lblIngredients.frame.size.width content:self.wallImage.strIngredients fontname:lblIngredients.font.fontName fontsize:lblIngredients.font.pointSize] + 40;
            
            break;
        }
            
        case 3:{
            cell = [tableView dequeueReusableCellWithIdentifier:DESCRIPTION_CELL];
            
            UILabel  *lblDescriptions = (UILabel *)[cell.contentView viewWithTag:2];
            
            height = [AppDelegate getRealHeightFrom:lblDescriptions.frame.size.width content:self.wallImage.strDirections fontname:lblDescriptions.font.fontName fontsize:lblDescriptions.font.pointSize] + 40;
            
            break;
        }
            
        default:
            break;
    }
    
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
