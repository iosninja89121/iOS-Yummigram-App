//
//  SuccontPullToRefreshView.m
//  PullToRefresh
//
//  Created by Tobias Tom on 19.08.10.
//  Copyright (c) 2010 succont. All rights reserved.
//

#import "SuccontPullToRefreshView.h"
#import <QuartzCore/QuartzCore.h>

@implementation SuccontPullToRefreshView

@synthesize loading;
@synthesize state;

@synthesize normalStateString;
@synthesize shouldReloadStateString;
@synthesize loadingStateString;

@synthesize statusLabel;
@synthesize reloadImageView;
@synthesize reloadActivityIndicatorView;

- (void)didMoveToSuperview {
	CGRect currentFrame = self.frame;
	currentFrame.origin.y = currentFrame.size.height * -1;
	
	self.frame = currentFrame;
}

#pragma mark -
#pragma mark Getter and Setter
- (void)setState:(SuccontPullToRefreshViewState)aState {
    if ( state == aState ) {
        return;
    }

    switch ( aState ) {
        case SuccontPullToRefreshViewStateNormal:
            [self shouldDisplayNormalState];
            state = aState;
            break;
        case SuccontPullToRefreshViewStateShouldReload:
            [self shouldDisplayShouldReloadState];
            state = aState;
            break;
        case SuccontPullToRefreshViewStateLoading:
            [self shouldDisplayLoadingState];
            state = aState;
            break;
    }
}

- (void)setLoading:(BOOL)isLoading {
    loading = isLoading;
    
    self.state = loading ? SuccontPullToRefreshViewStateLoading : SuccontPullToRefreshViewStateNormal;
}

- (UILabel *)statusLabel {
    if ( nil == statusLabel ) {
        CGFloat offset = ( self.frame.size.height - 20 ) / 2;
        statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, offset, 280, 20)];

        [self addSubview:statusLabel];
    }
    return statusLabel;
}

- (UIImageView *)reloadImageView {
    if ( nil == reloadImageView ) {
        CGFloat offset = ( self.frame.size.height - 40 ) / 2;
        reloadImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, offset, 40, 40)];
        
        [self addSubview:reloadImageView];
    }
    return reloadImageView;
}

- (UIActivityIndicatorView *)reloadActivityIndicatorView {
    if ( nil == reloadActivityIndicatorView ) {
        reloadActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        

        CGRect frame = reloadActivityIndicatorView.frame;
		CGFloat offset = ( self.frame.size.height - frame.size.height ) / 2;
        frame.origin.x = offset;
        frame.origin.y = offset;
        
        reloadActivityIndicatorView.frame = frame;

        [self addSubview:reloadActivityIndicatorView];
    }
    
    return reloadActivityIndicatorView;
}

- (NSString *)normalStateString {
    if ( nil == normalStateString ) {
        normalStateString = @"Pull down to refresh …";
    }
    return normalStateString;
}

- (NSString *)shouldReloadStateString {
    if ( nil == shouldReloadStateString ) {
        shouldReloadStateString = @"Release to refresh …";
    }
    return shouldReloadStateString;
}

- (NSString *)loadingStateString {
    if ( nil == loadingStateString ) {
        loadingStateString = @"Loading …";
    }
    return loadingStateString;
}

#pragma mark -
#pragma mark Helper methods
- (void)flipView:(UIView *)aView upsideDown:(BOOL)upsideDown {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    
    CGFloat roation = upsideDown ? M_PI : M_PI * 2;
    aView.layer.transform = CATransform3DMakeRotation(roation, 0, 0, 1);
    
    [UIView commitAnimations];
}

#pragma mark -
#pragma mark Methods to customize the default behaviour
- (void)shouldDisplayNormalState {
    self.statusLabel.text = self.normalStateString;

    if ( nil != reloadImageView ) {
        [self.reloadImageView setHidden:NO];
        [self flipView:reloadImageView upsideDown:NO];
    }

    [self.reloadActivityIndicatorView stopAnimating];
}

- (void)shouldDisplayShouldReloadState {
    self.statusLabel.text = self.shouldReloadStateString;

    if ( nil != reloadImageView ) {
        [self.reloadImageView setHidden:NO];
        [self flipView:reloadImageView upsideDown:YES];
    }
    
    [self.reloadActivityIndicatorView stopAnimating];
}

- (void)shouldDisplayLoadingState {
    self.statusLabel.text = self.loadingStateString;
    
    [self.reloadImageView setHidden:YES];
    [self.reloadActivityIndicatorView startAnimating];
}


@end
