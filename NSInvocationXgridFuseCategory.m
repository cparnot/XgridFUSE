//
//  NSInvocationOnMainThread.m
//  Xgrid FUSE
//
//  Created by Charles Parnot on 3/20/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

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
