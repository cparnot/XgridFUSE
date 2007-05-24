//
//  XgridFuseAppDelegate.m
//  Xgrid FUSE
//
//  Created by Charles Parnot on 5/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "XgridFuseAppDelegate.h"
#import <GridEZ/GridEZ.h>
#import <Sparkle/Sparkle.h>

@implementation XgridFuseAppDelegate



- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	NSLog(@"%s",_cmd);

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serverWillConnect:) name:GEZServerWillAttemptConnectionNotification object:nil];
	[GEZServer showServerWindow];

	//this seems to be necessary to bring the window in front and make it really key
	[NSApp activateIgnoringOtherApps:YES];
	
	//[[GEZServer serverWindow] orderFrontRegardless];
	//[[GEZServer serverWindow] makeKeyAndOrderFront:self];

	//we need these values to make a decision below
	NSNumber *shouldCheckAtStartup = [[NSUserDefaults standardUserDefaults] valueForKey:@"XgridFuseCheckAtStartup"];
	NSString *versionWhenUserWasAskedShouldCheckAtStartup = [[NSUserDefaults standardUserDefaults] valueForKey:@"XgridFuseVersionWhenUserWasAskedShouldCheckAtStartup"];
	NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	//NSLog (@"%@ - %@ - %@", shouldCheckAtStartup, versionWhenUserWasAskedShouldCheckAtStartup,currentVersion);

	//should we ask the user if she wants to check for updates at startup?
	//if no choice was made so far, or if the choice was made in a previous version, here is a chance for the user to enroll!
	if ( shouldCheckAtStartup == nil || ( [shouldCheckAtStartup boolValue] == NO && versionWhenUserWasAskedShouldCheckAtStartup != nil && currentVersion != nil && [currentVersion isEqualToString:versionWhenUserWasAskedShouldCheckAtStartup] == NO ) ) {
		shouldCheckAtStartup = [NSNumber numberWithBool:NSRunAlertPanel(@"Check for updates on startup?", @"Would you like Xgrid FUSE to check for updates on startup?", @"Yes", @"No", nil) == NSAlertDefaultReturn];
		[[NSUserDefaults standardUserDefaults] setObject:shouldCheckAtStartup forKey:@"XgridFuseCheckAtStartup"];
		[[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:@"XgridFuseVersionWhenUserWasAskedShouldCheckAtStartup"];
	}
	
	//check for updates
	if ( [shouldCheckAtStartup boolValue] )
		[sparkleUpdater checkForUpdatesInBackground];
	
}


- (void)serverWillConnect:(NSNotification *)notification
{
	[[notification object] disconnect];
	
	//save the managed object context to remember previous connections
	NSError *error = nil;
    if ( [[GEZManager managedObjectContext] save:&error] == NO ) {
		NSLog(@"Error while attempting to save Xgrid controller information:\n%@",error);
	}
	//save again if changes made - temporary fix for a limitation in GEZProxy - this needs to be addressed in the framework!!
	if ( [[GEZManager managedObjectContext] hasChanges] ) {
		if  ( [[GEZManager managedObjectContext] save:&error] == NO ) {
			NSLog(@"Error while attempting to save Xgrid controller information:\n%@",error);
		}
	}
	
	
	NSLog(@"Starting a new xgridfs process.");
	NSString *xgridfsBundlePath = [[NSBundle mainBundle] pathForResource:@"xgridfs" ofType:@"app"];
	NSString *xgridfsExecutablePath = [[NSBundle bundleWithPath:xgridfsBundlePath] executablePath];
	[NSTask launchedTaskWithLaunchPath:xgridfsExecutablePath arguments:[NSArray arrayWithObject:[[notification object] address]]];

	[NSApp terminate:nil];
}

//the application will quit if the connection window is closed
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}

@end
