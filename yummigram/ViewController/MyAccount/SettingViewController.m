//
//  SettingViewController.m
//  yummigram
//
//  Created by User on 4/16/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "SettingViewController.h"
#import "ContactsViewController.h"

@interface SettingViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tblSetting;
@property (nonatomic) NSArray *arrTittle;
@end

@implementation SettingViewController
- (IBAction)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onLogout:(id)sender {
    [PFUser logOut];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:DEFAULT_USER_LOGGED];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UIViewController *ctrl = (UIViewController *)[self.storyboard instantiateViewControllerWithIdentifier:WELCOME_NAV_CONTROLLER];
    [UIView transitionWithView:[appDelegate window]
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^(void){
                        BOOL oldState = [UIView areAnimationsEnabled];
                        [UIView setAnimationsEnabled:NO];
                        [[appDelegate window] setRootViewController:ctrl];
                        
                        [UIView setAnimationsEnabled:oldState];
                    }
                    completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.arrTittle = @[@"Invite FB Friends", @"Invite Contact Friends", @"Support", @"Report Problem", @"Help center", @"YummiGram blog", @"Privacy policy", @"Terms of service"];
    self.tblSetting.delegate = self;
    self.tblSetting.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)inviteFBFriend
{
    
    NSDictionary *parameters = @{@"to":@""};
    
    [FBWebDialogs presentRequestsDialogModallyWithSession:FBSession.activeSession
                                                  message:@"Please Use YummiGram"
                                                    title:@"Invite Friends"
                                               parameters:parameters
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error)
     {
         if(error)
         {
             NSLog(@"Some errorr: %@", [error description]);
             UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Invitiation Sending Failed" message:@"Unable to send inviation at this Moment, please make sure your are connected with internet" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
             [alrt show];
             //[alrt release];
         }
         else
         {
             if (![resultURL query])
             {
                 return;
             }
             
             NSDictionary *params = [self parseURLParams:[resultURL query]];
             NSMutableArray *recipientIDs = [[NSMutableArray alloc] init];
             for (NSString *paramKey in params)
             {
                 if ([paramKey hasPrefix:@"to["])
                 {
                     [recipientIDs addObject:[params objectForKey:paramKey]];
                 }
             }
             if ([params objectForKey:@"request"])
             {
                 NSLog(@"Request ID: %@", [params objectForKey:@"request"]);
             }
             if ([recipientIDs count] > 0)
             {
                 UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                                message:[NSString stringWithFormat:@"%lu Invitation(s) sent successfuly!", (unsigned long)recipientIDs.count]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles: nil];
                 [alrt show];
             }
             
         }
     }friendCache:nil];
    
}

- (void) inviteContactFriends{
    ContactsViewController *contactsCtrl = (ContactsViewController *)[self.storyboard instantiateViewControllerWithIdentifier:CONTACTS_VIEW_CONTROLLER];
    
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:contactsCtrl];
    
    navCtrl.navigationBar.hidden = YES;
    
    [self presentViewController:navCtrl animated:YES completion:nil];
}

- (NSDictionary *)parseURLParams:(NSString *)query
{
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs)
    {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        
        [params setObject:[[kv objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                   forKey:[[kv objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    
    return params;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    return self.arrTittle.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SETTING_CELL forIndexPath:indexPath];
    
    UILabel     *lblTitle    = (UILabel *)[cell.contentView viewWithTag:1];
    lblTitle.text = [self.arrTittle objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch(indexPath.row){
            
        case 0:
            [self inviteFBFriend];
            break;
            
        case 1:
            [self inviteContactFriends];
            break;
            
        default:
            break;
            
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
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
