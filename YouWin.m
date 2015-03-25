//
//  YouWin.m
//  quiz
//
//  Created by anhmantk on 2/24/15.
//  Copyright 2015 Apportable. All rights reserved.
//

#import "YouWin.h"
#import "GroupModel.h"

@implementation YouWin {
    int next_gid;
}

-(void)onEnter {
    [super onEnter];
    int gid = [UserInfo getInstance].gid;
    int total_heart = [UserInfo getInstance].total_heart;
    [[GroupModel getInstance] updateGroup:@"heart" andId:gid andValue:total_heart];
    
    int weight = [[[UserInfo getInstance].dictGroup valueForKey:@"weight"] intValue];
    next_gid = [[GroupModel getInstance] nextGroup:weight];
    [[GroupModel getInstance] updateGroup:@"unlock" andId:next_gid andValue:1];
    
    int total_finish = [[user_default valueForKey:@"total_finish"] intValue];
    [user_default setValue:[NSNumber numberWithInt:total_finish+1] forKey:@"total_finish"];
    [user_default synchronize];
    [UserInfo getInstance].isFinish = YES;
}


-(void)ActionClickButton:(CustomButton *)bt {
    
    if([bt.name isEqualToString:@"play"]) {        
        NSString *plist_data = [NSString stringWithFormat:@"%@/group_%d.plist", df_documentsDirectory, next_gid];
        [UserInfo getInstance].listCard = [NSArray arrayWithContentsOfFile:plist_data];
        [UserInfo getInstance].gid = next_gid;
        [UserInfo getInstance].dictGroup = [[GroupModel getInstance] getGroup:next_gid];
        [appcontroller showChartboost:2];        
    }
    
}

-(void)onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    [[OALSimpleAudio sharedInstance] playEffect:@"you_win.mp3" volume:0.5f pitch:1.0f pan:0.0f loop:NO];
}


@end
