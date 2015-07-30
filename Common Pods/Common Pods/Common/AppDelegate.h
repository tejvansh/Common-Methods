//
//  AppDelegate.h
//
//  Created by Tejvansh Singh Chhabra on 18/5/15.
//  Copyright (c) 2015 Tejvansh Singh Chhabra. All rights reserved.
//

#import "Constant.h"

@class MMDrawerController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (nonatomic, strong) MMDrawerController *drawerController;

@end
