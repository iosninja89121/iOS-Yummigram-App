//
//  ChatViewController.m
//  yummigram
//
//  Created by User on 5/11/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "ChatViewController.h"
#import "NewChatViewController.h"

@interface ChatViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tblChat;
@property (nonatomic, strong) NSMutableArray *arrData;
@end

@implementation ChatViewController
- (IBAction)onBack:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:N_MessageViewed object:nil];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tblChat.dataSource = self;
    self.tblChat.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(messageUpdated:)
                                                 name:N_MessageUpdated
                                               object:nil];
    
    [self refreshLoadData];
}

- (void) refreshLoadData{
    g_lastTotalMsgUpdate = [NSDate date];
    
    [[DataStore instance].totalMsg removeAllObjects];
    
    [AppDelegate getTotalMsg:self];
}

- (void) didGetTotalMsg{
    self.arrData = [DataStore instance].totalMsg;
    [self.tblChat reloadData];
}

- (void) messageUpdated:(NSNotification *)notification
{
    [self refreshLoadData];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    
    return self.arrData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:USER_CELL];
    
    UIImageView *imgPhoto        = (UIImageView *)[cell.contentView viewWithTag:1];
    UIButton     *btnFullName    = (UIButton *)[cell.contentView viewWithTag:2];
    UILabel      *lblDescription = (UILabel *)[cell.contentView viewWithTag:3];
    UILabel      *lblTime        = (UILabel *)[cell.contentView viewWithTag:4];
    UIImageView  *imgvBG         = (UIImageView *)[cell.contentView viewWithTag:5];
    
    TotalMsg *totalMsg = [self.arrData objectAtIndex:indexPath.row];
    
    UserInfo  *userInfo  = [AppDelegate getUserInfoFrom:totalMsg.strOtherUserObjId];
    
    NSString *strFullName = [NSString stringWithFormat:@"%@ %@", userInfo.strUserFirstName, userInfo.strUserLastName];
    
    imgPhoto.image = userInfo.imgPhoto;
    [btnFullName setTitle:strFullName forState:UIControlStateNormal];
    lblTime.text = [AppDelegate getTime:totalMsg.updatedDate];
    
    if(totalMsg.isFromMe){
        NSString *strDescription = [NSString stringWithFormat:@"You: %@", totalMsg.strMessage];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:strDescription];
        
        [attributedString addAttribute:NSForegroundColorAttributeName
                                 value:[UIColor grayColor]
                                 range:NSMakeRange(0, [@"You: " length])];
        
        lblDescription.attributedText = attributedString;
        
    }else{
        lblDescription.text = totalMsg.strMessage;
        
        if(!totalMsg.viewed){
            [imgvBG setImage:[UIImage imageNamed:@"conversations_cell_unread"]];
            lblTime.textColor = [UIColor colorWithRed:194.0f/255.0f green:169.0f/255.0f blue:132.0f/255.0f alpha:1.0f];
        }else{
            [imgvBG setImage:[UIImage imageNamed:@"conversations_cell"]];
            lblTime.textColor = [UIColor colorWithRed:143.0f/255.0f green:142.0f/255.0f blue:140.0f/255.0f alpha:1.0f];
        }
    }
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TotalMsg *totalmsg = [self.arrData objectAtIndex:indexPath.row];
    
    NewChatViewController *newChatViewCtrl = (NewChatViewController *)[self.storyboard instantiateViewControllerWithIdentifier:NEW_CHAT_VIEW_CONTROLLER];
    
    newChatViewCtrl.strOtherUserObjId = totalmsg.strOtherUserObjId;
    
    [self.navigationController pushViewController:newChatViewCtrl animated:YES];
    
    if(!totalmsg.viewed){
        totalmsg.viewed = YES;
        
        PFObject *pfObj = [[DataStore instance].totalMsgPFObjectMap objectForKey:totalmsg.strObjId];
        
        pfObj[pKeyViewed] = [[NSNumber alloc] initWithBool:YES];
        
        [pfObj saveInBackground];
        
        [tableView reloadData];
    }
    
    return nil;
}


@end
