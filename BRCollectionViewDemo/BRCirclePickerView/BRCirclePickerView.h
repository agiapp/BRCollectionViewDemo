//
//  BRCirclePickerView.h
//  AiBaoYun
//
//  Created by 任波 on 2017/6/6.
//  Copyright © 2017年 aby. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircleProgressView.h"

typedef void(^BRDidTapBlock)();
typedef void(^BRDidScrollEndBlock)(NSString *currentValue);

@interface BRCirclePickerView : UIView
/** 圆盘labelText数组 */
@property (nonatomic, strong) NSArray *circleTextArr;
/** 当前日期字符串 */
@property (nonatomic, strong) NSString *nowDateString;
/** 圆盘中心label文本 */
@property (nonatomic, strong) NSMutableAttributedString *centerText;
/** 当前怀孕周数对应的索引 */
@property (nonatomic, assign) NSInteger currentSelIndex;
/** 当前怀孕几率 */
@property (nonatomic, assign) CGFloat currentProbability;

/** 中心label点击事件的回调 */
@property (nonatomic, copy) BRDidTapBlock didTapCenterLabelBlock;
/** 滚动停止后的回调 */
@property (nonatomic, copy) BRDidScrollEndBlock didScrollEndBlock;

/** 初始化方法 */
- (instancetype)initWithFrame:(CGRect)frame homePageFlag:(NSInteger)flag;

/** 刷新初始化转盘数据 */
- (void)reloadDataForInit;

/** 刷新滚动结束转盘数据 */
- (void)reloadDataForSrcollEnd;

@end
