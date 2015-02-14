//
//  SegmentedCell.h
//  Yelp
//
//  Created by David Tong on 2/12/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SegmentedCell;

@protocol SegmentedCellDelegate <NSObject>

- (void)SegmentedCell:(SegmentedCell *)segmentedCell didUpdateValue:(NSInteger) selectedIndex;

@end

@interface SegmentedCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (weak, nonatomic) id<SegmentedCellDelegate> delegate;

@end
