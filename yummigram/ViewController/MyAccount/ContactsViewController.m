//
//  ContactsViewController.m
//  yummigram
//
//  Created by User on 4/18/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "ContactsViewController.h"
#import <AddressBook/AddressBook.h>
#import "PhoneEmailDetailViewController.h"
#import "Friend.h"

@interface ContactsViewController ()
@property (weak, nonatomic) IBOutlet UISearchBar *contactSearchBar;
@property (weak, nonatomic) IBOutlet UITableView *tblContacts;

@property (strong, nonatomic) NSMutableArray *arrContacts;
@property (strong, nonatomic) NSMutableArray *arrFilteredContacts;
@end

@implementation ContactsViewController
- (IBAction)onBack:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tblContacts.delegate = self;
    self.tblContacts.dataSource = self;
    
    [self getContacts];
    self.arrFilteredContacts = [NSMutableArray arrayWithCapacity:[self.arrContacts count]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)getContacts{
    
    self.arrContacts = [[NSMutableArray alloc] init];
    
    CFErrorRef *error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        if (granted) {
            
            CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
            CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
            
            for (int i = 0; i < numberOfPeople; i ++) {
                ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
                ABMultiValueRef emailAddress = ABRecordCopyValue(person, kABPersonEmailProperty);
                ABMultiValueRef phoneNumber = ABRecordCopyValue(person, kABPersonPhoneProperty);
                
                Friend *friend = [[Friend alloc] init];
                
                NSString *fname = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
                if (fname == NULL) {
                    fname = @"";
                }
                
                NSString *lname = (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
                if (lname == NULL) {
                    lname = @"";
                }
                
                NSString *name = [NSString stringWithFormat:@"%@ %@", fname, lname];
                friend.strName = name;
                
                for(int j = 0; j < ABMultiValueGetCount(phoneNumber); j ++){
                    NSString *strPhone = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumber, j);
                    CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(phoneNumber, j);
                    NSString *strLabel = (__bridge_transfer NSString *) ABAddressBookCopyLocalizedLabel(locLabel);
                    
                    [friend.arrPhoneLabel addObject:strLabel];
                    [friend.arrPhoneNumber addObject:strPhone];
                }
                
                for(int j = 0; j < ABMultiValueGetCount(emailAddress); j ++){
                    NSString *strEmail = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(emailAddress, j);
                    CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(emailAddress, j);
                    NSString *strLabel = (__bridge_transfer NSString *) ABAddressBookCopyLocalizedLabel(locLabel);
                    
                    
                    [friend.arrEmailLabel addObject:strLabel];
                    [friend.arrEmailAddress addObject:strEmail];
                }
                
                [self.arrContacts addObject:friend];
            }
            
            [self.tblContacts performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    });
}

#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [self.arrFilteredContacts removeAllObjects];
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.strName contains[c] %@",searchText];
    self.arrFilteredContacts = [NSMutableArray arrayWithArray:[self.arrContacts filteredArrayUsingPredicate:predicate]];
}

#pragma mark - UISearchDisplayController Delegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Check to see whether the normal table or search results table is being displayed and return the count from the appropriate array
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return [self.arrFilteredContacts count];
    }
    else
    {
        return [self.arrContacts count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Create a new Candy Object
    Friend *friend = nil;
    
    // Check to see whether the normal table or search results table is being displayed and set the Candy object from the appropriate array
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        friend = [self.arrFilteredContacts objectAtIndex:[indexPath row]];
    }
    else
    {
        friend = [self.arrContacts objectAtIndex:[indexPath row]];
    }
    
    // Configure the cell
    [[cell textLabel] setText:[friend strName]];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Perform segue to candy detail
    [self performSegueWithIdentifier:SG_PHONE_DETAIL sender:tableView];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ( [[segue identifier] isEqualToString:SG_PHONE_DETAIL] ) {
        PhoneEmailDetailViewController *phoneEmailCtrl = [segue destinationViewController];
        
        // In order to manipulate the destination view controller, another check on which table (search or normal) is displayed is needed
        if(sender == self.searchDisplayController.searchResultsTableView) {
            NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            
            phoneEmailCtrl.selContact = [self.arrFilteredContacts objectAtIndex:[indexPath row]];
        }
        else {
            NSIndexPath *indexPath = [self.tblContacts indexPathForSelectedRow];
            
            phoneEmailCtrl.selContact = [self.arrContacts objectAtIndex:[indexPath row]];
        }
    }
}

@end
