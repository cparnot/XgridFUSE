//
//  NSInvocationXgridFuseCategory.h
//  Xgrid FUSE
//
//  Created by Charles Parnot on 3/20/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/* this was initially used to communicate from the fuse thread to the main thread in a supposedly clean way; but then, the application was locking on some calls, apparently, so I gave up for now */

@interface NSInvocation (NSInvocationXgridFuseCategory)

//convenience factory method
+ (NSInvocation *)invocationWithTarget:(id)target selector:(SEL)selector;

//only use when the return value is an object or nil
//this method will also ensured that autoreleased objects are properly managed and not dealloced in the main thread, and are safely added to the autorelease pool of the calling thread
- (id)invokeOnMainThreadAndWait;

@end
