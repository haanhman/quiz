//
//  WordModel.m
//  WordMachine
//
//  Created by anhmantk on 10/3/14.
//  Copyright 2014 Apportable. All rights reserved.
//

#import "GroupModel.h"


@implementation GroupModel

static GroupModel *instance;

+(GroupModel *)getInstance{
    if (!instance) {
        instance=[[GroupModel alloc] init];
    }
    return instance;
}

-(id)init{
    self=[super init];
    return self;
}

-(void)insertGroup: (NSArray*)list_group {
    if(list_group == nil) {
        NSLog(@"Khong co du lieu de insert");
        return;
    }
    
    [self openConnect];
    sqlite3_stmt *compiledStatement;

    NSString *query = @"INSERT OR IGNORE INTO tbl_group (id, name, weight, download, heart, unlock) VALUES (?, ?, ?, 0, 0, 0)";
    const char *sqlStatement=(const char *) [query UTF8String];
    NSDictionary *dict;
    for(int i =0; i < list_group.count; i++) {
        dict = list_group[i];
        if(sqlite3_prepare_v2(db,sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
            //id,
            sqlite3_bind_int(compiledStatement, 1, [[dict valueForKey:@"id"] intValue]);
            sqlite3_bind_text(compiledStatement, 2, [[dict valueForKey:@"name"] UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int(compiledStatement, 3, [[dict valueForKey:@"weight"] intValue]);
            if (sqlite3_step(compiledStatement) != SQLITE_DONE) {
                NSLog(@"SQL prepare failed: %s", sqlite3_errmsg(db));
            }
        }
    }
    [self closeConnect:compiledStatement];
}

-(NSArray*)getListGroups {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    [self openConnect];
    sqlite3_stmt *compiledStatement;
    
    NSString *query=[NSString stringWithFormat:@"SELECT id, name, download, heart, unlock, weight, play_done FROM tbl_group ORDER BY weight"];
    const char *sqlStatement=(const char *) [query UTF8String];
    
    if(sqlite3_prepare_v2(db,sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
        while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
            NSMutableDictionary *dict_row = [[NSMutableDictionary alloc] init];
            [dict_row setValue:[NSNumber numberWithInt:sqlite3_column_int(compiledStatement, 0)] forKey:@"id"];
            [dict_row setValue:[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,1)] forKey:@"name"];
            [dict_row setValue:[NSNumber numberWithInt:sqlite3_column_int(compiledStatement, 2)] forKey:@"download"];
            [dict_row setValue:[NSNumber numberWithInt:sqlite3_column_int(compiledStatement, 3)] forKey:@"heart"];
            [dict_row setValue:[NSNumber numberWithInt:sqlite3_column_int(compiledStatement, 4)] forKey:@"unlock"];
            [dict_row setValue:[NSNumber numberWithInt:sqlite3_column_int(compiledStatement, 5)] forKey:@"weight"];
            [dict_row setValue:[NSNumber numberWithInt:sqlite3_column_int(compiledStatement, 6)] forKey:@"play_done"];
            [list addObject:dict_row];
        }
    }
    [self closeConnect:compiledStatement];
    return list;
}

-(NSDictionary*)getGroup: (int)gid {
    NSMutableDictionary *dict_row = [[NSMutableDictionary alloc] init];
    [self openConnect];
    sqlite3_stmt *compiledStatement;
    
    NSString *query=[NSString stringWithFormat:@"SELECT id, name, download, heart, unlock, weight FROM tbl_group WHERE id = %d", gid];
    const char *sqlStatement=(const char *) [query UTF8String];
    
    if(sqlite3_prepare_v2(db,sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
        if(sqlite3_step(compiledStatement) == SQLITE_ROW) {
            [dict_row setValue:[NSNumber numberWithInt:sqlite3_column_int(compiledStatement, 0)] forKey:@"id"];
            [dict_row setValue:[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,1)] forKey:@"name"];
            [dict_row setValue:[NSNumber numberWithInt:sqlite3_column_int(compiledStatement, 2)] forKey:@"download"];
            [dict_row setValue:[NSNumber numberWithInt:sqlite3_column_int(compiledStatement, 3)] forKey:@"heart"];
            [dict_row setValue:[NSNumber numberWithInt:sqlite3_column_int(compiledStatement, 4)] forKey:@"unlock"];
            [dict_row setValue:[NSNumber numberWithInt:sqlite3_column_int(compiledStatement, 5)] forKey:@"weight"];
        }
    }
    [self closeConnect:compiledStatement];
    return dict_row;
}


-(void)updateGroup:(NSString*)filed andId: (int)gid andValue: (int)value{
    [self openConnect];
    sqlite3_stmt *compiledStatement;
    NSString *query = [NSString stringWithFormat:@"UPDATE tbl_group SET %@ = %d WHERE id = ?", filed, value];
    const char *sqlStatement=(const char *) [query UTF8String];
    
    if(sqlite3_prepare_v2(db,sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
        sqlite3_bind_int(compiledStatement, 1, gid);
        if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
            NSLog(@"Update thanh cong: %d", gid);
        } else {
            NSLog(@"SQL prepare failed: %s", sqlite3_errmsg(db));
        }
    }
    
    [self closeConnect:compiledStatement];
}

-(int)nextGroup: (int)current_weight{
    int gid = 0;
    [self openConnect];
    sqlite3_stmt *compiledStatement;
    NSString *query = [NSString stringWithFormat:@"SELECT id FROM tbl_group WHERE weight > %d ORDER BY weight LIMIT 1", current_weight];
    const char *sqlStatement=(const char *) [query UTF8String];
    if(sqlite3_prepare_v2(db,sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
        if(sqlite3_step(compiledStatement) == SQLITE_ROW) {
            gid = [[NSNumber numberWithInt:sqlite3_column_int(compiledStatement, 0)] intValue];
        }
    }
    [self closeConnect:compiledStatement];
    return gid;
}


-(NSArray*)getGroupToDownload {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    [self openConnect];
    sqlite3_stmt *compiledStatement;
    
    NSString *query=[NSString stringWithFormat:@"SELECT id FROM tbl_group WHERE download = 0 AND id <> %d ORDER BY weight", df_group_default];
    const char *sqlStatement=(const char *) [query UTF8String];
    
    if(sqlite3_prepare_v2(db,sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
        while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
            [list addObject:[NSNumber numberWithInt:sqlite3_column_int(compiledStatement, 0)]];
        }
    }
    [self closeConnect:compiledStatement];
    return list;
}

@end
