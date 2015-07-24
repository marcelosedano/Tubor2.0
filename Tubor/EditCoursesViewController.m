//
//  EditCoursesViewController.m
//  Tubor
//
//  Created by Marcelo Sedano on 5/3/15.
//  Copyright (c) 2015 Marcelo Sedano. All rights reserved.
//

#import "EditCoursesViewController.h"

enum SegmentedControlIndices {
    Taking = 0,
    Tutoring = 1
};

@interface EditCoursesViewController ()

@end

@implementation EditCoursesViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.user = [PFUser currentUser];
    
    // Set the courses table to editing mode
    [self.coursesTable setEditing: YES animated: YES];
}

// Hides keyboard when user taps somewhere other than the keyboard
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

// Delete courses from table when in edit mode
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // User deletes a course from the "coursesTaking" section
    if (indexPath.section == 0)
        [self.user[@"coursesTaking"] removeObjectAtIndex:indexPath.row];
    
    // User deletes a course from the "coursesTutoring" section
    else
        [self.user[@"coursesTutoring"] removeObjectAtIndex:indexPath.row];
    
    // Remove course from table at indexpath
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    [self.user saveInBackground];
}

// Number of rows in section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Courses taking section
    if (section == 0)
        return [self.user[@"coursesTaking"] count];
    
    // Courses tutoring section
    else
        return [self.user[@"coursesTutoring"] count];
}

// Cell for row at indexpath
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DefaultCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Cells for courses taking
    if (indexPath.section == 0)
    {
        cell.textLabel.text = [self.user[@"coursesTaking"] objectAtIndex:indexPath.row];
    }
    // Cells for courses tutoring
    else
    {
        cell.textLabel.text = [self.user[@"coursesTutoring"] objectAtIndex:indexPath.row];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Set the editing style to delete for the rows in the table
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}


- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

// Number of sections in the table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

// Set the row height
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0;
}

// Set the title for each section of the table
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
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

// IBAction linked to the "Add Course" button that adds the course entered by user
- (IBAction)addCourseButton:(id)sender
{
    BOOL valid = [self validateCourse];
    
    if (valid)
    {
        NSString *courseToAdd = [self.courseTextField.text uppercaseString];
        
        // "Taking" is selected in the segmented control
        if (self.segmentedControl.selectedSegmentIndex == Taking)
        {
            [self.user[@"coursesTaking"] addObject:courseToAdd];
        }
        
        // "Tutoring" is selected in the segmented control
        else if (self.segmentedControl.selectedSegmentIndex == Tutoring)
        {
            [self.user[@"coursesTutoring"] addObject:courseToAdd];
        }
        
        // Clear text field once course has been added
        self.courseTextField.text = @"";
        
        [self.user saveInBackground];
        [self.coursesTable reloadData];
    }
}

-(BOOL)validateCourse
{
    NSString *courseToAdd = [self.courseTextField.text uppercaseString];
    NSLog(@"Course entered: %@", courseToAdd);
    
    // Check if course entered is 6 characters long or has correct format
    if ([courseToAdd length] != 6 || ![self hasCorrectFormat:courseToAdd])
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Not a valid course"
                              message:@"\nPlease enter a valid course with the correct format (3 letters, 3 numbers)"
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    
    // Check if course is already in courses table
    else
    {
        NSInteger selectedControl = self.segmentedControl.selectedSegmentIndex;
        
        if ((selectedControl == Taking && [self.user[@"coursesTaking"] containsObject:courseToAdd])
            || (selectedControl == Tutoring && [self.user[@"coursesTutoring"] containsObject:courseToAdd]))
        {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Already added"
                                  message:@"\nThe course you are trying to add has already been added"
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
            return NO;
        }
    }
    
    return YES;
}

-(BOOL)hasCorrectFormat: (NSString *)course
{
    // Check if course entered is 3 letters followed by 3 numbers
    for (int i = 0; i < 6; i++)
    {
        unichar currentChar = [course characterAtIndex:i];
        if (i < 3)
        {
            if (currentChar < 'A' || currentChar > 'Z') return NO;
        }
        else
        {
            if (currentChar < '0' || currentChar > '9') return NO;
        }
    }
    
    return YES;
}

@end
