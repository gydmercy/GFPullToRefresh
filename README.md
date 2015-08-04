# GFPullToRefresh


GFPullToRefresh is a simple and low coupling pull-to-refresh module, very easy to use.

## Installation

GFPullToRefresh is available on [CocoaPods](https://cocoapods.org/). Just add the following to your project Podfile:

	pod 'GFPullToRefresh', '~> 1.0.0'


## Usage

1、Import header file

	#import GFPullToRefresh.h

2、Add the pull-down refresh feature

	[self.tableView addHeaderWithHandler:^{
        // put your network request statements here
        // when it's down, use [self.tableView endHeaderRefresh] to end refresh
    }];
    
3、Add the pull-up refresh feature

	[self.tableView addFooterWithHandler:^{
        // put your network request statements here
        // when it's down, use [self.tableView endFooterRefresh] to end refresh
    }];
	
## Notice

1. This module can be used in both UIScrollView and its subclasses(UITableView and UICollectionView).
2. You can use `[self.tableTavle beginHeaderRefresh]` to start refresh automatically.


## License

GFPullToRefresh is published under MIT License

	Copyright (c) 2015 Gu Gaofei (@gydmercy)

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.