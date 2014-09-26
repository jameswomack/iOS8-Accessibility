//
//  ModelController.h
//  Granted
//
//  Created by James Womack on 9/26/14.
//  Copyright (c) 2014 James Womack. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataViewController;

@interface ModelController : NSObject <UIPageViewControllerDataSource>

- (instancetype)initWithPageData:(NSArray *)pageData NS_DESIGNATED_INITIALIZER;
- (DataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(DataViewController *)viewController;

@end

