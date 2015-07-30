//
//  HomeViewController.m
//  Common
//
//  Created by Tejvansh Singh Chhabra on 18/05/15.
//  Copyright (c) 2015 Tejvansh Singh Chhabra. All rights reserved.
//

#import "HomeViewController.h"
#import "FilesToImport.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	[self setSideMenuBarButtonItem];
	// Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Set up Navibar BarButtonItem

- (void)setSideMenuBarButtonItem {
	UIImage *sideImage = [UIImage imageNamed:@"menu-icon"];
	UIButton *btnSideMenu = [UIButton buttonWithType:UIButtonTypeCustom];
	[btnSideMenu setImage:sideImage forState:UIControlStateNormal];
	[btnSideMenu setImage:sideImage forState:UIControlStateHighlighted];
	[btnSideMenu setFrame:CGRectMake(0, 0, sideImage.size.width, sideImage.size.height)];
	[btnSideMenu addTarget:self action:@selector(btnLeftMenuClicked:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *sideMenuItem = [[UIBarButtonItem alloc] initWithCustomView:btnSideMenu];
	self.navigationItem.leftBarButtonItem = sideMenuItem;
}

- (void)btnLeftMenuClicked:(id)sender {
	[self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

@end
