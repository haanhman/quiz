//
//  WordModel.h
//  WordMachine
//
//  Created by anhmantk on 10/3/14.
//  Copyright 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "WMDatabase.h"

@interface GroupModel : WMDatabase {
    
}
+(GroupModel *)getInstance;

-(void)insertGroup: (NSArray*)list_group;
-(NSArray*)getListGroups;
-(void)updateGroup:(NSString*)filed andId: (int)gid andValue: (int)value;
-(int)nextGroup: (int)current_weight;
-(NSDictionary*)getGroup: (int)gid;
-(NSArray*)getGroupToDownload;
@end
