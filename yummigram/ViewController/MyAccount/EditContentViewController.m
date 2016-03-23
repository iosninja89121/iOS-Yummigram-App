//
//  EditContentViewController.m
//  yummigram
//
//  Created by User on 4/17/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "EditContentViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface EditContentViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UITextView *tvComments;
@property (weak, nonatomic) IBOutlet UITextView *tvRecipe;
@property (weak, nonatomic) IBOutlet UITextView *tvIngredients;
@property (weak, nonatomic) IBOutlet UITextView *tvDirections;

@end

@implementation EditContentViewController
- (IBAction)onBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onSave:(id)sender {
    NSString *strComments = self.tvComments.text;
    NSString *strRecipe = self.tvRecipe.text;
    NSString *strDirections = self.tvDirections.text;
    NSString *strIngredients = self.tvIngredients.text;
    
    if(strRecipe.length == 0  || [strRecipe compare:STRING_HINT_RECIPE_NAME] == NSOrderedSame){
        strRecipe = @"";
    }
    
    if(strIngredients.length == 0  || [strRecipe compare:STRING_HINT_INGREDIENTS] == NSOrderedSame){
        strIngredients = @"";
    }
    
    if(strDirections.length == 0  || [strRecipe compare:STRING_HINT_DIRECTIONS] == NSOrderedSame){
        strDirections = @"";
    }
    
    if(strComments.length == 0 || [strComments compare:STRING_HINT_COMMENT] == NSOrderedSame){
        strComments = @"";
    }
    
    if(strComments.length > 0){
        PFObject *commentObj = [PFObject objectWithClassName:pClassWallImageComments];
        
        commentObj[pKeyComments]   = strComments;
        commentObj[pKeyUserObjId]  = self.wallImage.strUserObjId;
        commentObj[pKeyUserFBId]   = self.wallImage.strUserFBId;
        commentObj[pKeyImageObjId] = self.wallImage.strImageObjId;
        
        [commentObj saveInBackground];
    }
    
    PFObject *pfObj = [[DataStore instance].wallImagePFObjectMap objectForKey:self.wallImage.strImageObjId];
    
    pfObj[pKeyRecipe] = strRecipe;
    pfObj[pKeyIngredients] = strIngredients;
    pfObj[pKeyDirections] = strDirections;
    
    self.wallImage.strDirections = strDirections;
    self.wallImage.strIngredients = strIngredients;
    self.wallImage.strRecipe = strRecipe;
    
    [SVProgressHUD showWithStatus:@"Updating..." maskType:SVProgressHUDMaskTypeGradient];
    
    [pfObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            [SVProgressHUD dismiss];
            
            [self onBack:nil];
        }else{
            [SVProgressHUD showErrorWithStatus: [error.userInfo objectForKey:@"error"]];
        }

    }];


}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.imgView setImageWithURL:[NSURL URLWithString:self.wallImage.image] placeholderImage:nil];
    
    self.tvComments.delegate = self;
    self.tvRecipe.delegate = self;
    self.tvIngredients.delegate = self;
    self.tvDirections.delegate = self;
    
    if(self.wallImage.strRecipe.length > 0){
        self.tvRecipe.textColor = [UIColor blackColor];
        self.tvRecipe.text = self.wallImage.strRecipe;
    }else{
        self.tvRecipe.textColor = [UIColor lightGrayColor];
        self.tvRecipe.text = STRING_HINT_RECIPE_NAME;
    }
    
    if(self.wallImage.strIngredients.length > 0){
        self.tvIngredients.textColor = [UIColor blackColor];
        self.tvIngredients.text = self.wallImage.strIngredients;
    }else{
        self.tvIngredients.textColor = [UIColor lightGrayColor];
        self.tvIngredients.text = STRING_HINT_INGREDIENTS;
    }
    
    if(self.wallImage.strDirections.length > 0){
        self.tvDirections.textColor = [UIColor blackColor];
        self.tvDirections.text = self.wallImage.strDirections;
    }else{
        self.tvDirections.textColor = [UIColor lightGrayColor];
        self.tvDirections.text = STRING_HINT_DIRECTIONS;
    }
    
    self.tvComments.textColor = [UIColor lightGrayColor];
    self.tvComments.text = STRING_HINT_COMMENT;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UITextViewDelegate


- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    NSString* strContent = [textView text];
    
    if([strContent compare:STRING_HINT_COMMENT] != NSOrderedSame && textView == self.tvComments) return YES;
    if([strContent compare:STRING_HINT_RECIPE_NAME] != NSOrderedSame && textView == self.tvRecipe) return YES;
    if([strContent compare:STRING_HINT_INGREDIENTS] != NSOrderedSame && textView == self.tvIngredients) return YES;
    if([strContent compare:STRING_HINT_DIRECTIONS] != NSOrderedSame && textView == self.tvDirections) return YES;
    
    textView.text = @"";
    textView.textColor = [UIColor blackColor];
    
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    
    if(textView.text.length == 0){
        textView.textColor = [UIColor lightGrayColor];
        
        if(textView == self.tvComments)    textView.text = STRING_HINT_COMMENT;
        if(textView == self.tvRecipe)  textView.text = STRING_HINT_RECIPE_NAME;
        if(textView == self.tvIngredients) textView.text = STRING_HINT_INGREDIENTS;
        if(textView == self.tvDirections)  textView.text = STRING_HINT_DIRECTIONS;
        
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
