//
//  GFPullToRefreshHeaderView.m
//  GFPullToRefresh
//
//  Created by Mercy on 15/7/8.
//  Copyright (c) 2015年 Mercy. All rights reserved.
//

#import "GFPullToRefreshHeaderView.h"

@interface GFPullToRefreshHeaderView()

@property (nonatomic, strong) UIScrollView *superview; // 将要添加到的父view
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView; // 小菊花
@property (nonatomic, strong) UIImageView *arrowImageView; // 下拉箭头
@property (nonatomic, strong) UILabel *stateLabel; // 显示状态文字
@property (nonatomic, strong) UILabel *lastUpdateLabel; // 显示“最近更新”文字
@property (nonatomic, strong) NSString *lastUpdateTime; // 最近更新的时间字符串
@property (nonatomic, assign) UIEdgeInsets superViewContentInset; // 父view正常状态下的 contentInset  ps：下面使用的_superview.contentInset是实时值
@property (nonatomic, assign) GFPullToRefreshState state; // 当前状态，用来引出动作
@property (nonatomic, assign) GFPullToRefreshState currentState; // 当前状态，用来判断
@property (nonatomic, assign) BOOL arrowUp; // 判断箭头是否朝上

@end


@implementation GFPullToRefreshHeaderView


#pragma mark - 初始化刷新头，设置KVO

- (void)willMoveToSuperview:(UIView *)newSuperview {
    _superview = (UIScrollView *)newSuperview;
    
    // 根据 superview 来确定刷新控件 frame
    self.frame = CGRectMake(0,  - GFPTR_HEIGHT, _superview.frame.size.width, GFPTR_HEIGHT);
    self.backgroundColor = [UIColor clearColor];
    
    [self initStateLabel];
    [self initLastUpdateLabel];
    [self initArrowImageView];
    [self initActivityIndicatorView];
    
    // 设置属性默认值
    _state = GFPullToRefreshStateNormal;
    _currentState = GFPullToRefreshStateNormal;
    _stateLabel.text = GFPTR_TEXT_PULLTOREFRESH;
    _superViewContentInset = _superview.contentInset;
    _arrowUp = NO;
    
    // 首次进入时取出上一次持久化的最后更新时间
    [self lastUpdateTimeToString];
    if (_lastUpdateTime) {
        _lastUpdateLabel.text = [NSString stringWithFormat:@"最后更新： %@",_lastUpdateTime];
    }
    
    
    // 注册 KVO 监听 ScrollView 的 contentOffset 属性
    [newSuperview addObserver:self forKeyPath:GFPTR_KVO_CONTENTFOFFSET options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if (object == _superview && [keyPath isEqualToString:GFPTR_KVO_CONTENTFOFFSET]) {
        
        // 取得被观察者的对象 contentOffset 属性
        UIScrollView *obj = (UIScrollView *)object;
        CGFloat scrollViewContentOffsetY = obj.contentOffset.y;
        
        // 下拉判断逻辑，要比较下拉时 contentOffset 的高度与正常状况下 contentInset 的相对高度
        // 要从 normal 状态进入 refreshing 状态必须要经过 pulling 状态
        // 刚拉出下拉头的时候先更新“最后更新时间”
        if (scrollViewContentOffsetY < - _superViewContentInset.top && scrollViewContentOffsetY >= (- _superViewContentInset.top - 5)) {
            [self lastUpdateTimeToString];
            if (_lastUpdateTime) {
                _lastUpdateLabel.text = [NSString stringWithFormat:@"最后更新： %@",_lastUpdateTime];
            }
        }
        // 下拉头没有完全拖出的情况下
        else if (scrollViewContentOffsetY >= (- _superViewContentInset.top - GFPTR_HEIGHT)) {
            // 如果此时是 pulling 状态，则转化为 normal 状态（即下拉头回退）
            if (_currentState == GFPullToRefreshStatePulling) {
                self.state = GFPullToRefreshStateNormal;
                
            }
            
        }
        // 下拉头完全拖出的情况下
        else if (scrollViewContentOffsetY < (-_superViewContentInset.top - GFPTR_HEIGHT)) {
            // 如果此时是 normal 状态，且此时手指尚未松开，则转化为 pulling 状态，准备刷新
            if (_currentState == GFPullToRefreshStateNormal && obj.isDragging) {
                self.state = GFPullToRefreshStatePulling;
                
            }
            // 如果此时是 pulling 状态，且此时已经松开手指，则转化为 refreshing 状态，开始刷新
            else if (_currentState == GFPullToRefreshStatePulling && !obj.isDragging) {
                self.state = GFPullToRefreshStateRefreshing;
                
            }
        }
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
}

- (void)dealloc {
    // 移除 KVO 监听
    [_superview removeObserver:self forKeyPath:GFPTR_KVO_CONTENTFOFFSET context:nil];
}


#pragma mark - 刷新控件子部件初始化

- (void)initStateLabel {
    _stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.08 * GFPTR_HEIGHT, 0.5 * self.frame.size.width, 0.25 * GFPTR_HEIGHT)];
    _stateLabel.center = CGPointMake(self.center.x, _stateLabel.center.y);
    _stateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _stateLabel.textAlignment = NSTextAlignmentCenter;
    _stateLabel.textColor = GFPTR_TEXT_COLOR;
    _stateLabel.font = [UIFont boldSystemFontOfSize:13];
    
    [self addSubview:_stateLabel];
}

- (void)initLastUpdateLabel {
    _lastUpdateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.55 * GFPTR_HEIGHT, 0.5 * self.frame.size.width, 0.25 * GFPTR_HEIGHT)];
    _lastUpdateLabel.center = CGPointMake(self.center.x, _lastUpdateLabel.center.y);
    _lastUpdateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _lastUpdateLabel.textAlignment = NSTextAlignmentCenter;
    _lastUpdateLabel.textColor = GFPTR_TEXT_COLOR;
    _lastUpdateLabel.font = [UIFont boldSystemFontOfSize:12];
    
    [self addSubview:_lastUpdateLabel];
}

- (void)initArrowImageView {
    _arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GFPullToRefreshArrow"]];
    _arrowImageView.center = CGPointMake(self.center.x - 0.25 * self.frame.size.width, self.center.y + GFPTR_HEIGHT);
    
    [self addSubview:_arrowImageView];
}

- (void)initActivityIndicatorView {
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicatorView.frame = CGRectMake(0, 0, 20, 20);
    _activityIndicatorView.center = CGPointMake(self.center.x - 0.25 * self.frame.size.width, self.center.y + GFPTR_HEIGHT);
    _activityIndicatorView.hidesWhenStopped = YES;
    
    [self addSubview:_activityIndicatorView];
}


#pragma mark - 设置不同状态，响应对应的 Actions

// 设置状态并进行相应处理
- (void)setState:(GFPullToRefreshState)state {
    
    // 得到父view正常状况（即非 refreshing 状态）下的 contentInset
    if (_state != GFPullToRefreshStateRefreshing) {
        _superViewContentInset = _superview.contentInset;
    }
    
    switch (state) {
            
        case GFPullToRefreshStateNormal:
            _state = GFPullToRefreshStateNormal;
            _currentState = GFPullToRefreshStateNormal;
            [self stateNormalAction];
            break;
            
        case GFPullToRefreshStatePulling:
            _state = GFPullToRefreshStatePulling;
            _currentState = GFPullToRefreshStatePulling;
            [self statePullingAction];
            break;
            
        case GFPullToRefreshStateRefreshing:
            _state = GFPullToRefreshStateRefreshing;
            _currentState = GFPullToRefreshStateRefreshing;
            [self stateRefreshingAction];
            break;
    }
}

- (void)stateNormalAction {
    [_activityIndicatorView stopAnimating];
    _arrowImageView.hidden = NO;
    _stateLabel.text = GFPTR_TEXT_PULLTOREFRESH;
    
    // 只有之前箭头朝上，此时才需要将箭头旋转180度使之朝下
    if (_arrowUp) {
        [UIView animateWithDuration:GFPTR_ARROW_DURATION animations:^{
            _arrowImageView.transform = CGAffineTransformRotate(_arrowImageView.transform, GFPTR_PI);
        }];
        _arrowUp = NO;
    }
    
    // 只有从 refreshing 状态转为 normal 状态，才需要改变 contentInset
    if (_superview.contentInset.top != _superViewContentInset.top) {
        [UIView animateWithDuration:GFPTR_INSET_DURATION animations:^{
            _superview.contentInset = UIEdgeInsetsMake(_superview.contentInset.top - GFPTR_HEIGHT, _superview.contentInset.left, _superview.contentInset.bottom, _superview.contentInset.right);
        }];
    }
    
}

- (void)statePullingAction {
    [UIView animateWithDuration:GFPTR_ARROW_DURATION animations:^{
        _stateLabel.text = GFPTR_TEXT_RELEASTTOREFRESH;
        _arrowImageView.transform = CGAffineTransformRotate(_arrowImageView.transform, GFPTR_PI);
    }];
    _arrowUp = YES;
}

- (void)stateRefreshingAction {
    _arrowImageView.hidden = YES;
    [_activityIndicatorView startAnimating];
    _stateLabel.text = GFPTR_TEXT_REFRESHING;
    
    [UIView animateWithDuration:GFPTR_INSET_DURATION animations:^{
        _superview.contentInset = UIEdgeInsetsMake(_superview.contentInset.top + GFPTR_HEIGHT, _superview.contentInset.left, _superview.contentInset.bottom, _superview.contentInset.right);
    }];
    
    // 回调刷新动作
    if (self.headerRefreshHandler) {
        self.headerRefreshHandler();
    }
    
}


#pragma mark - 刷新相关方法

- (void)beginRefresh {
    self.state = GFPullToRefreshStateRefreshing;
}

- (void)endRefresh {
    self.state = GFPullToRefreshStateNormal;

}

- (void)updateRefreshTime {
    // 持久化当前时间作为下次的最后更新时间
    NSDate *date = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:GFPTR_NSUD_LASTUPDATETIME];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)lastUpdateTimeToString {
    // 获取前一次存档的时间
    NSDate *lastTime = [[NSUserDefaults standardUserDefaults] objectForKey:GFPTR_NSUD_LASTUPDATETIME];
    // 获取当前时间
    NSDate *currentTime = [NSDate date];
    
    
    if (lastTime) {
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSUInteger unitFlags = NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
        NSDateComponents *lastComponents = [calendar components:unitFlags fromDate:lastTime];
        NSDateComponents *currentComponents = [calendar components:unitFlags fromDate:currentTime];
        
        // 格式化后的最后更新时间
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        if (currentComponents.minute - lastComponents.minute >= 0 && currentComponents.minute - lastComponents.minute < 2) {
            [dateFormatter setDateFormat:@"刚刚"];
            _lastUpdateTime = [dateFormatter stringFromDate:lastTime];
        }
        else if (lastComponents.day == currentComponents.day) {
            [dateFormatter setDateFormat:@"今天 HH:mm"];
            _lastUpdateTime = [dateFormatter stringFromDate:lastTime];
        } else if (lastComponents.day == currentComponents.day - 1) {
            [dateFormatter setDateFormat:@"昨天 HH:mm"];
            _lastUpdateTime = [dateFormatter stringFromDate:lastTime];
        } else if (lastComponents.day == currentComponents.day - 2) {
            [dateFormatter setDateFormat:@"前天 HH:mm"];
            _lastUpdateTime = [dateFormatter stringFromDate:lastTime];
        } else {
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
            _lastUpdateTime = [dateFormatter stringFromDate:lastTime];
        }
    }
    
}

@end
