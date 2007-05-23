//
//  main.m
//  Xgrid FUSE
//
//  Created by Charles Parnot on 3/13/07.
//  Copyright __MyCompanyName__ 2007. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//global with argv[1] = server to connect to (none if nil)
NSString *_xgridfs_ServerAddress = nil;

int main(int argc, char *argv[])
{
	int i;
	printf ( "%d arguments\n", argc );
	for ( i = 0 ; i < argc ; i++ )
		printf ( "%s\n", argv[i] );
	if ( argc >= 1 )
		_xgridfs_ServerAddress = [[NSString alloc] initWithUTF8String:(const char *)argv[1]];
    return NSApplicationMain(argc,  (const char **) argv);
}
