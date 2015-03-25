//
//  WMDatabase.m
//  WordMachine
//
//  Created by anhmantk on 10/2/14.
//  Copyright 2014 Apportable. All rights reserved.
//

#import "WMDatabase.h"

@implementation WMDatabase

-(id)init{
    if (self=[super init]) {
        sqlite_path =[NSString stringWithFormat:@"%@/database.sqlite",df_documentsDirectory];
    }
    return self;
}

-(void)openConnect {
    if(sqlite3_open([sqlite_path UTF8String], &db) == SQLITE_OK) {
        NSLog(@"Connect database success");
    } else {
        NSLog(@"Can't open %@", sqlite_path);
        return;
    }
}
-(void)closeConnect: (sqlite3_stmt*)compiledStatement {
    sqlite3_finalize(compiledStatement);
    sqlite3_close(db);
}

@end