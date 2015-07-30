//
//  UserDetailsModal.h
//  Dedicaring
//
//  Created by pratik on 31/10/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constant.h"

@interface UserDetailsModal : NSObject

@property (nonatomic, readwrite) BOOL isLoggedIn;
@property (nonatomic, readwrite) NSUInteger userState;

+ (UserDetailsModal *)sharedUserDetails;

@end
