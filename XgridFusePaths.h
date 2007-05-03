//
//  XgridFusePaths.h
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

