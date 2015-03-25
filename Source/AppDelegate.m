/*
 * SpriteBuilder: http://www.spritebuilder.org
 *
 * Copyright (c) 2012 Zynga Inc.
 * Copyright (c) 2013 Apportable Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "cocos2d.h"

#import "AppDelegate.h"
#import "CCBuilderReader.h"

#import <CommonCrypto/CommonDigest.h>
#import <AdSupport/AdSupport.h>
#import "QuangCao.h"
#import "ZipArchive.h"
#import "CCAnimationCache.h"
#import "CCTextureCache.h"
#import "GroupModel.h"
#import "HomeScene.h"
#import <MessageUI/MFMailComposeViewController.h>


@implementation AppController {
    id<ALSoundSource>background_music;
    NSMutableArray *list_group_id;
    int download_gid;
    NSURLConnection *connect;
    NSFileHandle *_filehandle;
    float fileSize;
    int download_length;
    NSTimer *timer;
    BOOL ChartboostReady;
    int ChartboostAction;
    QuangCao *quangcao;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Configure Cocos2d with the options set in SpriteBuilder
    NSString* configPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Published-iOS"]; // TODO: add support for Published-Android support
    configPath = [configPath stringByAppendingPathComponent:@"configCocos2d.plist"];
    
    NSMutableDictionary* cocos2dSetup = [NSMutableDictionary dictionaryWithContentsOfFile:configPath];
    [cocos2dSetup setObject:@GL_DEPTH24_STENCIL8_OES forKey:@"CCSetupDepthFormat"];
    [cocos2dSetup setObject:@NO forKey:@"CCSetupShowDebugStats"];
    // Note: this needs to happen before configureCCFileUtils is called, because we need apportable to correctly setup the screen scale factor.
#ifdef APPORTABLE
    if([cocos2dSetup[CCSetupScreenMode] isEqual:CCScreenModeFixed])
        [UIScreen mainScreen].currentMode = [UIScreenMode emulatedMode:UIScreenAspectFitEmulationMode];
    else
        [UIScreen mainScreen].currentMode = [UIScreenMode emulatedMode:UIScreenScaledAspectFitEmulationMode];
#endif
    
    // Configure CCFileUtils to work with SpriteBuilder
    [CCBReader configureCCFileUtils];
    
    CCFileUtils *fileutils=[CCFileUtils sharedFileUtils];
    fileutils.searchPath=
    [NSArray arrayWithObjects:
     [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Published-iOS"],
     [[NSBundle mainBundle] resourcePath],
     df_documentsDirectory,
     nil];
    
    // Do any extra configuration of Cocos2d here (the example line changes the pixel format for faster rendering, but with less colors)
    //[cocos2dSetup setObject:kEAGLColorFormatRGB565 forKey:CCConfigPixelFormat];
    
    [self setupCocos2dWithOptions:cocos2dSetup];
    
    user_default = [NSUserDefaults standardUserDefaults];
    if([user_default boolForKey:@"first_run"] == NO) {
        [self initFirstRun];
    }
    BOOL music = [user_default boolForKey:@"music"];
    [appcontroller enableBackgroundMusic:music];
    [self initChartboost];
    [self khoitaoQuangCao];
    return YES;
}

-(void)initFirstRun {
    [user_default setValue:@YES forKey:@"first_run"];
    [user_default setValue:@YES forKey:@"music"];
    [user_default setValue:@YES forKey:@"show_time"];
    [user_default setValue:@"2" forKey:@"min"];
    [user_default setValue:@"9" forKey:@"max"];
    
    [self checkInstallData];
    
    //copy file install vao thu muc Document va giai nen
    NSFileManager *fileManager = [NSFileManager defaultManager];
    

    NSString *strTarget=[NSString stringWithFormat:@"%@/%@", df_documentsDirectory, df_install_file];
    NSString *strfileSource=[[[NSBundle mainBundle] bundlePath] stringByAppendingFormat:@"/%@",df_install_file];
    BOOL exits;
    
    exits = [fileManager fileExistsAtPath:strTarget];
    if (!exits){
        if ([fileManager copyItemAtPath:strfileSource toPath:strTarget error:nil]) {
            [self unZipFileInDocument:df_install_file];
        }
    }    
}

//MARK: install data
-(void)checkInstallData {
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSString *database = [NSString stringWithFormat:@"%@/database.sqlite", df_documentsDirectory];
    if([fileManager fileExistsAtPath:database]) {
        //xoa di neu co roi
        [fileManager removeItemAtPath:database error:nil];
    }
    NSString *dataPath=[[[NSBundle mainBundle] resourcePath] stringByAppendingFormat:@"/database.sqlite"];
    [fileManager copyItemAtPath:dataPath toPath:database error:nil];
    
    NSArray *list_group = [NSArray arrayWithContentsOfFile:fullpath(@"group.plist")];
    if(list_group.count > 0) {
        [[GroupModel getInstance] insertGroup:list_group];
    }
}

-(void)detectDeviceType {
    CGSize screenSize = [[CCDirector sharedDirector] viewSize];
    NSLog(@"Scene width: %f", screenSize.width);
    NSLog(@"df_documentsDirectory: %@", df_documentsDirectory);
    
    float tile = screenSize.height/screenSize.width;
    //iphone 4
    device_type = @"phone";
    if(tile > 1.33f && tile < 1.5f) {
        //ipad
        device_type = @"ipad";
    }else if(tile > 1.7f) {
        //iphone 5
        device_type = @"phonehd";
    }
    NSLog(@"device_type: %@", device_type);
}

- (CCScene*) startScene
{
    ChartboostReady = YES;
    [self performSelector:@selector(downloadContent) withObject:nil afterDelay:5.0f];
    [self detectDeviceType];
    return [CCBReader loadAsScene:@"ccbi/home/HomeScene"];
    //return [CCBReader loadAsScene:@"MainScene"];
}

//MARK: send mail
-(void)GoSendMail{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate =(id)self;
        
        
        [mailViewController setSubject:[NSString stringWithFormat:df_app_name]];
        
        NSMutableString *emailBody = [[NSMutableString alloc] initWithString:@"<html><body>"];
        
        
        
//        NSArray *toRecipients = [NSArray arrayWithObject: @"support@monkeyjunior.com"];
//        [mailViewController setToRecipients:toRecipients];
        [mailViewController setMessageBody:emailBody isHTML:YES];
        
        AppController *appct=(AppController*)[[UIApplication sharedApplication] delegate];
        
        [appct.window.rootViewController presentModalViewController:mailViewController animated:YES];
        mailViewController=nil;
        
    }
    
    else {
        
        UIAlertView *alertview=[[UIAlertView alloc] initWithTitle:@"Login Mail" message:@"You need to set up your mail on this device first." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
        [alertview show];
        
    }
}
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    AppController *appct=(AppController*)[[UIApplication sharedApplication] delegate];
    [appct.window.rootViewController dismissModalViewControllerAnimated:YES];
    
}

//MARK: clear cache
-(void)clearDataCache{
    [[CCDirector sharedDirector] purgeCachedData];
    
    [[CCTextureCache sharedTextureCache] removeAllTextures];
    [CCTextureCache purgeSharedTextureCache];
    
    [CCSpriteFrameCache purgeSharedSpriteFrameCache];
    [[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
    
    [CCAnimationCache purgeSharedAnimationCache];
    
    NSLog(@"===> clean cache <===");
}

//MARK: backgroud musci
-(void)enableBackgroundMusic: (BOOL)bat {
    if(bat) {
        background_music = [[OALSimpleAudio sharedInstance] playEffect:@"bg_music.mp3" volume:0.3 pitch:1 pan:1 loop:YES];
    } else {
        [background_music stop];
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

- (NSMutableArray*)shuffleArray:(NSArray*)array {
    
    NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:array];
    
    for(NSUInteger i = [array count]; i > 1; i--) {
        NSUInteger j = arc4random_uniform(i);
        [temp exchangeObjectAtIndex:i-1 withObjectAtIndex:j];
    }
    
    return temp;
}


//MARK: download content
-(void)downloadContent {
    list_group_id = [NSMutableArray arrayWithArray:[[GroupModel getInstance] getGroupToDownload]];
    if(list_group_id.count == 0) {
        return;
    }
    [self activeDownload];
}
-(void)activeDownload {
    if(list_group_id.count == 0) {
        NSLog(@"Down het du lieu roi");
        return;
    }
    download_gid = [list_group_id[0] intValue];
    [list_group_id removeObjectAtIndex:0];
    NSURL *download_url = [NSURL URLWithString:[NSString stringWithFormat:df_download_url, download_gid]];
    NSDictionary *dictInfo = [NSDictionary dictionaryWithContentsOfURL:download_url];
    if(dictInfo == nil) {
        return;
    }
    NSString *strurl = [dictInfo valueForKey:@"url"];
    NSLog(@"Download: %@", strurl);
    if (connect == nil) {
        download_length = 0;
        NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:strurl]];
        connect=[NSURLConnection connectionWithRequest:request delegate:(id)self];
        
        timer=[NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(TinhToanSize) userInfo:nil repeats:YES];
        
        NSString *df_pathdownload = [NSString stringWithFormat:@"%@/group_%d.zip",df_documentsDirectory,download_gid];
        [[NSFileManager defaultManager] removeItemAtPath:df_pathdownload error:nil];
        [[NSFileManager defaultManager] createFileAtPath:df_pathdownload contents:nil attributes:nil];
        _filehandle =[NSFileHandle fileHandleForUpdatingAtPath:df_pathdownload] ;
        [connect start];
    }
    
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
    if([self unZipFileInDocument:[NSString stringWithFormat:@"group_%d.zip", download_gid]]) {
        //update download done
        [[GroupModel getInstance] updateGroup:@"download" andId:download_gid andValue:1];
        connect = nil;
        [self performSelector:@selector(activeDownload) withObject:nil afterDelay:5];
        CCNode *scene = [[CCDirector sharedDirector] runningScene].children[0];
        NSString *class_name = NSStringFromClass([scene class]);
        if([class_name isEqualToString:@"HomeScene"]) {
            HomeScene *home = (HomeScene*)scene;
            [home loadData];
        }
    }
}

//MARK: chartsboots
-(void)initChartboost {
    [Chartboost startWithAppId:CHARTBOOST_APP_ID appSignature:CHARTBOOST_APP_SIGNATURE delegate:self];
}


-(void)showChartboost: (int)actionID {
    [Chartboost showInterstitial:CBLocationStartup];
    ChartboostAction = actionID;
    NSLog(@"Quang cao san sang: %d", ChartboostReady);
}

#pragma mark - ChartboostDelegate

- (BOOL)shouldRequestInterstitialsInFirstSession {
    return YES;
}


// Called after an interstitial has been displayed on the screen.
- (void)didDisplayInterstitial:(CBLocation)location {
    NSLog(@"**** Chartboost Interstitial displayed.");
}


// Called after an interstitial has attempted to load from the Chartboost API
// servers but failed.
- (void)didFailToLoadInterstitial:(CBLocation)location
                        withError:(CBLoadError)error {
    ChartboostReady = NO;
    [self processAction];
    NSLog(@"Khong the load quang cao tu chartboots");
}

// Called after a click is registered, but the user is not forwarded to the App Store.
- (void)didFailToRecordClick:(CBLocation)location
                   withError:(CBClickError)error {
    NSLog(@"====> didFailToRecordClick");
}

// Called after an interstitial has been dismissed.
- (void)didDismissInterstitial:(CBLocation)location {
    NSLog(@"====> didDismissInterstitial");
}

// Called after an interstitial has been closed.
- (void)didCloseInterstitial:(CBLocation)location {
    NSLog(@"**** Chartboost Interstitial closed.");
    [self processAction];
}

// Called after an interstitial has been clicked.
- (void)didClickInterstitial:(CBLocation)location {
    NSLog(@"====> didClickInterstitial");
}

-(void)processAction {
    switch (ChartboostAction) {
        case 1:
            [self enterGamePlay];
            break;
        case 2:
            [self playNextGroup];
            break;
        case 3:
            [self playAgain];
            break;
        case 4:
            [self gotoHomePage];
            break;
            
    }
}

-(void)enterGamePlay {
    CCNode *node = [[CCDirector sharedDirector] runningScene].children[0];
    NSString *cl = NSStringFromClass([node class]);
    if([cl isEqualToString:@"HomeScene"]) {
        
        NSString *ccbi_file = @"ccbi/gameplay/game";
        [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:ccbi_file] withTransition:[CCTransition transitionFadeWithColor:[CCColor whiteColor] duration:0.4]];
        
        HomeScene *home = (HomeScene*)node;
        [home homeCleanCache];
    }
}

-(void)playNextGroup {
    NSString *ccbi_file = @"ccbi/gameplay/game";
    if([[UserInfo getInstance].dictGroup valueForKey:@"download"] == 0) {
        ccbi_file = @"ccbi/home/HomeScene";
    }
    
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:ccbi_file] withTransition:[CCTransition transitionFadeWithColor:[CCColor whiteColor] duration:0.4]];
}

-(void)playAgain {
    NSString *ccbi_file = @"ccbi/gameplay/game";
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:ccbi_file] withTransition:[CCTransition transitionFadeWithColor:[CCColor whiteColor] duration:0.4]];
}

-(void)gotoHomePage {
    [appcontroller enableBackgroundMusic:[user_default boolForKey:@"music"]];
    NSString *ccbi_file = @"ccbi/home/HomeScene";
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:ccbi_file] withTransition:[CCTransition transitionFadeWithColor:[CCColor whiteColor] duration:0.4]];
    return;
}

//MARK: adMod
#pragma mark Quang cao
-(void)RemoveAdv{
    if(quangcao != nil) {
        [quangcao removeTimer];
        [quangcao removeFromSuperview];
    }
}

-(void)khoitaoQuangCao{
    BOOL isBuy = [[NSUserDefaults standardUserDefaults] boolForKey:@"buyfinish"];
    if(isBuy) {
        return;
    }
    NSLog(@"khoi tao quang cao");
    quangcao=[[QuangCao alloc] init];
    quangcao.tag=1111;
    quangcao.backgroundColor=[UIColor clearColor];
    [window_.rootViewController.view addSubview:quangcao];
}
-(void)ShowFullScreen{
    BOOL isBuy = [[NSUserDefaults standardUserDefaults] boolForKey:@"buyfinish"];
    if(isBuy) {
        return;
    }
    NSLog(@"Show full quang cao");
    [quangcao ShowFullScreen];
}

-(void)setAdsPercent: (float)percent {
    self.ads_percent = percent;
}

-(void)setHaveAds: (BOOL)haveads {
    self.have_ads = haveads;
}

@end
