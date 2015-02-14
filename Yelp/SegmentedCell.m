//
//  SegmentedCell.m
//  Yelp
//
//  Created by David Tong on 2/12/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "SegmentedCell.h"

@interface SegmentedCell ()

- (IBAction)didUpdateValue:(id)sender;

@end

@implementation SegmentedCell

- (void)awakeFromNib {
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.tintColor = [UIColor redColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (IBAction)didUpdateValue:(id)sender {
    [self.delegate SegmentedCell:self didUpdateValue:self.segmentedControl.selectedSegmentIndex];
}
@end
