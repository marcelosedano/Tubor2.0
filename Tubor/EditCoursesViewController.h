//
//  EditCoursesViewController.h
//  Tubor
//
//  Created by Marcelo Sedano on 5/3/15.
//  Copyright (c) 2015 Marcelo Sedano. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface EditCoursesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) PFUser *user;

// Sub-views
@property (weak, nonatomic) IBOutlet UITableView *coursesTable;
@property (weak, nonatomic) IBOutlet UITextField *courseTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

// IBActions
- (IBAction)addCourseButton:(id)sender;

@end
