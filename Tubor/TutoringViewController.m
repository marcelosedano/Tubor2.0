//
//  TutoringViewController.m
//  Tubor
//
//  Created by Marcelo Sedano on 5/4/15.
//  Copyright (c) 2015 Marcelo Sedano. All rights reserved.
//

#import "TutoringViewController.h"

@interface TutoringViewController ()

@property (strong, nonatomic) UIDatePicker *timePicker;
@property (strong, nonatomic) UITextField *locationTextField;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UISwitch *availabilitySwitch;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) bool isShowingPicker;

@end

@implementation TutoringViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.user = [PFUser currentUser];
    
    // Navigation title
    [self.navigationItem setTitle:@"Tutoring"];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    // Set up location manager to get user location
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    
    // Location text field initialization
    self.locationTextField = [[UITextField alloc]initWithFrame:CGRectMake(20, 7, 285, 30)];
    self.locationTextField.clearsOnBeginEditing = NO;
    self.locationTextField.delegate = self;
    [self.locationTextField setReturnKeyType:UIReturnKeyDone];
    self.locationTextField.placeholder = @"Enter name of location";
    self.locationTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    // Availability switch initialization
    self.availabilitySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(250, 7, 185, 30)];
    [self.availabilitySwitch addTarget:self  action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    
    // Time picker initialization
    self.timePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(20, -15, 185, 165)];
    self.timePicker.datePickerMode = UIDatePickerModeTime;
    self.timePicker.minuteInterval = 15;
    [self.timePicker addTarget:self  action:@selector(timeChanged:)
         forControlEvents:UIControlEventValueChanged];
    
    // Time label initialization
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(225, 7, 185, 30)];
    NSDate *date = self.timePicker.date;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"hh:mm aa"];
    self.timeLabel.text = [dateFormat stringFromDate:date];
    
    // If tutor is not available for tutoring, switch should be off
    if ([self.user[@"isAvailable"]  isEqual: @NO]) {
        [self.availabilitySwitch setOn:NO];
    }
    
    // If tutor is available for tutoring, switch should be on
    if ([self.user[@"isAvailable"] isEqual:@YES]) {
        [self.availabilitySwitch setOn:YES];
    }
    
    // If student is in a tutoring session, alert student they cannot tutor while being tutored
    if ([self.user[@"studentAvailable"] isEqual: @NO] && [self.user[@"isAvailable"] isEqual: @NO])
    {
        [self.availabilitySwitch setOn:NO animated:YES];
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Tutoring Session in Progress"
                              message:[NSString stringWithFormat: @"\nIf you would like to be available to tutor, please end your current session."]
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
    

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(newTutorRequestNotification:)
     name:@"newTutorRequest"
     object:nil];

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(sessionEndedNotification:)
     name:@"sessionEnded"
     object:nil];
}

-(void)newTutorRequestNotification:(NSNotification *)notification
{
    NSLog(@"newTutorRequest method called in Tutoring VC");
    
    // If student
    if (self.user[@"tutorInSession"])
    {
        return;
    }
    
    // If tutor
    else
    {
        self.navigationController.tabBarItem.badgeValue = @"1";
        
        // Turn off isAvailable and availability switch
        self.user[@"isAvailable"] = @NO;
        [self.availabilitySwitch setOn:NO animated:YES];
        [self.user saveInBackground];
        
        
        NSString *key = @"student";
        NSDictionary *dictionary = [notification userInfo];
        
        // Query user database for student
        PFQuery *query = [PFUser query];
        [query whereKey:@"objectId" equalTo:[dictionary valueForKey:key]];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error)
         {
             self.student = (PFUser *) [results objectAtIndex:0];
             self.user[@"studentInSession"] = self.student[@"fullName"];
             self.user[@"courseRequested"] = self.student[@"courseRequested"];
             self.user[@"topicsDescription"] = self.student[@"topicsDescription"];
             [self.user saveInBackground];
             
             // Refresh tutor requests table
             NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:0 inSection:1];
             NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
             [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationFade];
         }];
    }
}

-(void)sessionEndedNotification:(NSNotification *)notification
{
    NSLog(@"sessionEnded method called in Tutoring VC");
    
    // If student
    if (self.user[@"tutorInSession"])
    {
        return;
    }
    
    // If tutor
    else
    {
        self.navigationController.tabBarItem.badgeValue = nil;
        self.student = nil;
        [self.user removeObjectForKey:@"studentInSession"];
        [self.user removeObjectForKey:@"tutorInSession"];
        [self.user removeObjectForKey:@"topicsDescription"];
        self.user[@"isAvailable"] = @YES;
        [self.availabilitySwitch setOn:YES animated:YES];
        
        [self.user saveInBackground];
        
        // Refresh tutor requests table
        NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:0 inSection:1];
        NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
        [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationFade];

    }
}

- (void)viewWillAppear:(BOOL)animated
{

}

-(void)switchChanged:(id)sender
{
    // If student is in a tutoring session, alert student they cannot tutor while being tutored
    if ([self.user[@"studentAvailable"] isEqual: @NO] && [self.user[@"isAvailable"] isEqual: @NO])
    {
        [self.availabilitySwitch setOn:NO animated:YES];
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Tutoring Session in Progress"
                              message:[NSString stringWithFormat: @"\nIf you would like to be available to tutor, please end your current session."]
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        // User is currently tutoring, switch turns availability off
        if ([self.user[@"isAvailable"]  isEqual: @YES])
        {
            self.user[@"isAvailable"] = @NO;
            self.user[@"studentAvailable"] = @YES;
            self.locationTextField.enabled = YES;
            self.locationTextField.textColor = [UIColor blackColor];
            [self.tableView reloadData];
        }
        
        // User is not currently tutoring, switch turns availability on
        else
        {
            NSString *location = self.locationTextField.text;
            NSString *timeAvailable = self.timeLabel.text;
            
            self.locationTextField.enabled = NO;
            self.locationTextField.textColor = [UIColor lightGrayColor];
            // User didn't enter a location
            if ([location length] == 0) {
                // Alert to enter a location
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"No Location"
                                      message:[NSString stringWithFormat: @"\nPlease enter your location."]
                                      delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil];
                // Set the switch back to NO
                [self.availabilitySwitch setOn:NO animated:YES];
                [alert show];
                return;
            }
            
            self.user[@"isAvailable"] = @YES;
            self.user[@"studentAvailable"] = @NO;
            self.user[@"location"] = location;
            self.user[@"timeAvailable"] = timeAvailable;
            [self.tableView reloadData];
            
            // Set user's current location on Parse
            [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
                if (!error) {
                    self.user[@"currentLocation"] = geoPoint;
                }
            }];
        }
        
        [self.user saveInBackground];
    }
}

-(void)timeChanged:(id)sender
{
    NSDate *date = self.timePicker.date;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"hh:mm aa"];
    self.timeLabel.text = [dateFormat stringFromDate:date];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

// Hides keyboard when user taps somewhere other than the keyboard
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    // Session information section
    if (section == 0) {
        if (self.isShowingPicker)
            return 4;
        else
            return 3;
    }
    
    // Tutor requests section
    else
        return 3;
}

// Set the row height.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isShowingPicker)
    {
        if (indexPath.section == 0 && indexPath.row == 2)
            return 190.0;
    }
    
    if ([indexPath section] == 1)
    {
        return 60.0;
    }
    else
    {
        return 44.0;
    }
}


// Add header titles in sections.
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Session Information";
    }
    if (section == 1) {
        return @"Tutor requests";
    }
    else
        return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Session information section
    if (indexPath.section == 0)
    {
        static NSString *CellIdentifier;
        // Location cell
        if(indexPath.row == 0)
        {
            CellIdentifier = @"locationCell";
        }
        
        // Time of session cell
        if(indexPath.row == 1)
        {
            CellIdentifier = @"timeCell";
        }
        
        // Availibility switch cell or date picker cell
        if(indexPath.row == 2)
        {
            if (self.isShowingPicker)
            {
                CellIdentifier = @"pickerCell";
            }
            else
            {
                CellIdentifier = @"availabilityCell";
            }
        }
        
        // Availability switch cell
        if(indexPath.row == 3)
        {
            CellIdentifier = @"availabilityCell";
        }
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        // Location cell
        if(indexPath.row == 0)
        {
            [cell.contentView addSubview:self.locationTextField];
        }
        
        // Time of session cell
        if(indexPath.row == 1)
        {
            cell.textLabel.text = @"Time of session";
            [cell.contentView addSubview:self.timeLabel];
        }
        
        // Availibility switch cell or date picker cell
        if(indexPath.row == 2)
        {
            if (self.isShowingPicker)
            {
                [cell.contentView addSubview:self.timePicker];
            }
            else
            {
                cell.textLabel.text = @"Available to tutor";
                [cell.contentView addSubview:self.availabilitySwitch];
            }
        }
        
        // Availability switch cell
        if(indexPath.row == 3)
        {
            cell.textLabel.text = @"Available to tutor";
            [cell.contentView addSubview:self.availabilitySwitch];
        }
        
        return cell;
    }
    
    // Tutor request section
    else
    {
        static NSString *CellIdentifier = @"EditPictureCell";
        EditPictureCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            [tableView registerNib:[UINib nibWithNibName:CellIdentifier bundle:nil] forCellReuseIdentifier:CellIdentifier];
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        }
        
        if (self.student)
        {
            [cell.cellImageView setHidden:NO];
            cell.cellTextLabel.text = self.student[@"fullName"];
            //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            PFFile *userImageFile = self.student[@"profilePicture"];
            [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                if (!error) {
                    cell.cellImageView.image = [UIImage imageWithData:imageData];
                    
                }
            }];

        }
        else
        {
            [cell.cellImageView setHidden:YES];
        }
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Session information section
    if (indexPath.section == 0)
    {
        // Time of session cell
        if (indexPath.row == 1)
        {
            // Change color of time label
            if (self.isShowingPicker)
            {
                [self.timeLabel setTextColor:[UIColor blackColor]];
            }
            else
            {
                [self.timeLabel setTextColor:[UIColor redColor]];
            }
            
            // Switch picker boolean
            self.isShowingPicker = !self.isShowingPicker;
            
            // Refresh table
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            /*
            NSIndexPath* rowToReload1 = [NSIndexPath indexPathForRow:2 inSection:0];
            NSIndexPath* rowToReload2 = [NSIndexPath indexPathForRow:3 inSection:0];
            NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload1, rowToReload2, nil];
            [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationFade];
             */
        }
    }
    
    // Tutor request section has a student
    else if (self.student && indexPath.section == 1 && indexPath.row == 0)
    {
        [self performSegueWithIdentifier:@"tutoringViewToSessionSegue" sender:self];
    }
}

@end
