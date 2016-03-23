//
//  SuccontPullToRefreshView.h
//  PullToRefresh
//
//  Created by Tobias Tom on 19.08.10.
//  Copyright (c) 2010 succont. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    SuccontPullToRefreshViewStateNormal = 1,
    SuccontPullToRefreshViewStateShouldReload,
    SuccontPullToRefreshViewStateLoading
}  SuccontPullToRefreshViewState;

@interface SuccontPullToRefreshView : UIView {
    BOOL loading;
    SuccontPullToRefreshViewState state;

    NSString *normalStateString;
    NSString *shouldReloadStateString;
    NSString *loadingStateString;

    UILabel *statusLabel;
    UIImageView *reloadImageView;
    UIActivityIndicatorView *reloadActivityIndicatorView;
}

@property (nonatomic, getter=isLoading) BOOL loading;
@property (nonatomic) SuccontPullToRefreshViewState state;

@property (nonatomic, retain) NSString *normalStateString;
@property (nonatomic, retain) NSString *shouldReloadStateString;
@property (nonatomic, retain) NSString *loadingStateString;

@property (nonatomic, retain) IBOutlet UILabel *statusLabel;
@property (nonatomic, retain) IBOutlet UIImageView *reloadImageView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *reloadActivityIndicatorView;

- (void)flipView:(UIView *)aView upsideDown:(BOOL)upsideDown;

- (void)shouldDisplayNormalState;
- (void)shouldDisplayShouldReloadState;
- (void)shouldDisplayLoadingState;

@end
