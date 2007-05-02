//
//  XgridFusePaths.h
//  Xgrid FUSE
//
//  Created by Charles Parnot on 3/13/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/* Categories to use Fuse paths for grids and jobs and tasks */


//filename is made unique by combining the identifier and the name of the grid
@interface GEZGrid (GEZGridFusePaths)
- (NSString *)fuseFilename;
@end


//filename is made unique by combining the identifier and the name of the job
@interface GEZJob (GEZJobFusePaths)
- (NSString *)fuseFilename;
@end


//server is the root, and can understand full paths
@interface GEZServer (GEZServerFusePaths)

- (GEZGrid *)gridWithFuseFilename:(NSString *)filename;
- (GEZJob *)jobWithFusePath:(NSString *)jobPath;
- (id)fileWithFusePath:(NSString *)filePath;
- (id)taskWithFusePath:(NSString *)taskPath;

//these methods translate the paths into /server/grid/job/task/[[dir/]dir/...]file to return the right values
//note that GEZGrid and GEZJob actually are given a "fuseFilename" in this path
- (NSArray *)directoryContentsAtPath:(NSString *)path; //returns nil if not valid path
- (NSData *)contentsAtPath:(NSString *)path;
- (NSDictionary *)fileAttributesAtPath:(NSString *)path;
- (BOOL)fileExistsAtPath:(NSString *)path isDirectory:(BOOL *)isDirectory;

//returns an array of NSNumber with BOOL { fileExists; isDirectory }
- (NSArray *)fileExistsAtPathAndIsDirectory:(NSString *)path;

@end

