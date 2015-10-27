//
//  ItemView.h
//  Caruso
//
//  Created by Steve Milano on 10/20/15.
//  Copyright © 2015 Steve Milano. All rights reserved.
//

@import UIKit;
@class ItemViewModel;

@interface ItemView : UIView

@property (nonatomic,strong) ItemViewModel * viewModel;

// members that might be of interest to others
@property (nonatomic,strong,readonly) NSString * shortMessage;
@property (nonatomic,strong,readonly) NSString * longMessage;



@end
