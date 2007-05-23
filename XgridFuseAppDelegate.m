//
//  XgridFuseAppDelegate.m
//  Xgrid FUSE
//
//  Created by Charles Parnot on 5/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "XgridFuseAppDelegate.h"
#import <GridEZ/GridEZ.h>

@implementation XgridFuseAppDelegate



- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serverWillConnect:) name:GEZServerWillAttemptConnectionNotification object:nil];
	[GEZServer showServerWindow];
	
	//NSLog(@"%@", [[NSBundle bundleWithIdentifier:@"parnot.charles.gridez"] executablePath]);
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
