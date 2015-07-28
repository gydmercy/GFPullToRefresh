//
//  UIScrollView+GFPullToRefresh.m
//  GFPullToRefresh
//
//  Created by Mercy on 15/7/8.
//  Copyright (c) 2015年 Mercy. All rights reserved.
//

#import "UIScrollView+GFPullToRefresh.h"
#import "GFPullToRefreshHeaderView.h"
#import "GFPullToRefreshFooterView.h"
#import <objc/runtime.h>

@interface UIScrollView ()

@property (nonatomic, strong) GFPullToRefreshHeaderView *header; //!< 下拉刷新控件
@property (nonatomic, strong) GFPullToRefreshFooterView *footer; //!< 上拉刷新控件

@end


@implementation UIScrollView (GFPullToRefresh)

#pragma mark - 为 UIScrollView 动态添加属性

static char GFPullToRefreshHeaderKey;
static char GFPullToRefreshFooterKey;

- (void)setHeader:(GFPullToRefreshHeaderView *)header {
    objc_setAssociatedObject(self, &GFPullToRefreshHeaderKey, header, OBJC_ASSOCIATION_ASSIGN);
}

- (GFPullToRefreshHeaderView *)header {
    return objc_getAssociatedObject(self, &GFPullToRefreshHeaderKey);
}

- (void)setFooter:(GFPullToRefreshFooterView *)footer {
    objc_setAssociatedObject(self, &GFPullToRefreshFooterKey, footer, OBJC_ASSOCIATION_ASSIGN);
}

- (GFPullToRefreshFooterView *)footer {
    return objc_getAssociatedObject(self, &GFPullToRefreshFooterKey);
}


#pragma mark - 下拉刷新

- (void)addHeaderWithHandler:(void (^)(void))handler {
    GFPullToRefreshHeaderView *header = [[GFPullToRefreshHeaderView alloc] init];
    [self addSubview:header];
    
    self.header = header;
    self.header.headerRefreshHandler = handler;
}

- (void)beginHeaderRefresh {
    [self.header beginRefresh];
}

- (void)endHeaderRefresh {
    [self.header updateRefreshTime];
    [self.header endRefresh];
}


#pragma mark - 上拉刷新

- (void)addFooterWithHandler:(void (^)(void))handler {
    GFPullToRefreshFooterView *footer = [[GFPullToRefreshFooterView alloc] init];
    [self addSubview:footer];
    
    self.footer = footer;
    self.footer.footerRefreshHandler = handler;
}

- (void)beginFooterRefresh {
    [self.footer beginRefresh];
}

- (void)endFooterRefresh {
    [self.footer endRefresh];
}

@end
