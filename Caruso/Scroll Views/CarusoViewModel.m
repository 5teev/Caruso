//
//  CarusoViewModel.m
//  Caruso
//
//  Created by Steve Milano on 10/20/15.
//  Copyright © 2015 Steve Milano. All rights reserved.
//

#import "CarusoViewModel.h"
#import "Constants.h"
#import "ItemViewModel.h"
#import <AFNetworking/AFNetworking.h>
#import <XMLDictionary/XMLDictionary.h>

@interface CarusoViewModel ()
// redeclare KVO flag so it's internally modifiable
@property (nonatomic,readwrite) BOOL isLoading;

// redeclare array so it's internally modifiable
@property (nonatomic,strong,readwrite) NSArray * scrollItems;

@end

@implementation CarusoViewModel
- (instancetype) init
{
    self = [super init];

    if ( self )
    {
        NSLog(@"CarusoViewModel: loading starts");
        self.isLoading = YES;

        self.scrollItems = @[];

        NSURL * URL = [NSURL URLWithString:DataSourceURLString];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFXMLParserResponseSerializer serializer];
        operation.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/atom+xml"];

        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [self createScrollItemsFromDictionary:[NSDictionary dictionaryWithXMLParser:(NSXMLParser*)responseObject]];
        
        } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
            NSLog(@"problem: %@ %@",error,operation);
        }];
        
        [operation start];

    }

    return self;
}

- (void) createScrollItemsFromDictionary:(NSDictionary *)dictionary
{
    self.isLoading = YES;

    NSArray * itemsArray = dictionary[DataItemsKeyString];

    // store ItemViewModel objects as they're created
    NSMutableArray * tmpAppendingArray = [NSMutableArray array];
    
    for (NSDictionary *dict in itemsArray )
    {
        // groping through the XML tree
        NSString * songTitle = dict[@"im:name"];
        NSString * albumTitle = dict[@"im:collection"][@"im:name"];
        NSString * artistName = dict[@"im:artist"][@"__text"];
        NSString * thumbURLString = dict[@"im:image"][2][@"__text"];
        NSString * genre = dict[@"category"][@"_label"];

        // extract date from string such as 2014-10-27T00:00:00-07:00
        NSString * releaseDateString = dict[@"im:releaseDate"][@"__text"];
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
        NSDate * releaseDate = [dateFormatter dateFromString:releaseDateString];

        NSString * price = dict[@"im:price"][@"_amount"];
        NSString * rights = dict[@"rights"];

        // because of the sketchy XML spelunking needed to build each item,
        // verify each element and if anything is null or empty, skip it
        if (
            [songTitle isEqual:[NSNull null]] || [songTitle isEqualToString:@""]
            ||
            [albumTitle isEqual:[NSNull null]] || [albumTitle isEqualToString:@""]
            ||
            [artistName isEqual:[NSNull null]] || [artistName isEqualToString:@""]
            ||
            [thumbURLString isEqual:[NSNull null]] || [thumbURLString isEqualToString:@""]
            ||
            [genre isEqual:[NSNull null]] || [genre isEqualToString:@""]
            ||
            [releaseDate isEqual:[NSNull null]] // NSDate should be valid, not just the extracted string
            ||
            [price isEqual:[NSNull null]] || [price isEqualToString:@""]
            ||
            [rights isEqual:[NSNull null]] || [rights isEqualToString:@""]
            )
        {
            NSLog(@"Could not instantiate ItemViewModel for %@", dict);
            continue;
        }

        // If we reach this point, all needed items exist;
        // use them to create an ItemViewModel instance.

        ItemViewModel * itemViewModel = [[ItemViewModel alloc] initWithSongTitle:songTitle
                                                                      albumTitle:albumTitle
                                                                      artistName:artistName
                                                                        thumbURL:[NSURL URLWithString:thumbURLString]
                                                                           genre:genre
                                                                     releaseDate:releaseDate
                                                                           price:[NSNumber numberWithFloat:[price floatValue]]
                                                                          rights:rights];
        [tmpAppendingArray addObject:itemViewModel];
    }

    // convert mutable array to array and replace any existing scrollItems
    self.scrollItems = [NSArray arrayWithArray:tmpAppendingArray];

    // signal observer that data is ready
    self.isLoading = NO;
}

@end
