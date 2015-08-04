# GFPullToRefresh

## 概述

一个松耦合下拉刷新上拉刷新控件

## CocoaPods下载


	pod 'GFPullToRefresh', '~> 1.0.0'


## 使用

1. 引入此头文件 GFPullToRefresh.h

2. 添加下拉刷新功能：在要进行下拉刷新的UIScrollView或其子类上调用 `- (void)addHeaderWithHandler:(void (^)(void))handler` 方法，其中 handler 中添加网络请求代码，请求结束后调用 `- (void)endHeaderRefresh` 方法。当界面下拉就会触发该网络请求，若要自动触发网络请求，则只需直接调用 `- (void)beginHeaderRefresh` 方法。

3. 添加上拉刷新功能：方法同下拉刷新，替换相关调用方法会上拉刷新的方法。