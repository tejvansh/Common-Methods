//
//  CommonMethods.m
//
//  Created by Tejvansh Singh Chhabra on 18/5/15.
//  Copyright (c) 2015 Tejvansh Singh Chhabra. All rights reserved.
//

#import "CommonMethods.h"

#define MB (1024 * 1024)
#define GB (MB * 1024)
#define kXMLDefaultKey @"temp"

NSNumberFormatter *priceFormatter;

@implementation CommonMethods

+ (instancetype)sharedInstance {
    static CommonMethods *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super allocWithZone:NULL] init];
        [sharedInstance initialize];
    });
    return sharedInstance;
}

- (void)initialize {
    [self setUpReachability];
}

#pragma mark - Do not back up on iCloud

/*--- Do not back up on iCloud ---*/
+ (BOOL)addSkipBackupAttributeToItemAtPath {
    NSURL *URL = [NSURL fileURLWithPath:DocumentsDirectoryPath()];
    assert([[NSFileManager defaultManager] fileExistsAtPath:[URL path]]);
    
    NSError *error = nil;
    
    BOOL success = [URL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
    
    if (!success) {
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

#pragma mark - Memory Info Methods

+ (NSString *)memoryFormatter:(long long)diskSpace {
    NSString *formatted;
    double bytes = 1.0 * diskSpace;
    double megabytes = bytes / MB;
    double gigabytes = bytes / GB;
    if (gigabytes >= 1.0)
        formatted = [NSString stringWithFormat:@"%.2f GB", gigabytes];
    else if (megabytes >= 1.0)
        formatted = [NSString stringWithFormat:@"%.2f MB", megabytes];
    else
        formatted = [NSString stringWithFormat:@"%.2f bytes", bytes];
    return formatted;
}

+ (NSString *)totalDiskSpace {
    long long space = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemSize] longLongValue];
    return [self memoryFormatter:space];
}

+ (NSString *)freeDiskSpace {
    long long freeSpace = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemFreeSize] longLongValue];
    return [self memoryFormatter:freeSpace];
}

+ (NSString *)usedDiskSpace {
    return [self memoryFormatter:[self usedDiskSpaceInBytes]];
}

+ (CGFloat)totalDiskSpaceInBytes {
    long long space = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemSize] longLongValue];
    return space;
}

+ (CGFloat)freeDiskSpaceInBytes {
    long long freeSpace = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemFreeSize] longLongValue];
    return freeSpace;
}

+ (CGFloat)usedDiskSpaceInBytes {
    long long usedSpace = [self totalDiskSpaceInBytes] - [self freeDiskSpaceInBytes];
    return usedSpace;
}

+ (NSString *)getAppVersionNum {
    //              NSString* appName = [infoDict objectForKey:@"CFBundleDisplayName"];
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersionNum = [infoDict objectForKey:@"CFBundleShortVersionString"];
    return appVersionNum;
}

+ (NSString *)getSystemVersion {
    //              NSString* appName = [infoDict objectForKey:@"CFBundleDisplayName"];
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    return currSysVer;
}

+ (NSString *)getDeviceType {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *code = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    NSString *deviceString = [NSString stringWithFormat:@"%@ (%@)", [[UIDevice currentDevice] model], code];
    
    return deviceString;
}

/**
 *  Shortcut method to get DocumentsDirectory Path
 *
 *  @return DocumentsDirectory Path
 */

NSString *DocumentsDirectoryPath() {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    return documentsDirectoryPath;
}

#pragma mark - Prevent Multiple Touch Methods
/**
 *  Method used to recursively disable multiple touch events inside UIView especially designed for UIButton
 *
 *  @param selfView UIView object where you want to disable multiple touch recursively.
 */
+ (void)disableMultipleTouch:(UIView *)selfView {
    for (UIView *v in selfView.subviews) {
        if ([v isMemberOfClass:[UIView class]]) {
            [self disableMultipleTouch:v];
        }
        else if ([v isMemberOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)v;
            [btn setExclusiveTouch:YES];
            [btn setMultipleTouchEnabled:NO];
        }
    }
}

#pragma mark - Reachability Methods

- (void)setUpReachability {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNetworkChange:) name:kReachabilityChangedNotification object:nil];
    internetReachability = [Reachability reachabilityForInternetConnection];
    [internetReachability startNotifier];
    
    NetworkStatus remoteHostStatus = [internetReachability currentReachabilityStatus];
    if (remoteHostStatus == NotReachable) {
        self.isConnected = NO;
    }
    else if (remoteHostStatus == ReachableViaWiFi) {
        self.isConnected = YES;
    }
    else if (remoteHostStatus == ReachableViaWWAN) {
        self.isConnected = YES;
    }
}

- (void)handleNetworkChange:(NSNotification *)notice {
    NetworkStatus remoteHostStatus = [internetReachability currentReachabilityStatus];
    if (remoteHostStatus == NotReachable) {
        self.isConnected = NO;
    }
    else if (remoteHostStatus == ReachableViaWiFi) {
        self.isConnected = YES;
    }
    else if (remoteHostStatus == ReachableViaWWAN) {
        self.isConnected = YES;
    }
}

+ (void)handleErrorOperation:(AFHTTPRequestOperation *)task withError:(NSError *)error {
    NSRange cancelRange = [[error localizedDescription] rangeOfString:@"cancelled"];
    if (![task isCancelled] && cancelRange.location == NSNotFound) {
        id errorBody = [error.userInfo valueForKey:@"body"];
        //NSLog(@"------------++++++++++----------Error Body %@",errorBody);
        if ([errorBody isKindOfClass:[NSArray class]]) {
            errorBody = errorBody[0];
        }
        if (errorBody != nil) {
            NSString *description = [NSString stringWithFormat:@"%@", [errorBody valueForKey:@"errorMessage"]];
            if ([description isEqualToString:@"(null)"]) {
                description = errorBody[@"error_description"];
            }
            [CommonMethods showToastWithMessage:description];
        }
        else {
            //[CommonMethods showToastWithMessage:[error localizedDescription]];
            //NSLog(@"-----------------Error %@", [error.userInfo valueForKey:@"NSLocalizedDescription"]);
        }
    }
}

/*----- check internet Connection -----*/
+ (BOOL)isInternetConnectionAvailable {
    const char *host_name = "www.google.com";
    BOOL _isDataSourceAvailable = NO;
    Boolean success;
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, host_name);
    SCNetworkReachabilityFlags flags;
    success = SCNetworkReachabilityGetFlags(reachability, &flags);
    _isDataSourceAvailable = success &&
    (flags & kSCNetworkFlagsReachable) &&
    !(flags & kSCNetworkFlagsConnectionRequired);
    
    CFRelease(reachability);
    return _isDataSourceAvailable;
}

#pragma mark - File Manager Methods
/*--- Unzip File ---*/
+ (void)UnzipFile {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        /* NSError *error = nil;
         
         // In order to make this code work add minizip library to project and import it.
         
         if (!error) {
         NSString *zipPath = [DocumentsDirectoryPath() stringByAppendingPathComponent:[[UserDefaults valueForKey:URL_ZIP_FILE]lastPathComponent]];
         
         if (!error) {
         ZipArchive *za = [[ZipArchive alloc] init];
         if ([za UnzipOpenFile:zipPath]) {
         BOOL ret = [za UnzipFileTo:DocumentsDirectoryPath() overWrite:YES];
         if (NO == ret) {
         }
         [za UnzipCloseFile];
         
         //[self renameDir:@"bio" asDir:[[[UserDefaults valueForKey:URL_ZIP_FILE] lastPathComponent] stringByDeletingPathExtension] cleanExisting:YES];
         }
         }
         else {
         NSLog(@"Error saving file %@", error);
         }
         }
         else {
         NSLog(@"Error downloading zip file: %@", error);
         }*/
    });
}

+ (BOOL)renameDir:(NSString *)dirPath asDir:(NSString *)newDirPath cleanExisting:(BOOL)clean {
    dirPath = [DocumentsDirectoryPath() stringByAppendingPathComponent:dirPath];
    newDirPath = [DocumentsDirectoryPath() stringByAppendingPathComponent:newDirPath];
    
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    if (clean && [fm fileExistsAtPath:newDirPath]) {
        [fm removeItemAtPath:newDirPath error:&error];
        if (error != nil) {
            NSLog(@"Error while renameDir %@ as %@ :\n%@", dirPath, newDirPath, error);
            return NO;
        }
    }
    //Make sure container directories exist
    NSString *newDirContainer = [newDirPath stringByDeletingLastPathComponent];
    if (![fm fileExistsAtPath:newDirContainer]) {
        [fm createDirectoryAtPath:newDirContainer withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    if (error == nil) {
        [fm moveItemAtPath:dirPath toPath:newDirPath error:&error];
    }
    if (error != nil) {
        NSLog(@"error while moveItemAtPath : %@", error);
    }
    return (error == nil);
}

#pragma mark - JSON & XML Methods

+ (void)printJson:(id)json {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:&error];
    if (!jsonData) {
        NSLog(@"\nJSON error: %@", error);
    }
    else {
        NSString *JSONString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
        NSLog(@"\nJSON OUTPUT: %@", JSONString);
    }
}

+ (NSString *)jsonStringFromID:(id)object isPretty:(BOOL)prettyPrint {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:(NSJSONWritingOptions)(prettyPrint ? NSJSONWritingPrettyPrinted : 0) error:&error];
    
    if (!jsonData) {
        NSLog(@"Json Print: error: %@", error.localizedDescription);
        return @"{}";
    }
    else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

/**
 *  This method is used to clean up dictionary which we get after XML parsing
 *
 *  @param XMLDictionary Dictionary on which we want to perform cleanup
 *
 *  @return Cleaned dictionary
 */
+ (NSMutableDictionary *)cleanUpXMLDictionary:(NSMutableDictionary *)XMLDictionary {
    for (NSString *key in[XMLDictionary allKeys]) {
        // get the current object for this key
        id object = [XMLDictionary objectForKey:key];
        
        if ([object isKindOfClass:[NSDictionary class]]) {
            if ([[object allKeys] count] == 1 &&
                [[[object allKeys] objectAtIndex:0] isEqualToString:kXMLDefaultKey] &&
                ![[object objectForKey:kXMLDefaultKey] isKindOfClass:[NSDictionary class]]) {
                // this means the object has the key "text" and has no node
                // or array (for multiple values) attached to it.
                [XMLDictionary setObject:[object objectForKey:kXMLDefaultKey] forKey:key];
            }
            else {
                // go deeper
                [self cleanUpXMLDictionary:object];
            }
        }
        else if ([object isKindOfClass:[NSArray class]]) {
            // this is an array of dictionaries, iterate
            for (id inArrayObject in (NSArray *)object) {
                if ([inArrayObject isKindOfClass:[NSDictionary class]]) {
                    // if this is a dictionary, go deeper
                    [self cleanUpXMLDictionary:inArrayObject];
                }
            }
        }
    }
    
    return XMLDictionary;
}

#pragma mark - Global Indicator Methods

/**
 *  This method displays SVProgressHUD on top of window to perform synchronous tasks.
 *
 *  @param title Title of the indicator you want to display while performing any task.
 */
+ (void)showGlobalHUDWithTitle:(NSString *)title {
    [SVProgressHUD showWithStatus:title maskType:SVProgressHUDMaskTypeGradient];
}

/**
 *  Method will hide any hud currently visible on the window.
 */
+ (void)hideGlobalHUD {
    [SVProgressHUD dismiss];
}

#pragma mark - Custom Overlay Methods

+ (void)displayOverlay:(UIView *)viewOverlay {
    viewOverlay.alpha = 1.0f;
    viewOverlay.frame = [[UIScreen mainScreen] bounds];
    [[[[UIApplication sharedApplication]delegate] window] addSubview:viewOverlay];
    
    viewOverlay.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3 / 1.5];
    [UIView setAnimationDelegate:self];
    [self performSelector:@selector(bounce1AnimationStoppedForView:) withObject:viewOverlay afterDelay:0.3 / 1.5];
    viewOverlay.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
    [UIView commitAnimations];
}

+ (void)bounce1AnimationStoppedForView:(UIView *)view {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3 / 2];
    [UIView setAnimationDelegate:self];
    [self performSelector:@selector(bounce2AnimationStoppedForView:) withObject:view afterDelay:0.3 / 2];
    view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
    [UIView commitAnimations];
}

+ (void)bounce2AnimationStoppedForView:(UIView *)view {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3 / 2];
    view.transform = CGAffineTransformIdentity;
    [UIView commitAnimations];
}

+ (void)removeOverlay:(UIView *)subView {
    [subView removeFromSuperview];
}

+ (void)displayOverlay:(UIView *)subView aboveView:(UIView *)superView {
    subView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [superView addSubview:subView];
    [superView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subView]|" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(subView)]];
    [superView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subView]|" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(subView)]];
    
    [superView layoutSubviews];
}

+ (void)showToastWithMessage:(NSString *)message {
    Toast *toast = [Toast toastWithMessage:message];
    UIWindow *window;
    if ([UIApplication sharedApplication].windows.count > 0)
        window = [UIApplication sharedApplication].windows.lastObject;
    else
        window = [(AppDelegate *)[[UIApplication sharedApplication] delegate] window];
    
    [toast showOnView:(UIView *)window];
}

+ (void)showAlertWithMessage:(NSString *)message {
    /*CustomAlertView *alertView = [CustomAlertView alertWithMessage:message];
     [alertView setOnButtonTouchUpInside: ^(CustomAlertView *sender, NSInteger buttonIndex) {
	    [sender close];
     }];
     [alertView show];*/
	   
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8")) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:AppName message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:STR_OK style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
            NSLog(@"OK action");
        }];
        
        [alertController addAction:okAction];
        UIWindow *window;
        if ([UIApplication sharedApplication].windows.count > 0)
            window = [UIApplication sharedApplication].windows.lastObject;
        else
            window = [(AppDelegate *)[[UIApplication sharedApplication] delegate] window];
        
        [window.rootViewController presentViewController:alertController animated:YES completion:nil];
    }
    else {
        SHOW_ALERT(AppName, message);
    }
}

+ (void)showAlertWithMessage:(NSString *)message withCompletion:(AlertBlock)completion {
    /*CustomAlertView *alertView = [CustomAlertView alertWithMessage:message];
     [alertView setOnButtonTouchUpInside: ^(CustomAlertView *sender, NSInteger buttonIndex) {
	    sender.userInteractionEnabled = NO;
	    [sender closeWithCompletion: ^(BOOL success, id result, NSError *error) {
     if (completion)
     completion();
	    }];
     }];
     [alertView show];*/
	   
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8")) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:AppName message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:STR_OK style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
            completion(YES);
        }];
        
        [alertController addAction:okAction];
        UIWindow *window;
        if ([UIApplication sharedApplication].windows.count > 0)
            window = [UIApplication sharedApplication].windows.lastObject;
        else
            window = [(AppDelegate *)[[UIApplication sharedApplication] delegate] window];
        
        [window.rootViewController presentViewController:alertController animated:YES completion:nil];
    }
    else {
        [CommonMethods sharedInstance].alertHandler = completion;
        SHOW_ALERT_DELEGATE(999, AppName, message, STR_OK, nil);
    }
}

+ (void)displayAlertwithTitle:(NSString *)title withMessage:(NSString *)msg withViewController:(UIViewController *)viewController {
    if (IS_IOS_8) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:defaultAction];
        [viewController presentViewController:alert animated:YES completion:nil];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

+ (UIViewController *)getTopViewController:(UINavigationController *)navController {
    if (navController.viewControllers.count > 0) {
        if (((UIViewController *)[navController.viewControllers lastObject]).presentedViewController) {
            if ([((UIViewController *)[navController.viewControllers lastObject]).presentedViewController isKindOfClass :[UINavigationController class]])
                return [self getTopViewController:((UINavigationController *)((UIViewController *)[navController.viewControllers lastObject]).presentedViewController)];
            else
                return ((UIViewController *)[navController.viewControllers lastObject]).presentedViewController;
        }
        else
            return [navController.viewControllers lastObject];
    }
    else
        return navController.visibleViewController;
}

#pragma mark - UIAlertView Delegate Method

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([CommonMethods sharedInstance].alertHandler) {
        [CommonMethods sharedInstance].alertHandler(YES);
    }
}

#pragma mark - User State Method

+ (void)setUserState:(NSUInteger)currentState {
    switch (currentState) {
        case NOT_LOGGED_IN: {
            kUserDetails.isLoggedIn = NO;
        }
            break;
            
        case LOGGED_IN: {
            kUserDetails.isLoggedIn = YES;
        }
            break;
            
        default:
            break;
    }
    //#warning Following 3 lines must not be commented
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithUnsignedInteger:currentState] forKey:kLOGIN_STATE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    kUserDetails.userState = currentState;
}

#pragma mark - Navigation Method

+ (void)popToLast:(Class)aClass fromNavigationController:(UINavigationController *)navController animated:(BOOL)animated {
    for (NSInteger i = navController.viewControllers.count - 1; i >= 0; i--) {
        UIViewController *vc = navController.viewControllers[i];
        if ([vc isKindOfClass:aClass]) {
            [navController popToViewController:vc animated:animated];
            break;
        }
    }
}

#pragma mark - Validation Methods

/**
 *  This method will check null validations for NSString, NSArray and Null class
 *
 *  @param thing Pass NSString, NSArray or NSNull class reference
 *
 *  @return YES/NO respectively
 */
+ (BOOL)isObjectEmpty:(id)object {
    if ([object isKindOfClass:[NSNull class]] || object == nil) {
        return YES;
    }
    if ([object isKindOfClass:[NSString class]]) {
        if (object == nil || ([object respondsToSelector:@selector(length)] && [(NSString *)object length] == 0)) {
            return YES;
        }
    }
    else if ([object isKindOfClass:[NSArray class]]) {
        if (object == nil || ([object respondsToSelector:@selector(count)] && [(NSArray *)object count] == 0)) {
            return YES;
        }
    }
    else if ([object isKindOfClass:[NSDictionary class]]) {
        if (object == nil || ([object respondsToSelector:@selector(count)] && [(NSDictionary *)object count] == 0)) {
            return YES;
        }
    }
    else if ([object isKindOfClass:[NSData class]]) {
        if (object == nil || ([object respondsToSelector:@selector(length)] && [(NSData *)object length] == 0)) {
            return YES;
        }
    }
    else if ([object isKindOfClass:[UIImage class]]) {
        if (object == nil) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)isArrayContainingAnyEmptyObject:(NSArray *)array {
    if ([self isObjectEmpty:array])
        return YES;
    
    for (NSInteger counter = 0; counter < [array count]; counter++)
        if ([self isObjectEmpty:[array objectAtIndex:counter]])
            return YES;
    
    return NO;
}

+ (BOOL)isValidEmail:(NSString *)checkString {
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

+ (BOOL)isDevice24HrFormat {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    NSRange amRange = [dateString rangeOfString:[formatter AMSymbol]];
    NSRange pmRange = [dateString rangeOfString:[formatter PMSymbol]];
    
    return (amRange.location == NSNotFound && pmRange.location == NSNotFound);
}

+ (BOOL)isPDF:(NSString *)strLastComponent {
    if ([strLastComponent containsString:@".pdf"]) {
        return YES;
    }
    else
        return NO;
}

+ (BOOL)isImage:(NSString *)strLastComponent {
    if ([strLastComponent containsString:@".jpg"] ||
        [strLastComponent containsString:@".jpeg"] ||
        [strLastComponent containsString:@".bmp"] ||
        [strLastComponent containsString:@".gif"] ||
        [strLastComponent containsString:@".png"]) {
        return YES;
    }
    else
        return NO;
}

+ (BOOL)isVideo:(NSString *)strLastComponent {
    if ([strLastComponent containsString:@".flv"] ||
        [strLastComponent containsString:@".mp4"] ||
        [strLastComponent containsString:@".wmv"]) {
        return YES;
    }
    else
        return NO;
}

+ (BOOL)isViewOrCorrespondingSubViewsScrolling:(UIView *)view {
    if ([view isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scroll_view = (UIScrollView *)view;
        if (scroll_view.dragging || scroll_view.decelerating) {
            return YES;
        }
    }
    
    for (UIView *sub_view in[view subviews]) {
        if ([self isViewOrCorrespondingSubViewsScrolling:sub_view]) {
            return YES;
        }
    }
    
    return NO;
}

+ (NSArray *)arrayAfterRemovingEmptyObjects:(NSArray *)array {
    NSMutableArray *newArray = [array mutableCopy];
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    for (NSInteger counter = 0; counter < [array count]; counter++) {
        if ([self isObjectEmpty:[array objectAtIndex:counter]])
            [indexSet addIndex:counter];
    }
    [newArray removeObjectsAtIndexes:indexSet];
    return [newArray copy];
}

+ (NSArray *)arrayAfterRemovingBlankObjects:(NSArray *)array {
    NSMutableArray *newArray = [array mutableCopy];
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    for (NSInteger counter = 0; counter < [array count]; counter++) {
        if ([self isObjectEmpty:[self getTrimmedString:[array objectAtIndex:counter]]])
            [indexSet addIndex:counter];
    }
    [newArray removeObjectsAtIndexes:indexSet];
    return [newArray copy];
}

+ (NSArray *)getPhoneNumbersFromList:(NSString *)phoneNumbers {
    NSString *commaSeparator = @",";
    NSString *invertedCommaSep = @"،";
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    NSArray *arrayContacts = [self arrayAfterRemovingBlankObjects:[phoneNumbers componentsSeparatedByString:commaSeparator]];
    for (NSInteger counter = 0; counter < [arrayContacts count]; counter++) {
        [newArray addObjectsFromArray:[self arrayAfterRemovingBlankObjects:[[arrayContacts objectAtIndex:counter] componentsSeparatedByString:invertedCommaSep]]];
    }
    return [newArray copy];
}

+ (NSDictionary *)stripNulls:(NSDictionary *)dictionary {
    NSMutableDictionary *returnDict = [NSMutableDictionary new];
    NSArray *allKeys = [dictionary allKeys];
    NSArray *allValues = [dictionary allValues];
    for (NSInteger i = 0; i < [allValues count]; i++) {
        if ([self isObjectEmpty:[allValues objectAtIndex:i]])
            [returnDict setValue:@"" forKey:[allKeys objectAtIndex:i]];
        else
            [returnDict setValue:[allValues objectAtIndex:i] forKey:[allKeys objectAtIndex:i]];
    }
    return returnDict;
}

+ (NSDictionary *)dictionaryAfterRemovingEmptyObjects:(NSDictionary *)dictionary {
    NSMutableDictionary *returnDict = [NSMutableDictionary new];
    NSArray *allKeys = [dictionary allKeys];
    NSArray *allValues = [dictionary allValues];
    for (NSInteger i = 0; i < [allValues count]; i++)
        if (![self isObjectEmpty:[allValues objectAtIndex:i]])
            [returnDict setValue:[allValues objectAtIndex:i] forKey:[allKeys objectAtIndex:i]];
    
    return returnDict;
}

+ (NSDictionary *)nestedDictionaryByReplacingNullsWithNil:(NSDictionary *)sourceDictionary {
    NSMutableDictionary *replaced = [NSMutableDictionary dictionaryWithDictionary:sourceDictionary];
    const id nul = [NSNull null];
    const NSString *blank = @"";
    [sourceDictionary enumerateKeysAndObjectsUsingBlock: ^(id key, id object, BOOL *stop) {
        object = [sourceDictionary objectForKey:key];
        if ([object isKindOfClass:[NSDictionary class]]) {
            NSDictionary *innerDict = object;
            [replaced setObject:[self nestedDictionaryByReplacingNullsWithNil:innerDict] forKey:key];
        }
        else if ([object isKindOfClass:[NSArray class]]) {
            NSMutableArray *nullFreeRecords = [NSMutableArray array];
            for (id record in object) {
                if ([record isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *nullFreeRecord = [self nestedDictionaryByReplacingNullsWithNil:record];
                    [nullFreeRecords addObject:nullFreeRecord];
                }
            }
            [replaced setObject:nullFreeRecords forKey:key];
        }
        else if (object == nul) {
            [replaced setObject:blank forKey:key];
        }
    }];
    
    return [NSDictionary dictionaryWithDictionary:replaced];
}

#pragma mark - Height Width Calculation Methods

/**
 *  This method is used to calculate height of text given which fits in specific width having    font provided
 *
 *  @param text       Text to calculate height of
 *  @param widthValue Width of container
 *  @param font       Font size of text
 *
 *  @return Height required to fit given text in container
 */

+ (CGFloat)findHeightForText:(NSString *)text havingWidth:(CGFloat)widthValue andFont:(UIFont *)font {
    CGSize size = CGSizeZero;
    if (text) {
#ifdef __IPHONE_7_0
        CGRect frame = [text boundingRectWithSize:CGSizeMake(widthValue, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:font } context:nil];
        size = CGSizeMake(frame.size.width, frame.size.height);
#else
        size = [text sizeWithFont:font constrainedToSize:CGSizeMake(widthValue, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
#endif
    }
    return size.height;
}

/**
 *  This method is used to calculate height of attributed text given which fits in specific width having font provided
 *
 *  @param text       Attributed text to calculate height of
 *  @param widthValue Width of container
 *  @param font       Font size of text
 *
 *  @return Height required to fit given text in container
 */
+ (CGFloat)findAttributedHeightForText:(NSAttributedString *)text havingWidth:(CGFloat)widthValue andFont:(UIFont *)font {
    CGFloat result = font.pointSize + 4;
    //CGFloat width = widthValue;
    if (text)
        result = (ceilf(CGRectGetHeight([text boundingRectWithSize:CGSizeMake(widthValue, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil])) + 1);
    
    return result;
}

//+ (CGFloat)findAttributedHeightForText:(NSAttributedString *)text havingWidth:(CGFloat)widthValue andFont:(UIFont *)font {
//	CGFloat result = font.pointSize + 4;
//	//CGFloat width = widthValue;
//	if (text) {
//		//CGSize textSize = { width, CGFLOAT_MAX };       //Width and height of text area
//		CGSize size;
//		CGRect frame = [text boundingRectWithSize:CGSizeMake(widthValue, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading context:nil];
//		size = CGSizeMake(frame.size.width, frame.size.height + 1);
//		result = MAX(size.height, result); //At least one row
//	}
//	return result;
//}

+ (CGFloat)findWidthForText:(NSString *)text havingMaximumHeight:(CGFloat)heightValue andFont:(UIFont *)font {
    CGSize size = CGSizeZero;
    if (text) {
#ifdef __IPHONE_7_0
        CGRect frame = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, heightValue) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:font } context:nil];
        size = CGSizeMake(frame.size.width, frame.size.height + 1);
#else
        size = [text sizeWithFont:font constrainedToSize:CGSizeMake(CGFLOAT_MAX, heightValue) lineBreakMode:NSLineBreakByWordWrapping];
#endif
    }
    return size.width;
}

+ (NSInteger)findNumOfLinesForText:(NSString *)string havingSize:(CGSize)size havingFont:(UIFont *)font {
    CTFontRef fnt;
    CFAttributedStringRef str;
    CTFramesetterRef fs;
    
    fnt = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, NULL);
    str = CFAttributedStringCreate(kCFAllocatorDefault, (CFStringRef)string, (CFDictionaryRef)[NSDictionary dictionaryWithObjectsAndKeys:(__bridge id)fnt, kCTFontAttributeName, nil]);
    fs = CTFramesetterCreateWithAttributedString(str);
    CFRange r = { 0, 0 };
    CFRange res = { 0, 0 };
    CTFramesetterSuggestFrameSizeWithConstraints(fs, r, NULL, size, &res);
    return res.length;
}

#pragma mark - Number Methods

+ (NSString *)suffixNumber:(NSNumber *)number {
    if (!number)
        return @"";
    long long num = [number longLongValue];
    if (num < 1000) {
        return [NSString stringWithFormat:@"%lld", num];
    }
    int exp = (int)(log(num) / log(1000));
    NSArray *units = @[@"k", @"m", @"g", @"t", @"p", @"e"];
    return [NSString stringWithFormat:@"%.0f%@", (num / pow(1000, exp)), [units objectAtIndex:(exp - 1)]];
}

+ (NSString *)getPriceFromNumber:(NSString *)price {
    if (priceFormatter == nil) {
        priceFormatter =  [[NSNumberFormatter alloc] init];
        [priceFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        priceFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [priceFormatter setMaximumFractionDigits:0];
    }
    
    NSString *strTxt = [[price stringByReplacingOccurrencesOfString:@"," withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet symbolCharacterSet]];
    NSString *numberString = [priceFormatter stringFromNumber:@([strTxt longLongValue])];
    return numberString;
}

+ (NSString *)getPriceFromNumberWithFraction:(NSNumber *)price {
    if (priceFormatter == nil) {
        priceFormatter =  [[NSNumberFormatter alloc] init];
        [priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        priceFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    }
    [priceFormatter setMaximumFractionDigits:2];
    NSString *currencyNumb = [priceFormatter stringFromNumber:price];
    return currencyNumb;
}

+ (NSString *)convertStringToPhoneNumber:(NSString *)phoneStr {
    if (phoneStr != nil && phoneStr.length >= 10) {
        phoneStr = [phoneStr stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d{3})(\\d{4})" withString:@"$1-$2-$3" options:NSRegularExpressionSearch range:NSMakeRange(0, [phoneStr length])];
    }
    return phoneStr;
}

#pragma mark - String & AttributedString Methods

+ (NSString *)removeCommaFromString:(NSString *)str {
    return allTrim([[str stringByReplacingOccurrencesOfString:@"," withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet symbolCharacterSet]]);
}

+ (NSString *)getTrimmedString:(NSString *)string {
    NSArray *arrayString = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    arrayString = [self arrayAfterRemovingEmptyObjects:arrayString];
    return [arrayString componentsJoinedByString:@" "];
}

+ (NSAttributedString *)getHTMLText:(NSString *)text withAlignment:(NSTextAlignment)alignment {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:alignment];
    NSDictionary *dictAttrib = @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding) };
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithData:[text dataUsingEncoding:NSUTF8StringEncoding] options:dictAttrib documentAttributes:nil error:nil];
    [attributedText addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attributedText.length)];
    return attributedText;
}

+ (NSMutableAttributedString *)setBaseLineForString:(NSString *)string andFont:(UIFont *)font {
    return [[NSMutableAttributedString alloc] initWithString:string attributes:@{ NSFontAttributeName:font, NSForegroundColorAttributeName:[UIColor whiteColor], NSBaselineOffsetAttributeName:@1.5 }];
}

+ (NSMutableAttributedString *)createAttributedString:(NSString *)string andFont:(UIFont *)font andColor:(UIColor *)color {
    NSMutableAttributedString *mutableAttString = [[NSMutableAttributedString alloc] initWithString:string];
    [mutableAttString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, string.length)];
    [mutableAttString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, string.length)];
    return mutableAttString;
}

+ (NSMutableAttributedString *)createAttributedString:(NSString *)baseString withSubString:(NSString *)subString withBaseFont:(UIFont *)baseFont withSubFont:(UIFont *)subFont withBaseColor:(UIColor *)baseColor andSubColor:(UIColor *)subColor {
    NSMutableAttributedString *mutableAttString = [[NSMutableAttributedString alloc] initWithString:baseString];
    [mutableAttString addAttribute:NSFontAttributeName value:baseFont range:NSMakeRange(0, baseString.length)];
    [mutableAttString addAttribute:NSForegroundColorAttributeName value:baseColor range:NSMakeRange(0, baseString.length)];
    
    NSRange range = NSMakeRange(0, baseString.length);
    while (range.location != NSNotFound) {
        range = [baseString rangeOfString:subString options:0 range:range];
        if (range.location != NSNotFound) {
            [mutableAttString addAttribute:NSFontAttributeName value:subFont range:range];
            [mutableAttString addAttribute:NSForegroundColorAttributeName value:subColor range:range];
            range = NSMakeRange(range.location + range.length, baseString.length - (range.location + range.length));
        }
    }
    
    return mutableAttString;
}

#pragma mark - String-NSDate Conversion Methods

+ (NSDate *)nsDateFromString:(NSString *)string usingDateFormat:(NSString *)dateFormat {
    static NSDateFormatter *formatter = nil;
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
    }
    [formatter setDateFormat:dateFormat];
    NSDate *date = [formatter dateFromString:string];
    return date;
}

+ (NSString *)nsStringFromDate:(NSDate *)date andToFormatString:(NSString *)formatString {
    static NSDateFormatter *formatter = nil;
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
    }
    [formatter setDateFormat:formatString];
    NSString *dateString = [formatter stringFromDate:date];
    return dateString;
}

+ (NSDate *)dateFromStringDateFormate:(NSString *)time format:(NSString *)format Type:(int)type {
    NSLog(@"Sever Time ==== %@", time);
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    NSDateFormatter *formatterUtc = [[NSDateFormatter alloc] init];
    [formatterUtc setDateFormat:format];
    [formatterUtc setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [formatterUtc setLocale:enUSPOSIXLocale];
    
    // Cast the input string to NSDate
    NSDate *utcDate = [formatterUtc dateFromString:time];
    NSLog(@"UTC Date Time ==== %@", utcDate);
    
    // Set up an NSDateFormatter for the device's local time zone
    NSDateFormatter *formatterLocal = [[NSDateFormatter alloc] init];
    [formatterLocal setDateFormat:format];
    [formatterLocal setTimeZone:[NSTimeZone localTimeZone]];
    [formatterLocal setLocale:enUSPOSIXLocale];
    NSLog(@"UTC string ==== %@", [formatterLocal stringFromDate:utcDate]);
    
    // Create local NSDate with time zone difference
    NSDate *localDate = [formatterUtc dateFromString:[formatterLocal stringFromDate:utcDate]];
    NSLog(@"Local Date Time ==== %@", localDate);
    
    if (type == 0) {
        return utcDate;
    }
    else
        return localDate;
}

+ (NSString *)getLocaleDate:(NSDate *)date forDateFormat:(NSString *)dateFormat calendar:(NSString *)calendarIdentifier {
    NSDateFormatter *newDateFormatter = [[NSDateFormatter alloc] init];
    newDateFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:calendarIdentifier]; //NSPersianCalendar
    newDateFormatter.dateFormat = dateFormat;
    return [newDateFormatter stringFromDate:date];
}

+ (NSString *)getTotalAudioDuration:(NSString *)strURLAudio {
    AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:strURLAudio] options:nil];
    CMTime audioDuration = audioAsset.duration;
    float durationTotalAudio = CMTimeGetSeconds(audioDuration);
    return [NSString stringWithFormat:@"%f", durationTotalAudio];
}

+ (NSInteger)daysBetweenDate:(NSDate *)fromDateTime andDate:(NSDate *)toDateTime {
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}
#pragma mark - UIImage and UIColor Methods

+ (void)loadFromSenderURL:(NSURL *)urlSender withReceiverURL:(NSURL *)urlReceiver callback:(void (^)(UIImage *imgSender, UIImage *imgReceiver))callback {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        NSData *imageData1 = [NSData dataWithContentsOfURL:urlSender];
        NSData *imageData2 = [NSData dataWithContentsOfURL:urlReceiver];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image1 = [UIImage imageWithData:imageData1];
            UIImage *image2 = [UIImage imageWithData:imageData2];
            callback(image1, image2);
        });
    });
}

+ (void)generateVideoThumbnailUsingBlock:(NSString *)strVideoURL withHandler:(void (^)(UIImage *imageF))compilation {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        AVURLAsset *asset1 = [[AVURLAsset alloc] initWithURL:[NSURL URLWithString:[strVideoURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] options:nil];
        AVAssetImageGenerator *generate1 = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
        generate1.appliesPreferredTrackTransform = YES;
        NSError *err = NULL;
        CMTime time = CMTimeMake(1, 2);
        CGImageRef oneRef = [generate1 copyCGImageAtTime:time actualTime:NULL error:&err];
        UIImage *one = [[UIImage alloc] initWithCGImage:oneRef];
        compilation(one);
        CGImageRelease(oneRef);
    });
}

+ (void)rotateLayerInfinite:(CALayer *)layer {
    CABasicAnimation *rotation;
    rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotation.fromValue = [NSNumber numberWithFloat:0];
    rotation.toValue = [NSNumber numberWithFloat:(2 * M_PI)];
    rotation.duration = 0.7f; // Speed
    rotation.repeatCount = HUGE_VALF; // Repeat forever. Can be a finite number.
    [layer removeAllAnimations];
    [layer addAnimation:rotation forKey:@"Spin"];
}

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert {
    NSString *noHashString = [stringToConvert stringByReplacingOccurrencesOfString:@"#" withString:@""]; // remove the #
    NSScanner *scanner = [NSScanner scannerWithString:noHashString];
    [scanner setCharactersToBeSkipped:[NSCharacterSet symbolCharacterSet]]; // remove + and $
    unsigned hex;
    if (![scanner scanHexInt:&hex]) return nil;
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f];
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (NSString *)encodeToBase64String:(UIImage *)image {
    return [UIImageJPEGRepresentation(image, 0.8) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

+ (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData {
    NSData *data = [[NSData alloc]initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}

+ (UIImage *)scaleAndRotateImage:(UIImage *)image {
    int kMaxResolution = 1242; // Or whatever
    CGImageRef imgRef = image.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width / height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch (orient) {
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //[self setRotatedImage:imageCopy];
    return imageCopy;
}

+ (UIImage *)imageRotatedByDegrees:(UIImage *)oldImage deg:(CGFloat)degrees {
    //Calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, oldImage.size.width, oldImage.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(degrees * M_PI / 180);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    //Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    //Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width / 2, rotatedSize.height / 2);
    
    //Rotate the image context
    CGContextRotateCTM(bitmap, (degrees * M_PI / 180));
    
    //Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-oldImage.size.width / 2, -oldImage.size.height / 2, oldImage.size.width, oldImage.size.height), [oldImage CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)circularScaleAndCropImage:(UIImage *)image frame:(CGRect)frame {
    // This function returns a newImage, based on image, that has been:
    // - scaled to fit in (CGRect) rect
    // - and cropped within a circle of radius: rectWidth/2
    
    //Create the bitmap graphics context
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(frame.size.width, frame.size.height), NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //Get the width and heights
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    CGFloat rectWidth = frame.size.width;
    CGFloat rectHeight = frame.size.height;
    
    //Calculate the scale factor
    CGFloat scaleFactorX = rectWidth / imageWidth;
    CGFloat scaleFactorY = rectHeight / imageHeight;
    
    //Calculate the centre of the circle
    CGFloat imageCentreX = rectWidth / 2;
    CGFloat imageCentreY = rectHeight / 2;
    
    // Create and CLIP to a CIRCULAR Path
    // (This could be replaced with any closed path if you want a different shaped clip)
    CGFloat radius = rectWidth / 2;
    CGContextBeginPath(context);
    CGContextAddArc(context, imageCentreX, imageCentreY, radius, 0, 2 * M_PI, 0);
    CGContextClosePath(context);
    CGContextClip(context);
    
    //Set the SCALE factor for the graphics context
    //All future draw calls will be scaled by this factor
    CGContextScaleCTM(context, scaleFactorX, scaleFactorY);
    
    // Draw the IMAGE
    CGRect myRect = CGRectMake(1, 1, imageWidth, imageHeight);
    [image drawInRect:myRect];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark - Thumbnail Methods

+ (void)setThumbnailTo:(UIImageView *)imgV {
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *strTempPath = [DocumentsDirectoryPath() stringByAppendingPathComponent:@"FOLDER_NAME"];
    NSString *strFilePath = [strTempPath stringByAppendingPathComponent:@"FILE_NAME"];
    
    BOOL fileExists = [fileMgr fileExistsAtPath:strFilePath];
    if (fileExists == NO) {
        NSLog(@"not exist");
    }
    else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            __block UIImage *image;
            @autoreleasepool {
                /* obtain the image here */
                
                
                NSURL *fileUrl = [NSURL fileURLWithPath:strFilePath];
                AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:fileUrl options:nil];
                AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
                generator.appliesPreferredTrackTransform = TRUE;
                CMTime thumbTime = kCMTimeZero;
                AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) {
                    if (result != AVAssetImageGeneratorSucceeded) {
                        NSLog(@"couldn't generate thumbnail, error:%@", error);
                        [self setThumbnailTo:imgV];
                    }
                    else {
                        image = [UIImage imageWithCGImage:im];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            imgV.image = image;
                        });
                    }
                };
                
                CGSize maxSize = CGSizeMake(imgV.frame.size.width * 2, imgV.frame.size.height * 2);
                generator.maximumSize = maxSize;
                [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
            }
        });
    }
}

+ (void)setVideoThumbnail:(UIImageView *)imgV withURL:(NSString *)strURL {
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL fileExists = [fileMgr fileExistsAtPath:strURL];
    if (fileExists == NO) {
        NSLog(@"not exist");
    }
    else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            __block UIImage *image;
            @autoreleasepool {
                /* obtain the image here */
                
                NSURL *fileUrl = [NSURL fileURLWithPath:strURL];
                
                AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:fileUrl options:nil];
                AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
                generator.appliesPreferredTrackTransform = TRUE;
                CMTime thumbTime = kCMTimeZero;
                AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) {
                    if (result != AVAssetImageGeneratorSucceeded) {
                        NSLog(@"couldn't generate thumbnail, error:%@", error);
                        [self setVideoThumbnail:imgV withURL:strURL];
                    }
                    else {
                        image = [UIImage imageWithCGImage:im];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            imgV.image = image;
                        });
                    }
                };
                
                CGSize maxSize = CGSizeMake(imgV.frame.size.width * 2, imgV.frame.size.height * 2);
                generator.maximumSize = maxSize;
                [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
            }
        });
    }
}

+ (UIImage *)generatePDFThumbnail:(NSString *)strPath withSize:(CGSize)size {
    NSURL *pdfFileUrl = [NSURL fileURLWithPath:strPath];
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((CFURLRef)pdfFileUrl);
    CGPDFPageRef page;
    
    CGRect aRect = CGRectMake(0, 0, size.width, size.height); // thumbnail size
    UIGraphicsBeginImageContext(aRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIImage *thumbnailImage;
    
    //NSUInteger totalNum = CGPDFDocumentGetNumberOfPages(pdf);
    
    for (int i = 0; i < 1; i++) {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 0.0, aRect.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        CGContextSetGrayFillColor(context, 1.0, 1.0);
        CGContextFillRect(context, aRect);
        
        // Grab the first PDF page
        page = CGPDFDocumentGetPage(pdf, i + 1);
        CGAffineTransform pdfTransform = CGPDFPageGetDrawingTransform(page, kCGPDFMediaBox, aRect, 0, true);
        // And apply the transform.
        CGContextConcatCTM(context, pdfTransform);
        
        CGContextDrawPDFPage(context, page);
        
        // Create the new UIImage from the context
        thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
        
        //Use thumbnailImage (e.g. drawing, saving it to a file, etc)
        
        CGContextRestoreGState(context);
    }
    UIGraphicsEndImageContext();
    CGPDFDocumentRelease(pdf);
    
    return thumbnailImage;
}

#pragma mark - Static Data Methods

/**
 *  To get list of fonts available in system
 */

+ (void)dumpAllFonts {
    for (NSString *familyName in[UIFont familyNames]) {
        for (NSString *fontName in[UIFont fontNamesForFamilyName:familyName]) {
            NSLog(@"%@", fontName);
        }
    }
}

+ (NSArray *)getCountryList {
    NSMutableArray *countries = [NSMutableArray arrayWithCapacity:[[NSLocale ISOCountryCodes] count]];
    NSLocale *persianLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    for (NSString *countryCode in[NSLocale ISOCountryCodes]) {
        NSString *identifier = [NSLocale localeIdentifierFromComponents:[NSDictionary dictionaryWithObject:countryCode forKey:NSLocaleCountryCode]];
        NSString *country = [persianLocale displayNameForKey:NSLocaleIdentifier value:identifier];
        [countries addObject:country];
    }
    [countries sortUsingSelector:@selector(caseInsensitiveCompare:)];
    return countries;
}

@end
