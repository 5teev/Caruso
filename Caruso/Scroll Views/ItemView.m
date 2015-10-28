//
//  ItemView.m
//  Caruso
//
//  Created by Steve Milano on 10/20/15.
//  Copyright © 2015 Steve Milano. All rights reserved.
//

#import "ItemView.h"
#import "ItemViewModel.h"
#import "Constants.h"
#import "UIImageView+AFNetworking.h"

@interface ItemView ()
@property (nonatomic,strong,readwrite) NSString * shortMessage;
@property (nonatomic,strong,readwrite) NSString * longMessage;
@property (nonatomic,strong) UITextView * textView;
@property (nonatomic,strong) UIImageView * imageView;

@end

@implementation ItemView

- (instancetype) initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];

    if ( self )
    {
        // additional setup?

        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(ItemViewMargin, ItemViewMargin, 64.0f, 64.0f)];
        self.imageView.backgroundColor = [UIColor grayColor];
        [self addSubview:self.imageView];

        CGRect textViewRect = CGRectMake(CGRectGetMaxX(self.imageView.frame) + ItemViewMargin, ItemViewMargin, CGRectGetWidth(frame) - 2.0f * ItemViewMargin - CGRectGetMaxX(self.imageView.frame), CGRectGetHeight(frame) - 2.0f * ItemViewMargin);

        _textView = [[UITextView alloc] initWithFrame:textViewRect];
        self.textView.font = [UIFont systemFontOfSize:ItemTextHeight];
        self.textView.backgroundColor = [UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:0.25];
        self.textView.textColor = [UIColor whiteColor];
        [self addSubview:self.textView];

    }

    return self;
}

- (instancetype) initWithFrame:(CGRect)frame andViewModel: (ItemViewModel *)viewModel {
    self = [self initWithFrame:frame];

    if ( self )
    {
        self.viewModel = viewModel;
    }

    return self;
}

- (void) setViewModel:(ItemViewModel *)viewModel {
    _viewModel = viewModel;
    self.textView.text = self.viewModel.shortDescription;
    [self.imageView setImageWithURL:self.viewModel.thumbURL];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
