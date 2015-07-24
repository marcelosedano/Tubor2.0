//
//  SessionViewController.h
//  Tubor
//
//  Created by Marcelo Sedano on 5/6/15.
//  Copyright (c) 2015 Marcelo Sedano. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface SessionViewController : UIViewController <UIAlertViewDelegate>

@property (nonatomic) PFUser *user;
@property (nonatomic) PFUser *tutor;
@property (weak, nonatomic) IBOutlet UILabel *tutorLabel;
@property (weak, nonatomic) IBOutlet UILabel *studentLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseLabel;
@property (weak, nonatomic) IBOutlet UITextView *topicsTextView;

@end
