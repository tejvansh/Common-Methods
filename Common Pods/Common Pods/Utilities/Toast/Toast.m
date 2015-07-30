//
//  Toast.m
//
//  Created by Aviel Gross on 7/15/13.
//  Copyright (c) 2013 Aviel Gross. All rights reserved.
//

#import "Toast.h"
#import <QuartzCore/QuartzCore.h>

@implementation Toast {
}

+ (Toast *)toastWithMessage:(NSString *)msg {
	static Toast *t = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
	    t = [[Toast alloc] init];
	    t.label = [[UILabel alloc] init];
	    t.label.layer.cornerRadius = 5.0;
	    t.label.layer.masksToBounds = YES;
	    t.label.lineBreakMode = 0;
	    t.label.textColor = [UIColor whiteColor];
	    t.label.numberOfLines = 0;
	    t.label.font = [UIFont systemFontOfSize:FONT_SIZE];
	    t.label.textAlignment = NSTextAlignmentCenter;
	    t.label.backgroundColor = [UIColor BACKGROUND_COLOR];
	});

	CGRect screen = [[UIScreen mainScreen] bounds];
	CGRect frame = [msg boundingRectWithSize:CGSizeMake(310, CGFLOAT_MAX)
	                                 options:NSStringDrawingUsesLineFragmentOrigin
	                              attributes:@{ NSFontAttributeName:[UIFont systemFontOfSize:FONT_SIZE] }
	                                 context:nil];
	CGSize size = frame.size;
	if (size.width > screen.size.width) {
		size.width = screen.size.width;
	}
	CGRect rect = CGRectMake((screen.size.width - size.width - LEFT_RIGHT_PADDING) / 2,
	                         screen.size.height - BOTTOM_MARGIN,
	                         size.width + LEFT_RIGHT_PADDING, size.height + TOP_BOTTOM_PADDING);

	t.message = msg;
	t.label.text = msg;
	t.label.frame = rect;
	return t;
}

- (void)showOnView:(UIView *)view {
	[self.label setAlpha:0];
	[view addSubview:self.label];
	[UIView animateWithDuration:FADE_IN_DURATION
	                 animations: ^{
	    [self.label setAlpha:1];
	}

	                 completion: ^(BOOL finished) {
	    [UIView animateWithDuration:FADE_OUT_DURATION
	                          delay:DELAY
	                        options:0
	                     animations: ^{ [self.label setAlpha:0]; }
	                     completion: ^(BOOL finished) {}
	    ];
	}];
}

@end
