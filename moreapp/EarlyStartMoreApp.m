//
//  EarlyStartMoreApp.m
//  DotGame
//
//  Created by anhmantk on 3/10/15.
//  Copyright 2015 Apportable. All rights reserved.
//

#import "EarlyStartMoreApp.h"
#import "AppItem.h"
#import "ZipArchive.h"

@implementation EarlyStartMoreApp {
    CGSize sceneSize;
    float item_scale;
    
    CCNodeColor *stencil;
    CCNode *listNode;
    CCClippingNode *cliper;
    float paddingBotton;
    float paddingLeft;
    CCScrollView *scroll_view;
    NSMutableArray *listItem;
    
    //download
    NSURLConnection *connect;
    NSFileHandle *_filehandle;
    float fileSize;
    int download_length;
    NSTimer *timer;
    int moreapp_version;
    float sync_time;
    CCLabelTTF *lbl_loadding;
    int cot;
}

-(void)onEnter {
    [super onEnter];
    sync_time = 3600*24;
    cot = 2;
    sceneSize = [[CCDirector sharedDirector] viewSize];
    float item_weight = 168.0f;
    item_scale = sceneSize.width/(item_weight*cot);
    if(item_scale > 1) {
        item_scale = 1;
    } else {
        item_scale -= 0.05f;
    }
    NSLog(@"item_scale: %f", item_scale);
    listItem = [NSMutableArray array];
    [self loadData];
}

-(void)loadData {
    [self getChildByName:@"NoTouch" recursively:YES].zOrder = 1;
    [self getChildByName:@"free_app" recursively:YES].zOrder = 2;
    [self getChildByName:@"back" recursively:YES].zOrder = 2;
    stencil = (CCNodeColor*)[self getChildByName:@"stencil_node" recursively:YES];
    stencil.opacity = 0;
    listNode = [CCNode node];
    
    [self refreshListNode];
    if(listNode == nil) {
        return;
    }
    
    cliper = [CCClippingNode clippingNodeWithStencil:stencil];
    [cliper setAlphaThreshold:0.0f];
    cliper.zOrder = 0;
    [self addChild:cliper];
    
    float x = stencil.contentSize.width * sceneSize.width;
    float y = stencil.contentSize.height * sceneSize.height;
    
    scroll_view = [[CCScrollView alloc] initWithContentNode:listNode];
    scroll_view.contentSizeType = CCSizeTypePoints;
    scroll_view.contentSize = CGSizeMake(x, y);
    scroll_view.position = ccp(0, 0);
    scroll_view.horizontalScrollEnabled = NO;
    scroll_view.delegate = (id)self;
    [cliper addChild:scroll_view];
}

-(void)refreshListNode {
    if(listItem.count) {
        for (AppItem *item in listItem) {
            [item removeFromParentAndCleanup:YES];
        }
        [listItem removeAllObjects];
    }
    
    
    NSString *more_app_plist = [NSString stringWithFormat:@"%@/more_app/more_app.plist", df_documentsDirectory];
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:more_app_plist]) {
        NSLog(@"Sync server ...");
        sync_time = 1;
        NSString *fontName = @"moreapp/my_BerlinSansFB.ttf";
        lbl_loadding = [CCLabelTTF labelWithString:@"Loading..." fontName:fontName fontSize:20.0f];
        lbl_loadding.fontColor = [CCColor colorWithRed:0 green:193/255.0f blue:243/255.0f alpha:1];
        lbl_loadding.anchorPoint = ccp(0.5, 0.5);
        lbl_loadding.position = ccp(sceneSize.width/2, sceneSize.height/2);
        [self addChild:lbl_loadding];
        return;
    }
    
    NSArray *list_app = [NSArray arrayWithContentsOfFile:more_app_plist];
    if(list_app.count <= 0) {
        return;
    }
    //NSLog(@"list_app: %@", list_app);

    float item_weight = 168.0f * item_scale;
    float item_height = 82.0f * item_scale;
    NSLog(@"item_weight: %f", item_weight);
    NSLog(@"item_height: %f", item_height);
    int total = list_app.count;
    float total_page =  ceilf(total/(float)cot);
    float full_scroll_height = total_page * item_height + 100;
    listNode.contentSize = CGSizeMake(sceneSize.width, full_scroll_height);
    
    AppItem *app_item;
    float x = item_weight/2;
    float y = full_scroll_height - item_height/2;
    int i = 1;
    for (NSDictionary *dict in list_app) {
        int app_id = [[dict valueForKey:@"app_id"] intValue];
        if(app_id == AppId) {
            continue;
        }
        app_item = (AppItem*)[CCBReader load:@"moreapp/app"];
        app_item.dict = dict;
        app_item.scale = item_scale;
        app_item.position = ccp(x, y);
        app_item.anchorPoint = ccp(0.5, 0.5);
        [listNode addChild:app_item];
        [listItem addObject:app_item];
        if(i % cot == 0 && i > 0) {
            x = item_weight/2;
            y -= item_height + 6.0f;
        } else {
            x += item_weight + ((sceneSize.width-(item_weight*cot))/(cot-1));
        }
        i++;
    }
    [lbl_loadding removeFromParentAndCleanup:YES];
}

-(void)ActionClickButton:(CustomButton *)bt {
    if([bt.name isEqualToString:@"back"]) {
        NSString *ccbi_file = @"ccbi/home/HomeScene";
        [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:ccbi_file]];
        stencil = nil;
        listNode = nil;
        cliper = nil;
        scroll_view = nil;
        [self removeAllElement];
    }
    if([bt.name isEqualToString:@"free_app"]) {
        NSString *subscribe_url = @"http://www.monkeyjunior.com/subscribe";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:subscribe_url]];
    }
}

-(void)onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    moreapp_version = [[userDefault valueForKey:@"moreapp_version"] intValue];
    
    int unixTime =  [[NSDate date] timeIntervalSince1970];
    int moreapp_sync = [[userDefault valueForKey:@"moreapp_sync"] intValue];
    
    int diff_time = unixTime - moreapp_sync;
    if(diff_time <= sync_time) {
        return;
    }
    NSString *os = @"ios";
#if ANDROID
    os = @"amazon";
#if NOTAMAZON
    os = @"android";
#endif
#endif
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:df_moreapp_url, moreapp_version, os]];
    NSDictionary *dictInfo = [NSDictionary dictionaryWithContentsOfURL:url];
    if(dictInfo != nil && [[dictInfo valueForKey:@"status"] intValue] == 1) {
        [self activeDownload:[dictInfo valueForKey:@"url"]];
        moreapp_version = [[dictInfo valueForKey:@"version"] intValue];
    }
}

-(void)activeDownload: (NSString*)strurl {
    download_length = 0;
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:strurl]];
    connect=[NSURLConnection connectionWithRequest:request delegate:(id)self];
    
    timer=[NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(TinhToanSize) userInfo:nil repeats:YES];
    
    NSString *df_pathdownload = [NSString stringWithFormat:@"%@/more_app.zip",df_documentsDirectory];
    [[NSFileManager defaultManager] removeItemAtPath:df_pathdownload error:nil];
    [[NSFileManager defaultManager] createFileAtPath:df_pathdownload contents:nil attributes:nil];
    _filehandle =[NSFileHandle fileHandleForUpdatingAtPath:df_pathdownload] ;
    [connect start];
}


-(void)TinhToanSize {
    float percent = (download_length / 1024) / fileSize;
    percent *= 100;
    NSLog(@"percent: %f", percent);
}

#pragma mark -- download delagate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
    NSDictionary *dictDataTB=[HTTPResponse allHeaderFields];
    fileSize = [[dictDataTB valueForKey:@"Content-Length"] intValue] / 1024;
    int dungluong=[[dictDataTB valueForKey:@"Content-Length"] intValue]/1048576.0f;
    NSLog(@"start connect Update:%d Mb",dungluong);
    NSLog(@"Size:%f",fileSize);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"tai file co van de");
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    download_length += [data length];
    //NSLog(@"download_length: %d", download_length);
    if (_filehandle)  {
        [_filehandle seekToEndOfFile];
        
    } [_filehandle writeData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [_filehandle closeFile];
    NSLog(@"Download thanh cong");
    [timer invalidate];

    //unzip data
    if([self unZipFileInDocument:@"more_app.zip"]) {
        NSLog(@"Download moreapp thanh cong");
        connect = nil;
        int unixTime =  [[NSDate date] timeIntervalSince1970];
        NSUserDefaults *user_default = [NSUserDefaults standardUserDefaults];
        [user_default setValue:[NSNumber numberWithInt:moreapp_version] forKey:@"moreapp_version"];
        [user_default setValue:[NSNumber numberWithInt:unixTime] forKey:@"moreapp_sync"];
        [user_default synchronize];
        [self loadData];
    }
}

-(BOOL)unZipFileInDocument:(NSString*)fileUnzip{
    ZipArchive *currentZip = [[ZipArchive alloc] init];
    NSLog(@"File zip: %@", [df_documentsDirectory stringByAppendingPathComponent:fileUnzip]);
    BOOL blx=[currentZip UnzipOpenFile:[df_documentsDirectory stringByAppendingPathComponent:fileUnzip]];
    if (!blx) {
        NSLog(@"File zip co van de khong giai nen duoc.....");
        return NO;
    }
    NSFileManager *filemanager=[NSFileManager defaultManager];
    NSString *unzipPath = df_documentsDirectory;
    [currentZip UnzipFileTo:unzipPath overWrite:YES];
    NSString *folder=[df_documentsDirectory stringByAppendingString:@"/__MACOSX"];
    [filemanager removeItemAtPath:folder error:nil];
    [filemanager removeItemAtPath:[df_documentsDirectory stringByAppendingPathComponent:fileUnzip] error:nil];
    NSLog(@"Giai nen thanh cong ");
    return YES;
}

@end
