//
//  TutoringViewController.h
//  Tubor
//
//  Created by Marcelo Sedano on 5/4/15.
//  Copyright (c) 2015 Marcelo Sedano. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <CoreLocation/CoreLocation.h>
#import "EditPictureCell.h"

@interface TutoringViewController : UITableViewController <UITextFieldDelegate, CLLocationManagerDelegate>

@property (nonatomic) PFUser *user;
@property (nonatomic) PFUser *student;

@end
