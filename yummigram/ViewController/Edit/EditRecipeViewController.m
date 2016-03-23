//
//  EditRecipeViewController.m
//  yummigram
//
//  Created by User on 5/27/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "EditRecipeViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface EditRecipeViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imgWallImage;
@property (weak, nonatomic) IBOutlet UITextView *tvRecipe;
@property (weak, nonatomic) IBOutlet UITextView *tvIngrediants;
@property (weak, nonatomic) IBOutlet UITextView *tvDirections;

@end

@implementation EditRecipeViewController
- (IBAction)onBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onSave:(id)sender {
    [self proceedFieldEntris];
}

- (void) proceedFieldEntris{
    NSString *strRecipe = self.tvRecipe.text;
    NSString *strDirections = self.tvDirections.text;
    NSString *strIngredients = self.tvIngrediants.text;
    
    if(strRecipe.length == 0  || [strRecipe compare:STRING_HINT_RECIPE_NAME] == NSOrderedSame){
        strRecipe = @"";
    }
    
    if(strIngredients.length == 0  || [strRecipe compare:STRING_HINT_INGREDIENTS] == NSOrderedSame){
        strIngredients = @"";
    }
    
    if(strDirections.length == 0  || [strRecipe compare:STRING_HINT_DIRECTIONS] == NSOrderedSame){
        strDirections = @"";
    }
    
    PFObject *pfObj = [[DataStore instance].wallImagePFObjectMap objectForKey:self.wallImage.strImageObjId];
    
    pfObj[pKeyRecipe] = strRecipe;
    pfObj[pKeyIngredients] = strIngredients;
    pfObj[pKeyDirections] = strDirections;
    
    if(strRecipe.length > 0) {
        pfObj[pKeyIsRecipe] = @(1);
    }
    
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
    [self.imgWallImage setImageWithURL:[NSURL URLWithString:self.wallImage.image] placeholderImage:nil];
    
    self.tvRecipe.delegate = self;
    self.tvIngrediants.delegate = self;
    self.tvDirections.delegate = self;
    
    if(self.wallImage.strRecipe.length > 0){
        self.tvRecipe.textColor = [UIColor blackColor];
        self.tvRecipe.text = self.wallImage.strRecipe;
    }else{
        self.tvRecipe.textColor = [UIColor lightGrayColor];
        self.tvRecipe.text = STRING_HINT_RECIPE_NAME;
    }
    
    if(self.wallImage.strIngredients.length > 0){
        self.tvIngrediants.textColor = [UIColor blackColor];
        self.tvIngrediants.text = self.wallImage.strIngredients;
    }else{
        self.tvIngrediants.textColor = [UIColor lightGrayColor];
        self.tvIngrediants.text = STRING_HINT_INGREDIENTS;
    }
    
    if(self.wallImage.strDirections.length > 0){
        self.tvDirections.textColor = [UIColor blackColor];
        self.tvDirections.text = self.wallImage.strDirections;
    }else{
        self.tvDirections.textColor = [UIColor lightGrayColor];
        self.tvDirections.text = STRING_HINT_DIRECTIONS;
    }
    
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
    
    self.tvRecipe.inputAccessoryView = toolBar;
    self.tvIngrediants.inputAccessoryView = toolBar;
    self.tvDirections.inputAccessoryView = toolBar;
}

-(IBAction)barButtonPrevious:(UIBarButtonItem*)sender
{
    if(self.tvIngrediants.isFirstResponder){
        [self.tvRecipe becomeFirstResponder];
    }else if(self.tvDirections.isFirstResponder){
        [self.tvIngrediants becomeFirstResponder];
    }
}

-(IBAction)barButtonNext:(UIBarButtonItem*)sender
{
    if(self.tvRecipe.isFirstResponder){
        [self.tvIngrediants becomeFirstResponder];
    }else if(self.tvIngrediants.isFirstResponder){
        [self.tvDirections becomeFirstResponder];
    }
}

-(IBAction)barButtonSave:(UIBarButtonItem*)sender
{
    [self proceedFieldEntris];
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
    
    if([strContent compare:STRING_HINT_RECIPE_NAME] != NSOrderedSame && textView == self.tvRecipe) return YES;
    if([strContent compare:STRING_HINT_INGREDIENTS] != NSOrderedSame && textView == self.tvIngrediants) return YES;
    if([strContent compare:STRING_HINT_DIRECTIONS] != NSOrderedSame && textView == self.tvDirections) return YES;
    
    textView.text = @"";
    textView.textColor = [UIColor blackColor];
    
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    
    if(textView.text.length == 0){
        textView.textColor = [UIColor lightGrayColor];
        
        if(textView == self.tvRecipe)  textView.text = STRING_HINT_RECIPE_NAME;
        if(textView == self.tvIngrediants) textView.text = STRING_HINT_INGREDIENTS;
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
