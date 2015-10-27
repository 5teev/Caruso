//
//  CarusoCollectionViewController.m
//  Caruso
//
//  Created by Steve Milano on 10/8/15.
//  Copyright © 2015 Steve Milano. All rights reserved.
//

#import "CarusoViewController.h"
#import "CarusoViewModel.h"
#import "InfiniteScrollView.h"
#import <KVOController/FBKVOController.h>

@interface CarusoViewController () <UIScrollViewDelegate>
    
@property (nonatomic) FBKVOController *KVOController;
@property (nonatomic,strong) InfiniteScrollView * scrollView;
@property (nonatomic,strong) CarusoViewModel * viewModel;

@end

@implementation CarusoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    _scrollView = [[InfiniteScrollView alloc] initWithFrame:self.view.bounds andType:InfiniteScrollViewTypeVertical];

    [self.view addSubview:self.scrollView];

    // Allocate KVOController
    self.KVOController = [FBKVOController controllerWithObserver:self];

    // Allocate view model
    self.viewModel = [[CarusoViewModel alloc] init];

    // overkill reference loop avoidance because this view will never dealloc...
    // (unless it's reused someday, but for now this is simply good hygiene)
    __weak CarusoViewController *weakSelf = self;
    [self.KVOController observe:self.viewModel keyPath:@"isLoading" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {

        __strong typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf) {
            // when isLoading == NO, we have data
            if ([change[@"new"] boolValue] == NO)
            {
                NSLog(@"the view model is done loading: %@",change);
                [strongSelf refreshScrollItems];
            }
        }
    }];

}

- (void)viewDidAppear:(BOOL)animated {
    [UIView animateWithDuration:1.0 animations:^{
//        self.view.alpha = 0.05f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 animations:^{
            self.view.alpha = 1.0f;
        } completion:^(BOOL finished) {
        }];
    }];
}

- (void) refreshScrollItems
{
    self.scrollView.scrollItems = self.viewModel.scrollItems;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
