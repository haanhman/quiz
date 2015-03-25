//
//  CustomButton.m
//  Edu
//
//  Created by Sơn Lê Khắc on 6/3/14.
//  Copyright 2014 Apportable. All rights reserved.
//

#import "CustomButton.h"

@implementation CustomButton{
    
}


-(void)onEnter{
    [super onEnter];
    [self enableTouch];
}
-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
}

- (void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    [self disableTouch];
    [[OALSimpleAudio sharedInstance] playEffect:@"click_touch.mp3"];
    float current=self.scale;
    CCActionScaleTo *sc1=[CCActionScaleTo actionWithDuration:0.15 scale:current+0.15];
    CCActionScaleTo *sc2=[CCActionScaleTo actionWithDuration:0.15 scale:current];
    [self runAction:[CCActionSequence actionOne:sc1 two:sc2]];
    [self scheduleOnce:@selector(LoadActionView) delay:0.3f];
    [self scheduleOnce:@selector(enableTouch) delay:0.3f];
}

-(void)disableTouch {
    self.userInteractionEnabled = NO;
}

-(void)enableTouch {
    self.userInteractionEnabled = YES;
}

-(void)LoadActionView{
    NSString *base_node = @"BaseNode";
    BaseNode *mainsc=(BaseNode *)self.parent;
    if (![mainsc.name isEqualToString:base_node]) {
        mainsc=(BaseNode *)self.parent.parent;
        if (![mainsc.name isEqualToString:base_node]) {
            mainsc=(BaseNode *)self.parent.parent.parent;
            if (![mainsc.name isEqualToString:base_node]) {
                mainsc=(BaseNode *)self.parent.parent.parent.parent;
                if (![mainsc.name isEqualToString:base_node]) {
                    mainsc=(BaseNode *)self.parent.parent.parent.parent.parent;
                }
            }
        }
    }
    [mainsc ActionClickButton:self];
}

@end


