//
//  HomeItem.m
//  quiz
//
//  Created by anhmantk on 2/24/15.
//  Copyright 2015 Apportable. All rights reserved.
//

#import "HomeItem.h"
#import "HomeScene.h"

@implementation HomeItem {
    CCNode *tim, *download;
    CCSprite *icon;
    CCLabelTTF *lbl_name;
    int total_tim;
    CCSprite *background;
    int un_lock;
    int gid;
    BOOL is_move;
}

-(void)onEnter {
    [super onEnter];
    icon.visible = NO;
    gid = [[self.dict valueForKey:@"id"] intValue];
    un_lock = [[self.dict valueForKey:@"unlock"] intValue];
    if([[self.dict valueForKey:@"download"] intValue] == 0 && un_lock == 1) {
        download.visible = YES;
        tim.visible = NO;
        lbl_name.visible = NO;
        return;
    }
    if(([[self.dict valueForKey:@"download"] intValue] == 1 && un_lock == 1) || gid == df_group_default) {
        icon.visible = YES;
    }
    
    
    self.userInteractionEnabled = YES;
    
    
    if(gid == df_group_default) {
        un_lock = 1;
    }
    if(un_lock == 0) {
        [background removeAllChildrenWithCleanup:YES];
        background.spriteFrame = [CCSpriteFrame frameWithImageNamed:@"img/Home_screen/khoa.png"];
        return;
    }
    
    
    NSString *lbl_text = [self.dict valueForKey:@"name"];
    lbl_text = [lbl_text stringByReplacingOccurrencesOfString:@"**" withString:@"\n"];
    lbl_name.string = lbl_text;
    float scale = 75/lbl_name.contentSize.width;
    if(scale > 1) {
        scale = 1;
    }
    lbl_name.scale = scale;
    
    total_tim = [[self.dict valueForKey:@"heart"] intValue];
    [self activeTim];
}

-(void)activeTim {
    if(total_tim == 0 && [[self.dict valueForKey:@"play_done"] intValue] == 0) {
        [tim removeFromParentAndCleanup:YES];
        lbl_name.position = ccp(lbl_name.position.x, lbl_name.position.y-10);
        return;
    }
    int i = 1;
    NSString *bg;
    for (CCSprite *sprite in tim.children) {
        if(i <= total_tim) {
            bg = @"img/Home_screen/3.png";
        } else {
            bg = @"img/Home_screen/4.png";
        }
        sprite.spriteFrame = [CCSpriteFrame frameWithImageNamed:bg];
        i++;
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
    if(un_lock == 0) {
        return;
    }
    [appcontroller showChartboost:1];
    [[OALSimpleAudio sharedInstance] playEffect:@"click_touch.mp3"];
    [appcontroller enableBackgroundMusic:NO];
    NSString *plist_data = [NSString stringWithFormat:@"%@/group_%d.plist", df_documentsDirectory, gid];
    [UserInfo getInstance].listCard = [NSArray arrayWithContentsOfFile:plist_data];
    [UserInfo getInstance].gid = gid;
    [UserInfo getInstance].dictGroup = self.dict;
    [UserInfo getInstance].isFinish = NO;        
}

@end
