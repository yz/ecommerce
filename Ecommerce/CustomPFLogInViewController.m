//
//  CustomPFLogInViewController.m
//  Ecommerce
//
//  Created by Ashwinkarthik Srinivasan on 4/16/15.
//  Copyright (c) 2015 Ashwinkarthik Srinivasan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ParseUI/PFLogInViewController.h>

@interface CustomPFLogInViewController : PFLogInViewController

@end

@implementation CustomPFLogInViewController

- (void)_loginDidFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(logInViewController:didFailToLogInWithError:)]) {
        [self.delegate logInViewController:self didFailToLogInWithError:error];
    }
}

@end