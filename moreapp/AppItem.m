//
//  AppItem.m
//  DotGame
//
//  Created by anhmantk on 3/10/15.
//  Copyright 2015 Apportable. All rights reserved.
//

#import "AppItem.h"
#import "EarlyStartMoreApp.h"

@implementation AppItem {
    CCSprite *icon;
    CCLabelTTF *app_name;
    BOOL is_move;
}

-(void)onEnter {
    [super onEnter];
    app_name.string = [self.dict valueForKey:@"name"];
    
    if(app_name.contentSize.height > 33) {
        app_name.fontSize = 10.0f;
    }
    
    NSString *icon_frame = [NSString stringWithFormat:@"more_app/icon/%@", [self.dict valueForKey:@"icon"]];
    icon.spriteFrame = [CCSpriteFrame frameWithImageNamed:icon_frame];
    icon.scale = 60 / icon.contentSize.width;
    self.userInteractionEnabled = YES;
    
    int star = [[self.dict valueForKey:@"star"] intValue];
    for (int i = 1; i <= star; i++) {
        NSString *star_name = [NSString stringWithFormat:@"star_%d", i];
        [self getChildByName:star_name recursively:YES].visible = YES;
    }
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    is_move = NO;
}

-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
#if ANDROID
    is_move = YES;
#endif
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    if(is_move) {
        return;
    }
    NSString *app_url = [self.dict valueForKey:@"url"];    
    NSLog(@"app_url: %@", app_url);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:app_url]];
}


@end
