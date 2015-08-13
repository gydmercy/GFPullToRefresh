//
//  GFPullToRefreshFooterView.m
//  GFPullToRefresh
//
//  Created by Mercy on 15/7/8.
//  Copyright (c) 2015年 Mercy. All rights reserved.
//

#import "GFPullToRefreshFooterView.h"

@interface GFPullToRefreshFooterView()

@property (nonatomic, strong) UIScrollView *superview; //!< 将要添加到的父view
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView; //!< 小菊花
@property (nonatomic, strong) UIImageView *arrowImageView; //!< 下拉箭头
@property (nonatomic, strong) UILabel *stateLabel; //!< 显示状态文字
@property (nonatomic, assign) UIEdgeInsets superViewContentInset; //!< 父view的 contentInset
@property (nonatomic, assign) CGFloat offsetWhenScrollToBottom; //!< 上拉刷新开始时的 contentOffset
@property (nonatomic, assign) GFPullToRefreshState state; //!< 当前状态，用来引出动作
@property (nonatomic, assign) GFPullToRefreshState currentState; //!< 当前状态，用来判断
@property (nonatomic, assign) BOOL arrowUp; //!< 判断箭头是否朝上

@end


@implementation GFPullToRefreshFooterView


#pragma mark - 初始化刷新头，设置KVO

- (instancetype)init {
    if (self = [super init]) {
        _stateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GFPullToRefreshArrow"]];
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        [self addSubview:_stateLabel];
        [self addSubview:_arrowImageView];
        [self addSubview:_activityIndicatorView];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    _superview = (UIScrollView *)newSuperview;
    
//    CGFloat scrollViewHeight = _superview.frame.size.height - _superview.contentInset.top - _superview.contentInset.bottom;
    
    // 根据 superview 来确定刷新控件 frame
    self.frame = CGRectMake(0, _superview.contentSize.height, _superview.frame.size.width, GFPTR_HEIGHT);
//    self.frame = CGRectMake(0, scrollViewHeight, _superview.frame.size.width, GFPTR_HEIGHT);
    self.backgroundColor = [UIColor clearColor];
    
    // 设置属性默认值
    _state = GFPullToRefreshStateNormal;
    _currentState = GFPullToRefreshStateNormal;
    _stateLabel.text = GFPTR_TEXT_PULLUPTOREFRESH;
    _superViewContentInset = _superview.contentInset;
    _arrowImageView.transform = CGAffineTransformRotate(_arrowImageView.transform, GFPTR_PI);
    _arrowUp = YES;
    
    // 注册 KVO 监听 ScrollView 的 contentOffset 属性
    [newSuperview addObserver:self forKeyPath:GFPTR_KVO_CONTENTFOFFSET options:NSKeyValueObservingOptionNew context:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self adjustSelfViewFrame];
    
    [self setupStateLabel];
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
        
        [self adjustSelfViewFrame];
        [self chooseOffsetWhenScrollToBottom];
        
        // 取得被观察者的对象 contentSize 属性
        UIScrollView *obj = (UIScrollView *)object;
        CGFloat scrollViewContentOffsetY = obj.contentOffset.y;
        
        
        // 下拉判断逻辑，要比较上拉时 contentOffset 的高度与正常状况下 拉到内容底时的 contentOffset
        // 要从 normal 状态进入 refreshing 状态必须要经过 pulling 状态
        
        // 上拉头没有完全拖出的情况下
        if (scrollViewContentOffsetY > _offsetWhenScrollToBottom && scrollViewContentOffsetY <= (_offsetWhenScrollToBottom + GFPTR_HEIGHT)) {
            // 如果此时是 pulling 状态，则转化为 normal 状态（即下拉头回退）
            if (_currentState == GFPullToRefreshStatePulling) {
                self.state = GFPullToRefreshStateNormal;
            }
            
        }
        // 上拉头完全拖出的情况下
        else if (scrollViewContentOffsetY > (_offsetWhenScrollToBottom + GFPTR_HEIGHT)) {
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

// 更新上拉控件的frame
- (void)adjustSelfViewFrame {
    // superview 除了上下 inset 后剩余部分的高度
    CGFloat scrollViewHeight = _superview.frame.size.height - _superview.contentInset.top - _superview.contentInset.bottom;
    
    if (_superview.contentSize.height >= scrollViewHeight) {
        self.frame = CGRectMake(0, _superview.contentSize.height, _superview.frame.size.width, GFPTR_HEIGHT);
    } else {
        self.frame = CGRectMake(0, scrollViewHeight, _superview.frame.size.width, GFPTR_HEIGHT);
    }
}

// 根据内容大小来选择判断上拉高度的基准
- (void)chooseOffsetWhenScrollToBottom {
    // superview 除了上下 inset 后剩余部分的高度
    CGFloat scrollViewHeight = _superview.frame.size.height - _superview.contentInset.top - _superview.contentInset.bottom;
    
    if (_superview.contentSize.height < scrollViewHeight) {
        _offsetWhenScrollToBottom = - _superview.contentInset.top;
    } else  {
        _offsetWhenScrollToBottom = _superview.contentSize.height - (_superview.frame.size.height - _superview.contentInset.bottom);
    }
    
}



#pragma mark - 刷新控件子部件初始化

- (void)setupStateLabel {
    _stateLabel.frame = CGRectMake(0, 0, 0.5 * self.frame.size.width, 0.25 * GFPTR_HEIGHT);
    _stateLabel.center = CGPointMake(0.5 * self.frame.size.width, 0.5 * self.frame.size.height);
    _stateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _stateLabel.textAlignment = NSTextAlignmentCenter;
    _stateLabel.textColor = GFPTR_TEXT_COLOR;
    _stateLabel.font = [UIFont boldSystemFontOfSize:13];
}

- (void)setupArrowImageView {
    _arrowImageView.center = CGPointMake(0.25 * self.frame.size.width, 0.5 * self.frame.size.height);
}

- (void)setupActivityIndicatorView {
    _activityIndicatorView.frame = CGRectMake(0, 0, 20, 20);
    _activityIndicatorView.center = CGPointMake(0.25 * self.frame.size.width, 0.5 * self.frame.size.height);
    _activityIndicatorView.hidesWhenStopped = YES;
}



#pragma mark - 设置不同状态，响应对应的 Actions

// 设置状态并进行相应处理
- (void)setState:(GFPullToRefreshState)state {
    
    // 得到父view正常状况（即非 refreshing 状态）下的 contentInset
    if (_state != GFPullToRefreshStateRefreshing) {
        _superViewContentInset.bottom = _superview.contentInset.bottom;
        
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
    _stateLabel.text = GFPTR_TEXT_PULLUPTOREFRESH;
    
    // 表示从 refreshing 状态转为 normal 状态
    if (_superview.contentInset.bottom != _superViewContentInset.bottom) {
        
        [_activityIndicatorView stopAnimating];
        _arrowImageView.hidden = NO;
        
        // 只有之前箭头朝上，此时才需要将箭头旋转180度使之朝下
        if (!_arrowUp) {
            _arrowImageView.transform = CGAffineTransformRotate(_arrowImageView.transform, GFPTR_PI);
            _arrowUp = YES;
        }
        
        // 改变 contentInset
        [UIView animateWithDuration:GFPTR_INSET_DURATION animations:^{
            _superview.contentInset = UIEdgeInsetsMake(_superview.contentInset.top, _superview.contentInset.left, _superview.contentInset.bottom - GFPTR_HEIGHT, _superview.contentInset.right);
        }];
    }
    // 表示从 pulling 状态转为 normal 状态
    else {
        // 只有之前箭头朝下，此时才需要将箭头旋转180度使之朝上
        if (!_arrowUp) {
            // 此处需要动画过度
            [UIView animateWithDuration:GFPTR_ARROW_DURATION animations:^{
                _arrowImageView.transform = CGAffineTransformRotate(_arrowImageView.transform, GFPTR_PI);
            }];
            _arrowUp = YES;
        }
    }
    
}

- (void)statePullingAction {
    [UIView animateWithDuration:GFPTR_ARROW_DURATION animations:^{
        _stateLabel.text = GFPTR_TEXT_RELEASTTOREFRESH;
        _arrowImageView.transform = CGAffineTransformRotate(_arrowImageView.transform, GFPTR_PI);
    }];
    _arrowUp = NO;
}

- (void)stateRefreshingAction {
    _arrowImageView.hidden = YES;
    [_activityIndicatorView startAnimating];
    _stateLabel.text = GFPTR_TEXT_REFRESHING;
    
    
    [UIView animateWithDuration:GFPTR_INSET_DURATION animations:^{
        _superview.contentInset = UIEdgeInsetsMake(_superview.contentInset.top, _superview.contentInset.left, _superview.contentInset.bottom + GFPTR_HEIGHT, _superview.contentInset.right);
        
    }];
    
    // 回调刷新动作
    if (self.footerRefreshHandler) {
        self.footerRefreshHandler();
    }
    
}


#pragma mark - 刷新相关方法

- (void)beginRefresh {
    self.state = GFPullToRefreshStateRefreshing;
}

- (void)endRefresh {
    self.state = GFPullToRefreshStateNormal;
}


@end
