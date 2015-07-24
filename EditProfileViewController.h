//
//  EditProfileViewController.h
//  Tubor
//
//  Created by Marcelo Sedano on 4/28/15.
//  Copyright (c) 2015 Marcelo Sedano. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ProfileTableViewCell.h"
#import "TextViewCell.h"
#import "EditPictureCell.h"

@interface EditProfileViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic) PFUser *user;
@property (retain, nonatomic) IBOutlet UITableView *table;

@end
