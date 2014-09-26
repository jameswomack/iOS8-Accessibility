//
//  NGTextPropertyHolder.h
//  Granted
//
//  Created by James Womack on 9/26/14.
//  Copyright (c) 2014 James Womack. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NGTextPropertyHolder <NSObject>
@optional
- (NSString *)text;
- (void)setText:(NSString *)text;
- (UIFont *)font;
- (void)setFont:(UIFont *)font;
- (UIColor *)textColor;
- (void)setTextColor:(UIFont *)font;
@end
