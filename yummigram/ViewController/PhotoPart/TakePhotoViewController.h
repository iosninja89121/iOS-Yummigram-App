//
//  TakePhotoViewController.h
//  yummigram
//
//  Created by User on 3/23/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AdobeCreativeSDKImage/AdobeCreativeSDKImage.h>

@interface TakePhotoViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate, AdobeUXImageEditorViewControllerDelegate>
@property (strong) UIImagePickerController *pickerTakePhoto;
@end
