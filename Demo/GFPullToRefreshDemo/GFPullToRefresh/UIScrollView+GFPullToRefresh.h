//
//  UIScrollView+GFPullToRefresh.h
//  GFPullToRefresh
//
//  Created by Mercy on 15/7/8.
//  Copyright (c) 2015年 Mercy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (GFPullToRefresh)

/**
 *  添加下拉刷新控件
 *
 *  @param handler 网络请求，刷新时回调
 */
- (void)addHeaderWithHandler:(void (^)(void))handler;

/**
 *  开始下拉刷新
 */
- (void)beginHeaderRefresh;

/**
 *  停止下拉刷新
 */
- (void)endHeaderRefresh;



/**
 *  添加上拉刷新控件
 *
 *  @param handler 网络请求，刷新时回调
 */
- (void)addFooterWithHandler:(void (^)(void))handler;

/**
 *  开始上拉刷新
 */
- (void)beginFooterRefresh;

/**
 *  停止上拉刷新
 */
- (void)endFooterRefresh;

@end
