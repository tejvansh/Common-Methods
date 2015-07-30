//
//  AFAPIClient.h
//
//  Created by Tejvansh Singh Chhabra on 18/5/15.
//  Copyright (c) 2015 Tejvansh Singh Chhabra. All rights reserved.
//

#import "Constant.h"
#import "AFHTTPRequestOperationManager.h"

@interface AFAPIClient : AFHTTPRequestOperationManager

	typedef void (^AFCompletionHandler)(BOOL success, id result, NSError *error);

+ (instancetype)sharedClient;

@property (nonatomic, readwrite, copy) AFCompletionHandler completionHandler;

- (void)cancelAllHTTPOperationsWithPath:(NSString *)path;

@end
