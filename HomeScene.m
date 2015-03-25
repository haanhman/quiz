//
//  HomeScene.m
//  quiz
//
//  Created by anhmantk on 2/23/15.
//  Copyright 2015 Apportable. All rights reserved.
//

#import "HomeScene.h"
#import "HomeItem.h"
#import "RatePopup.h"
#import "GroupModel.h"
@implementation HomeScene {
    CCNodeColor *stencil;
    CCNode *listNode;
    CCClippingNode *cliper;
    float paddingBotton;
    float paddingLeft;
    CCScrollView *scroll_view;
    CGSize screenSize;
    float full_scroll_height;
}

-(void)didLoadFromCCB {
    BOOL first_run = [user_default boolForKey:@"first_run"];
    if(!first_run) {
        return;
    }
    int update_time = [[user_default valueForKey:@"update_time"] intValue];
    int unixTime =  [[NSDate date] timeIntervalSince1970];
    
    if((unixTime - update_time) > df_update_time) {
        //chay update
        NSLog(@"sync server");
        NSURL *url = [NSURL URLWithString:df_update_url];
        NSArray *list_group = [NSArray arrayWithContentsOfURL:url];
        if(list_group.count > 0) {
            NSLog(@"list_group: %@", list_group);
            [[GroupModel getInstance] insertGroup:list_group];
            [user_default setValue:[NSNumber numberWithInt:unixTime] forKey:@"update_time"];
            [user_default synchronize];
        }
    }
}

-(void)onEnter {
    [super onEnter];
    [self loadData];
}

-(void)loadData {
    NSLog(@"Load data");
    float stencil_height = 72.0f;//phone
    if([device_type isEqualToString:@"phonehd"]) {
        stencil_height = 76.0f;//phonehd
    }else if([device_type isEqualToString:@"ipad"]) {
        stencil_height = 73.0f;//ipad
    }
    NSLog(@"stencil_height: %f", stencil_height);
    stencil = (CCNodeColor*)[self getChildByName:@"stencil_node" recursively:YES];
    stencil.contentSize = CGSizeMake(1, stencil_height/100.0f);
    stencil.opacity = 0.0f;
    
    screenSize = [[CCDirector sharedDirector] viewSize];
    
    [listNode removeAllChildrenWithCleanup:YES];
    scroll_view = nil;
    
    listNode = [CCNode node];
    [self refreshListNode];
    if(listNode == nil) {
        return;
    }
    
    cliper = [CCClippingNode clippingNodeWithStencil:stencil];
    [cliper setAlphaThreshold:0.0f];
    cliper.zOrder = 0;
    [self addChild:cliper];
    
    float x = stencil.contentSize.width * screenSize.width;
    float y = stencil.contentSize.height * screenSize.height;
    
    
paddingBotton = stencil.position.y * screenSize.height - stencil.contentSize.height * stencil.anchorPoint.y;
    //    paddingLeft = stencil.position.x * screenSize.width - stencil.contentSize.width * stencil.anchorPoint.x;
    
    //paddingBotton = 0;
    paddingLeft = 0;
    if([device_type isEqualToString:@"ipad"]) {
        paddingLeft = 5;
    }
    scroll_view = [[CCScrollView alloc] initWithContentNode:listNode];
    scroll_view.contentSizeType = CCSizeTypePoints;
    scroll_view.contentSize = CGSizeMake(x, y);
    scroll_view.position = ccp(paddingLeft, paddingBotton);
    scroll_view.horizontalScrollEnabled = NO;
    scroll_view.delegate = (id)self;
    
    [cliper addChild:scroll_view];
    
    if([[user_default valueForKey:@"scroll_y"] floatValue] > 0) {
        scroll_view.scrollPosition = ccp(0, [[user_default valueForKey:@"scroll_y"] floatValue]);
    }
    
    [self getChildByName:@"layer_bottom" recursively:YES].zOrder = 10;
    [self getChildByName:@"no_touch" recursively:YES].zOrder = 10;
    [self getChildByName:@"more_app" recursively:YES].zOrder = 11;
    [self getChildByName:@"setting" recursively:YES].zOrder = 11;
}

-(void)refreshListNode {
    NSArray *list_card = [[GroupModel getInstance] getListGroups];
    if(list_card.count <= 0) {
        list_card = [NSArray arrayWithContentsOfFile:fullpath(@"group.plist")];
    }
    
    //NSLog(@"list_card: %@", list_card);
    
    HomeItem *home_item;
    float item_scale = 0.89f;
    
    float paddingX = 0;
    float paddingY = 5;
    if([device_type isEqualToString:@"ipad"]) {
        item_scale = 0.95f;
        paddingX = 15;
        paddingY = 5;
    }
    
    float item_weight = 120.0f*item_scale;
    float item_height = 115.0f*item_scale;
    int total = list_card.count;
    float total_page =  ceilf(total/3.0f);
    full_scroll_height = total_page * item_height + (total_page * 5) + 35;
    listNode.contentSize = CGSizeMake(screenSize.width, full_scroll_height);
    NSLog(@"full_scroll_height: %f", full_scroll_height);
    
    float x = item_weight/2;
    float y = full_scroll_height - item_height/2;
    int i = 1;
    for (NSDictionary *dict in list_card) {
        home_item = (HomeItem*)[CCBReader load:@"ccbi/home/HomeItem"];
        home_item.scale = item_scale;
        home_item.dict = dict;
        home_item.position = ccp(x, y);
        home_item.anchorPoint = ccp(0.5, 0.5);
        [listNode addChild:home_item];
        if(i % 3 == 0 && i > 0) {
            x = item_weight/2;
            y -= item_height + paddingY;
        } else {
            x += item_weight + paddingX;
        }
        i++;
    }
}


- (void)scrollViewDidEndDecelerating:(CCScrollView *)scrollView {
    [user_default setObject:[NSNumber numberWithFloat:scrollView.scrollPosition.y] forKey:@"scroll_y"];
    [user_default synchronize];
}

-(void)showRateApp {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if([[userDefault valueForKey:@"rated"] boolValue] == YES) {
        return;
    }
    
    int unixTime =  [[NSDate date] timeIntervalSince1970];
    int rate_time = [[userDefault valueForKey:@"rate_time"] intValue];
    
    int diff_time = 10;
    
    //neu nguoi dung click vao rate sau thi phai sau 4 ngay moi hien thi lai
    if([[userDefault valueForKey:@"rate_later"] boolValue] == YES) {
        diff_time = 86400*4;
    }
    
    if(unixTime-rate_time > diff_time) {
        
        RatePopup *rate_popup = (RatePopup*)[CCBReader load:@"ccbi/RateApp"];
        rate_popup.zOrder = 20;
        [self addChild:rate_popup];
        //luu thoi gian lan hien thi cuoi cung
        [userDefault setValue:[NSNumber numberWithInt:unixTime] forKey:@"rate_time"];
        [userDefault setValue:@NO forKey:@"rate_later"];
    }
    [userDefault synchronize];
}


-(void)onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    int total_finish = [[user_default valueForKey:@"total_finish"] intValue];
    if(total_finish > 0 && [UserInfo getInstance].isFinish == YES) {
        [self showRateApp];
    }
}

-(void)ActionClickButton:(CustomButton *)bt {
    if([bt.name isEqualToString:@"setting"]) {
        NSString *ccbi_file = @"ccbi/home/Setting";
        [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:ccbi_file] withTransition:[CCTransition transitionFadeWithColor:[CCColor whiteColor] duration:0.4]];
        [self homeCleanCache];
        return;
    }
    if([bt.name isEqualToString:@"more_app"]) {
        
        NSString *ccbi_file = @"moreapp/moreapp";
        [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:ccbi_file] withTransition:[CCTransition transitionFadeWithColor:[CCColor whiteColor] duration:0.4]];
        [self homeCleanCache];        
    }
}

-(void)homeCleanCache {
    stencil = nil;
    listNode = nil;
    cliper = nil;
    scroll_view = nil;
    [self removeAllElement];
}

@end
