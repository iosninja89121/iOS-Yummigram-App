//
//  PhoneEmailDetailViewController.m
//  yummigram
//
//  Created by User on 4/18/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "PhoneEmailDetailViewController.h"
#import "PhoneEmailDetail.h"

@interface PhoneEmailDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UITableView *tblDetail;

@property (strong, nonatomic) NSMutableArray *arrData;
@property (strong, nonatomic) PhoneEmailDetail *selItem;
@end

@implementation PhoneEmailDetailViewController
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.lblTitle.text = self.selContact.strName;
    [self loadData];
    
    self.tblDetail.delegate = self;
    self.tblDetail.dataSource = self;
    
    [self.tblDetail reloadData];
}

- (void) loadData{
    self.arrData = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < self.selContact.arrEmailAddress.count; i ++){
        PhoneEmailDetail *detailItem = [[PhoneEmailDetail alloc] init];
        
        detailItem.strLabel = [self.selContact.arrEmailLabel objectAtIndex:i];
        detailItem.strValue = [self.selContact.arrEmailAddress objectAtIndex:i];
        detailItem.category = modeEmail;
        
        [self.arrData addObject:detailItem];
    }
    
    for(int i = 0; i < self.selContact.arrPhoneNumber.count; i ++){
        PhoneEmailDetail *detailItem = [[PhoneEmailDetail alloc] init];
        
        detailItem.strLabel = [self.selContact.arrPhoneLabel objectAtIndex:i];
        detailItem.strValue = [self.selContact.arrPhoneNumber objectAtIndex:i];
        detailItem.category = modePhone;
        
        [self.arrData addObject:detailItem];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showMessageShare{
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    
    if([MFMessageComposeViewController canSendText]){
        messageController.body = @"Check out the YummiGram app on the app store";
        messageController.recipients = [NSArray arrayWithObjects:self.selItem.strValue, nil];
        [self presentViewController:messageController animated:YES completion:nil];
    }
}

- (void) showEmailShare{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        
        mailer.mailComposeDelegate = self;
        
        [mailer setSubject:@"Please Check out"];
        
        NSArray *toRecipients = [NSArray arrayWithObjects:self.selItem.strValue, nil];
        [mailer setToRecipients:toRecipients];
        
        NSString *emailBody = @"Check out the YummiGram app on the app store";
        [mailer setMessageBody:emailBody isHTML:NO];
        
        [self presentViewController:mailer animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                        message:@"Your device doesn't support the composer sheet"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
}

#pragma mark - Mail Composer

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult: (MFMailComposeResult)result error:  (NSError*)error {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - Message Composer

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result{
    switch (result) {
        case MessageComposeResultSent: NSLog(@"SENT"); [self dismissViewControllerAnimated:YES completion:nil]; break;
        case MessageComposeResultFailed: NSLog(@"FAILED"); [self dismissViewControllerAnimated:YES completion:nil]; break;
        case MessageComposeResultCancelled: NSLog(@"CANCELLED"); [self dismissViewControllerAnimated:YES completion:nil]; break;
    }
    
}

#pragma mark - Action sheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex == 0) [self showEmailShare];
    if(buttonIndex == 1) [self showMessageShare];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Check to see whether the normal table or search results table is being displayed and return the count from the appropriate array
    return [self.arrData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PHONE_DETAIL_CELL forIndexPath:indexPath];
    
    PhoneEmailDetail *detailItem = [self.arrData objectAtIndex:indexPath.row];
    
    UILabel     *lblLabel    = (UILabel *)[cell.contentView viewWithTag:1];
    UILabel     *lblValue    = (UILabel *)[cell.contentView viewWithTag:2];
    
    lblLabel.text = detailItem.strLabel;
    lblValue.text = detailItem.strValue;
    
    return cell;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Perform segue to candy detail
    self.selItem = [self.arrData objectAtIndex:indexPath.row];
    
    if(self.selItem.category == modePhone){
        [self showMessageShare];
    }else{
        NSMutableArray *shareList =[[NSMutableArray alloc] initWithObjects:@"Email", @"iMessage", nil];
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Invite"
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
