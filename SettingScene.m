//
//  SettingScene.m
//  quiz
//
//  Created by anhmantk on 2/23/15.
//  Copyright 2015 Apportable. All rights reserved.
//

#import "SettingScene.h"


@implementation SettingScene {
    NSUserDefaults *userDefault;
    BOOL show_time;
    BOOL music;
}

-(void)onEnter {
    [super onEnter];
    userDefault = [NSUserDefaults standardUserDefaults];
    show_time = [userDefault boolForKey:@"show_time"];
    music = [userDefault boolForKey:@"music"];
    [self activeButton];
}

-(void)activeButton {
    NSString *bg_img = music == YES ? @"img/setting/on.png" : @"img/setting/off.png";
    CCSprite *mbtn = (CCSprite*)[self getChildByName:@"music" recursively:YES];
    mbtn.spriteFrame = [CCSpriteFrame frameWithImageNamed:bg_img];
    
    bg_img = show_time == YES ? @"img/setting/on.png" : @"img/setting/off.png";
    CCSprite *tbtn = (CCSprite*)[self getChildByName:@"time" recursively:YES];
    tbtn.spriteFrame = [CCSpriteFrame frameWithImageNamed:bg_img];
    
    
    NSArray *list = [self getChildByName:@"min_group" recursively:YES].children;
    NSString *bg;
    CCLabelTTF *label;
    NSString *min = [userDefault valueForKey:@"min"];
    for (CCSprite *sprite in list) {
        label = (CCLabelTTF*)sprite.children[0];
        if([label.string isEqualToString:min]) {
            bg = @"img/setting/7.png";
        } else {
            bg = @"img/setting/8.png";
        }
        sprite.spriteFrame = [CCSpriteFrame frameWithImageNamed:bg];
    }
    
    list = [self getChildByName:@"max_group" recursively:YES].children;
    NSString *max = [userDefault valueForKey:@"max"];
    for (CCSprite *sprite in list) {
        label = (CCLabelTTF*)sprite.children[0];
        if([label.string isEqualToString:max]) {
            bg = @"img/setting/7.png";
        } else {
            bg = @"img/setting/8.png";
        }
        sprite.spriteFrame = [CCSpriteFrame frameWithImageNamed:bg];
    }
    
}

-(void)ActionClickButton:(CustomButton *)bt {
    NSLog(@"name: %@", bt.name);
    
    if([bt.name isEqualToString:@"black"]) {
        NSString *ccbi_file = @"ccbi/home/HomeScene";
        [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:ccbi_file] withTransition:[CCTransition transitionFadeWithColor:[CCColor whiteColor] duration:0.4]];
        return;
    }
    
    
    if([bt.name isEqualToString:@"min"]) {
        
        int max_option = [[userDefault valueForKey:@"max"] intValue];
        
        CCLabelTTF *label = (CCLabelTTF*)bt.children[0];
        NSString *min = label.string;
        int min_option = [min intValue];
        if(min_option > max_option) {
            return;
        }
        
        [userDefault setValue:min forKey:@"min"];
        [userDefault synchronize];
        
        NSArray *list = bt.parent.children;
        NSString *bg;
        for (CCSprite *sprite in list) {
            label = (CCLabelTTF*)sprite.children[0];
            if([label.string isEqualToString:min]) {
                bg = @"img/setting/7.png";
            } else {
                bg = @"img/setting/8.png";
            }
            sprite.spriteFrame = [CCSpriteFrame frameWithImageNamed:bg];
        }
        return;
    }
    
    if([bt.name isEqualToString:@"max"]) {
        int min_option = [[userDefault valueForKey:@"min"] intValue];
        CCLabelTTF *label = (CCLabelTTF*)bt.children[0];
        NSString *max = label.string;
        int max_option = [max intValue];
        if(max_option < min_option) {
            return;
        }
        [userDefault setValue:max forKey:@"max"];
        [userDefault synchronize];
        
        NSArray *list = bt.parent.children;
        NSString *bg;
        for (CCSprite *sprite in list) {
            label = (CCLabelTTF*)sprite.children[0];
            if([label.string isEqualToString:max]) {
                bg = @"img/setting/7.png";
            } else {
                bg = @"img/setting/8.png";
            }
            sprite.spriteFrame = [CCSpriteFrame frameWithImageNamed:bg];
        }
        return;
        
    }
    
    
    if([bt.name isEqualToString:@"music"]) {
        music = !music;
        NSString *bg_img = music == YES ? @"img/setting/on.png" : @"img/setting/off.png";
        bt.spriteFrame = [CCSpriteFrame frameWithImageNamed:bg_img];
        [userDefault setValue:@(music) forKey:@"music"];
        [userDefault synchronize];
        [appcontroller enableBackgroundMusic:music];
        return;
    }
    
    if([bt.name isEqualToString:@"time"]) {
        show_time = !show_time;
        
        NSString *bg_img = show_time == YES ? @"img/setting/on.png" : @"img/setting/off.png";
        bt.spriteFrame = [CCSpriteFrame frameWithImageNamed:bg_img];
        
        [userDefault setValue:@(show_time) forKey:@"show_time"];
        [userDefault synchronize];
        return;
    }
    
    if([bt.name isEqualToString:@"rate_app"]) {
        [self rateApp];
        return;
    }
    if([bt.name isEqualToString:@"mail_us"]) {
        [appcontroller GoSendMail:1];
        return;
    }
    
    if([bt.name isEqualToString:@"mail_to"]) {
        [appcontroller GoSendMail:2];
        return;
    }
    if([bt.name isEqualToString:@"our_store"]) {
        NSString *ccbi_file = @"moreapp/moreapp";
        [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:ccbi_file] withTransition:[CCTransition transitionFadeWithColor:[CCColor whiteColor] duration:0.4]];
        return;
    }
}

-(void)rateApp {
    NSLog(@"rateApp");
    [userDefault setValue:@YES forKey:@"rated"];
    [userDefault synchronize];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:df_urlrateapp]];
}

@end
