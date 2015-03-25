//
//  UserInfo.m
//  WordMachine
//
//  Created by anhmantk on 10/14/14.
//  Copyright 2014 Apportable. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo {

}
static UserInfo *instance;

+(UserInfo *)getInstance{
    if (!instance) {
        instance=[[UserInfo alloc] init];
    }    
    return instance;
}

-(id)init{
    self=[super init];
    return self;
}

@end
