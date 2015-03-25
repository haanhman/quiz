//
//  UserInfo.h
//  WordMachine
//
//  Created by anhmantk on 10/14/14.
//  Copyright 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface UserInfo : NSObject {
    
}
+(UserInfo *)getInstance;
@property(nonatomic, retain)NSArray *listCard;
@property(nonatomic, assign)int lose_type;
@property(nonatomic, assign)int gid;
@property(nonatomic, assign)int total_heart;
@property(nonatomic, assign)BOOL isFinish;
@property(nonatomic, retain)NSDictionary *dictGroup ;

@end
