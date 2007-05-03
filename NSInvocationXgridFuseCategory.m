//
//  NSInvocationOnMainThread.m
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


#import "NSInvocationXgridFuseCategory.h"


@implementation NSInvocation (NSInvocationXgridFuseCategory)

+ (NSInvocation *)invocationWithTarget:(id)target selector:(SEL)selector;
{
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:selector]];
	[invocation setSelector:selector];
	[invocation setTarget:target];
	return invocation;
}

- (void)invokeAndStoreReturnObjectInMutableArray:(NSMutableArray *)array
{
	[self invoke];
	id result;
	[self getReturnValue:&result];
	[array addObject:result];
	//NSLog(@"<%@:%p> %s %@ --> %@",[self class],self,_cmd, self, result);
}

- (id)invokeOnMainThreadAndWait
{
	[self retainArguments];
	NSMutableArray *resultWrapper = [[NSMutableArray alloc] initWithCapacity:1];
	[self performSelectorOnMainThread:@selector(invokeAndStoreReturnObjectInMutableArray:) withObject:resultWrapper waitUntilDone:YES];
	id result = [[[resultWrapper lastObject] retain] autorelease];
	[resultWrapper release];
	return result;
}

@end
