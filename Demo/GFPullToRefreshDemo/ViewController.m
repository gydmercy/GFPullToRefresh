//
//  ViewController.m
//  GFPullToRefreshDemo
//
//  Created by Mercy on 15/7/20.
//  Copyright (c) 2015年 Mercy. All rights reserved.
//

#import "ViewController.h"
#import "GFPullToRefresh.h"

@interface ViewController () <UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic) int rowCount;

@end

@implementation ViewController

static NSString *const cellIdentifier = @"cellIdentifier";


#pragma mark - Lifecyle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"GFPullToRefreshDemo";
    
    // 默认 TableView 行数
    self.rowCount = 10;
    
    // 添加下拉刷新功能
    [self headerRefresh];
    // 添加上拉刷新功能
    [self footerRefresh];
    
    // 进入页面就开始刷新
//    [self.tableView beginHeaderRefresh];
    
    
}


#pragma mark - Initialization

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tableView.tableFooterView = [[UIView alloc] init];
//        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 64, 0);
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}


#pragma mark - 下拉刷新

- (void)headerRefresh {
    __weak typeof(self) sf = self;
    [self.tableView addHeaderWithHandler:^{
        
        // 此处添加网络请求代码
        
        // 请求结束后调用 ednHeaderRefresh 方法，此处模拟 2.5S 后结束请求
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            sf.rowCount = 10;
            [sf.tableView reloadData];
            [sf.tableView endHeaderRefresh];
        });
    }];
}


#pragma mark - 上拉刷新

- (void)footerRefresh {
    __weak typeof(self) sf = self;
    [self.tableView addFooterWithHandler:^{
        
        // 此处添加网络请求代码
        
        // 请求结束后调用 ednHeaderRefresh 方法，此处模拟 2.5S 后结束请求
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            sf.rowCount += 10;
            [sf.tableView reloadData];
            [sf.tableView endFooterRefresh];
        });
    }];
}


#pragma mark - <UITableViewDataSourece>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
//    cell.contentView.backgroundColor = [UIColor redColor];
    return cell;
}



@end
