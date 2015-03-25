//
//  GameItem.h
//  quiz
//
//  Created by anhmantk on 2/24/15.
//  Copyright 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameItem : CCSprite {
    
}
@property(nonatomic, retain)NSDictionary *dict;
@property(nonatomic, assign)BOOL isTrue;
-(void)removeCard;
@end
