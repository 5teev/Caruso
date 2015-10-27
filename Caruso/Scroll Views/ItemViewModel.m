//
//  ItemViewModel.m
//  Caruso
//
//  Created by Steve Milano on 10/20/15.
//  Copyright © 2015 Steve Milano. All rights reserved.
//

#import "ItemViewModel.h"

@interface ItemViewModel ()
@property (nonatomic,readwrite) NSString * shortDescription;
@property (nonatomic,readwrite) NSString * longDescription;

@property (nonatomic,readwrite) NSString *  songTitle;
@property (nonatomic,readwrite) NSString *  albumTitle;
@property (nonatomic,readwrite) NSString *  artistName;
@property (nonatomic,readwrite) NSURL    *  thumbURL;
@property (nonatomic,readwrite) NSString *  songGenre;
@property (nonatomic,readwrite) NSDate   *  releaseDate;
@property (nonatomic,readwrite) NSNumber *  price;
@property (nonatomic,readwrite) NSString *  rights;
@end

@implementation ItemViewModel

- (instancetype) initWithSongTitle:(NSString *)songTitle albumTitle:(NSString *)albumTitle artistName:(NSString *)artistName thumbURL:(NSURL *)thumbURL genre:(NSString *)songGenre releaseDate:(NSDate *)releaseDate price:(NSNumber*)price rights:(NSString *)rights
{
    self = [super init];

    if ( self )
    {
        _songTitle   = songTitle;
        _albumTitle  = albumTitle;
        _artistName  = artistName;
        _thumbURL    = thumbURL;
        _songGenre   = songGenre;
        _releaseDate = releaseDate;
        _price       = price;
        _rights      = rights;
    }

    return self;
}

- (NSString *) shortDescription {
    return [NSString stringWithFormat:@"%@\n%@\n%@",self.songTitle,self.albumTitle,self.artistName];
}

- (NSString *) longDescription {
    return [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@",self.songTitle,self.albumTitle,self.artistName,self.songGenre,self.releaseDate];
}
@end
