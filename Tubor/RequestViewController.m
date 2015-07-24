//
//  RequestViewController.m
//  Tubor
//
//  Created by Jake Irvin on 3/25/15.
//  Copyright (c) 2015 Marcelo Sedano. All rights reserved.
//

#import "RequestViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface RequestViewController () 

@end

@implementation RequestViewController

PFUser *selectedTutor;

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    // Set the property for the current user
    self.user = [PFUser currentUser];
    
    // Session button initialization
    self.sessionButton = [[UIBarButtonItem alloc] initWithTitle:@"Session" style:UIBarButtonItemStylePlain target:self action:@selector(segueToSession)];
    self.sessionButton.tintColor = [UIColor whiteColor]; // Color of button
    
    // Navigation bar GUI
    UIImageView *navigationImage =[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 76, 25)];
    navigationImage.image=[UIImage imageNamed:@"tNavTitle.png"];
    
    UIImageView *workaroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 76, 25)];
    [workaroundImageView addSubview:navigationImage];
    self.navigationItem.titleView = workaroundImageView;
    
    // Location manager and map authorization code
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    self.mapView.showsUserLocation=YES;
    self.mapView.delegate = self;
    
    // Set mapview region (ASU campus)
    MKCoordinateRegion region;
    region.center.latitude = 33.419834;
    region.center.longitude = -111.932500;
    region.span.latitudeDelta = 0.005;
    region.span.longitudeDelta = 0.005;
    
    [self.mapView setRegion:region animated:YES];
    
    // Table view instantiation (drop down menu)
    
    self.courseSelectionTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Rounded corners for drop down menu
    self.courseSelectionTable.layer.cornerRadius = 5;
    
    // Initially, the isShowingList value will be set to NO.
    // We don't want the list to be dislplayed when the view loads.
    self.isShowingList = NO;
    
    // By default, when the view loads, the first value of the five we created
    // above will be set as selected.
    // We'll do that by pointing to the first index of the array.
    // Don't forget that for the five items of the array, the indexes are from
    // zero to four (0 - 4).
    self.selectedValueIndex = 0;
    
    
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

-(void)segueToSession
{
    [self performSegueWithIdentifier:@"requestViewToSessionSegue" sender:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.coursesArray = [[NSMutableArray alloc] init];
    [self.coursesArray addObject:@"Select Course"];
    [self.coursesArray addObjectsFromArray:self.user[@"coursesTaking"]];
    
    // Hide navigation bar
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // Add session button to nav bar if there is a session in progress
    if ([self.user[@"studentAvailable"] isEqual: @NO] && [self.user[@"isAvailable"] isEqual: @NO])
    {
        if (!self.navigationItem.rightBarButtonItem)
            self.navigationItem.rightBarButtonItem = self.sessionButton;
    }
    else
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

-(void)newTutorRequestNotification:(NSNotification *)notification
{
    NSLog(@"newTutorRequest method called in Request VC");
    self.navigationItem.rightBarButtonItem = self.sessionButton;
    
    // If student
    if (self.user[@"tutorInSession"])
    {
        self.navigationController.tabBarItem.badgeValue = @"1";
    }
}

-(void)sessionEndedNotification:(NSNotification *)notification
{
    NSLog(@"sessionEnded method called in Request VC");
    
    // If student
    if (self.user[@"tutorInSession"])
    {
        self.user[@"studentAvailable"] = @YES;
        [self.user removeObjectForKey:@"studentInSession"];
        [self.user removeObjectForKey:@"tutorInSession"];
        [self.user removeObjectForKey:@"location"];
        [self.user removeObjectForKey:@"topicsDescription"];
        [self.user saveInBackground];
        
        self.navigationController.tabBarItem.badgeValue = nil;
    }

    self.navigationItem.rightBarButtonItem = nil;
    
}

#pragma mark - Drop Down Table Methods

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // We are going to have only three sections in this example.
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.isShowingList)
    {
        return 1;
    }
    else
    {
        return [self.coursesArray count];
    }
}

// Set the row height.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    
    if (!self.isShowingList)
    {
        // Not a list in this case.
        // We'll only display the item of the demoData array of which array
        // index matches the selectedValueList.
        [[cell textLabel] setText:[self.coursesArray objectAtIndex:self.selectedValueIndex]];
            
        // We'll also display the disclosure indicator to prompt user to
        // tap on that cell.
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else
    {
        // Listing the array items.
        [[cell textLabel] setText:[self.coursesArray objectAtIndex:[indexPath row]]];
        
        // We'll display the checkmark next to the already selected value.
        // That means that we'll apply the checkmark only to the cell
        // where the [indexPath row] value is equal to selectedValueIndex value.
        if ([indexPath row] == self.selectedValueIndex)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // If user is currently tutoring, alert user they cannot request a tutor while tutoring
    if ([self.user[@"isAvailable"] isEqual: @YES])
    {
        UIAlertView *alert = [[UIAlertView alloc]
                    initWithTitle:[NSString stringWithFormat: @"You're Tutoring Right Now"]
                                       message:[NSString stringWithFormat: @"You can't tutor and be tutored at the same time :)"]
                                       delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
        [alert show];
        return;
        
    }
    
    // If user is currently in a tutoring session, alert user they cannot request another tutor
    if ([self.user[@"studentAvailable"] isEqual: @NO])
    {
        UIAlertView *alert = [[UIAlertView alloc]
                                       initWithTitle:[NSString stringWithFormat: @"Tutoring Session in Progress"]
                                       message:[NSString stringWithFormat: @"If you would like to be available to tutor, please end your current session."]
                                       delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (self.isShowingList)
    {
        self.selectedValueIndex = (int) [indexPath row];
        UITableViewCell *selectedCourse = [self.courseSelectionTable cellForRowAtIndexPath:indexPath];
        self.user[@"courseRequested"] = selectedCourse.textLabel.text;
        //[self.user saveInBackground]; Should only save this when request is made in tutor's profile VC
    }
    
    self.isShowingList = !self.isShowingList;

    if (self.isShowingList)
    {
        self.courseSelectionTable.frame = CGRectMake(self.courseSelectionTable.frame.origin.x, self.courseSelectionTable.frame.origin.y, self.courseSelectionTable.frame.size.width, (self.courseSelectionTable.contentSize.height)*[self.coursesArray count]);
    }
    else
    {
        self.courseSelectionTable.frame = CGRectMake(self.courseSelectionTable.frame.origin.x, self.courseSelectionTable.frame.origin.y, self.courseSelectionTable.frame.size.width, 40.0);

        // Remove any annotations from map view
        [self removeAllPins];
        
        // Query user database for tutors for specific course
        PFQuery *query = [PFUser query];
        [query whereKey:@"isAvailable" equalTo:[NSNumber numberWithBool:YES]];
        [query whereKey:@"coursesTutoring" equalTo:[self.coursesArray objectAtIndex:self.selectedValueIndex]];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error)
        {
            self.tutorsOnMap = (NSMutableArray *) results;
            
            // Add map annotations for all available tutors
            for (int i = 0; i < [results count]; i++)
            {
                [self addAnnotation:results[i]];
            }
        }];
    }
    [self.courseSelectionTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

// Method to add an annotation
- (void)addAnnotation:(PFUser *)availableTutor {
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    PFGeoPoint *geoPoint = availableTutor[@"currentLocation"];
    point.coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
    point.title = availableTutor[@"fullName"];
    point.subtitle = [NSString stringWithFormat:@"%@",
                availableTutor[@"location"]];
    [self.mapView addAnnotation:point];
}

// View for annotations
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle any custom annotations.
    else
    {
        
        // If an existing pin view was not available, create one.
        MKPinAnnotationView *pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
        pinView.animatesDrop = YES;
        pinView.canShowCallout = YES;
        
        // Annotation button initialization
        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [rightButton addTarget:self
                        action:@selector(showTutorProfile:)
              forControlEvents:UIControlEventTouchUpInside];
        pinView.rightCalloutAccessoryView = rightButton;
        
        // Annotation tutor picture initialization
        UIImageView *tutorPicture = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        tutorPicture.contentMode = UIViewContentModeScaleAspectFill;
        tutorPicture.layer.cornerRadius = 20;
        tutorPicture.clipsToBounds = YES;
        tutorPicture.layer.borderWidth = 0.25f;
        tutorPicture.layer.borderColor = [UIColor blackColor].CGColor;
        
        MKPointAnnotation *selectedAnn = (MKPointAnnotation *)annotation;
        self.selectedTutor = [self findTutorWithName:selectedAnn.title];
        
        PFFile *userImageFile = self.selectedTutor[@"profilePicture"];
        [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                tutorPicture.image = [UIImage imageWithData:imageData];
            }
        }];
        pinView.leftCalloutAccessoryView = tutorPicture;
        
        return pinView;
    }
}

// Method to search tutors array for tutor belonging to annotation
- (PFUser *)findTutorWithName:(NSString *)fullName
{
    PFUser *tutor;
    for (int i = 0; i < [self.tutorsOnMap count]; i++)
    {
        tutor = self.tutorsOnMap[i];
        if ([tutor[@"fullName"] isEqualToString:fullName])
        {
            return tutor;
        }
    }
    
    return NULL;
}

// Show tutor segue action
- (void)showTutorProfile:(id)sender
{
    id<MKAnnotation> annotation = [[self.mapView selectedAnnotations] objectAtIndex:0];
    self.selectedTutor = [self findTutorWithName:annotation.title];
    [self performSegueWithIdentifier:@"showTutorSegue" sender:self];
}

// Remove all pins from map view
- (void)removeAllPins
{
    id userLocation = [self.mapView userLocation];
    NSMutableArray *pins = [[NSMutableArray alloc] initWithArray:[self.mapView annotations]];
    if (userLocation != nil) {
        [pins removeObject:userLocation]; // avoid removing user location off the map
    }
    
    [self.mapView removeAnnotations:pins];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"showTutorSegue"])
    {
        UINavigationController *navController = segue.destinationViewController;
        ProfileViewController *userProfileViewController = (ProfileViewController *) navController.topViewController;
        
        //if you need to pass data to the next controller do it here
        userProfileViewController.user = self.selectedTutor;
        userProfileViewController.previousVC = @"Request";
    }
}

@end












