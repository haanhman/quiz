//
//  BaseNode.h
//  WordMachine
//
//  Created by anhmantk on 11/22/14.
//  Copyright 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
@class CustomButton;
@interface BaseNode : CCNode {
    
}
-(void)removeAllElement;
-(void)ActionClickButton:(CustomButton*)bt;
@end
