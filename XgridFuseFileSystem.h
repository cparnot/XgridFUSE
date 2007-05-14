//
//  XgridFuseFileSystem.h
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

#import <MacFUSE-ObjC/FUSEFileSystem.h>


@interface XgridFuseFileSystem : FUSEFileSystem
{
	GEZServer *mountedServer;
	NSDate *modificationDate;
	NSDate *creationDate;
	NSDate *mountingDate;
	
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
