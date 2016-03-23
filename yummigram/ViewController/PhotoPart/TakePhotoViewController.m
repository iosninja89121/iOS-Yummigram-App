//
//  TakePhotoViewController.m
//  yummigram
//
//  Created by User on 3/23/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "TakePhotoViewController.h"
#import "MainTabBarController.h"
#import "SharePhotoViewController.h"


@interface TakePhotoViewController ()
@property (strong, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UIView *shutterView;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnFlash;
@property (weak, nonatomic) IBOutlet UIButton *btnCamera;
@property (weak, nonatomic) IBOutlet UIButton *btnGallery;
@property (weak, nonatomic) IBOutlet UIButton *btnShutter;
@property (weak, nonatomic) IBOutlet UIButton *btnProfile;
@property (strong) UIImagePickerController *pickerGallery;
@property (strong) AVCaptureDevice *device;
@property (nonatomic) int nFlashMode;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nDHeight;
@end

@implementation TakePhotoViewController

- (IBAction)onBtnCancelClick:(id)sender {
    [self.pickerTakePhoto dismissViewControllerAnimated:NO completion:nil];
    [self dismissViewControllerAnimated:NO completion:nil];
    
    g_takePhotoCtrl = nil;
}
- (IBAction)onBtnFlashClick:(id)sender {
    if ([self.device hasTorch] && [self.device hasFlash])
    {
        [self.device lockForConfiguration:nil];
        if (self.nFlashMode == 0)
        {
            [self.device setFlashMode:AVCaptureFlashModeOn];
            self.pickerTakePhoto.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
            [self.btnFlash setImage:[UIImage imageNamed:@"btn_flash_on.png"] forState:UIControlStateNormal];
            self.nFlashMode = 1;
        }
        else if (self.nFlashMode == 1)
        {
            [self.device setFlashMode:AVCaptureFlashModeOff];
            self.pickerTakePhoto.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
            [self.btnFlash setImage:[UIImage imageNamed:@"btn_flash_off.png"] forState:UIControlStateNormal];
            self.nFlashMode = 0;
        }
    
        [self.device unlockForConfiguration];
    }

}
- (IBAction)onBtnCameraClick:(id)sender {
    if(self.pickerTakePhoto.cameraDevice == UIImagePickerControllerCameraDeviceFront){
        self.pickerTakePhoto.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        [self.btnCamera setImage:[UIImage imageNamed:@"btn_camera_rear.png"] forState:UIControlStateNormal];
    }else{
        self.pickerTakePhoto.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        [self.btnCamera setImage:[UIImage imageNamed:@"btn_camera_front.png"] forState:UIControlStateNormal];
    }
}
- (IBAction)onBtnGalleryClick:(id)sender {
    self.pickerGallery = [[UIImagePickerController alloc] init];
    self.pickerGallery.delegate = self;
    self.pickerGallery.allowsEditing = YES;
    self.pickerGallery.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self.pickerTakePhoto presentViewController:self.pickerGallery animated:YES completion:NULL];
}

- (IBAction)onBtnShutterClick:(id)sender {
//    [SVProgressHUD showWithStatus:@"Processing..." maskType:SVProgressHUDMaskTypeGradient];
    [self.pickerTakePhoto takePicture];
//    [self.overlayView setBackgroundColor:[UIColor blackColor]];
//    [NSThread sleepForTimeInterval:2];
//
    
    [self performSelector:@selector(animateShutter) withObject:nil afterDelay:0.4f];
}

- (void)animateShutter {
    
    CATransition *shutterAnimation = [CATransition animation];
    [shutterAnimation setDelegate:self];
    [shutterAnimation setDuration:0.4];
    
    shutterAnimation.timingFunction = UIViewAnimationCurveEaseInOut;
    [shutterAnimation setType:@"cameraIrisHollowClose"];
    [shutterAnimation setValue:@"cameraIrisHollowClose" forKey:@"cameraIrisHollowClose"];
    CALayer *cameraShutter = [[CALayer alloc]init];
    [cameraShutter setBounds:CGRectMake(0.0, 0.0, 320.0, 425.0)];
    [self.shutterView.layer addSublayer:cameraShutter];
    [self.shutterView.layer addAnimation:shutterAnimation forKey:@"cameraIrisHollowClose"];
}

- (IBAction)onBtnProfile:(id)sender {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    g_takePhotoCtrl = self;
    
    self.nDHeight.constant = 70 + g_dH / 3;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        self.pickerTakePhoto = [[UIImagePickerController alloc] init];
        self.pickerTakePhoto.delegate = self;
        self.pickerTakePhoto.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.pickerTakePhoto.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
        self.pickerTakePhoto.showsCameraControls = NO;
        self.pickerTakePhoto.cameraOverlayView = self.overlayView;
        self.pickerTakePhoto.allowsEditing = YES;
        self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        [self.device lockForConfiguration:nil];
//        [btnFlash setImage:[UIImage imageNamed:@"flash_auto.png"] forState:UIControlStateNormal];
        if ([self.device hasTorch] && [self.device hasFlash])
        {
            [self.device setFlashMode:AVCaptureFlashModeOff];
            self.nFlashMode = 0;
        }
        
        [self presentViewController:self.pickerTakePhoto animated:NO completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark AdobeUXImageEditorViewControllerDelegate

- (void)photoEditor:(AdobeUXImageEditorViewController *)editor finishedWithImage:(UIImage *)image
{
    // Handle the result image here
    [editor dismissViewControllerAnimated:NO completion:nil];
    
    g_originalImage = image;
    
    SharePhotoViewController *shareCtrl = (SharePhotoViewController *)[self.storyboard instantiateViewControllerWithIdentifier:SHARE_PHOTO_VIEW_CONTROLLER];
    
    [self.pickerTakePhoto presentViewController:shareCtrl animated:YES completion:nil];
}

- (void)photoEditorCanceled:(AdobeUXImageEditorViewController *)editor
{
    // Handle cancellation here
    [editor dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark ImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{

    UIImage *takenImage = [AppDelegate squareImageWithImage:[info objectForKey:@"UIImagePickerControllerOriginalImage"] scaledToSize:CGSizeMake(450, 450)];
    
    g_originalImage = takenImage;
    
    if(picker == self.pickerGallery) [picker dismissViewControllerAnimated:NO completion:nil];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:DEFAULT_USER_PHOTO_EFFECT]){
        static dispatch_once_t onceToken;
        
        dispatch_once(&onceToken, ^{
            [AdobeUXImageEditorViewController setAPIKey:kAdobeAPIKey secret:kAdobeSecret];
        });
        
        AdobeUXImageEditorViewController *editorCtrl = [[AdobeUXImageEditorViewController alloc] initWithImage:g_originalImage];
        [AdobeImageEditorCustomization setToolOrder:@[kAdobeImageEditorEffects, kAdobeImageEditorFocus, kAdobeImageEditorEnhance, kAdobeImageEditorOrientation, kAdobeImageEditorLightingAdjust]];
        
        [editorCtrl setDelegate:self];
        
        [self.pickerTakePhoto presentViewController:editorCtrl animated:YES completion:nil];
    }else{
        SharePhotoViewController *shareCtrl = (SharePhotoViewController *)[self.storyboard instantiateViewControllerWithIdentifier:SHARE_PHOTO_VIEW_CONTROLLER];
        
        [self.pickerTakePhoto presentViewController:shareCtrl animated:YES completion:nil];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
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
