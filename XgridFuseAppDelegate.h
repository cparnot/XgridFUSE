//
//  XgridFuseAppDelegate.h
//  Xgrid FUSE
//
//  Created by Charles Parnot on 5/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/* 
An instance of this class is created in the MainMenu nib, and is made the NSApp delegate.
The sole function and action of this delegate is to allow the user to choose an Xgrid controller and then launch an NSTask for a new xgridfs process.
Once the task is launched, the app can quit.
 */

@class SUUpdater;

@interface XgridFuseAppDelegate : NSObject
{
	IBOutlet SUUpdater *sparkleUpdater;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
- (void)serverWillConnect:(NSNotification *)notification;


@end
