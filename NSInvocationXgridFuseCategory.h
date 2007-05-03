//
//  NSInvocationXgridFuseCategory.h
//  Xgrid FUSE
//
//  Created by Charles Parnot on 3/20/07.
//  Copyright 2007 Charles Parnot. All rights reserved.
//

/*
 This file is part of Xgrid FUSE.
 Xgrid FUSE is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
 Xgrid FUSE is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with Xgrid FUSE; if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */

/* NOT USED */

/* this was initially used to communicate from the fuse thread to the main thread in a supposedly clean way; but then, the application was locking on some calls, apparently, so I gave up for now */

@interface NSInvocation (NSInvocationXgridFuseCategory)

//convenience factory method
+ (NSInvocation *)invocationWithTarget:(id)target selector:(SEL)selector;

//only use when the return value is an object or nil
//this method will also ensured that autoreleased objects are properly managed and not dealloced in the main thread, and are safely added to the autorelease pool of the calling thread
- (id)invokeOnMainThreadAndWait;

@end
