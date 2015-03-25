//
//  GameItem.m
//  quiz
//
//  Created by anhmantk on 2/24/15.
//  Copyright 2015 Apportable. All rights reserved.
//

#import "GameItem.h"
#import "PlayGame.h"

@implementation GameItem {
    CCSprite *img, *icon;
}

-(void)onEnter {
    [super onEnter];
    NSString *img_path = [NSString stringWithFormat:@"image/%@", [self.dict valueForKey:@"img_path"]];
    img.spriteFrame = [CCSpriteFrame frameWithImageNamed:img_path];
    img.scale = 110/img.contentSize.width;
    self.userInteractionEnabled = YES;
}

-(void)removeCard {
    CCAnimationManager *ani = self.userObject;
    [ani runAnimationsForSequenceNamed:@"hide"];
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    [[OALSimpleAudio sharedInstance] playEffect:@"click_ingame.mp3"];
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    
    self.userInteractionEnabled = NO;
    NSString *icon_bg;
    if(self.isTrue == NO) {
        icon_bg = @"img/gameplay/game/3.png";
        PlayGame *pr = (PlayGame*)self.parent.parent;
        [pr missHeart];
        [[OALSimpleAudio sharedInstance] playEffect:@"sai.mp3" volume:0.6f pitch:1.0f pan:0.0f loop:NO];
    } else {
        icon_bg = @"img/gameplay/game/4.png";
        [self scheduleOnce:@selector(nextCard) delay:0.5f];
        [[OALSimpleAudio sharedInstance] playEffect:@"dung.mp3"];
        PlayGame *pr = (PlayGame*)self.parent.parent;
        [pr disableAllItem];
    }
    
    
    
    icon.spriteFrame = [CCSpriteFrame frameWithImageNamed:icon_bg];
    icon.visible = YES;
}

-(void)nextCard {
    PlayGame *pr = (PlayGame*)self.parent.parent;
    [pr nextCard];
}

@end
