//
//  YouLose.m
//  quiz
//
//  Created by anhmantk on 2/24/15.
//  Copyright 2015 Apportable. All rights reserved.
//

#import "YouLose.h"


@implementation YouLose {
}

-(void)onEnter {
    [super onEnter];
    if([UserInfo getInstance].lose_type == 2) {
        CCSprite *lose_type = (CCSprite*) [self getChildByName:@"lose_type" recursively:YES];
        lose_type.spriteFrame = [CCSpriteFrame frameWithImageNamed:@"img/gameplay/time.png"];
    }
}


-(void)ActionClickButton:(CustomButton *)bt {
    if([bt.name isEqualToString:@"home"]) {
        [appcontroller showChartboost:4];        
    }
    
    if([bt.name isEqualToString:@"replay"]) {
        NSLog(@"Choi lai tu dau");
        int gid = [UserInfo getInstance].gid;
        NSString *plist_data = [NSString stringWithFormat:@"%@/group_%d.plist", df_documentsDirectory, gid];
        [UserInfo getInstance].listCard = [NSArray arrayWithContentsOfFile:plist_data];
        [appcontroller showChartboost:3];
    }
    
}

-(void)onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    if([UserInfo getInstance].lose_type == 2) {
        [[OALSimpleAudio sharedInstance] playEffect:@"lose_time.mp3"];
    } else {
        [[OALSimpleAudio sharedInstance] playEffect:@"lose_heart.mp3"];
    }
    
}

@end
