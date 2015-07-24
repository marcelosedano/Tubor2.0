//
//  TextViewCell.h
//  Tubor
//
//  Created by Marcelo Sedano on 5/1/15.
//  Copyright (c) 2015 Marcelo Sedano. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *cellTextView;
@property (weak, nonatomic) IBOutlet UILabel *cellTextLabel;

@end
