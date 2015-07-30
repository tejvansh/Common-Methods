//
//  MenuViewController.h
//  IntroADS
//
//  Created by Tejvansh Singh Chhabra on 9/12/14.
//  Copyright (c) 2014 Tejvansh Singh Chhabra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface MenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
	IBOutlet UITableView *tblMenu;
	IBOutlet UILabel *lblUserName;

	NSArray *arrMenu;
}

@end
