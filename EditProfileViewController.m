//
//  EditProfileViewController.m
//  Tubor
//
//  Created by Marcelo Sedano on 4/28/15.
//  Copyright (c) 2015 Marcelo Sedano. All rights reserved.
//

#import "EditProfileViewController.h"

@interface EditProfileViewController ()

@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.user = [PFUser currentUser];
    
    // Cancel button
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButton)];
    [[self navigationItem] setLeftBarButtonItem:cancelButton];
    
    // Done button
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButton)];
    [[self navigationItem] setRightBarButtonItem:doneButton];
}

-(void)cancelButton
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)doneButton
{
    // Save profile picture
    EditPictureCell *editPictureCell = (EditPictureCell *) [self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UIImage *newProfilePicture = editPictureCell.cellImageView.image;
    NSData *imageData = UIImagePNGRepresentation(newProfilePicture);
    NSString *imageName = [NSString stringWithFormat:@"%@.png", self.user.username];
    PFFile *imageFile = [PFFile fileWithName:imageName data:imageData];
    self.user[@"profilePicture"] = imageFile;
    
    // Save name
    ProfileTableViewCell *nameCell = (ProfileTableViewCell *) [self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    self.user[@"fullName"] = nameCell.cellTextField.text;
    
    // Save phone number
    ProfileTableViewCell *phoneCell = (ProfileTableViewCell *) [self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    self.user[@"phoneNumber"] = phoneCell.cellTextField.text;
    
    // Save bio
    TextViewCell *bioCell = (TextViewCell *) [self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    self.user[@"bio"] = bioCell.cellTextView.text;
    
    [[PFUser currentUser] saveInBackground];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Take photo button
    if (buttonIndex == 0)
    {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:picker animated:YES completion:NULL];
        }
        else
        {
            NSLog(@"Oh noes, the camera doesn’t work on the simulator!");
        }
    }
    
    // Choose from library button
    else if (buttonIndex == 1)
    {
        if ([UIImagePickerController isSourceTypeAvailable:
             UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            [self presentViewController:picker animated:YES completion:NULL];
        }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    EditPictureCell *editPictureCell = (EditPictureCell *) [self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    editPictureCell.cellImageView.image = chosenImage;
    
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

// Hides keyboard when user taps somewhere other than the keyboard
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // We are going to have only three sections in this example.
    return 2;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Profile section
    if (section == 0)
    {
        return 5;
    }
    
    // Account information section
    else
    {
        return 3;
    }
    
}

// Add header titles in sections.
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Profile Information";
    }
    
    else
    {
        return @"Account Information";
    }

}

// Set the row height.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Bio cell
    if ([indexPath section] == 0 && [indexPath row] == 3)
    {
        return 240.0;
    }
    
    // Change profile picture cell
    else if ([indexPath section] == 0 && [indexPath row] == 0)
    {
        return 60.0;
    }
    
    else
    {
        return 45.0;
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Profile section
    if ([indexPath section] == 0)
    {
        // Change profile picture cell
        if ([indexPath row] == 0)
        {
            static NSString *CellIdentifier = @"EditPictureCell";
            EditPictureCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil)
            {
                [tableView registerNib:[UINib nibWithNibName:CellIdentifier bundle:nil] forCellReuseIdentifier:CellIdentifier];
                cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            }
            
            cell.cellTextLabel.text = @"Change profile picture";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            PFFile *userImageFile = self.user[@"profilePicture"];
            [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                if (!error) {
                    cell.cellImageView.image = [UIImage imageWithData:imageData];
                    
                }
            }];
            
            return cell;
        }
        
        // Bio cell
        else if ([indexPath row] == 3)
        {
            static NSString *CellIdentifier = @"TextViewCell";
            TextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil)
            {
                [tableView registerNib:[UINib nibWithNibName:CellIdentifier bundle:nil] forCellReuseIdentifier:CellIdentifier];
                cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            }
            
            cell.cellTextLabel.text = @"Bio";
            cell.cellTextView.text = self.user[@"bio"];
            cell.cellTextView.delegate = self;
            [cell.cellTextView setReturnKeyType:UIReturnKeyDone];
            
            return cell;
        }
        
        // Edit courses cell
        else if ([indexPath row] == 4)
        {
            static NSString *CellIdentifier = @"DefaultCell";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            cell.textLabel.text = @"Edit courses";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

            return cell;
        }
        
        else
        {
            static NSString *CellIdentifier = @"profileTableCell";
            ProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
            if (cell == nil)
            {
                [tableView registerNib:[UINib nibWithNibName:@"CustomProfileCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
                cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            }
        
            switch ([indexPath row])
            {
                case 1:
                    cell.cellTextLabel.text = @"Name";
                    cell.cellTextField.text = self.user[@"fullName"];
                    break;
                
                case 2:
                    cell.cellTextLabel.text = @"Phone";
                    cell.cellTextField.text = self.user[@"phoneNumber"];
                    cell.cellTextField.delegate = cell;
                    [cell.cellTextField setReturnKeyType:UIReturnKeyDone];
                    break;
            }
        
            return cell;
        }
    }
    
    // Account information section
    else
    {
        static NSString *CellIdentifier = @"DefaultCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        switch ([indexPath row])
        {
            case 0:
                cell.textLabel.text = @"Change email";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
                
            case 1:
                cell.textLabel.text = @"Change password";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
                
            case 2:
                cell.textLabel.textColor = [UIColor redColor];
                cell.textLabel.text = @"Log out";
                break;
        }
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Change profile picture cell
    if ([indexPath section] == 0 && [indexPath row] == 0)
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:@"Change profile picture"
                                      delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"Take photo", @"Choose from library", nil];
        [actionSheet showInView:self.view];
    }
    
    // Change email cell
    if ([indexPath section] == 1 && [indexPath row] == 0)
    {
        [self performSegueWithIdentifier:@"changeEmailSegue" sender:self];
    }
    
    // Change password cell
    if ([indexPath section] == 1 && [indexPath row] == 1)
    {
        [self performSegueWithIdentifier:@"changePasswordSegue" sender:self];
    }
    
    // Edit courses cell
    if ([indexPath section] == 0 && [indexPath row] == 4)
    {
        [self performSegueWithIdentifier:@"editCoursesSegue" sender:self];
    }
    
    // Log out cell
    else if ([indexPath section] == 1 && [indexPath row] == 2)
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:[NSString stringWithFormat: @"Are you sure you want to log out?"]
                              message:nil
                              delegate:self
                              cancelButtonTitle:@"Cancel"
                              otherButtonTitles:@"Log out", nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        self.user[@"studentAvailable"] = @NO;
        self.user[@"isAvailable"] = @NO;
        [self.user saveInBackground];
        [PFUser logOut];
        [self performSegueWithIdentifier:@"logoutSegue" sender:self];
    }
}

@end
