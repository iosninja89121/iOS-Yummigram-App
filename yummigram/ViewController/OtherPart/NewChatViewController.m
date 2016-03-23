//
//  NewChatViewController.m
//  yummigram
//
//  Created by User on 5/12/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "NewChatViewController.h"

@interface NewChatViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UITableView *tblChat;
@property (weak, nonatomic) IBOutlet UITextField *tfChat;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nContentWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nContentHeight;

@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, strong) UserInfo       *otherUserInfo;

@property (nonatomic, strong) NSString *strCompoundKey;
@end

@implementation NewChatViewController
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onPost:(id)sender {
    [self.tfChat resignFirstResponder];
    NSString *strChat = self.tfChat.text;
    
    if(strChat.length > 0) [self sendChat:strChat];
    
    self.tfChat.text = @"";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tblChat.delegate = self;
    self.tblChat.dataSource = self;
    self.tfChat.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(messageUpdated:)
                                                 name:N_MessageUpdated
                                               object:nil];
    
    CGFloat fWidth  = [[UIScreen mainScreen] bounds].size.width;
    CGFloat fHeight = [[UIScreen mainScreen] bounds].size.height;
    
    self.nContentWidth.constant = fWidth;
    self.nContentHeight.constant = fHeight - 44;

    self.arrData = [[NSMutableArray alloc] init];
    self.otherUserInfo = [AppDelegate getUserInfoFrom:self.strOtherUserObjId];
    
    self.lblTitle.text = [NSString stringWithFormat:@"%@ %@", self.otherUserInfo.strUserFirstName, self.otherUserInfo.strUserLastName];
    
    self.strCompoundKey = [AppDelegate getKeyString:g_myInfo.strUserObjID secondObjectID:self.strOtherUserObjId];
    
    [self refreshLoadData];
}

- (void) refreshLoadData{
    [[DataStore instance].detailMsg removeAllObjects];
    g_lastDetailMsgUpdate = [NSDate date];
    
    [AppDelegate getDetailMsg:self compoundKey:self.strCompoundKey];
}

- (void) messageUpdated:(NSNotification *)notification
{
    [self refreshLoadData];
}

- (void) didGetDetailMsg{
    self.arrData = [DataStore instance].detailMsg;
    
    [self.tblChat reloadData];
}

- (void) sendChat:(NSString *)strChat{
    PFQuery *queryUser = [PFUser query];
    
    [queryUser whereKey:@"objectId" equalTo:self.strOtherUserObjId];
    
    PFUser *otherUser = (PFUser *)[queryUser getFirstObject];
    
    BOOL isNotifyMessage = [otherUser[pKeyNotifyMessage] boolValue];
    
    if(!isNotifyMessage) return;
    
    PFObject *detailMsgObj = [PFObject objectWithClassName:pClassDetailMsg];
    
    detailMsgObj[pKeyCompoundUser] = self.strCompoundKey;
    detailMsgObj[pKeyMainUser] = g_myInfo.strUserObjID;
    detailMsgObj[pKeyMsg] = strChat;
    
    [detailMsgObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded){

            NSString *strFirstUser  = g_myInfo.strUserObjID;
            NSString *strSecondUser = self.strOtherUserObjId;
            
            if([strFirstUser compare:strSecondUser] == NSOrderedDescending){
                strFirstUser  = self.strOtherUserObjId;
                strSecondUser = g_myInfo.strUserObjID;
            }
            
            PFQuery *totalMsgQuery = [PFQuery queryWithClassName:pClassTotalMsg];
            
            [totalMsgQuery whereKey:pKeyFirstUser  equalTo:strFirstUser];
            [totalMsgQuery whereKey:pKeySecondUser equalTo:strSecondUser];
            
            NSInteger nCount = [totalMsgQuery countObjects];
            
            PFObject *totalMsgObj = (nCount > 0) ? [totalMsgQuery getFirstObject] : [PFObject objectWithClassName:pClassTotalMsg];
            
            totalMsgObj[pKeyFirstUser]  = strFirstUser;
            totalMsgObj[pKeySecondUser] = strSecondUser;
            totalMsgObj[pKeyLastUser]   = g_myInfo.strUserObjID;
            totalMsgObj[pKeyLastMsg]    = strChat;
            totalMsgObj[pKeyViewed] = [NSNumber numberWithBool:NO];
            
            [totalMsgObj saveInBackground];
            
            DetailMsg *detailMsg = [DetailMsg initWithObject:detailMsgObj];
            
            [self.arrData addObject:detailMsg];
            
            g_lastDetailMsgUpdate = detailMsg.createdDate;
            
            [self.tblChat reloadData];
            
            NSString *strAlert = [NSString stringWithFormat:@"message from %@ %@:\n%@", g_myInfo.strUserFirstName, g_myInfo.strUserLastName, strChat];
            
            // Build the actual push notification target query
            PFQuery *query = [PFInstallation query];
            
            [query whereKey:pKeyUserObjId equalTo:self.strOtherUserObjId];
            
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                  PN_MESSAGE,                                       pnMode,
                                  PN_INCREMENT,                                     pnBadge,
                                  strAlert,                                          pnAlert,
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

#pragma TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    NSString *strComment = textField.text;
    
    if(strComment.length > 0) [self sendChat:strComment];
    
    textField.text = @"";
    
    return  YES;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    
    return [self.arrData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    DetailMsg *detailMsg = [self.arrData objectAtIndex:indexPath.row];
    BOOL isLastCell = NO;
    
    if(indexPath.row + 1 == [self.arrData count]){
        isLastCell = YES;
    }else{
        DetailMsg *nextMsg = [self.arrData objectAtIndex:indexPath.row + 1];
        
        if(nextMsg.isFromMe == detailMsg.isFromMe){
            isLastCell = NO;
        }else{
            isLastCell = YES;
        }
    }
    
    if(detailMsg.isFromMe){
        if(isLastCell)
            cell = [tableView dequeueReusableCellWithIdentifier:CHAT_ME_LAST_CELL];
        else
            cell = [tableView dequeueReusableCellWithIdentifier:CHAT_ME_GENERAL_CELL];
    }else{
        if(isLastCell)
            cell = [tableView dequeueReusableCellWithIdentifier:CHAT_OTHER_LAST_CELL];
        else
            cell = [tableView dequeueReusableCellWithIdentifier:CHAT_OTHER_GERNERAL_CELL];
    }
    
    UIView *view = (UIView *)[cell.contentView viewWithTag:1];
    
    view.layer.cornerRadius = 5;
    view.layer.masksToBounds = YES;
    view.layer.borderWidth = 1;
    view.layer.borderColor = [[UIColor colorWithRed:(229/255.0) green:(216/255.0) blue:(209/255.0) alpha:1] CGColor];
    
    UILabel *lblMessage = (UILabel *)[cell.contentView viewWithTag:2];
    lblMessage.text = detailMsg.strMessage;
    
    if(isLastCell){
        
        UILabel *lblTime    = (UILabel *)[cell.contentView viewWithTag:3];
        UIImageView *imgvPhoto = (UIImageView *)[cell.contentView viewWithTag:4];
       
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"hh:mm a"];
        
        lblTime.text = [dateFormatter stringFromDate:detailMsg.createdDate];
        
        imgvPhoto.image = (detailMsg.isFromMe)? g_myInfo.imgPhoto: self.otherUserInfo.imgPhoto;
    }
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 60;
    
    DetailMsg *detailMsg = [self.arrData objectAtIndex:indexPath.row];
    BOOL isLastCell = NO;
    
    if(indexPath.row + 1 == [self.arrData count]){
        isLastCell = YES;
    }else{
        DetailMsg *nextMsg = [self.arrData objectAtIndex:indexPath.row + 1];
        
        if(nextMsg.isFromMe == detailMsg.isFromMe){
            isLastCell = NO;
        }else{
            isLastCell = YES;
        }
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CHAT_ME_GENERAL_CELL];
    UILabel *lblMessage = (UILabel *)[cell.contentView viewWithTag:2];
    
    height = [AppDelegate getRealHeightFrom:lblMessage.frame.size.width content:detailMsg.strMessage fontname:lblMessage.font.fontName fontsize:lblMessage.font.pointSize] + 40;
    
    if(isLastCell) height = height + 20;
    
    return height;
}

@end
