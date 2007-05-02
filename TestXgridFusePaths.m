//
//  TestXgridFusePaths.m
//  Xgrid FUSE
//
//  Created by Charles Parnot on 3/20/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//


/* Not very convincing attempt at adding tests */


#import "TestXgridFusePaths.h"
#import "XgridFuseFileSystem.h"
#import "XgridFusePaths.h"
#import "NSInvocationXgridFuseCategory.h"

@implementation TestXgridFusePaths

//waiting for a server, assuming Keychain is used, etc...
- (void)setUp
{
	server = [[GEZServer connectedServer] retain];
	STAssertNotNil(server, @"Could not find a GEZServer connected");
	STAssertTrue([server isLoaded], @"Could not find a GEZServer loaded");
}

- (void)testGridPaths
{
	NSSet *directoryContentsAtRoot = [NSSet setWithArray:[server directoryContentsAtPath:@"/"]];
	NSSet *gridFuseFilenames = [NSSet setWithArray:[[[server grids] allObjects] valueForKeyPath:@"@unionOfObjects.fuseFilename"]];
	STAssertTrue([directoryContentsAtRoot isEqualToSet:gridFuseFilenames], @"\ndirectoryContentsAtRoot=%@\ngridFuseFilenames=%@\n", directoryContentsAtRoot, gridFuseFilenames);
	STAssertTrue([directoryContentsAtRoot count]>0,@"no grids listed in root");
}

- (void)testGridPathsMainThread
{
	//get directory contents from the main thread
	NSString *path = @"/";
	NSInvocation *invocation = [NSInvocation invocationWithTarget:server selector:@selector(directoryContentsAtPath:)];
	[invocation setArgument:&path atIndex:2];
	NSArray *directoryContents = [invocation invokeOnMainThreadAndWait];
	
	NSSet *directoryContentsAtRoot = [NSSet setWithArray:directoryContents];
	NSSet *gridFuseFilenames = [NSSet setWithArray:[[[server grids] allObjects] valueForKeyPath:@"@unionOfObjects.fuseFilename"]];
	STAssertTrue([directoryContentsAtRoot isEqualToSet:gridFuseFilenames], @"\ndirectoryContentsAtRoot=%@\ngridFuseFilenames=%@\n", directoryContentsAtRoot, gridFuseFilenames);
	STAssertTrue([directoryContentsAtRoot count]>0,@"no grids listed in root");
}


- (BOOL)directoryContentsIsConsistent:(NSString *)path
{
	NSEnumerator *e = [[server directoryContentsAtPath:path] objectEnumerator];
	NSString *filename;
	BOOL result = YES;
	while ( filename == [e nextObject] ) {
		NSString *subpath = [path stringByAppendingPathComponent:filename];
		NSArray *fileExistsAndIsDirectory = [server fileExistsAtPathAndIsDirectory:subpath];
		STAssertTrue([fileExistsAndIsDirectory count]==2,@"fileExistsAndIsDirectory = %@",fileExistsAndIsDirectory);
		if ( [fileExistsAndIsDirectory count] == 2 ) {
			BOOL fileExists = [[fileExistsAndIsDirectory objectAtIndex:0] boolValue];
			BOOL isDirectory = [[fileExistsAndIsDirectory objectAtIndex:1] boolValue];
			STAssertTrue(fileExists==YES,@"file should exist at path %@",subpath);
			if ( isDirectory == YES && [self directoryContentsIsConsistent:subpath] == NO )
				result = NO;
		}
	}
	return result;
}

- (void)testFileExists
{
	[self directoryContentsIsConsistent:@"/"];
}

- (BOOL)directoryContentsIsConsistentOnMainThread:(NSString *)path
{
	NSEnumerator *e = [[server directoryContentsAtPath:path] objectEnumerator];
	NSString *filename;
	BOOL result = YES;
	while ( filename == [e nextObject] ) {
		NSString *subpath = [path stringByAppendingPathComponent:filename];

		NSInvocation *invocation = [NSInvocation invocationWithTarget:server selector:@selector(fileExistsAtPathAndIsDirectory:)];
		[invocation setArgument:&subpath atIndex:2];
		NSArray *fileExistsAndIsDirectory = [invocation invokeOnMainThreadAndWait];

		STAssertTrue([fileExistsAndIsDirectory count]==2,@"fileExistsAndIsDirectory = %@",fileExistsAndIsDirectory);
		if ( [fileExistsAndIsDirectory count] == 2 ) {
			BOOL fileExists = [[fileExistsAndIsDirectory objectAtIndex:0] boolValue];
			BOOL isDirectory = [[fileExistsAndIsDirectory objectAtIndex:1] boolValue];
			STAssertTrue(fileExists==YES,@"file should exist at path %@",subpath);
			if ( isDirectory == YES && [self directoryContentsIsConsistentOnMainThread:subpath] == NO )
				result = NO;
		}
	}
	return result;
}

- (void)testFileExistsOnMainThread
{
	[self directoryContentsIsConsistentOnMainThread:@"/"];
}


- (void)tearDown
{
	[server release];
}

@end


@implementation XgridFuseFileSystem (XgridFuseFileSystemStartTest)

- (void)serverDidLoad:(NSNotification *)aNotification
{
	if ( mountedServer != nil )
		return;
	mountedServer = [[aNotification object] retain];
	[mountedServer setObservingAllJobs:YES];
	[self setValue:[NSDate date] forKey:@"modificationDate"];
	
	NSEnumerator *e = [[mountedServer valueForKeyPath:@"jobs"] objectEnumerator];
	GEZJob *oneJob;
	while ( oneJob = [e nextObject] )
		[oneJob setDelegate:self];
	
	//hide the app
	[GEZManager hideServerWindow];
	
	//run a test
	NSLog(@"test");
	SenTestRun	*testRun = nil;
	testRun = [(SenTestSuite *)[SenTestSuite defaultTestSuite] run];
	
	//hijacking the superclass
	//[NSThread detachNewThreadSelector:@selector(startFuse) toTarget:self withObject:nil];
}


@end