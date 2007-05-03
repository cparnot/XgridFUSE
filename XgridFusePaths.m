//
//  XgridFusePaths.m
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

#import "XgridFusePaths.h"


@implementation GEZServer (GEZServerFusePaths)

- (GEZGrid *)gridWithFuseFilename:(NSString *)filename
{
	NSArray *allGrids = [[self grids] allObjects];
	int index = [[allGrids valueForKeyPath:@"@unionOfObjects.fuseFilename"] indexOfObject:filename];
	if ( index == NSNotFound )
		return nil;
	else
		return [allGrids objectAtIndex:index];
}

- (GEZJob *)jobWithFusePath:(NSString *)jobPath
{
	NSArray *components = [jobPath pathComponents];
	if ( [components count] != 3 )
		return nil;
	NSString *fuseFilename = [components objectAtIndex:2];
	NSArray *allJobs = [[[self gridWithFuseFilename:[components objectAtIndex:1]] jobs] allObjects];
	int index = [[allJobs valueForKeyPath:@"@unionOfObjects.fuseFilename"] indexOfObject:fuseFilename];
	if ( index == NSNotFound )
		return nil;
	else
		return [allJobs objectAtIndex:index];
}

//using private classes in GridEZ
- (id)taskWithFusePath:(NSString *)taskPath
{
	NSArray *components = [taskPath pathComponents];
	if ( [components count] != 4 )
		return nil;
	
	//parent = a job
	GEZJob *job = [self jobWithFusePath:[taskPath stringByDeletingLastPathComponent]];
	if ( job == nil )
		return nil;
	
	//task = simply the number
	NSArray *allTasks = [[job valueForKey:@"tasks"] allObjects];
	int index = [[allTasks valueForKeyPath:@"@unionOfObjects.fuseFilename"] indexOfObject:[components objectAtIndex:3]];
	if ( index == NSNotFound )
		return nil;
	else
		return [allTasks objectAtIndex:index];
}


//using private classes in GridEZ
- (id)fileWithFusePath:(NSString *)filePath
{
	NSArray *components = [filePath pathComponents];
	if ( [components count] < 5 )
		return nil;
	
	//parent = a task
	id task = [self taskWithFusePath:[NSString pathWithComponents:[components subarrayWithRange:NSMakeRange(0,4)]]];
	if ( task == nil )
		return nil;
	
	//file path within the task
	NSString *filePathOnly = [NSString pathWithComponents:[components subarrayWithRange:NSMakeRange(4,[components count]-4)]];
	NSArray *allFiles = [[task valueForKey:@"allFiles"] allObjects];
	int index = [[allFiles valueForKeyPath:@"@unionOfObjects.path"] indexOfObject:filePathOnly];
	if ( index == NSNotFound )
		return nil;
	else
		return [allFiles objectAtIndex:index];

}

- (NSArray *)directoryContentsAtPath:(NSString *)path
{
	NSArray *fileList = nil;
	
	//root = self = the server, which contains grids
	if ( [path isEqualToString:@"/"] )
		fileList = [[[self grids] allObjects] valueForKeyPath:@"@unionOfObjects.fuseFilename"];

	else {
		NSArray *components = [path pathComponents];
		int n = [components count];

		//grids contain jobs
		//list only jobs not deleted/deleting
		if ( n == 2 ) {
			GEZGrid *parentGrid = [self gridWithFuseFilename:[components objectAtIndex:1]];
			if ( parentGrid != nil ) {
				NSSet *allJobs = [parentGrid jobs];
				NSMutableArray *existingJobs = [NSMutableArray arrayWithCapacity:[allJobs count]];
				NSEnumerator *e = [allJobs objectEnumerator];
				GEZJob *oneJob;
				while ( oneJob = [e nextObject] ) {
					if ( [oneJob isDeleted] == NO && [oneJob isDeleting] == NO )
						[existingJobs addObject:oneJob];
					
				}
				fileList = [existingJobs valueForKeyPath:@"@unionOfObjects.fuseFilename"];
			}
		}

		//jobs contain tasks
		else if ( n == 3 ) {
			GEZJob *parentJob = [self jobWithFusePath:path];
			if ( parentJob != nil ) {
				if ( [parentJob isRetrieved] == NO && [parentJob isRetrievingResults] == NO )
					[parentJob performSelectorOnMainThread:@selector(retrieveResults) withObject:nil waitUntilDone:NO];
				fileList = [[[parentJob valueForKeyPath:@"tasks"] allObjects] valueForKeyPath:@"@unionOfObjects.fuseFilename"];
			}
		}
		
		//tasks contain files
		else if ( n == 4 ) {
			id parentTask = [self taskWithFusePath:path];
			if ( parentTask != nil )
				fileList = [[[parentTask valueForKeyPath:@"files"] allObjects] valueForKeyPath:@"@unionOfObjects.name"];
		}
		
		//file inside a task : list contents if it is a directory
		if ( n > 4 ) {
			id file = [self fileWithFusePath:path];
			if ( file != nil ) {
				if  ( [[file valueForKey:@"isDirectory"] boolValue] == NO )
					fileList = [NSArray array];
				else
					fileList = [[[file valueForKey:@"children"] allObjects] valueForKeyPath:@"@unionOfObjects.name"];
			}
		}
		
	}
	
	return fileList;
}

//- (BOOL)fileExistsAtPath:(NSString *)path isDirectory:(BOOL *)isDirectory
- (NSArray *)fileExistsAtPathAndIsDirectory:(NSString *)path;
{
	NSArray *components = [path pathComponents];
	BOOL fileExists = NO;
	BOOL isDirectory = NO;
	
	//root = server
	if ( [path isEqualToString:@"/"] ) {
		isDirectory = YES;
		fileExists = YES;
	}
	
	//grids
	else if ( [components count] == 2 ) {
		if ( [self gridWithFuseFilename:[components objectAtIndex:1]] != nil ) {
			isDirectory = YES;
			fileExists = YES;
		}
	}
	
	//jobs
	else if ( [components count] == 3 ) {
		if ( [self jobWithFusePath:path] != nil ) {
			isDirectory = YES;
			fileExists = YES;
		}
	}
	
	//tasks
	else if ( [components count] == 4 ) {
		if ( [self taskWithFusePath:path] != nil ) {
			isDirectory = YES;
			fileExists = YES;
		}
	}
	
	//files
	else {
		id file = [self fileWithFusePath:path]; 
		if ( file != nil ) {
			isDirectory = [[file valueForKey:@"isDirectory"] boolValue];
			fileExists = YES;
		}
	}	
	
	//if ( fileExists ) NSLog(@"<%@:%p> %s %@",[self class],self,_cmd, path);
	
	return [NSArray arrayWithObjects:[NSNumber numberWithBool:fileExists], [NSNumber numberWithBool:isDirectory], nil];
}

- (BOOL)fileExistsAtPath:(NSString *)path isDirectory:(BOOL *)isDirectory
{
	*isDirectory = NO;
	NSArray *flags = [self fileExistsAtPathAndIsDirectory:path];
	if ( [flags count] < 2 )
		return NO;
	*isDirectory = [[flags objectAtIndex:1] boolValue];
	return [[flags objectAtIndex:0] boolValue];
}

- (NSData *)contentsAtPath:(NSString *)path
{
	NSData *fileContents;
	id file = [self fileWithFusePath:path];
	if ( file == nil || [[file valueForKey:@"isDirectory"] boolValue] == YES )
		fileContents = [NSData data];
	else
		fileContents = [file valueForKey:@"contents"];
	return fileContents;
}


- (NSDictionary *)fileAttributesAtPath:(NSString *)path
{
	BOOL isDir;
	BOOL exists = [self fileExistsAtPath:path isDirectory:&isDir];
	if ( exists == NO )
		return nil;

	//file type
	NSString *fileType = NSFileTypeRegular;
	if ( exists == YES && isDir == YES )
		fileType = NSFileTypeDirectory;
	
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:	
		fileType,NSFileType,
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
		nil];
	
	return attributes;	
}



@end


@implementation GEZGrid (GEZGridFusePaths)
- (NSString *)fuseFilename
{
	NSMutableString *cleanName = [NSMutableString stringWithString:[self valueForKey:@"name"]];
	[cleanName replaceOccurrencesOfString:@"/" withString:@"-" options:NSLiteralSearch range:NSMakeRange(0, [cleanName length])];
	return [NSString stringWithFormat:@"-%@- %@", [self valueForKey:@"identifier"], cleanName] ;
}

@end

@implementation GEZJob (GEZJobFusePaths)
- (NSString *)fuseFilename
{
	NSMutableString *cleanName = [NSMutableString stringWithString:[self valueForKey:@"name"]];
	[cleanName replaceOccurrencesOfString:@"/" withString:@"-" options:NSLiteralSearch range:NSMakeRange(0, [cleanName length])];
	NSString *marker = @"-";
	//don't do that anymore, this is annoying when going through the jobs, it keeps jumping in the Finder
	//instead, do it on the tasks
	/*
	if ( [self isRetrieved] == YES )
		marker = @"+";
	else if ( [self isRetrievingResults] == YES )
		marker = @"*";
	else
		marker = @"-";
	*/
	return [NSString stringWithFormat:@"-%@%@ %@", [self valueForKey:@"identifier"], marker, cleanName] ;
}
@end

@implementation NSManagedObject (GEZTaskFusePaths)
- (NSString *)fuseFilename
{
	//bad bad hack
	if ( [self class] != NSClassFromString(@"GEZTask") )
		 return @"not a task";
	NSString *marker = @"-loading...";
	if ( [[self valueForKey:@"job"] isRetrieved] == YES )
		 marker = @"";
	return [NSString stringWithFormat:@"%@%@", [self valueForKey:@"name"], marker] ;
}

@end