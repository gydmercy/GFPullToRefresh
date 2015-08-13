//
//  GFPullToRefreshHeaderView.m
//  GFPullToRefresh
//
//  Created by Mercy on 15/7/8.
//  Copyright (c) 2015年 Mercy. All rights reserved.
//

#import "GFPullToRefreshHeaderView.h"

@interface GFPullToRefreshHeaderView()

@property (nonatomic, strong) UIScrollView *superview; //!< 将要添加到的父View
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView; //!< 小菊花
@property (nonatomic, strong) UIImageView *arrowImageView; ///!< 下拉箭头
@property (nonatomic, strong) UILabel *stateLabel; //!< 显示状态文字
@property (nonatomic, strong) UILabel *lastUpdateLabel; //!< 显示“最近更新”文字
@property (nonatomic, strong) NSString *lastUpdateTime; //!< 最近更新的时间字符串
@property (nonatomic, assign) UIEdgeInsets superViewContentInset; //!< 父view正常状态下的 contentInset
@property (nonatomic, assign) GFPullToRefreshState state; //!< 当前状态，用来引出动作
@property (nonatomic, assign) GFPullToRefreshState currentState; //!< 当前状态，用来判断
@property (nonatomic, assign) BOOL arrowUp; //!< 判断箭头是否朝上

@end


@implementation GFPullToRefreshHeaderView


#pragma mark - 初始化刷新头，设置KVO

- (instancetype)init {
    if (self = [super init]) {
        _stateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _lastUpdateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GFPullToRefreshArrow"]];
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        [self addSubview:_stateLabel];
        [self addSubview:_lastUpdateLabel];
        [self addSubview:_arrowImageView];
        [self addSubview:_activityIndicatorView];
    }
    return self;
}


- (void)willMoveToSuperview:(UIView *)newSuperview {
    _superview = (UIScrollView *)newSuperview;
    
    // 设置属性默认值
    _state = GFPullToRefreshStateNormal;
    _currentState = GFPullToRefreshStateNormal;
    _stateLabel.text = GFPTR_TEXT_PULLDOWNTOREFRESH;
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

- (void)layoutSubviews {
    [super layoutSubviews];

    // 根据 superview 来确定刷新控件 frame
    self.frame = CGRectMake(0,  - GFPTR_HEIGHT, _superview.frame.size.width, GFPTR_HEIGHT);
    self.backgroundColor = [UIColor clearColor];
    
    [self setupStateLabel];
    [self setupLastUpdateLabel];
    [self setupArrowImageView];
    [self setupActivityIndicatorView];
    
}

- (void)dealloc {
    // 移除 KVO 监听
    [_superview removeObserver:self forKeyPath:GFPTR_KVO_CONTENTFOFFSET context:nil];
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
        
        // 下拉头没有完全拖出的情况下
        if ((scrollViewContentOffsetY >= (- _superViewContentInset.top - GFPTR_HEIGHT)) && (scrollViewContentOffsetY < - _superViewContentInset.top)) {
            
            // 刚拉出下拉头的时候先更新“最后更新时间”
            if (scrollViewContentOffsetY >= (- _superViewContentInset.top - 10)) {
                [self lastUpdateTimeToString];
                if (_lastUpdateTime) {
                    _lastUpdateLabel.text = [NSString stringWithFormat:@"最后更新： %@",_lastUpdateTime];
                }
            }
            
            // 如果此时是 pulling 状态，则转化为 normal 状态（即下拉头回退）
            if (_currentState == GFPullToRefreshStatePulling) {
                self.state = GFPullToRefreshStateNormal;
            }
            
        }
        // 下拉头完全拖出的情况下
        else if (scrollViewContentOffsetY < (-_superViewContentInset.top - GFPTR_HEIGHT)) {
            // 如果此时是 normal 状态，则转化为 pulling 状态，准备刷新
            if (_currentState == GFPullToRefreshStateNormal && obj.dragging) {
                self.state = GFPullToRefreshStatePulling;
            }
            // 如果此时是 pulling 状态，则转化为 refreshing 状态，开始刷新
            else if (_currentState == GFPullToRefreshStatePulling && !obj.dragging) {
                self.state = GFPullToRefreshStateRefreshing;
            }
        }
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
}



#pragma mark - 配置刷新控件子部件

- (void)setupStateLabel {
    _stateLabel.frame = CGRectMake(0, 0.08 * GFPTR_HEIGHT, 0.5 * self.frame.size.width, 0.25 * GFPTR_HEIGHT);
    _stateLabel.center = CGPointMake(0.5 * self.frame.size.width, _stateLabel.center.y);
    _stateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _stateLabel.textAlignment = NSTextAlignmentCenter;
    _stateLabel.textColor = GFPTR_TEXT_COLOR;
    _stateLabel.font = [UIFont boldSystemFontOfSize:13];
}

- (void)setupLastUpdateLabel {
    _lastUpdateLabel.frame = CGRectMake(0, 0.55 * GFPTR_HEIGHT, 0.5 * self.frame.size.width, 0.25 * GFPTR_HEIGHT);
    _lastUpdateLabel.center = CGPointMake(0.5 * self.frame.size.width, _lastUpdateLabel.center.y);
    _lastUpdateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _lastUpdateLabel.textAlignment = NSTextAlignmentCenter;
    _lastUpdateLabel.textColor = GFPTR_TEXT_COLOR;
    _lastUpdateLabel.font = [UIFont boldSystemFontOfSize:12];
}

- (void)setupArrowImageView {
    _arrowImageView.center = CGPointMake(0.22 * self.frame.size.width, 0.5 * self.frame.size.height);
}

- (void)setupActivityIndicatorView {
    _activityIndicatorView.frame = CGRectMake(0, 0, 20, 20);
    _activityIndicatorView.center = CGPointMake(0.22 * self.frame.size.width, 0.5 * self.frame.size.height);
    _activityIndicatorView.hidesWhenStopped = YES;
}


#pragma mark - 设置不同状态，响应对应的 Actions

/**
 *  设置状态并进行相应处理
 *
 *  @param state 当前要设置的状态
 */
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
    _stateLabel.text = GFPTR_TEXT_PULLDOWNTOREFRESH;
    
    // 表示从 refreshing 状态转为 normal 状态
    if (_superview.contentInset.top != _superViewContentInset.top) {
        
        [_activityIndicatorView stopAnimating];
        _arrowImageView.hidden = NO;
        
        // 只有之前箭头朝上，此时才需要将箭头旋转180度使之朝下
        if (_arrowUp) {
            _arrowImageView.transform = CGAffineTransformRotate(_arrowImageView.transform, GFPTR_PI);
            _arrowUp = NO;
        }
        
        // 恢复 contentInset
        [UIView animateWithDuration:GFPTR_INSET_DURATION animations:^{
            _superview.contentInset = _superViewContentInset;
        }];
    }
    // 表示从 pulling 状态转为 normal 状态
    else {
        // 只有之前箭头朝上，此时才需要将箭头旋转180度使之朝下
        if (_arrowUp) {
            // 此处需要动画过渡
            [UIView animateWithDuration:GFPTR_ARROW_DURATION animations:^{
                _arrowImageView.transform = CGAffineTransformRotate(_arrowImageView.transform, GFPTR_PI);
            }];
            _arrowUp = NO;
        }
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

/**
 *  持久化当前时间作为下次的最后更新时间
 */
- (void)updateRefreshTime {
    NSDate *date = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:GFPTR_NSUD_LASTUPDATETIME];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 *  格式化最后更新时间用以显示
 */
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
