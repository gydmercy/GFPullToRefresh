//
//  GFPullToRefreshFooterView.h
//  GFPullToRefresh
//
//  Created by Mercy on 15/7/8.
//  Copyright (c) 2015年 Mercy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFPullToRefreshContants.h"

@interface GFPullToRefreshFooterView : UIView

@property (nonatomic, copy) void (^footerRefreshHandler)(); // 上拉刷新回调

- (void)beginRefresh; // 开始刷新
- (void)endRefresh; // 停止刷新

@end
