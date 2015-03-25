//
//  BaseNode.m
//  WordMachine
//
//  Created by anhmantk on 11/22/14.
//  Copyright 2014 Apportable. All rights reserved.
//

#import "BaseNode.h"


@implementation BaseNode {
    
}

-(void)onEnter{
    [super onEnter];
    self.name = @"BaseNode";
}

-(void)removeAllElement {
    NSArray *arr1 = self.children;
    for (CCNode *node1 in arr1) {
        [self showName:1 withName:node1.name];
        NSArray *arr2 = node1.children;
        for (CCNode *node2 in arr2) {
            [self showName:2 withName:node2.name];
            NSArray *arr3 = node2.children;
            for (CCNode *node3 in arr3) {
                [self showName:3 withName:node3.name];
                NSArray *arr4 = node3.children;
                for (CCNode *node4 in arr4) {
                    [self showName:4 withName:node4.name];
                    NSArray *arr5 = node4.children;
                    for (CCNode *node5 in arr5) {
                        [self showName:5 withName:node5.name];
                        NSArray *arr6 = node5.children;
                        for (CCNode *node6 in arr6) {
                            [self showName:6 withName:node6.name];
                            NSArray *arr7 = node6.children;
                            for (CCNode *node7 in arr7) {
                                [self showName:7 withName:node7.name];
                                NSArray *arr8 = node7.children;
                                for (CCNode *node8 in arr8) {
                                    [self showName:8 withName:node8.name];
                                    [node8 stopAllActions];
                                    [node8 removeAllChildrenWithCleanup:YES];
                                }
                                [node7 stopAllActions];
                                [node7 removeAllChildrenWithCleanup:YES];
                            }
                            [node6 stopAllActions];
                            [node6 removeAllChildrenWithCleanup:YES];
                        }
                        [node5 stopAllActions];
                        [node5 removeAllChildrenWithCleanup:YES];
                    }
                    [node4 stopAllActions];
                    [node4 removeAllChildrenWithCleanup:YES];
                }
                [node3 stopAllActions];
                [node3 removeAllChildrenWithCleanup:YES];
            }
            [node2 stopAllActions];
            [node2 removeAllChildrenWithCleanup:YES];
        }
        [node1 stopAllActions];
        [node1 removeAllChildrenWithCleanup:YES];
    }
    [self unscheduleAllSelectors];
    [self stopAllActions];
    [self removeAllChildrenWithCleanup:YES];
    self.userObject=nil;
    [appcontroller clearDataCache];
}

-(void)showName: (int)index withName: (NSString*)name {
    //NSLog(@"name_%d: %@", index,name);
}

-(void)dealloc {
    NSLog(@"==> dealoc: %@", NSStringFromClass([self class]));
}

-(void)ActionClickButton:(CustomButton*)bt{
    
}

@end
