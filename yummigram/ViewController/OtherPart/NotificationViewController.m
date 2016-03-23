//
//  NotificationViewController.m
//  yummigram
//
//  Created by User on 5/11/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "NotificationViewController.h"
#import "ProfileViewController.h"
#import "PostCommentViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface NotificationViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tblNotification;

@property (nonatomic) NSArray *arrNotifyCategory;
@property (nonatomic) NSMutableArray *arrData;
@end

@implementation NotificationViewController
- (IBAction)onBack:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:N_NotifyViewed object:nil];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tblNotification.delegate = self;
    self.tblNotification.dataSource = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notifyUpdated:)
                                                 name:N_NotifyUpdated
                                               object:nil];
    
    self.arrNotifyCategory = @[@"started following", @"liked", @"commented to", @"added to favorites", @"requested the recipe to"];
    
    if([DataStore instance].notifyPosts.count == 0) [AppDelegate getNotifyPosts:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) notifyUpdated:(NSNotification *)notification
{
    [self.tblNotification reloadData];
}

- (void) didGetNotifyPosts{
    [self.tblNotification reloadData];
}

- (void) onGoEvent:(id) sender{
    UIView *senderView = (UIView *)sender;
    
    NSInteger nIdx = [senderView.accessibilityIdentifier integerValue];
    
    NotifyPost *notifyPost = [[DataStore instance].notifyPosts objectAtIndex:nIdx];
    
    if(notifyPost.nType == 0){
        ProfileViewController *profileViewCtrl = (ProfileViewController *)[self.storyboard instantiateViewControllerWithIdentifier:PROFILE_VIEW_CONTROLLER];
        
        profileViewCtrl.strUserObjID = notifyPost.strOtherUserObjId;
        
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:profileViewCtrl];
        
        navCtrl.navigationBar.hidden = YES;
        
        [self.navigationController presentViewController:navCtrl animated:YES completion:nil];
    }else{
        WallImage *wallImage = [[DataStore instance].wallImageMap objectForKey:notifyPost.strImageObjId];
        
        PostCommentViewController *commentViewCtrl = (PostCommentViewController *)[self.storyboard instantiateViewControllerWithIdentifier:POST_COMMENT_VIEW_CONTROLLER];
        commentViewCtrl.wallImage = wallImage;
        [self presentViewController:commentViewCtrl animated:YES completion:nil];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    
    return [[DataStore instance].notifyPosts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:USER_CELL];
    
    UIImageView *imgPhoto        = (UIImageView *)[cell.contentView viewWithTag:1];
    UIButton     *btnFullName    = (UIButton *)[cell.contentView viewWithTag:2];
    UILabel      *lblNotify      = (UILabel *)[cell.contentView viewWithTag:3];
    UILabel      *lblTime        = (UILabel *)[cell.contentView viewWithTag:4];
    UIImageView  *imgWall        = (UIImageView *)[cell.contentView viewWithTag:5];
    UILabel      *lblYourPost    = (UILabel *)[cell.contentView viewWithTag:6];
    UIImageView  *imgvBG         = (UIImageView *)[cell.contentView viewWithTag:7];
    
    NotifyPost *notifyPost = [[DataStore instance].notifyPosts objectAtIndex:indexPath.row];

    if(notifyPost.nType == notifyFollowing){
        [imgWall setHidden:YES];
    }else{
        WallImage *wallImage = [[DataStore instance].wallImageMap objectForKey:notifyPost.strImageObjId];
        
        [imgWall setImageWithURL:[NSURL URLWithString:wallImage.image] placeholderImage:nil];
    }
    
    UserInfo  *userInfo  = [AppDelegate getUserInfoFrom:notifyPost.strOtherUserObjId];
    
    NSString *strFullName = [NSString stringWithFormat:@"%@ %@", userInfo.strUserFirstName, userInfo.strUserLastName];
    
    imgPhoto.image = userInfo.imgPhoto;
    [btnFullName setTitle:strFullName forState:UIControlStateNormal];
    lblTime.text = [AppDelegate getTime:notifyPost.createdDate];
   
    btnFullName.accessibilityIdentifier = @(indexPath.row).stringValue;
    
    [btnFullName addTarget:self action:@selector(onGoEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *strNotifyCat   = [self.arrNotifyCategory objectAtIndex:notifyPost.nType];
    NSString *strYourPost = (notifyPost.nType == 0) ? @"you" : @"your post";
    
    lblNotify.text = strNotifyCat;
    lblYourPost.text = strYourPost;
    
    if(!notifyPost.viewed){
        [imgvBG setImage:[UIImage imageNamed:@"conversations_cell_unread"]];
        lblTime.textColor = [UIColor colorWithRed:194.0f/255.0f green:169.0f/255.0f blue:132.0f/255.0f alpha:1.0f];
    }else{
        [imgvBG setImage:[UIImage imageNamed:@"conversations_cell"]];
        lblTime.textColor = [UIColor colorWithRed:143.0f/255.0f green:142.0f/255.0f blue:140.0f/255.0f alpha:1.0f];
    }
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 70;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NotifyPost *notifyPost = [[DataStore instance].notifyPosts objectAtIndex:indexPath.row];
    
    if(notifyPost.nType == 0){
        ProfileViewController *profileViewCtrl = (ProfileViewController *)[self.storyboard instantiateViewControllerWithIdentifier:PROFILE_VIEW_CONTROLLER];
        
        profileViewCtrl.strUserObjID = notifyPost.strOtherUserObjId;
        
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:profileViewCtrl];
        
        navCtrl.navigationBar.hidden = YES;
        
        [self.navigationController presentViewController:navCtrl animated:YES completion:nil];
    }else{
        WallImage *wallImage = [[DataStore instance].wallImageMap objectForKey:notifyPost.strImageObjId];
        
        if(wallImage == nil) {
            PFQuery *wallImageQuery = [PFQuery queryWithClassName:pClassWallImageOther];
            PFObject *wallImageObj = [wallImageQuery getObjectWithId:notifyPost.strImageObjId];
            
            wallImage = [AppDelegate getImageDataFrom:wallImageObj];
        }
        
        PostCommentViewController *commentViewCtrl = (PostCommentViewController *)[self.storyboard instantiateViewControllerWithIdentifier:POST_COMMENT_VIEW_CONTROLLER];
        commentViewCtrl.wallImage = wallImage;
        [self presentViewController:commentViewCtrl animated:YES completion:nil];
    }
    
    if(!notifyPost.viewed){
        notifyPost.viewed = YES;
        
        PFObject *pfObj = [[DataStore instance].userNotifyPostPFObjectMap objectForKey:notifyPost.strObjId];
        
        pfObj[pKeyViewed] = [[NSNumber alloc] initWithBool:YES];
        
        [pfObj saveInBackground];
        
        [tableView reloadData];
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == [DataStore instance].notifyPosts.count - 2) {
        [AppDelegate getNotifyPosts:self];
    }
}


@end
