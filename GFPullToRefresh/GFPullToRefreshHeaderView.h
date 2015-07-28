//
//  GFPullToRefreshHeaderView.h
//  GFPullToRefresh
//
//  Created by Mercy on 15/7/8.
//  Copyright (c) 2015年 Mercy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFPullToRefreshContants.h"


@interface GFPullToRefreshHeaderView : UIView

@property (nonatomic, copy) void (^headerRefreshHandler)(); //!< 下拉刷新回调

- (void)beginRefresh; //!< 开始刷新
- (void)endRefresh; //!< 停止刷新
- (void)updateRefreshTime; //!< 更新“最后刷新时间”

@end
