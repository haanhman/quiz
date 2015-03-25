//
//  QuangCao.m
//  DemoAdvertising
//
//  Created by Sơn Lê Khắc on 7/28/14.
//  Copyright (c) 2014 Sơn Lê Khắc. All rights reserved.
//

#import "QuangCao.h"
#import "GADBannerView.h"
#import "GADInterstitial.h"
#import <QuartzCore/QuartzCore.h>
@interface QuangCao()<GADInterstitialDelegate, GADBannerViewDelegate> {
    GADBannerView *mBannerView;
    GADInterstitial *mInterstitial;
    int cshow;
}


@end

float phanbiet =6.0f;


@implementation QuangCao {
    NSTimer *timer;
}

-(float)getWith{
    AppController *appcntroller=(AppController *)[[UIApplication sharedApplication] delegate];
    return appcntroller.window.rootViewController.view.frame.size.width;
}
-(float)getHeigh{
    AppController *appcntroller=(AppController *)[[UIApplication sharedApplication] delegate];
    return appcntroller.window.rootViewController.view.frame.size.height;
    
}
- (id)init
{
    CGRect rr;
    CGSize screenView = [[CCDirector sharedDirector] viewSize];
    
    int xx = 0;
    int xx2 = 0;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {
        xx = 30;
        xx2 = 30;
#if ANDROID
        xx = 28;
        xx2 = 40;
#endif
        rr=CGRectMake(0, 0, [self getWith], xx);
        [appcontroller setAdsPercent:xx2/screenView.height];
    }else{
        xx = 90;
        xx2 = 45;
#if ANDROID
        xx = 88;
        xx2 = 50;
#endif
        rr=CGRectMake(0, 0, [self getWith], xx);
        [appcontroller setAdsPercent:xx2/screenView.height];
    }
    
    
    self = [super initWithFrame:rr];
    
    if (self) {
        self.androiscreen=CGSizeMake(self.window.frame.size.width, self.window.frame.size.height);
        self.diagonalSize=4.0f;
#if ANDROID
        self.diagonalSize=[UIScreen mainScreen].diagonalSize;
        self.androiscreen=CGSizeMake([UIScreen mainScreen].physicalDpi*[UIScreen mainScreen].physicalSize.width, [UIScreen mainScreen].physicalDpi*[UIScreen mainScreen].physicalSize.height);
#endif
        [self KhoiTaoQuangCao];
    }
    return self;
}
-(void)KhoiTaoQuangCao{
    AppController *appcntroller=(AppController *)[[UIApplication sharedApplication] delegate];
#if  ANDROID
    if (self.diagonalSize>phanbiet) {
        mBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
        self.AdSize=CGSizeMake(appcntroller.window.rootViewController.view.frame.size.width, 90);
    }else{
        mBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
        self.AdSize=CGSizeMake(appcntroller.window.rootViewController.view.frame.size.width, 30);
    }
#else
    
    if ([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {
        self.AdSize=CGSizeMake([self getWith], 30);
        mBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
    }else{
        self.AdSize=CGSizeMake([self getWith], 90);
        mBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
    }
#endif
    
    mBannerView.adUnitID = df_idQuangCao;
    mBannerView.rootViewController = appcntroller.window.rootViewController;
    mBannerView.delegate = self;
    [self addSubview:mBannerView];
    GADRequest *request = [GADRequest request];
    
    float y=[self getHeigh]-self.frame.size.height/2;
    float x = [self getWith]/2;
    self.center=CGPointMake(x,y);
    NSLog(@"W: %f, H: %f", [self getWith], [self getHeigh]);
#if ANDROID
    mBannerView.center=CGPointMake(x,y);
    
#endif
    cshow=0;
    
    
    NSLog(@"thong tin: %f %f",[self getWith],[self getHeigh]);
    
    CGAffineTransform tr = CGAffineTransformScale(self.transform, 1, 1);
    self.transform = tr;
    
    
    
    [mBannerView loadRequest:request];
    [self loadInterstitial];
}
-(void)ShowFullScreen{
    if (mInterstitial.isReady) {
        [mInterstitial presentFromRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
    } else {
        timer=[NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(createThreadCheckReady) userInfo:nil repeats:YES];
    }
}


-(void)removeTimer {
    [timer invalidate];
}

//tao thread chay 1s check mInterstitial.isReady 1 lan neu ok thi show quang cao
-(void)createThreadCheckReady {
    NSLog(@"==> createThreadCheckReady");
    if (mInterstitial.isReady) {
        [mInterstitial presentFromRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
        [timer invalidate];
    }
}

#pragma mark - Private


- (void)loadInterstitial
{
    mInterstitial = [[GADInterstitial alloc] init];
    mInterstitial.adUnitID = df_idFulScreen;
    mInterstitial.delegate = self;
    [mInterstitial loadRequest:[GADRequest request]];
}
- (void)reloadInterstitial
{
    mInterstitial = nil;
    [self loadInterstitial];
}


#pragma mark - MPIntersitialAdControllerDelegate

- (void)interstitial:(GADInterstitial *)interstitial didFailToReceiveAdWithError:(GADRequestError *)error {
    [appcontroller setHaveAds:NO];
    NSLog(@"**** MoPub Interstitial load failed.:%@",error.userInfo);
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial {
    NSLog(@"**** MoPub Interstitial did load - load quang cao thanh cong.");
    NSLog(@"quang cao: %f", [appcontroller ads_percent]);
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)interstitial {
    [[NSUserDefaults standardUserDefaults] setValue:@YES forKey:@"play_finish"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"**** MoPub interstitialWillPresentScreen did load.");
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial {
    NSLog(@"tat quang cao");
    BOOL play_finish = [[[NSUserDefaults standardUserDefaults] valueForKey:@"play_finish"] boolValue];
    NSLog(@"play_finish: %d", play_finish);
    if(play_finish == YES) {
        [[NSUserDefaults standardUserDefaults] setValue:@NO forKey:@"play_finish"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [self reloadInterstitial];
}

- ( void ) onAdColonyAdAttemptFinished:(BOOL)shown inZone:( NSString * )zoneID {
    NSLog(@"adcolony recieved onAdColonyAdAttemptFinished in app");
}

- ( void ) onAdColonyAdStartedInZone:( NSString * )zoneID {
    NSLog(@"adcolony recieved onAdColonyAdStartedInZone in app");
}


#pragma -mark GADBannerViewDelegate

- (void)adViewDidReceiveAd:(GADBannerView *)view {
    
    NSLog(@"admobview did receivedAD");
    
    //NSLog(@"Man hinh android :%f %f, quang cao %f %f",self.frame.size.width,self.frame.size.height,view.frame.size.width,view.frame.size.height);
    
    cshow++;
    
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"admobview didFailToReceiveAdWithError");
}

- (void)adViewWillPresentScreen:(GADBannerView *)adView {
    NSLog(@"admobview adViewWillPresentScreen");
}

- (void)adViewWillDismissScreen:(GADBannerView *)adView {
    NSLog(@"admobview adViewWillDismissScreen");
}

- (void)adViewDidDismissScreen:(GADBannerView *)adView {
    NSLog(@"admobview adViewDidDismissScreen");
}

- (void)adViewWillLeaveApplication:(GADBannerView *)adView {
    NSLog(@"admobview adViewWillLeaveApplication");
}


@end
