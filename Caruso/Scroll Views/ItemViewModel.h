//
//  ItemViewModel.h
//  Caruso
//
//  Created by Steve Milano on 10/20/15.
//  Copyright © 2015 Steve Milano. All rights reserved.
//

@import Foundation;

@interface ItemViewModel : NSObject

@property (nonatomic,strong) NSString * message;
//@property (nonatomic,strong) NSString * imageURLString;

- (instancetype) initWithSongTitle:(NSString *)songTitle albumTitle:(NSString *)albumTitle artistName:(NSString *)artistName thumbURL:(NSURL *)thumbURL genre:(NSString *)songGenre releaseDate:(NSDate *)releaseDate price:(NSNumber*)price rights:(NSString *)rights;

// define short and long text
@property (nonatomic,readonly) NSString * shortDescription;
@property (nonatomic,readonly) NSString * longDescription;

// it might also be convenient to read individual items
@property (nonatomic,readonly) NSString * songTitle;
@property (nonatomic,readonly) NSString * albumTitle;
@property (nonatomic,readonly) NSString * artistName;
@property (nonatomic,readonly) NSURL * thumbURL;
@property (nonatomic,readonly) NSString * songGenre;
@property (nonatomic,readonly) NSDate * releaseDate;
@property (nonatomic,readonly) NSNumber * price;
@property (nonatomic,readonly) NSString * rights;

@end
