//
//  NoTouch.m
//  WordMachine
//
//  Created by anhmantk on 10/9/14.
//  Copyright 2014 Apportable. All rights reserved.
//

#import "NoTouch.h"


@implementation NoTouch

-(void)onEnter {
    [super onEnter];
    self.userInteractionEnabled = YES;
    //self.zOrder = 20;
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
}
-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    
}
-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    NSLog(@"Vung khong cho phep touch");
}

@end
