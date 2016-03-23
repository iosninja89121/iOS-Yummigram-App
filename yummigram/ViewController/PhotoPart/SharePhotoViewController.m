  //
//  SharePhotoViewController.m
//  yummigram
//
//  Created by User on 3/26/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "SharePhotoViewController.h"
#import "TakePhotoViewController.h"
#import <SVProgressHUD.h>

@interface SharePhotoViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imgViewPhoto;
@property (weak, nonatomic) IBOutlet UITextView *txtViewComments;
@property (weak, nonatomic) IBOutlet UITextView *txtViewRecipeName;
@property (weak, nonatomic) IBOutlet UITextView *txtViewIngrediants;
@property (weak, nonatomic) IBOutlet UITextView *txtViewDirections;
@property (weak, nonatomic) IBOutlet UIButton *btnCheckBox;
@property (nonatomic) BOOL  flagChecked;
@property (nonatomic, strong) NSData  *imageData;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nContentHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nContentWidth;
@end

@implementation SharePhotoViewController
- (IBAction)onBackButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)onCheckBoxClick:(id)sender {
    self.flagChecked = ! self.flagChecked;
    if(self.flagChecked){
        [self.btnCheckBox setImage:[UIImage imageNamed:@"icon_check"] forState:UIControlStateNormal];
    }else{
        [self.btnCheckBox setImage:[UIImage imageNamed:@"icon_uncheck"] forState:UIControlStateNormal];
    }
}
- (IBAction)onShareOnlyPhotoClick:(id)sender {

    [self uploadImage:NO];
    
}
- (IBAction)onShareRecipeClick:(id)sender {
    
    [self uploadImage:YES];
}

- (void) uploadImage:(BOOL) modeShareWithRecipe{
    
    NSString *strComments    = self.txtViewComments.text;
    NSString *strRecipe      = self.txtViewRecipeName.text;
    NSString *strIngredients = self.txtViewIngrediants.text;
    NSString *strDirections  = self.txtViewDirections.text;
    
    if(modeShareWithRecipe){
        if(strRecipe.length == 0  || [strRecipe compare:STRING_HINT_RECIPE_NAME] == NSOrderedSame){
            [SVProgressHUD showErrorWithStatus:@"Please add the recipe name"];
            return;
        }
        
        if(strIngredients.length == 0  || [strRecipe compare:STRING_HINT_INGREDIENTS] == NSOrderedSame){
            [SVProgressHUD showErrorWithStatus:@"Please add the ingredient"];
            return;
        }
        
        if(strDirections.length == 0  || [strRecipe compare:STRING_HINT_DIRECTIONS] == NSOrderedSame){
            [SVProgressHUD showErrorWithStatus:@"Please add the directions"];
            return;
        }
    }
    
    if(strComments.length == 0 || [strComments compare:STRING_HINT_COMMENT] == NSOrderedSame){
        strComments = @"";
    }
    
    if(self.flagChecked){
        if(g_myInfo.strFacebookToken.length == 0){
            [SVProgressHUD showErrorWithStatus:@"You have no facebook account, please set up the facebook account"];
            return;
        }else{
            NSString *strRealComments = @"";
            
            if(modeShareWithRecipe){
                strRealComments = [NSString stringWithFormat:@"%@ RECIPE -> www.yummigram.com/recipeid\n%@", strRecipe, strComments];
            }else{
                strRealComments = [NSString stringWithFormat:@"%@\nShared via Yummigram -> www.yummigram.com", strComments];
            }
            
            [AppDelegate postImageToFB:g_originalImage comments:strRealComments];
        }
    }

    // 2
    PFFile *imageFile = [PFFile fileWithName:@"img" data:self.imageData];
    
    [SVProgressHUD showWithStatus:@"Uploading..." maskType:SVProgressHUDMaskTypeGradient];
    
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // 3
            PFObject *wallImageObject = [PFObject objectWithClassName:pClassWallImageOther];

            wallImageObject[pKeyImage]        = imageFile.url;
            wallImageObject[pKeyUserFBId]     = g_myInfo.strFacebookID;
            wallImageObject[pKeyUserObjId]    = g_myInfo.strUserObjID;
            wallImageObject[pKeyUserFullName] = [NSString stringWithFormat:@"%@ %@", g_myInfo.strUserFirstName, g_myInfo.strUserLastName];
            wallImageObject[pKeySelfComment]  = strComments;
            wallImageObject[pKeyTag]          = [AppDelegate getTagsFromComment:strComments];
            wallImageObject[pKeyCity]         = [DataStore instance].strCity;
            wallImageObject[pKeyCountry]      = [DataStore instance].strCountry;
            
            if(modeShareWithRecipe){
                wallImageObject[pKeyRecipe]      = strRecipe;
                wallImageObject[pKeyIngredients] = strIngredients;
                wallImageObject[pKeyDirections]  = strDirections;
                wallImageObject[pKeyIsRecipe] = @(1);
            }else{
                wallImageObject[pKeyIsRecipe] = @(0);
            }
            
            wallImageObject[pKeyLikes]     = [[NSArray alloc] init];
            wallImageObject[pKeyFavorites] = [[NSArray alloc] init];
            
            [wallImageObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(succeeded){
                    [SVProgressHUD dismiss];

                    [g_myInfo.arrWallImages addObject:wallImageObject.objectId];
                    
                    PFUser *currentUser = [PFUser currentUser];

                    [currentUser addUniqueObject:wallImageObject.objectId forKey:pKeyWallImages];
                    
                    [currentUser saveInBackground];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:N_ImageUploaded object:nil];
                    [self dismissViewControllerAnimated:NO completion:^{
                        
                        [((TakePhotoViewController *)g_takePhotoCtrl).pickerTakePhoto dismissViewControllerAnimated:NO completion:nil];
                        [g_takePhotoCtrl dismissViewControllerAnimated:YES completion:nil];
                    }];
                }else{
                    [SVProgressHUD showErrorWithStatus: [error.userInfo objectForKey:@"error"]];
                }
            }];
        } else {
            // 7
            [SVProgressHUD showErrorWithStatus: [error.userInfo objectForKey:@"error"]];
        }
    }];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.txtViewComments.delegate = self;
    self.txtViewRecipeName.delegate = self;
    self.txtViewIngrediants.delegate = self;
    self.txtViewDirections.delegate = self;
    
    self.txtViewComments.text = STRING_HINT_COMMENT;
    self.txtViewComments.textColor = [UIColor lightGrayColor];
    
    self.txtViewRecipeName.text = STRING_HINT_RECIPE_NAME;
    self.txtViewRecipeName.textColor = [UIColor lightGrayColor];
    
    self.txtViewIngrediants.text = STRING_HINT_INGREDIENTS;
    self.txtViewIngrediants.textColor = [UIColor lightGrayColor];
    
    self.txtViewDirections.text = STRING_HINT_DIRECTIONS;
    self.txtViewDirections.textColor = [UIColor lightGrayColor];
    
    [self.btnCheckBox setImage:[UIImage imageNamed:@"icon_uncheck"] forState:UIControlStateNormal];
    self.flagChecked = NO;
    
    CGFloat compression = 1.0f;
    CGFloat maxCompression = 0.01f;
    
    self.imageData = UIImageJPEGRepresentation(g_originalImage, compression);
    
    NSInteger maxFileSize = [self.imageData length] * 8 / 10;
    
    while([self.imageData length] > maxFileSize && compression > maxCompression){
        compression -= 0.01;
        self.imageData = UIImageJPEGRepresentation(g_originalImage, compression);
    }
    
    UIImage *compressedImage = [AppDelegate squareImageWithImage:[UIImage imageWithData:self.imageData] scaledToSize:CGSizeMake(450, 450)];
    
    NSLog(@"%@:%@", @([UIImageJPEGRepresentation(g_originalImage, 1.0) length]).stringValue, @([self.imageData length]).stringValue);
    
    [self.imgViewPhoto setImage:compressedImage];
    
    CGFloat fWidth  = [[UIScreen mainScreen] bounds].size.width;
    CGFloat fHeight = [[UIScreen mainScreen] bounds].size.height;
    
    self.nContentWidth.constant = fWidth;
    self.nContentHeight.constant = fHeight - 44;

    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f,
                                                                     self.view.window.frame.size.width, 44.0f)];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        toolBar.tintColor = [UIColor colorWithRed:0.6f green:0.6f blue:0.64f alpha:1.0f];
    }
    else
    {
        toolBar.tintColor = [UIColor colorWithRed:0.56f green:0.59f blue:0.63f alpha:1.0f];
    }
    
    toolBar.translucent = NO;
    toolBar.items =   @[ [[UIBarButtonItem alloc] initWithTitle:@"Previous"
                                                          style:UIBarButtonItemStyleBordered
                                                         target:self
                                                         action:@selector(barButtonPrevious:)],
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                       target:nil
                                                                       action:nil],
                         [[UIBarButtonItem alloc] initWithTitle:@"Next"
                                                          style:UIBarButtonItemStyleBordered
                                                         target:self
                                                         action:@selector(barButtonNext:)],
                         [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                       target:nil
                                                                       action:nil],
                         [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                          style:UIBarButtonItemStyleBordered
                                                         target:self
                                                         action:@selector(barButtonSave:)]
                         ];
    
    self.txtViewRecipeName.inputAccessoryView = toolBar;
    self.txtViewIngrediants.inputAccessoryView = toolBar;
    self.txtViewDirections.inputAccessoryView = toolBar;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)barButtonPrevious:(UIBarButtonItem*)sender
{
    if(self.txtViewIngrediants.isFirstResponder){
        [self.txtViewRecipeName becomeFirstResponder];
    }else if(self.txtViewDirections.isFirstResponder){
        [self.txtViewIngrediants becomeFirstResponder];
    }
}

-(IBAction)barButtonNext:(UIBarButtonItem*)sender
{
    if(self.txtViewRecipeName.isFirstResponder){
        [self.txtViewIngrediants becomeFirstResponder];
    }else if(self.txtViewIngrediants.isFirstResponder){
        [self.txtViewDirections becomeFirstResponder];
    }
}

-(IBAction)barButtonSave:(UIBarButtonItem*)sender
{
    [self uploadImage:YES];
}

#pragma mark -
#pragma mark UITextViewDelegate


- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    NSString* strContent = [textView text];
    
    if([strContent compare:STRING_HINT_COMMENT] != NSOrderedSame && textView == self.txtViewComments) return YES;
    if([strContent compare:STRING_HINT_RECIPE_NAME] != NSOrderedSame && textView == self.txtViewRecipeName) return YES;
    if([strContent compare:STRING_HINT_INGREDIENTS] != NSOrderedSame && textView == self.txtViewIngrediants) return YES;
    if([strContent compare:STRING_HINT_DIRECTIONS] != NSOrderedSame && textView == self.txtViewDirections) return YES;
  
    textView.text = @"";
    textView.textColor = [UIColor blackColor];
    
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    
    if(textView.text.length == 0){
        textView.textColor = [UIColor lightGrayColor];
        
        if(textView == self.txtViewComments)    textView.text = STRING_HINT_COMMENT;
        if(textView == self.txtViewRecipeName)  textView.text = STRING_HINT_RECIPE_NAME;
        if(textView == self.txtViewIngrediants) textView.text = STRING_HINT_INGREDIENTS;
        if(textView == self.txtViewDirections)  textView.text = STRING_HINT_DIRECTIONS;
        
        [textView resignFirstResponder];
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
