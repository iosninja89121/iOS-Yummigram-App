//
//  UIViewController+SuccontPullToRefresh.m
//  Succont
//
//  Created by Tobias Tom on 19.08.10.
//  Copyright (c) 2010 succont. All rights reserved.
//

#import "UIViewController+SuccontPullToRefresh.h"

@implementation UIViewController (SuccontPullToRefresh)

- (void)pullToRefreshView:(SuccontPullToRefreshView *)pullToRefresh shouldHandleScrollViewDidScroll:(UIScrollView *)scrollView {
    if ( pullToRefresh.isLoading ) {
        return;
    }
    
    pullToRefresh.state = pullToRefresh.frame.size.height + 40 < ABS( scrollView.contentOffset.y ) ? SuccontPullToRefreshViewStateShouldReload : SuccontPullToRefreshViewStateNormal;
}

- (void)pullToRefreshView:(SuccontPullToRefreshView *)pullToRefresh shouldHandleScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ( pullToRefresh.isLoading ) {
        return;
    }
    
    if ( SuccontPullToRefreshViewStateShouldReload != pullToRefresh.state || scrollView.contentOffset.y >= 0 ) {
        return;
    }
    
    if ( pullToRefresh.frame.size.height + 40 > ABS( scrollView.contentOffset.y ) ) {
        return;
    }

    [self pullToRefreshShouldLoadData:pullToRefresh];
}

- (void)pullToRefreshWillLoadData:(SuccontPullToRefreshView *)pullToRefresh {
    pullToRefresh.loading = YES;
}

- (void)pullToRefreshShouldLoadData:(SuccontPullToRefreshView *)pullToRefresh {
    
}

- (void)pullToRefreshDidLoadData:(SuccontPullToRefreshView *)pullToRefresh {
    pullToRefresh.loading = NO;
}

@end
