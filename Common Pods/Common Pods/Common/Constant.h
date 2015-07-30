//
//  Constant.h
//
//  Created by Tejvansh Singh Chhabra on 18/5/15.
//  Copyright (c) 2015 Tejvansh Singh Chhabra. All rights reserved.
//

#import "FilesToImport.h"

// Common Strings
#define AppName  @"App Name"
#define STR_OK   @"OK"
#define HUDTitle @"Loading..."
#define NO_INTERNET @"Unable to connect. Please check your internet connection."
#define TIME_FORMAT @"hh:mm a"
#define DATE_FORMAT @"MMMM dd, yyyy"
#define DEGREES_TO_RADIANS(d) (d * M_PI / 180)
#define POP_VIEW [self.navigationController popViewControllerAnimated:YES]

// API Keys
#define kAPI_KEY @""
#define kCONSUMER_KEY    @""        // Twitter Consumer Key
#define kCONSUMER_SECRET @""        // Twitter Consumer Secret
#define FACEBOOK_APP_ID  @""        // Facebook App ID
#define kGOOGLE_API_KEY  @""        // Google Plus API Key
#define kGOOGLE_ANALYTICS_KEY @""   // Google Analytics Client Key

// Notifications Name

// Parameters
#define SUCCESS @"Success"
#define MESSAGE @"Message"
#define kLOGIN_STATE @"userState"

//Singleton constants
#define UserDefaults [NSUserDefaults standardUserDefaults]
#define kAFClient    [AFAPIClient sharedClient]
#define kUserDetails [UserDetailsModal sharedUserDetails]
#define CommonSingleton [CommonMethods sharedInstance]
#define appDel ((AppDelegate *)[[UIApplication sharedApplication] delegate])

/*
 * IOS Version and Device Macros
 */

#define SYSTEM_SCREEN_SIZE [[UIScreen mainScreen] bounds].size

#define IS_IPAD      (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE    (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_4  (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 480.0f)
#define IS_IPHONE_5  (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_IPHONE_6  (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0f)
#define IS_IPHONE_6P (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0f)

#define IS_IOS_7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IS_IOS_8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define SYSTEM_VERSION_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_LESS_THAN(v)    ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_GREATER_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)    ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define IPHONE6PLUS_WIDTH  414
#define IPHONE6PLUS_HEIGHT 736
#define kRATIO_WIDTH(width)   ((SYSTEM_SCREEN_SIZE.width  / IPHONE6PLUS_WIDTH)  * width)
#define kRATIO_HEIGHT(height) ((SYSTEM_SCREEN_SIZE.height / IPHONE6PLUS_HEIGHT) * height)

/*
 * CGRect Width Height Macros
 */

#define CGRectSetHeightWidthToView(v, height, width) \
	v.frame = CGRectMake(v.frame.origin.x, \
	                     v.frame.origin.y, \
	                     width, \
	                     height)

#define CGRectSetOriginToView(v, origin) \
	v.frame = CGRectMake(origin.x, \
	                     origin.y, \
	                     v.frame.size.width, \
	                     v.frame.size.height)

#define CGRectSetHeightToView(v, height) \
	v.frame = CGRectMake(v.frame.origin.x, \
	                     v.frame.origin.y, \
	                     v.frame.size.width, \
	                     height)

#define CGRectSetWidthToView(v, width) \
	v.frame = CGRectMake(v.frame.origin.x, \
	                     v.frame.origin.y, \
	                     width, \
	                     v.frame.size.height)

#define CGRectSetOriginXToView(v, originX) \
	v.frame = CGRectMake(originX, \
	                     v.frame.origin.y, \
	                     v.frame.size.width, \
	                     v.frame.size.height)

#define CGRectSetOriginYToView(v, originY) \
	v.frame = CGRectMake(v.frame.origin.x, \
	                     originY, \
	                     v.frame.size.width, \
	                     v.frame.size.height)

#define CGRectSetHeightPositionToView(v, height, y) \
	v.frame = CGRectMake(v.frame.origin.x, \
	                     y, \
	                     v.frame.size.width, \
	                     height)

/*
 * UIImage Macros
 */

#define IMAGE_NAMED(img)  [UIImage imageNamed : img]
#define SET_ORIGINAL_IMAGE(imgName) [[UIImage imageNamed:imgName] imageWithRenderingMode : UIImageRenderingModeAlwaysOriginal]

/*
 * NSString Macros
 */

#define LSSTRING(str) NSLocalizedString(str, nil)
#define NSSTRING_WITH_NUM(no)        [NSString stringWithFormat : @"%d", (int)no]
#define NSSTRING_WITH_FORMAT(string) [NSString stringWithFormat : @"%@", string]
#define allTrim(object) [object stringByTrimmingCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]]

/*
 * UIColor RGB Macros
 */

#define CLRCOLOR [UIColor clearColor]
#define RGB(r, g, b)     [UIColor colorWithRed : (r) / 255.0 green : (g) / 255.0 blue : (b) / 255.0 alpha : 1]
#define RGBA(r, g, b, a) [UIColor colorWithRed : (r) / 255.0 green : (g) / 255.0 blue : (b) / 255.0 alpha : (a)]
#define UIColorFromRGB(rgbValue, alphaValue) [UIColor colorWithRed : ((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 green : ((float)((rgbValue & 0xFF00) >> 8)) / 255.0 blue : ((float)(rgbValue & 0xFF)) / 255.0 alpha : alphaValue]

/*
 * UIFont Macros
 */

#define kFontBold       @"FontName-Bold"
#define kFontRegular    @"FontName-Regular"
#define kFontSemiBold   @"FontName-Semibold"
#define kFontNovaLight  @"FontName-Light"

#define kCustomFont(fontName, fontSize) [UIFont fontWithName : fontName size : fontSize]

/*
 * GCD Macros
 */

#define ASYNC_BACK(...) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ __VA_ARGS__ })
#define ASYNC_MAIN(...) dispatch_async(dispatch_get_main_queue(), ^{ __VA_ARGS__ })


/*
 * UIAlertView Macros
 */

#define SHOW_ALERT(TITLE, MSG) [[[UIAlertView alloc] initWithTitle:(TITLE) \
	                                                       message:(MSG) \
	                                                      delegate:nil \
	                                             cancelButtonTitle:STR_OK \
	                                             otherButtonTitles:nil] show]

#define SHOW_ALERT_DELEGATE(tag, title, msg, button, buttons) { UIAlertView *alert = \
		                                                            [[UIAlertView alloc] initWithTitle:title message:msg delegate:self \
		                                                                             cancelButtonTitle:button otherButtonTitles:buttons]; [alert setTag:tag]; [alert show]; }

/*
 * Indicator Methods
 */

#define showIndicator [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
#define hideIndicator [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

/*
 * Enums
 */

typedef NS_ENUM (NSUInteger, USER_STATE) {
	NOT_LOGGED_IN,
	LOGGED_IN,
};

//Webservice URLs

#define MAIN_URL  @"http://website.com"
#define LOGIN_URL MAIN_URL@ "/login.php"
