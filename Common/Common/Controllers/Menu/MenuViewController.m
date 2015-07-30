//
//  MenuViewController.m
//  IntroADS
//
//  Created by Tejvansh Singh Chhabra on 9/12/14.
//  Copyright (c) 2014 Tejvansh Singh Chhabra. All rights reserved.
//

#import "FilesToImport.h"
#import "MenuViewController.h"
#import "HomeViewController.h"

@implementation MenuViewController

#pragma mark - View Lifecycle Methods

- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.backgroundColor = RGB(91, 91, 91);
	tblMenu.backgroundColor   = RGB(91, 91, 91);
	tblMenu.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

	NSDictionary *dict1, *dict2;

	lblUserName.font = kCustomFont(kFontBold, 16.0f);
	lblUserName.textColor = [UIColor whiteColor];

	dict1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Home", @"name", nil];
	dict2 = [NSDictionary dictionaryWithObjectsAndKeys:@"LOGOUT", @"name", nil];

	arrMenu = [NSArray arrayWithObjects:dict1, dict2, nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - UITableview Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [arrMenu count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	UILabel *lblMenu = nil;

	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}

	if (indexPath.row == [arrMenu count] - 1) {
		[lblMenu setHidden:YES];
		UIButton *btnLogout = [UIButton buttonWithType:UIButtonTypeCustom];
		btnLogout.frame = CGRectMake(15, 10, 250, 40);
		btnLogout.layer.cornerRadius = 7.0f;
		btnLogout.layer.masksToBounds = YES;
		btnLogout.titleLabel.font = kCustomFont(kFontBold, 16);
		btnLogout.backgroundColor = RGB(0, 0, 50);
		[btnLogout setTitle:@" LOGOUT" forState:UIControlStateNormal];
		[btnLogout setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, -5, 0)];
		[btnLogout setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 0)];
		[btnLogout setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[btnLogout addTarget:self action:@selector(btnLogoutAction:) forControlEvents:UIControlEventTouchUpInside];
		[cell.contentView addSubview:btnLogout];
		cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width, 0.f, 0.f);
	}
	else {
		[lblMenu setHidden:NO];
		lblMenu = [[UILabel alloc] init];
		lblMenu.frame = CGRectMake(40, 8, 200, 25);
		lblMenu.font = kCustomFont(kFontRegular, 13.0f);
		lblMenu.textColor = RGB(206, 207, 207);
		lblMenu.textAlignment = NSTextAlignmentLeft;
		lblMenu.tag = 1001;

		[cell.contentView addSubview:lblMenu];

		lblMenu.text = [[arrMenu objectAtIndex:indexPath.row] objectForKey:@"name"];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}

	cell.backgroundColor = [UIColor clearColor];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
}

#pragma mark - UITableview Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == [arrMenu count] - 1)
		return 60.0;

	return 40.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.row) {
		case 0: {
			// Home
			HomeViewController *controller = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
			[self setCenterViewController:controller];
			return;
		}
		break;

		default:
			break;
	}
}

#pragma mark - UIButton Methods

- (void)btnLogoutAction:(id)sender {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:AppName
	                                                message:@"Are you sure want to logout ?"
	                                               delegate:self
	                                      cancelButtonTitle:@"No"
	                                      otherButtonTitles:@"Yes, I am", nil];
	[alert show];
}

- (void)setCenterViewController:(UIViewController *)viewController {
	NSArray *controllers = [NSArray arrayWithObjects:viewController, nil];
	appDel.navigationController.viewControllers = controllers;

	[self.mm_drawerController setCenterViewController:appDel.navigationController withCloseAnimation:YES completion:nil];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
		[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
		[self.mm_drawerController closeDrawerAnimated:NO completion: ^(BOOL finished) {
		    [appDel.navigationController popToRootViewControllerAnimated:YES];
		}];
	}
}

@end
