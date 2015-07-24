//
//  AppDelegate.m
//  Tubor
//
//  Created by Marcelo Sedano on 3/21/15.
//  Copyright (c) 2015 Marcelo Sedano. All rights reserved.
//


/*
 Fixes:
 
 1) User can request a tutoring session and still say that they are available to be tutored. This needs to be fixed so that after a user requests a tutor, they can't say they are available to tutor
 
 2) Maybe add a "cancel tutoring request" button for user ?
 
 3) Also, maybe we need to add logic for when a tutor's time is up to immediately become unavailable
 
 4) Think about how a session is over.
 
 5) make the tutor's request button gray out after they've been requested
 
 */




#import "AppDelegate.h"
#import <Parse/Parse.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface AppDelegate ()

@property (nonatomic) UITabBarController *tabBarController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
   
    
    // [Optional] Power your app with Local Datastore. For more info, go to
    // https://parse.com/docs/ios_guide#localdatastore/iOS
    [Parse enableLocalDatastore];
    
    // Initialize Parse.
    [Parse setApplicationId:@"YupCtlLhZW2Gzy9d26dEPvcsgsvXtvIkPUJUEXqJ"
                  clientKey:@"824tAs3J87658gt9SvTlJJ52vfRNr4uilBhzgq0y"];
    
    // [Optional] Track statistics around application opens.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // Tab bar attributes
    [[UITabBar appearance] setBarTintColor:UIColorFromRGB(0x000000)];
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    
    // Navigation bar attributes
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0xc81f1f)];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    
    // Register the app for remote notifications
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    return YES;
}

//<------ NEEDED FOR PUSH NOTIFICATIONS --------->

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current Installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code == 3010) {
        NSLog(@"Push notifications are not supported in the iOS Simulator.");
    } else {
        // show some alert or otherwise handle the failure to register.
        NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
        
     // Add notification to notification center
     NSString *notificationName = [userInfo valueForKey:@"notificationName"];
    
    // User received a rating
    if ([notificationName isEqualToString:@"ratingPush"])
    {
        NSLog(@"You received a rating!");
        
        PFUser *currentUser = [PFUser currentUser];
        currentUser[@"rating"] = [userInfo valueForKey:@"newRating"];
        currentUser[@"ratingCount"] = [userInfo valueForKey:@"ratingCount"];
        
        [currentUser saveInBackground];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:userInfo];
    }
}

// <--------------------------------------------->

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // Clear badge count when user opens app
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
