//
//  QuangCao.h
//  DemoAdvertising
//
//  Created by Sơn Lê Khắc on 7/28/14.
//  Copyright (c) 2014 Sơn Lê Khắc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuangCao : UIView{
    
}
/** lay ra kich thuoc man hinh la bao nhieu inch */
@property(nonatomic,assign)float diagonalSize;
/** lay ra do rong man hinh android */
@property(nonatomic,assign)CGSize androiscreen;
@property(nonatomic,assign)CGSize AdSize;
-(void)ShowFullScreen;
-(void)removeTimer;
@end
