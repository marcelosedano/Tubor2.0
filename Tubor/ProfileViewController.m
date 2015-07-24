//
//  ProfileViewController.m
//  Tubor
//
//  Created by Marcelo Sedano on 3/24/15.
//  Copyright (c) 2015 Marcelo Sedano. All rights reserved.
//

#import "ProfileViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ProfileViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UITableView *coursesTakingTable;
@property (weak, nonatomic) IBOutlet UITextField *userFullName;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *majorLabel;
@property (weak, nonatomic) IBOutlet UITextView *biography;
@property (weak, nonatomic) IBOutlet UIButton *requestButton;
- (IBAction)requestTutor:(id)sender;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.profilePicture.layer.cornerRadius = 44;
    self.profilePicture.clipsToBounds = YES;
    self.profilePicture.layer.borderWidth = 0.25f;
    self.profilePicture.layer.borderColor = [UIColor blackColor].CGColor;
    
    // Customize view controller depending on source view controller
    if ([self.previousVC isEqualToString:@"Login"]) {
        [self.navigationItem setTitle:@"My Profile"];
        
        [self.requestButton setHidden:YES];
        
        UIImage *buttonImage = [UIImage imageNamed:@"settingsIcon.png"];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:buttonImage landscapeImagePhone:nil style:UIBarButtonItemStylePlain target:self action:@selector(segueToEditProfile)];
    } else if ([self.previousVC isEqualToString:@"Request"]) {
        [self.navigationItem setTitle:self.user[@"fullName"]];
        
        // Add "Request" button
        CALayer *btnLayer = [self.requestButton layer];
        [btnLayer setMasksToBounds:YES];
        [btnLayer setCornerRadius:5.0f];
        self.requestButton.layer.borderWidth=1.0f;
        self.requestButton.layer.borderColor=[[UIColor lightGrayColor] CGColor];
    }
    
    // Table section title font size
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setFont:[UIFont boldSystemFontOfSize:12]];
    // Table view rounded corners
    self.coursesTakingTable.layer.cornerRadius = 5; // Uses QuartzCore
    
    // Rounded text view for biography
    [self.biography.layer setBorderColor: [[UIColor clearColor] CGColor]];
    [self.biography.layer setBorderWidth: 1.0];
    [self.biography.layer setCornerRadius:8.0f];
    [self.biography.layer setMasksToBounds:YES];
}

-(void)segueToEditProfile {
    [self performSegueWithIdentifier:@"editProfileSegue" sender:self];
}

- (void)viewWillAppear:(BOOL)animated {
    self.userFullName.text = self.user[@"fullName"];
    self.phoneNumber.text = self.user[@"phoneNumber"];
    self.majorLabel.text = self.user[@"major"];
    self.biography.text = self.user[@"bio"];

    PFFile *userImageFile = self.user[@"profilePicture"];
    [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            self.profilePicture.image = [UIImage imageWithData:imageData];
        }
    }];
    
    [self.coursesTakingTable reloadData];
}

#pragma mark - Table View Methods

// Delete courses from table when in edit mode
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [self.user[@"coursesTaking"] removeObjectAtIndex:indexPath.row];
    } else {
        [self.user[@"coursesTutoring"] removeObjectAtIndex:indexPath.row];
    }
    
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

// Number of rows in section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.user[@"coursesTaking"] count];
    } else {
        return [self.user[@"coursesTutoring"] count];
    }
}

// Cell for row at indexpath
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"DefaultCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    //cell.textLabel.font = [cell.textLabel.font fontWithSize:14];

    // Cells for courses taking
    if (indexPath.section == 0) {
        cell.textLabel.text = [self.user[@"coursesTaking"] objectAtIndex:indexPath.row];
    }
    // Cells for courses tutoring
    else {
        cell.textLabel.text = [self.user[@"coursesTutoring"] objectAtIndex:indexPath.row];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

// Set the row height
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *sectionName;
    switch (section) {
        case 0:
            sectionName = @"Current Courses";
            break;
        case 1:
            sectionName = @"Courses Tutoring";
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

- (IBAction)requestTutor:(id)sender {
    // If user is currently in a tutoring session, alert user they cannot request another tutor
    if ([[PFUser currentUser][@"studentAvailable"] isEqual: @NO]) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:[NSString stringWithFormat: @"Tutoring Session in Progress"]
                              message:[NSString stringWithFormat: @"If you would like to be available to tutor, please end your current session."]
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"Are you sure you want to send a request?"
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Send tutor request", nil];
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // User select "Yes" from action sheet
    if (buttonIndex == 0) {
        [self.requestButton setTitle:@"Requested" forState:UIControlStateNormal];
        
        // Ask student to type any concepts or topics they need help with
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Request Details" message:@"Enter any concepts or topics you need help with." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send", nil] ;
        alertView.tag = 1;
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1 && buttonIndex == 1) {
        PFUser *currentUser = [PFUser currentUser];
        
        // When a user taps the "request" button, this will send a push notification to the requested tutor
        PFQuery *pushQuery = [PFInstallation query];
        [pushQuery whereKey:@"username" equalTo:self.user[@"username"]];
        
        NSString *message = [NSString stringWithFormat:@"%@ has requested you for help with %@ and will be arriving at your location shortly.", currentUser[@"fullName"], currentUser[@"courseRequested"]];
        
        NSDictionary *data = @{
                               @"alert"            : message,
                               @"badge"            :@"Increment",
                               @"content-available" : @1,
                               @"student"          : currentUser.objectId,
                               @"notificationName" : @"newTutorRequest"
                               };
        
        PFPush *push = [[PFPush alloc] init];
        [push setQuery:pushQuery];
        [push setData:data];
        [push sendPushInBackground];
        
        currentUser[@"studentAvailable"] = @NO;
        currentUser[@"tutorInSession"] = self.user[@"fullName"];
        currentUser[@"location"] = self.user[@"location"];
        currentUser[@"topicsDescription"] = [alertView textFieldAtIndex:0].text;
        [currentUser saveInBackground];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"newTutorRequest" object:self userInfo:nil];
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:[NSString stringWithFormat: @"Tutor request sent!"]
                              message:[NSString stringWithFormat: @"\nYou have requested help from %@.  They will be expecting you at %@.", self.user[@"fullName"], self.user[@"location"]]
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}
@end