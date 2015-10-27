//
//  CarusoViewModel.h
//  Caruso
//
//  Created by Steve Milano on 10/20/15.
//  Copyright © 2015 Steve Milano. All rights reserved.
//

@import Foundation;

@interface CarusoViewModel : NSObject

// declare KVO flag as observe-only
@property (nonatomic,readonly) BOOL isLoading;

// declare array as read-only
@property (nonatomic,strong,readonly) NSArray * scrollItems;

@end
