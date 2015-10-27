//
//  InfiniteScrollView.h
//  Caruso
//
//  Created by Steve Milano on 10/19/15.
//  Copyright © 2015 Steve Milano. All rights reserved.
//

@import UIKit;

typedef NS_ENUM(NSUInteger, InfiniteScrollViewType) {
    InfiniteScrollViewTypeVertical = 0,
    InfiniteScrollViewTypeHorizontal = 1
};

@interface InfiniteScrollView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic,strong) NSArray * scrollItems;

// custom initializer
- (instancetype)initWithFrame:(CGRect)frame andType:(InfiniteScrollViewType)scrollType;

// defensive "deprecations"
- (instancetype)init DEPRECATED_MSG_ATTRIBUTE("Should use initWithFrame:andType:");
- (instancetype)initWithFrame:(CGRect)frame DEPRECATED_MSG_ATTRIBUTE("Should use initWithFrame:andType:");

// no storyboard/xib so this might be overkill...
- (instancetype)initWithCoder:(NSCoder *)aDecoder DEPRECATED_MSG_ATTRIBUTE("Should use initWithFrame:andType:");

@end
