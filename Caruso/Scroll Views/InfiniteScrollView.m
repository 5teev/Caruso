//
//  InfiniteScrollView.m
//  Caruso
//
//  Created by Steve Milano on 10/19/15.
//  Copyright © 2015 Steve Milano. All rights reserved.
//

#import "InfiniteScrollView.h"
#import "ItemView.h"
#import "ItemViewModel.h"
#import "Constants.h"

@interface InfiniteScrollView ()

@property (nonatomic,strong) NSMutableArray *visibleItemViews;
@property (nonatomic,strong) UIView *itemViewsContainerView;
@property InfiniteScrollViewType scrollType;
@end


@implementation InfiniteScrollView


- (instancetype)init
{
    // harshly insist upon which initializer to use
    NSAssert(0, @"use initWithType:andFrame:");
    return nil;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    // harshly insist upon which initializer to use
    NSAssert(0, @"use initWithType:andFrame:");
    return nil;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    // harshly insist upon which initializer to use
    NSAssert(0, @"use initWithType:andFrame:");
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame andType:(InfiniteScrollViewType)scrollType 
{
    if ((self = [super initWithFrame:frame]))
    {
        _scrollType = scrollType;

        // type-specific configuration
        switch ( self.scrollType ) {
            case InfiniteScrollViewTypeHorizontal:
                self.contentSize = CGSizeMake(self.frame.size.width * 4.0f, self.frame.size.height );
                self.backgroundColor = [UIColor colorWithRed:0.25 green:0.0 blue:0.25 alpha:0.5];
                break;

            // vertical type is the default
            case InfiniteScrollViewTypeVertical:
            default:
                self.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height * 4.0f );
                self.backgroundColor = [UIColor colorWithRed:0.75 green:0.80 blue:0.25 alpha:0.5];
                break;
                
        }

        // universal configuration
        _visibleItemViews = [[NSMutableArray alloc] init];
        
        _itemViewsContainerView = [[UIView alloc] init];
        self.itemViewsContainerView.frame = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
        [self addSubview:self.itemViewsContainerView];

        [self.itemViewsContainerView setUserInteractionEnabled:NO];
        
        // hide indicators so user doesn't see jumps during scrolling
        [self setShowsHorizontalScrollIndicator:NO];
        [self setShowsVerticalScrollIndicator:NO];
        [self setBounces:NO];

// DEBUG: show scroll indicators
        [self setShowsHorizontalScrollIndicator:YES];
        [self setShowsVerticalScrollIndicator:YES];
    }

    return self;
}

- (void) setScrollItems:(NSArray *)scrollItems {
    _scrollItems = scrollItems;
    for ( UIView * view in self.itemViewsContainerView.subviews ) {
        [view removeFromSuperview];
    }

    // clear visibleItemViewss array
    self.visibleItemViews = [NSMutableArray array];

    // build layout again
    [self layoutSubviews];
}

#pragma mark - Layout

// recenter content periodically to achieve impression of infinite scrolling
- (void)recenterIfNecessary
{
    CGPoint currentOffset = [self contentOffset];
    
    CGFloat contentHeight = [self contentSize].height;
    CGFloat centerOffsetY = ( contentHeight - CGRectGetHeight([self bounds]) ) / 2.0;
    CGFloat distanceFromCenterY = fabs(currentOffset.y - centerOffsetY);

    CGFloat contentWidth = [self contentSize].width;
    CGFloat centerOffsetX = ( contentWidth - CGRectGetWidth([self bounds]) ) / 2.0;
    CGFloat distanceFromCenterX = fabs(currentOffset.x - centerOffsetX);
    
    if ( self.scrollType == InfiniteScrollViewTypeVertical && distanceFromCenterY > (contentHeight / 10.0) )
    {
        self.contentOffset = CGPointMake(currentOffset.x, centerOffsetY);
        
        // move content by the same amount so it appears to stay still
        for ( ItemView * itemView in self.visibleItemViews ) {
            CGPoint center = [self.itemViewsContainerView convertPoint:itemView.center toView:self];
            center.y += (centerOffsetY - currentOffset.y);
            itemView.center = [self convertPoint:center toView:self.itemViewsContainerView];
        }
    }
    else if ( self.scrollType == InfiniteScrollViewTypeHorizontal && distanceFromCenterX > (contentWidth / 10.0) )
    {
        self.contentOffset = CGPointMake(centerOffsetX, currentOffset.y);
        
        // move content by the same amount so it appears to stay still
        for ( ItemView * itemView in self.visibleItemViews ) {
            CGPoint center = [self.itemViewsContainerView convertPoint:itemView.center toView:self];
            center.x += (centerOffsetX - currentOffset.x);
            itemView.center = [self convertPoint:center toView:self.itemViewsContainerView];
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    // return early if there's nothing to show
    if ( self.scrollItems.count == 0 ) { return; }

    [self recenterIfNecessary];
 
    // tile content in visible bounds
    CGRect visibleBounds = [self convertRect:[self bounds] toView:self.itemViewsContainerView];
    CGFloat minimumVisibleX = CGRectGetMinX(visibleBounds);
    CGFloat maximumVisibleX = CGRectGetMaxX(visibleBounds);
    CGFloat minimumVisibleY = CGRectGetMinY(visibleBounds);
    CGFloat maximumVisibleY = CGRectGetMaxY(visibleBounds);

    switch ( self.scrollType ) {
        case InfiniteScrollViewTypeHorizontal:
            [self tileItemViewsFromMinX:minimumVisibleX toMaxX:maximumVisibleX];
            break;
            
            // make vertical type the default
        case InfiniteScrollViewTypeVertical:
        default:
            [self tileItemViewsFromMinY:minimumVisibleY toMaxY:maximumVisibleY];
            break;
            
    }
}


#pragma mark - View Tiling

- (ItemView *)createItemView
{
    CGFloat itemViewWidth = CGRectGetWidth(self.frame);
    ItemView * itemView = [[ItemView alloc] initWithFrame:CGRectMake(0, 0, itemViewWidth, ItemViewHeight)];
    itemView.backgroundColor = [UIColor yellowColor];
    [self.itemViewsContainerView addSubview:itemView];

    return itemView;
}

- (ItemView *)setUpItemView {
    ItemView * itemView = [self createItemView];
    if ( self.visibleItemViews.count == 0 ) {
        itemView.tag = 0;
    } else {
        ItemView * lastItemView = (ItemView *)self.visibleItemViews.lastObject;
        itemView.tag = (lastItemView.tag + 1) % self.scrollItems.count;
    }

    return itemView;
}

// folding some vertical/horizontal methods together is a little too messy
- (CGFloat)placeNewItemViewOnBottom:(CGFloat)bottomEdge
{
    ItemView * itemView = [self setUpItemView];
    
    [self.visibleItemViews addObject:itemView]; // add bottom-most ItemView at the end of the array
    
//    NSLog(@"placeNewItemViewOnBottom: itemView.tag %ld %% scrollItems.count %lu",(long)itemView.tag,(unsigned long)self.scrollItems.count);
    ItemViewModel * viewModel = self.scrollItems[itemView.tag];
    itemView.viewModel = viewModel;
    
    
    CGRect frame = [itemView frame];
    frame.origin.x = 0;
    frame.origin.y = bottomEdge;
    [itemView setFrame:frame];
    
    return CGRectGetMaxY(frame);
}

- (CGFloat)placeNewItemViewOnTop:(CGFloat)topEdge
{
    ItemView * itemView = [self setUpItemView];
    
    [self.visibleItemViews insertObject:itemView atIndex:0]; // add leftmost ItemView at the beginning of the array
    
//    NSLog(@"placeNewItemViewOnTop: itemView.tag %ld %% scrollItems.count %lu",(long)itemView.tag,(unsigned long)self.scrollItems.count);
    ItemViewModel * viewModel = self.scrollItems[itemView.tag];
    itemView.viewModel = viewModel;
    
    CGRect frame = [itemView frame];
    frame.origin.x = 0;
    frame.origin.y = topEdge - frame.size.height;
    [itemView setFrame:frame];
    
    return CGRectGetMinY(frame);
}

- (CGFloat)placeNewItemViewOnLeft:(CGFloat)leftEdge
{
    ItemView * itemView = [self setUpItemView];
    
    [self.visibleItemViews insertObject:itemView atIndex:0]; // add leftmost ItemView at the beginning of the array
    
//    NSLog(@"placeNewItemViewOnLeft: itemView.tag %ld %% scrollItems.count %lu",(long)itemView.tag,(unsigned long)self.scrollItems.count);
    ItemViewModel * viewModel = self.scrollItems[itemView.tag];
    itemView.viewModel = viewModel;
    
    CGRect frame = [itemView frame];
    frame.origin.x = leftEdge - frame.size.width;
    frame.origin.y = [self.itemViewsContainerView bounds].size.height / 2.0f - frame.size.height;
    [itemView setFrame:frame];
    
    return CGRectGetMinX(frame);
}

- (CGFloat)placeNewItemViewOnRight:(CGFloat)rightEdge
{
    ItemView * itemView = [self setUpItemView];
    
    [self.visibleItemViews addObject:itemView]; // add rightmost ItemView at the end of the array
    
//    NSLog(@"placeNewItemViewOnRight: itemView.tag %ld %% scrollItems.count %lu",(long)itemView.tag,(unsigned long)self.scrollItems.count);
    ItemViewModel * viewModel = self.scrollItems[itemView.tag];
    itemView.viewModel = viewModel;
    
    CGRect frame = [itemView frame];
    frame.origin.x = rightEdge;
    frame.origin.y = [self.itemViewsContainerView bounds].size.height / 2.0f - frame.size.height;
    [itemView setFrame:frame];
    
    return CGRectGetMaxX(frame);
}

- (void)tileItemViewsFromMinX:(CGFloat)minimumVisibleX toMaxX:(CGFloat)maximumVisibleX
{
    // tiling logic depends on there already being at least one ItemView in the visibleItemViews array
    // i.e., make sure there's at least one ItemView
    if ([self.visibleItemViews count] == 0)
    {
        [self placeNewItemViewOnLeft:minimumVisibleX];
    }
    
    // add ItemViews that are missing on right side
    ItemView * lastItemView = [self.visibleItemViews lastObject];
    CGFloat endEdge = CGRectGetMaxX([lastItemView frame]);
    while (endEdge < maximumVisibleX)
    {
        endEdge = [self placeNewItemViewOnRight:endEdge];
    }
    
    // add ItemViews that are missing on left side
    ItemView * firstItemView = self.visibleItemViews[0];
    CGFloat beginningEdge = CGRectGetMinX([firstItemView frame]);
    while (beginningEdge > minimumVisibleX)
    {
        beginningEdge = [self placeNewItemViewOnLeft:beginningEdge];
    }
    
    // remove ItemViews that have fallen off right edge
    lastItemView = [self.visibleItemViews lastObject];
    while ([lastItemView frame].origin.x > maximumVisibleX)
    {
        [lastItemView removeFromSuperview];
        [self.visibleItemViews removeLastObject];
        lastItemView = [self.visibleItemViews lastObject];
    }
    
    // remove ItemViews that have fallen off left edge
    firstItemView = self.visibleItemViews[0];
    while (CGRectGetMaxX([firstItemView frame]) < minimumVisibleX)
    {
        [firstItemView removeFromSuperview];
        [self.visibleItemViews removeObjectAtIndex:0];
        firstItemView = self.visibleItemViews[0];
    }
}

- (void)tileItemViewsFromMinY:(CGFloat)minimumVisibleY toMaxY:(CGFloat)maximumVisibleY
{
    // tiling logic depends on there already being at least one ItemView in the visibleItemViews array
    // i.e., make sure there's at least one ItemView
    if ([self.visibleItemViews count] == 0)
    {
        [self placeNewItemViewOnTop:minimumVisibleY];
    }
    
    // add ItemViews that are missing on right side
    ItemView * lastItemView = [self.visibleItemViews lastObject];
    CGFloat bottomEdge = CGRectGetMaxY([lastItemView frame]);
    while (bottomEdge < maximumVisibleY)
    {
        bottomEdge = [self placeNewItemViewOnBottom:bottomEdge];
    }
    
    // add ItemViews that are missing on top
    ItemView * firstItemView = self.visibleItemViews[0];
    CGFloat topEdge = CGRectGetMinY([firstItemView frame]);
    while (topEdge > minimumVisibleY)
    {
        topEdge = [self placeNewItemViewOnTop:topEdge];
    }
    
    // remove ItemViews that have fallen off right edge
    lastItemView = [self.visibleItemViews lastObject];
    while ([lastItemView frame].origin.y > maximumVisibleY)
    {
        [lastItemView removeFromSuperview];
        [self.visibleItemViews removeLastObject];
        lastItemView = [self.visibleItemViews lastObject];
    }
    
    // remove ItemViews that have fallen off left edge
    firstItemView = self.visibleItemViews[0];
    while (CGRectGetMaxY([firstItemView frame]) < minimumVisibleY)
    {
        [firstItemView removeFromSuperview];
        [self.visibleItemViews removeObjectAtIndex:0];
        firstItemView = self.visibleItemViews[0];
    }
}


@end
