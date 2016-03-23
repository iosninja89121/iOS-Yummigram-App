//
//  SearchResultViewController.h
//  yummigram
//
//  Created by User on 6/18/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NIAttributedLabel.h>

@interface SearchResultViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,NIAttributedLabelDelegate>
@property (nonatomic, strong) NSString *strSearch;
@property (nonatomic) NSInteger nMode;
@end
