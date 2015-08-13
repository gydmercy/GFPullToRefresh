//
//  GFPullToRefreshContants.h
//  GFPullToRefresh
//
//  Created by Mercy on 15/7/9.
//  Copyright (c) 2015年 Mercy. All rights reserved.
//

#import <UIKit/UIKit.h>


#define GFPTR_TEXT_COLOR [UIColor colorWithRed:126.0f / 255 green:126.0f / 255 blue:126.0f / 255 alpha:1.0f]


typedef NS_ENUM(NSUInteger, GFPullToRefreshState){
    GFPullToRefreshStateNormal = 0,
    GFPullToRefreshStatePulling,
    GFPullToRefreshStateRefreshing
};

extern const CGFloat GFPTR_PI; //!< 圆周率
extern const CGFloat GFPTR_HEIGHT; //!< 刷新控件高度
extern const NSTimeInterval GFPTR_ARROW_DURATION; //!< 箭头旋转的动画时长
extern const NSTimeInterval GFPTR_INSET_DURATION; //!< contentInset 改变的动画时长

extern NSString *const GFPTR_KVO_CONTENTFOFFSET; //!< KVO 监听的 contentOffset 属性
extern NSString *const GFPTR_NSUD_LASTUPDATETIME; //!< NSUserDefaults 存储最近更新时间

// 刷新控件显示的文字
extern NSString *const GFPTR_TEXT_PULLDOWNTOREFRESH; //<! "下拉可以刷新"
extern NSString *const GFPTR_TEXT_PULLUPTOREFRESH; //<! "上拉可以刷新"
extern NSString *const GFPTR_TEXT_RELEASTTOREFRESH; //!< "松开立即刷新"
extern NSString *const GFPTR_TEXT_REFRESHING; //<! "正在刷新..."
