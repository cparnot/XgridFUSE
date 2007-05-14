//
//  XgridFuseFileSystem.m
//  Xgrid FUSE
//
//  Created by Charles Parnot on 3/13/07.
//  Copyright 2007 Charles Parnot. All rights reserved.
//

/*
 This file is part of Xgrid FUSE.
 Xgrid FUSE is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
 Xgrid FUSE is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with Xgrid FUSE; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */

#import "XgridFuseFileSystem.h"
#import "XgridFusePaths.h"
#import <CoreServices/CoreServices.h>
#import "NSInvocationXgridFuseCategory.h"

//path to README.html file that will be in the root
NSString *ReadMeHtmlPath ( )
{
	return [[NSBundle mainBundle] pathForResource:@"README" ofType:@"html"];
}

@implementation XgridFuseFileSystem

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[mountedServer release];
	[creationDate release];
	[modificationDate release];
	[mountingDate release];

	/*
	[jobSubmissionContents release];
	[jobSubmissionPath release];
	[jobSubmissionParentPath release];
	
	//[extraFiles release];
	*/
	
	[super dealloc];
}


#pragma mark *** Start and Mount ***

- (BOOL)shouldStartFuse
{
	return NO;
}

//hijacking the superclass
- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	[NSApp activateIgnoringOtherApps:YES];
	[GEZManager showServerWindow];
	//[GEZManager showXgridPanel];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serverDidLoad:) name:GEZServerDidLoadNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serverDidDisconnect:) name:GEZServerDidDisconnectNotification object:nil];
	//private notifications
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gridsDidChange:) name:@"GEZGridHookDidChangeJobsNotification" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gridsDidChange:) name:@"GEZGridHookDidChangeNameNotification" object:nil];
	
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
	[NSApp activateIgnoringOtherApps:YES];
	[GEZManager showServerWindow];
	return NO;
}

- (void)applicationDidBecomeActive:(NSNotification *)aNotification
{
	[GEZManager showServerWindow];
}

//the application will quit if the connection window is closed and no server is connected
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	if ( [GEZServer connectedServer] )
		return NO;
	else
		return YES;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	//maybe I should implement that
	//[[GEZManager managedObjectContext] save:NULL];
	//int shouldSaveManagedObjectContext = 0;//warning
	return [super applicationShouldTerminate:sender];
}


- (void)serverDidLoad:(NSNotification *)aNotification
{
	//no more Bonjour browsing necessary
	[GEZServer stopBrowsing];
	
	if ( mountedServer != nil )
		return;
	mountedServer = [[aNotification object] retain];
	[mountedServer setObservingAllJobs:YES];
	[self setValue:[NSDate date] forKey:@"modificationDate"];
	[self setValue:[NSDate date] forKey:@"creationDate"];
	[self setValue:[NSDate date] forKey:@"mountingDate"];
	
	NSEnumerator *e = [[mountedServer valueForKeyPath:@"jobs"] objectEnumerator];
	GEZJob *oneJob;
	while ( oneJob = [e nextObject] )
		[oneJob setDelegate:self];
	
	//close the connection window
	[GEZManager hideServerWindow];
	
	NSLog(@"mount");

	//hijacking the superclass
	[NSThread detachNewThreadSelector:@selector(startFuse) toTarget:self withObject:nil];
}

- (void)serverDidDisconnect:(NSNotification *)aNotification

{
	[self performSelector:@selector(stopFuse)];
}

- (NSString *)mountName
{
	return [mountedServer address];
}

- (NSString *)mountPoint;
{
	return [NSString stringWithFormat:@"/Volumes/%@",[self mountName]];
}

- (void)fuseWillUnmount
{
	[mountedServer disconnect];
}

- (void)fuseDidUnmount
{
	[mountedServer disconnect];
}


#pragma mark *** Notifications of changes in the Xgrid components ***

/* this part if very primitive but sort of works - Need to get filesystem notifications working (e.g. for Finder updates) */

//the modificationDate is modified by the Xgrid thread, while it is used by the FUSE thread, hence a lock
- (void)setModificationDate:(NSDate *)newDate
{
	@synchronized(modificationDate)
    {
		[newDate retain];
		[modificationDate autorelease];
		modificationDate = newDate;
    }
}

- (void)gridsDidChange:(NSNotification *)aNotification
{
	[self setValue:[NSDate date] forKey:@"modificationDate"];

	NSEnumerator *e = [[mountedServer valueForKeyPath:@"jobs"] objectEnumerator];
	GEZJob *oneJob;
	while ( oneJob = [e nextObject] )
		[oneJob setDelegate:self];
	
	return;
	//NSLog(@"<%@:%p> %s",[self class],self,_cmd);
	FNNotifyByPath((const UInt8 *)[[self mountPoint] UTF8String],
		kFNDirectoryModifiedMessage,
		kNilOptions);
}

- (void)jobDidRetrieveResults:(GEZJob *)aJob
{
	[self setValue:[NSDate date] forKey:@"modificationDate"];
}
- (void)jobDidSubmit:(GEZJob *)aJob;
{
	[self setValue:[NSDate date] forKey:@"modificationDate"];
}
- (void)jobDidNotSubmit:(GEZJob *)aJob;
{
	[self setValue:[NSDate date] forKey:@"modificationDate"];
}
- (void)jobDidStart:(GEZJob *)aJob;
{
	[self setValue:[NSDate date] forKey:@"modificationDate"];
}
- (void)jobDidFinish:(GEZJob *)aJob;
{
	[self setValue:[NSDate date] forKey:@"modificationDate"];
}
- (void)jobDidFail:(GEZJob *)aJob;
{
	[self setValue:[NSDate date] forKey:@"modificationDate"];
}
- (void)jobWillBeDeleted:(GEZJob *)aJob fromGrid:(GEZGrid *)aGrid;
{
	[self setValue:[NSDate date] forKey:@"modificationDate"];
}
- (void)jobWasNotDeleted:(GEZJob *)aJob;
{
	[self setValue:[NSDate date] forKey:@"modificationDate"];
}
- (void)jobDidProgress:(GEZJob *)aJob completedTaskCount:(unsigned int)count;
{
	[self setValue:[NSDate date] forKey:@"modificationDate"];
}


#pragma mark *** FUSEFileSystem : READ ***

- (NSArray *)directoryContentsAtPath:(NSString *)path
{
	NSArray *directoryContents = [mountedServer directoryContentsAtPath:path];
	
	//attempt at running things in the main thread
	//get directory contents contributed by Xgrid components, from the main thread
	//NSInvocation *invocation = [NSInvocation invocationWithTarget:mountedServer selector:@selector(directoryContentsAtPath:)];
	//[invocation setArgument:&path atIndex:2];
	//NSArray *directoryContents = [invocation invokeOnMainThreadAndWait];

	
	//TODO: job submission by copying text file into grid or server
	//add entry for job submission
	//if ( [jobSubmissionParentPath isEqualToString:path] ) {
	//	NSMutableArray *moreEntries = [NSMutableArray arrayWithCapacity:[directoryContents count]+1];
	//	if ( directoryContents != nil )
	//		[moreEntries addObjectsFromArray:directoryContents];
	//	[moreEntries addObject:[jobSubmissionPath lastPathComponent]];
	//	directoryContents = [NSArray arrayWithArray:moreEntries];
	//}
	
	//special case = 'README' file in root
	if ( [path isEqualToString:@"/"] )
		directoryContents = [directoryContents arrayByAddingObject:@"Read Me.html"];

	if ( directoryContents == nil )
		return [NSArray array];
	else
		return directoryContents;
}

- (BOOL)fileExistsAtPath:(NSString *)path isDirectory:(BOOL *)isDirectory
{
	// Thread-safe way? --> this causes a big bad hang
//	NSInvocation *invocation = [NSInvocation invocationWithTarget:mountedServer selector:@selector(fileExistsAtPathAndIsDirectory:)];
//	[invocation setArgument:&path atIndex:2];
//	NSArray *flags = [invocation invokeOnMainThreadAndWait];
//	if ( [jobSubmissionPath isEqualToString:path] || [jobSubmissionResourcePath isEqualToString:path]) {
//		NSLog(@"<%@:%p> %s %@",[self class],self,_cmd, path);
//		*isDirectory = NO;
//		return YES;
//	}
//	

	//special case = 'README' file in root
	if ( [path isEqualToString:@"/Read Me.html"] ) {
		*isDirectory = YES;
		return YES;
	}

	//get information contributed by Xgrid components
	return [mountedServer fileExistsAtPath:path isDirectory:isDirectory];


	//TODO: job submission by copying text file into grid or server
	
}

- (NSData *)contentsAtPath:(NSString *)path
{
	NSData *fileContents;
	
	//TODO: job submission by copying text file into grid or server
//	//get file contents from job submission
//	if ( [jobSubmissionPath isEqualToString:path] ) {
//		NSLog(@"<%@:%p> %s %@",[self class],self,_cmd, path);
//		fileContents = [NSData dataWithData:jobSubmissionContents];
//	}
//	else if ( [jobSubmissionResourcePath isEqualToString:path] ) {
//		NSLog(@"<%@:%p> %s %@",[self class],self,_cmd, path);
//		fileContents = [NSData dataWithData:jobSubmissionResourceContents];
//	}
//	

	//get file contents from Xgrid components
	fileContents = [mountedServer contentsAtPath:path];

	if ( fileContents == nil )
		return [NSData data];
	else
		return fileContents;
}


- (NSDictionary *)fileAttributesAtPath:(NSString *)path
{
	//special case: root
	if ( [path isEqualToString:@"/"] )
		return [NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt:0500], NSFilePosixPermissions,
			[NSNumber numberWithInt:geteuid()], NSFileOwnerAccountID,
			[NSNumber numberWithInt:getegid()], NSFileGroupOwnerAccountID,
			mountingDate, NSFileCreationDate,
			mountingDate, NSFileModificationDate,
			nil];
	
	//TODO: job submission by copying text file into grid or server
	
	//xgrid attributes
	NSDictionary *xgridAttributes = [mountedServer fileAttributesAtPath:path];
	if ( xgridAttributes == nil ) {

		//special case = 'README' file in root
		if ( [path isEqualToString:@"/Read Me.html"] ) {
			NSMutableDictionary *finalAttributes = [NSMutableDictionary dictionaryWithDictionary:[[NSFileManager defaultManager] fileAttributesAtPath:ReadMeHtmlPath() traverseLink:NO]];
			if ( finalAttributes == nil )
				finalAttributes = [NSMutableDictionary dictionary];
			[finalAttributes setObject:NSFileTypeSymbolicLink forKey:NSFileType];
			return [NSDictionary dictionaryWithDictionary:finalAttributes];
		}

		NSLog(@"Unexpected call:\n<%@:%p> %s\npath = %@", [self class],self,_cmd, path);
		return nil;
	}

	//add other useful attributes
	NSMutableDictionary *finalAttributes = [NSMutableDictionary dictionary];
	[finalAttributes addEntriesFromDictionary:xgridAttributes];
	
	//fake dates updated when things change somewhere, which forces the Finder to refresh more often than it would otherwise
	[finalAttributes setObject:modificationDate forKey:NSFileCreationDate];
	[finalAttributes setObject:modificationDate forKey:NSFileModificationDate];
	
	//file permissions: we set the write bit to 1 for directories, because jobs can in fact be deleted
	if ( [finalAttributes objectForKey:NSFileType] == NSFileTypeDirectory )
		[finalAttributes setObject:[NSNumber numberWithInt:0750] forKey:NSFilePosixPermissions];
	else
		[finalAttributes setObject:[NSNumber numberWithInt:0440] forKey:NSFilePosixPermissions];
	[finalAttributes setObject:[NSNumber numberWithInt:geteuid()] forKey:NSFileOwnerAccountID];
	[finalAttributes setObject:[NSNumber numberWithInt:getegid()] forKey:NSFileGroupOwnerAccountID];
	

	return [NSDictionary dictionaryWithDictionary:finalAttributes];	
	
	//NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:	
		//fileType,NSFileType,
		//,NSFileSize,
		//modificationDate,NSFileModificationDate,
		//,NSFileReferenceCount,
		//,NSFileDeviceIdentifier,
		//,NSFileOwnerAccountName,
		//,NSFileGroupOwnerAccountName,
		//,NSFilePosixPermissions,
		//,NSFileSystemFileNumber,
		//,NSFileExtensionHidden,
		//,NSFileHFSCreatorCode,
		//,NSFileHFSTypeCode,
		//[NSNumber numberWithBool:YES],NSFileImmutable,
		//,NSFileAppendOnly,
		//modificationDate,NSFileCreationDate,
		//,NSFileOwnerAccountID,
		//,NSFileGroupOwnerAccountID,
		//nil];

}

- (NSString *)pathContentOfSymbolicLinkAtPath:(NSString *)path
{
	if ( ![path isEqualToString:@"/Read Me.html"] )
		return @"/dev/null";

	return ReadMeHtmlPath();
}

- (NSString *)iconFileForPath:(NSString *)path
{
	//volume icon
    if ( [path isEqualToString:@"/"] ) {
		NSString *diskIconPath = [[NSBundle mainBundle] pathForResource:@"XgridFuseDisk" ofType:@"icns"];
		//NSLog(@"<%@:%p> %s %@ = %@",[self class],self,_cmd, path, diskIconPath);
		return diskIconPath;
    }
	
	return nil;
	
	
	//the following does not work well without appropriate notifications
	
	/*
	//grid icon
	if ( [[path pathComponents] count] == 2 ) {
		return [[NSBundle mainBundle] pathForResource:@"grid-folder" ofType:@"icns"];
	}
	
	//job icon
	else if ( [[path pathComponents] count] == 3 ) {
		return [[NSBundle mainBundle] pathForResource:@"IconRetrieving" ofType:@"icns"];
		GEZJob *job = [mountedServer jobWithFusePath:path];
		//NSLog(@"<%@:%p> %s %@ --> %@",[self class],self,_cmd, path, [job status]);
		if ( [job status] == nil )
			return [[NSBundle mainBundle] pathForResource:@"IconLoading" ofType:@"icns"];
		return [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Icon%@",[job status]] ofType:@"icns"];
	}
    return nil;
	 */
}

- (BOOL)usesResourceForks
{
	return YES;
}


#pragma mark *** FUSEFileSystem : MODIFY / WRITE ***

- (BOOL)removeFileAtPath:(NSString *)path handler:(id)handler
{
	//NSLog(@"<%@:%p> %s %@",[self class],self,_cmd, path);
	
	GEZJob *removedJob = [mountedServer jobWithFusePath:path];
	[removedJob performSelectorOnMainThread:@selector(delete) withObject:nil waitUntilDone:NO];
	return YES;
}

/*
- (BOOL)createFileAtPath:(NSString *)path attributes:(NSDictionary *)attributes
{
	NSLog(@"<%@:%p> %s %@ %@",[self class],self,_cmd, path, attributes);
	
	//only create files in servers or grids
	int level = [[path pathComponents] count];
	if ( level < 2 || level > 3 )
		return NO;
	
	//create a new entry
	if ( jobSubmissionPath == nil ) {
		jobSubmissionPath = [path retain];
		jobSubmissionParentPath = [[path stringByDeletingLastPathComponent] retain];
		jobSubmissionResourcePath = [[jobSubmissionParentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"._%@", [path lastPathComponent]]] retain];
		jobSubmissionContents = [[NSMutableData alloc] init];
		jobSubmissionResourceContents = [[NSMutableData alloc] init];
		return YES;
	} else
		return NO;
}


- (int)writeFileAtPath:(NSString *)path handle:(id)handle buffer:(const char *)buffer size:(size_t)size offset:(off_t)offset
{
	NSLog(@"<%@:%p> %s %@\nbuffer: %@\noffset:%d",[self class],self,_cmd, path, [NSData dataWithBytes:buffer length:size], offset);
	
	if ( [jobSubmissionResourcePath isEqualToString:path] == YES && [jobSubmissionResourceContents length] <= offset ) {
		if ( [jobSubmissionResourceContents length] > offset )
			[jobSubmissionResourceContents replaceBytesInRange:NSMakeRange(offset,[jobSubmissionResourceContents length]-offset) withBytes:buffer length:size];
		else
				[jobSubmissionResourceContents appendBytes:buffer length:size];
		return size;
	}

	if ( [jobSubmissionPath isEqualToString:path] == YES && [jobSubmissionContents length] <= offset ) {
		if ( [jobSubmissionContents length] > offset )
			[jobSubmissionContents replaceBytesInRange:NSMakeRange(offset,[jobSubmissionContents length]-offset) withBytes:buffer length:size];
		else
			[jobSubmissionContents appendBytes:buffer length:size];
		return size;
	}
	
	return -EACCES;
}

- (int)readFileAtPath:(NSString *)path handle:(id)handle
               buffer:(char *)buffer size:(size_t)size offset:(off_t)offset {
	
	if ( [jobSubmissionPath isEqualToString:path] || [jobSubmissionResourcePath isEqualToString:path] )
		NSLog(@"<%@:%p> %s %@",[self class],self,_cmd, path);
	
	return [super readFileAtPath:path handle:handle buffer:buffer size:size offset:offset];
}

- (id)openFileAtPath:(NSString *)path mode:(int)mode
{
	NSLog(@"<%@:%p> %s %@",[self class],self,_cmd, path);

	if ( [jobSubmissionPath isEqualToString:path] ) {
		NSLog(@"<%@:%p> %s %@",[self class],self,_cmd, path);
		//return jobSubmissionContents;
	}

	if ( [jobSubmissionResourcePath isEqualToString:path] ) {
		NSLog(@"<%@:%p> %s %@",[self class],self,_cmd, path);
		//return jobSubmissionResourceContents;
	}
	
	return [super openFileAtPath:path mode:mode];
}

//loadingFiles into extraFiles
- (void)releaseFileAtPath:(NSString *)path handle:(id)handle
{
	if ( [jobSubmissionPath isEqualToString:path] == NO && [jobSubmissionResourcePath isEqualToString:path] == NO )
		return;
	
	NSLog(@"<%@:%p> %s %@",[self class],self,_cmd, path);

	return;

	//todo: submit job
	//NSData *fileData = [NSData dataWithData:jobSubmissionContents];

	[jobSubmissionContents release];
	jobSubmissionContents = nil;
	[jobSubmissionPath release];
	jobSubmissionPath = nil;
	[jobSubmissionParentPath release];
	jobSubmissionParentPath = nil;
	
	
}
*/

@end
