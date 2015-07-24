//
//  ProfileTableViewCell.m
//  Tubor
//
//  Created by Marcelo Sedano on 4/1/15.
//  Copyright (c) 2015 Marcelo Sedano. All rights reserved.
//

#import "ProfileTableViewCell.h"

@implementation ProfileTableViewCell

- (void)awakeFromNib {
    // Initialization code
    //self.cellTextField.delegate = self;
    //[self.cellTextField setReturnKeyType:UIReturnKeyDone];
}

-(void)setTextFieldEditable:(BOOL)editable
{
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

// Hides keyboard when user taps somewhere other than the keyboard
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.cellTextField endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
