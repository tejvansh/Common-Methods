//
//  UserDetailsModal.m
//  Dedicaring
//
//  Created by pratik on 31/10/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "UserDetailsModal.h"

@implementation UserDetailsModal

+ (UserDetailsModal *)sharedUserDetails {
	static dispatch_once_t once;
	static id sharedInstance;
	dispatch_once(&once, ^{
	    sharedInstance = [[self alloc] init];
	    [sharedInstance initialize];
	});
	return sharedInstance;
}

- (void)initialize {
}

@end
