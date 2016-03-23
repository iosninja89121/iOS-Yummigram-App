//
//  EditCommentViewController.m
//  yummigram
//
//  Created by User on 5/27/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "EditCommentViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface EditCommentViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imgWallImage;
@property (weak, nonatomic) IBOutlet UITextView *tvComment;

@end

@implementation EditCommentViewController
- (IBAction)onBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onSave:(id)sender {
    NSString *strComments = self.tvComment.text;
    
    if(strComments.length == 0 || [strComments compare:STRING_HINT_COMMENT] == NSOrderedSame){
        strComments = @"";
    }
    
    if(strComments.length > 0){
        self.wallImage.strSelfComments = strComments;
        self.wallImage.arrTag = [AppDelegate getTagsFromComment:strComments];
        
        PFObject *pfObj = [[DataStore instance].wallImagePFObjectMap objectForKey:self.wallImage.strImageObjId];
        
        pfObj[pKeySelfComment] = strComments;
        pfObj[pKeyTag] = self.wallImage.arrTag;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:N_ImageDataChanged object:nil];
        
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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.imgWallImage setImageWithURL:[NSURL URLWithString:self.wallImage.image] placeholderImage:nil];
    
    self.tvComment.delegate = self;
    
    if(self.wallImage.strSelfComments.length > 0){
        self.tvComment.textColor = [UIColor blackColor];
        self.tvComment.text = self.wallImage.strSelfComments;
    }else{
        self.tvComment.textColor = [UIColor lightGrayColor];
        self.tvComment.text = STRING_HINT_COMMENT;
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Keyboard

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark -
#pragma mark UITextViewDelegate


- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    NSString* strContent = [textView text];
    
    if([strContent compare:STRING_HINT_COMMENT] != NSOrderedSame) return YES;
    
    textView.text = @"";
    textView.textColor = [UIColor blackColor];
    
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    
    if(textView.text.length == 0){
        textView.textColor = [UIColor lightGrayColor];
        textView.text = STRING_HINT_COMMENT;
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
