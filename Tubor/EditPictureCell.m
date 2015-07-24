//
//  EditPictureCell.m
//  Tubor
//
//  Created by Marcelo Sedano on 5/3/15.
//  Copyright (c) 2015 Marcelo Sedano. All rights reserved.
//

#import "EditPictureCell.h"

@implementation EditPictureCell

- (void)awakeFromNib {
    // Initialization code
    self.cellImageView.layer.cornerRadius = 25;
    self.cellImageView.clipsToBounds = YES;
    self.cellImageView.layer.borderWidth = 0.25f;
    self.cellImageView.layer.borderColor = [UIColor blackColor].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
