//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
@implementation MainScene {
    
}

-(void)onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
}

-(void)showQuangCao {
    //[appcontroller showChartboost:10];
    NSString *ccbi_file = @"ccbi/home/HomeScene";
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:ccbi_file] withTransition:[CCTransition transitionFadeWithColor:[CCColor whiteColor] duration:0.4]];
}

@end
