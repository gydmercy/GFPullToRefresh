//
//  GFPullToRefresh.h
//  GFPullToRefresh
//
//  Created by Mercy on 15/7/20.
//  Copyright (c) 2015年 Mercy. All rights reserved.
//
//  使用方法：
//      1、引入此头文件
//      2、添加下拉刷新功能：在要进行下拉刷新的UIScrollView或其子类上调用 - (void)addHeaderWithHandler:(void (^)(void))handler 方法，
//                        其中 handler 中添加网络请求代码，请求结束后调用 - (void)endHeaderRefresh 方法。
//                        当界面下拉就会触发该网络请求，若要自动触发网络请求，则只需直接调用 - (void)beginHeaderRefresh 方法。
//      3、添加上拉刷新功能：方法同下拉刷新，替换相关调用方法为上拉刷新的方法。
//

#import "UIScrollView+GFPullToRefresh.h"

