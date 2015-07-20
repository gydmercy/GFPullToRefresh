//
//  UIScrollView+GFPullToRefresh.h
//  GFPullToRefresh
//
//  Created by Mercy on 15/7/8.
//  Copyright (c) 2015年 Mercy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (GFPullToRefresh)

- (void)addHeaderWithHandler:(void (^)(void))handler;
- (void)beginHeaderRefresh;
- (void)endHeaderRefresh;

- (void)addFooterWithHandler:(void (^)(void))handler;
- (void)beginFooterRefresh;
- (void)endFooterRefresh;

@end
