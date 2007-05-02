//
//  XgridFuseFileSystem.h
//  Xgrid FUSE
//
//  Created by Charles Parnot on 3/13/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "FUSEFileSystem.h"


@interface XgridFuseFileSystem : FUSEFileSystem
{
	GEZServer *mountedServer;
	NSDate *modificationDate;
	NSDate *creationDate;
	/*
	 // I tried to add job submission by dropping xml files to the FS
	NSMutableDictionary *extraFiles;
	//NSMutableDictionary *loadingFiles;
	NSString *jobSubmissionPath;
	NSString *jobSubmissionResourcePath;
	NSString *jobSubmissionParentPath;
	NSMutableData *jobSubmissionContents;
	NSMutableData *jobSubmissionResourceContents;
	 */
}

- (BOOL)shouldStartFuse;
- (NSString *)mountName;

- (void)fuseWillUnmount;
- (void)fuseDidUnmount;

- (NSArray *)directoryContentsAtPath:(NSString *)path; // Array of NSStrings
- (BOOL)fileExistsAtPath:(NSString *)path isDirectory:(BOOL *)isDirectory;
- (NSDictionary *)fileAttributesAtPath:(NSString *)path;
- (NSData *)contentsAtPath:(NSString *)path;

@end
