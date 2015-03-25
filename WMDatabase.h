//
//  WMDatabase.h
//  WordMachine
//
//  Created by anhmantk on 10/2/14.
//  Copyright 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import <sqlite3.h>

@interface WMDatabase : NSObject {
    sqlite3 *db;
    NSString *sqlite_path;
}

-(void)openConnect;
-(void)closeConnect: (sqlite3_stmt*)compiledStatement;
@end
