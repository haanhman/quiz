//
//  RatePopup.m
//  FlashCard
//
//  Created by anhmantk on 12/17/14.
//  Copyright 2014 Apportable. All rights reserved.
//

#import "RatePopup.h"
#import "CustomButton.h"
@implementation RatePopup {
    
}

-(void)ActionClickButton:(CustomButton*)bt{
    if([bt.name isEqualToString:@"later"]) {
        [self maybeLater];
    }
    if([bt.name isEqualToString:@"rate"]) {
        [self rateApp];
    }
    [self removeFromParentAndCleanup:YES];
    [self removeAllElement];
}

-(void)maybeLater {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setValue:@YES forKey:@"rate_later"];
    [userDefault synchronize];
}

-(void)rateApp {
    NSLog(@"rateApp");
    [user_default setValue:@YES forKey:@"rated"];
    [user_default synchronize];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:df_urlrateapp]];
}

@end
