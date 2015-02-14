//
//  Business.m
//  Yelp
//
//  Created by David Tong on 2/10/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "Business.h"

@implementation Business

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];

    if (self) {
        NSArray *categories = dictionary[@"categories"];
        NSMutableArray *categoryName = [NSMutableArray array];
        [categories enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [categoryName addObject:obj[0]];
        }];
        self.categories = [categoryName componentsJoinedByString:@", "];
        self.name = dictionary[@"name"];
        self.imageUrl = dictionary[@"image_url"];
        
        // location might not be present, so do some work here
        NSDictionary *location = dictionary[@"location"];
        if (location) {
            NSArray *streetInfo = [dictionary valueForKeyPath:@"location.address"];
            NSArray *neighborhoodInfo =[dictionary valueForKeyPath:@"location.neighborhoods"];
            NSString *street = @"";
            NSString *neighborhood = @"";
            
            if ([streetInfo count]) {
                street = [dictionary valueForKeyPath:@"location.address"][0];
            }
            if ([neighborhoodInfo count]) {
                neighborhood = [dictionary valueForKeyPath:@"location.neighborhoods"][0];
            }
            
            if ([street length] && [neighborhood length]) {
                self.address = [NSString stringWithFormat:@"%@, %@", street, neighborhood];
            } else if ([street length]) {
                self.address = street;
            } else if ([neighborhood length]) {
                self.address = neighborhood;
            }
        }
        
        
        self.numReviews = [dictionary[@"review_count"] integerValue];
        self.ratingImageUrl = dictionary[@"rating_img_url"];
        float milesPerMeter = 0.00621371;
        self.distance = [dictionary[@"distance"] integerValue] * milesPerMeter;
        
    }
    return self;
}


+ (NSArray *)businessesWithDictionaries:(NSArray *)dictionaries {
    NSMutableArray *businesses = [NSMutableArray array];
    for (NSDictionary *dictionary in dictionaries) {
        Business *business = [[Business alloc] initWithDictionary:dictionary];
        
        [businesses addObject:business];
    }
    
    return businesses;
}

@end
