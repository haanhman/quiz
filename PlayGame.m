//
//  PlayGame.m
//  quiz
//
//  Created by anhmantk on 2/24/15.
//  Copyright 2015 Apportable. All rights reserved.
//

#import "PlayGame.h"
#import "GameItem.h"

@implementation PlayGame {
    float content_height;
    CCNodeColor *content_node;
    CCLabelTTF *thoigian, *lbl_card_name;
    int phut, giay;
    float total_second;
    CCNode *tim;
    NSTimer *timer;
    CGSize sceneSize;
    CCProgressNode *progress;
    int answerDone;
    NSMutableArray *listCard;
    int count_card;
    NSArray *list_data;
    int total_heart;
    int dunglientuc;
    BOOL isFalse;
    int count_card_index;
    NSMutableArray *count_item;
    id<ALSoundSource>time_out;
}

-(void)didLoadFromCCB {
    lbl_card_name.visible = NO;
    sceneSize = [[CCDirector sharedDirector] viewSize];
    content_height = 73.0f;
    if([device_type isEqualToString:@"phonehd"]) {
        content_height = 77.0f;
    }else if([device_type isEqualToString:@"ipad"]) {
        content_height = 75.0f;
    }
    
    NSArray *option_tmp = @[@2, @4, @6, @9];
    count_item = [NSMutableArray array];
    int min = [[user_default valueForKey:@"min"] intValue];
    int max = [[user_default valueForKey:@"max"] intValue];
    for(int i = 0; i< option_tmp.count; i++) {
        int option = [option_tmp[i] intValue];
        if(option < min || option > max) {
            continue;
        }
        [count_item addObject:[NSNumber numberWithInt:option]];
    }
    
    listCard = [NSMutableArray array];
    list_data = [appcontroller shuffleArray:[UserInfo getInstance].listCard];
    content_node.contentSize = CGSizeMake(1, content_height/100);
    content_node.opacity = 0;
    int total_card = list_data.count;
    total_second = 2.96f * total_card;
    [self updateTime];
    answerDone = 0;
    
    CCSprite *done_bar = (CCSprite*)[self getChildByName:@"done_bar" recursively:YES];
    
    CCSprite *download_fill = [CCSprite spriteWithImageNamed:@"img/gameplay/game/loading_bar_2.png"];
    progress = [CCProgressNode progressWithSprite:download_fill];
    [done_bar addChild:progress];
    progress.type=CCProgressNodeTypeBar;
    progress.midpoint=CGPointMake(0.0f, 0.1f);
    progress.barChangeRate=CGPointMake(1, 0);
    progress.percentage = 0.0f;
    progress.position = ccp(75.0f, 11.5f);
    dunglientuc = 0;
    count_card_index = 0;
    total_heart = 3;
    [self activeHeart];
}

-(void)missHeart {
    total_heart--;
    if(total_heart == -1) {
        [timer invalidate];
        NSLog(@"out hearts");
        [UserInfo getInstance].lose_type = 1;
        NSString *ccbi_file = @"ccbi/gameplay/youlose";
        [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:ccbi_file] withTransition:[CCTransition transitionFadeWithColor:[CCColor whiteColor] duration:0.4]];
        [self removeCache];
        return;
    }
    [self activeHeart];
    isFalse = YES;
    dunglientuc=0;
}

-(void)activeHeart {
    int i = 0;
    for (CCSprite *heart in tim.children) {
        if(i < total_heart) {
            heart.spriteFrame = [CCSpriteFrame frameWithImageNamed:@"img/Home_screen/3.png"];
        } else {
            heart.spriteFrame = [CCSpriteFrame frameWithImageNamed:@"img/Home_screen/4.png"];
        }
        i++;
    }
}

-(void)updateTime {
    if(total_second >= 60) {
        total_second = (int)total_second;
        phut = (int)total_second / 60;
        giay = total_second - (phut*60);
    } else {
        phut = 0;
        giay = total_second;
    }
    thoigian.string = [NSString stringWithFormat:@"%.2d:%.2d", phut, giay];
}

-(void)onEnter {
    [super onEnter];
}

-(void)onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    [self addGameNode];
    BOOL show_time = [user_default boolForKey:@"show_time"];
    if(show_time == YES) {
        timer=[NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(changeTime) userInfo:nil repeats:YES];
    } else {
        thoigian.visible = NO;
    }
}

-(void)changeTime {
    if(total_second <= 0) {
        [timer invalidate];
        [UserInfo getInstance].lose_type = 2;
        NSString *ccbi_file = @"ccbi/gameplay/youlose";
        [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:ccbi_file] withTransition:[CCTransition transitionFadeWithColor:[CCColor whiteColor] duration:0.4]];
        [self removeCache];
        NSLog(@"Time out");
        return;
    }
    total_second--;
    
    if((int)total_second == 10) {
        time_out = [[OALSimpleAudio sharedInstance] playEffect:@"time_out.mp3" volume:1.0f pitch:1.0f pan:0.0f loop:YES];
    }
    
    [self updateTime];
}

-(void)disableAllItem {
    for (GameItem *item in listCard) {
        item.userInteractionEnabled = NO;
    }
}

-(void)addGameNode {
    isFalse = NO;
    if(listCard.count > 0) {
        for(GameItem *item in listCard) {
            [item removeFromParentAndCleanup:YES];
        }
        [listCard removeAllObjects];
    }
    
    float y = sceneSize.height * (content_height/100.0f);
    float x = sceneSize.width/2;
    float item_scale = 1.0f;    
    
    if(dunglientuc > 0 && dunglientuc % 2 == 0) {
        count_card_index++;
        if(count_card_index >= count_item.count) {
            count_card_index = count_item.count-1;
        }
    }
    //count_card_index = 3;
    count_card = [count_item[count_card_index] intValue];
    
    //card dung
    NSDictionary *cardTrue = list_data[answerDone];
    NSString *cardDung = [cardTrue valueForKey:@"name"];
    lbl_card_name.string = cardDung;
    lbl_card_name.visible = YES;
    
    //ram dom lay so card tuong ung
    NSMutableArray *card_ramdom = [NSMutableArray array];
    [card_ramdom addObject:cardTrue];
    NSArray *tmp_arr = [NSArray arrayWithArray:list_data];
    tmp_arr = [appcontroller shuffleArray:tmp_arr];
    for (NSDictionary *dd in tmp_arr) {
        if(card_ramdom.count >= count_card) {
            break;
        }
        if([[dd valueForKey:@"name"] isEqualToString:cardDung]) {
            continue;
        }
        [card_ramdom addObject:dd];
    }
    
    card_ramdom = [appcontroller shuffleArray:card_ramdom];

    
    if(count_card == 4) {
        x = sceneSize.width/4;
        item_scale = 0.95f;
        if([device_type isEqualToString:@"ipad"]) {
            item_scale = 1.0f;
            x += 15;
        }
    } else if(count_card == 6) {
        x = sceneSize.width/4;
        item_scale = 0.75f;
        if([device_type isEqualToString:@"phone"]) {
            item_scale = 0.65f;
        }
        
        if([device_type isEqualToString:@"phone"]) {
            x+=25;
        }
        
        if([device_type isEqualToString:@"phonehd"]) {
            x+=15;
        }
        
        if([device_type isEqualToString:@"ipad"]) {
            x+=25;
        }
        
    } else if(count_card == 9) {
        x = sceneSize.width/3/2;
        item_scale = 0.65f;
        if([device_type isEqualToString:@"phone"]) {
            item_scale = 0.6f;
        }
    }
    
    float item_height = 141 * item_scale;
    y -= item_height / 2;
    
    
    float firstX = x;
    GameItem *game_item;
    for (int i = 1; i <= count_card; i++) {
        game_item = (GameItem*)[CCBReader load:@"ccbi/gameplay/game_item"];
        NSDictionary *dddd = card_ramdom[i-1];
        game_item.dict = dddd;
        
        if([[dddd valueForKey:@"name"] isEqualToString:cardDung]) {
            game_item.isTrue = YES;
        }
        
        game_item.scale = item_scale;
        game_item.position = ccp(x, y);
        game_item.anchorPoint = ccp(0.5f, 0.5f);
        [content_node addChild:game_item];
        [listCard addObject:game_item];
        if(count_card == 2) {
            y-=item_height;
            y-=10;
        } else if(count_card == 4) {
            if(i > 0 && i %2 == 0) {
                y-=item_height;
                //y-=5;
                x = firstX;
            } else {
                if([device_type isEqualToString:@"ipad"]) {
                    x=(firstX-15)*3;
                    x-=15;
                } else {
                    x=firstX*3;
                }
            }
        } else if(count_card == 6) {
            if(i > 0 && i %2 == 0) {
                y-=item_height;
                //y-=5;
                x = firstX;
            } else {
                if([device_type isEqualToString:@"phone"]) {
                    x=(firstX-25)*3;
                    x-=25;
                }else if([device_type isEqualToString:@"phonehd"]) {
                    x=(firstX-15)*3;
                    x-=15;
                }else if([device_type isEqualToString:@"ipad"]) {
                    x=(firstX-25)*3;
                    x-=25;
                }
            }
        } else if(count_card == 9) {
            if(i > 0 && i %3 == 0) {
                y-=item_height;
                y-=5;
                x = firstX;
            } else {
                x+=sceneSize.width/3;
            }
        }
    }
    
    NSString *card_audio = [NSString stringWithFormat:@"audio/%@", [cardTrue valueForKey:@"audio"]];
    [[OALSimpleAudio sharedInstance] playEffect:card_audio];
}

-(void)nextCard {
    if(!isFalse) {
        dunglientuc++;
    }
    answerDone++;
    float percent = (float)answerDone/list_data.count * 100;
    NSLog(@"percent: %f", percent);
    progress.percentage = percent;
    
    if(answerDone == list_data.count) {
        //finish
        [self youWin];
        return;
    }
    
    if(listCard.count > 0) {
        for(GameItem *item in listCard) {
            [item removeCard];
        }
    }
    [self scheduleOnce:@selector(addGameNode) delay:0.5f];
}

-(void)youWin {
    [timer invalidate];
    [UserInfo getInstance].total_heart = total_heart;
    NSString *ccbi_file = @"ccbi/gameplay/youwin";
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:ccbi_file] withTransition:[CCTransition transitionFadeWithColor:[CCColor whiteColor] duration:0.4]];
    [self removeCache];
}

-(void)ActionClickButton:(CustomButton *)bt {

    if([bt.name isEqualToString:@"home"]) {
        [appcontroller enableBackgroundMusic:[user_default boolForKey:@"music"]];
        [timer invalidate];
        NSString *ccbi_file = @"ccbi/home/HomeScene";
        [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:ccbi_file] withTransition:[CCTransition transitionFadeWithColor:[CCColor whiteColor] duration:0.4]];
        [self removeCache];
        return;
    }
    
}

-(void)removeCache {
    content_node = nil;
    thoigian = nil;
    lbl_card_name = nil;
    tim = nil;
    [timer invalidate];
    progress = nil;
    [time_out stop];
    [listCard removeAllObjects];
    [count_item removeAllObjects];
}

@end
