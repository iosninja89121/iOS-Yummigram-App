//
//  UIViewController+SuccontPullToRefresh.h
//  PullToRefresh
//
//  Created by Tobias Tom on 19.08.10.
//  Copyright (c) 2010 succont. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuccontPullToRefreshView.h"

@interface UIViewController (SuccontPullToRefresh)

- (void)pullToRefreshView:(SuccontPullToRefreshView *)pullToRefresh shouldHandleScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)pullToRefreshView:(SuccontPullToRefreshView *)pullToRefresh shouldHandleScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

- (void)pullToRefreshWillLoadData:(SuccontPullToRefreshView *)pullToRefresh;
- (void)pullToRefreshShouldLoadData:(SuccontPullToRefreshView *)pullToRefresh;
- (void)pullToRefreshDidLoadData:(SuccontPullToRefreshView *)pullToRefresh;

@end
