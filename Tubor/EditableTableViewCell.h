//
//  EditableTableViewCell.h
//  Tubor
//
//  Created by Marcelo Sedano on 4/30/15.
//  Copyright (c) 2015 Marcelo Sedano. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditableTableViewCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UITextField *cellTextField;
@property (nonatomic, weak) IBOutlet UILabel *cellTextLabel;
@end
