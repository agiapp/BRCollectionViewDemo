//
//  BRCirclePickerView.m
//  AiBaoYun
//
//  Created by 任波 on 2017/6/6.
//  Copyright © 2017年 aby. All rights reserved.
//

#import "BRCirclePickerView.h"
#import "BRCircleLayout.h"
#import "NSDate+BRAdd.h"
//#import "NSString+BRAdd.h"

/** 圆盘弧形文本个数 */
#define itemCount 6
/** 圆盘半径 */
#define RADIUS (self.bounds.size.width / 2)
/** 弧度转角度 */
#define RADIAN_TO_ANGLE(__VALUE__) ((__VALUE__) * 180 / M_PI)
/** 角度转弧度 */
#define ANGLE_TO_RADIAN(__VALUE__) ((__VALUE__) * M_PI / 180.0)

@interface BRCirclePickerView ()<UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>
{
    NSInteger _identityFlag;    // 身份标识(1:备孕期，2:孕产期，3:育儿期)
    NSInteger _lastSelIndex;    // 上一个选中的index
}
/** 底部背景图层 */
@property (nonatomic, strong) UIImageView *bgImageView;
/** 底部转动图层 */
@property (nonatomic, strong) UIImageView *rotateImageView;
/** 圆盘滚动视图 */
@property (nonatomic, strong) UICollectionView *collectionView;
/** 圆盘中心背景图片 */
@property (nonatomic, strong) UIImageView *centerImageView;
/** 圆盘中心Label */
@property (nonatomic, strong) UILabel *centerLabel;

/** 日期 */
@property (nonatomic, strong) UILabel *dateLabel;

@end

@implementation BRCirclePickerView

- (instancetype)initWithFrame:(CGRect)frame homePageFlag:(NSInteger)flag {
    if (self = [super initWithFrame:frame]) {
        _identityFlag = flag;
        
        [self setupUI];
    }
    return self;
}

#pragma mark - 添加子视图
- (void)setupUI {
    self.bgImageView.hidden = NO;
    self.rotateImageView.hidden = NO;
    self.collectionView.hidden = NO;
    self.centerImageView.hidden = NO;
    self.dateLabel.hidden = NO;
}

#pragma mark - 刷新数据
- (void)reloadDataForInit {
    // 刷新collectionView
    [self.collectionView reloadData];
    // 加载当前日期label
    self.dateLabel.text = self.nowDateString;
    // 刷新centerLabel的数据
    self.centerLabel.attributedText = self.centerText;
    
    // 默认滚动
    [self scrollToItemAtIndex:self.currentSelIndex animated:YES];
}

- (void)reloadDataForSrcollEnd {
    if (_identityFlag == 1) {
        // 刷新centerLabel的数据
        self.centerLabel.attributedText = self.centerText;
    }
}

#pragma mark - 懒加载 子视图
- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(5 * kScaleFit, 5 * kScaleFit, 310 * kScaleFit, 310 * kScaleFit)];
        _bgImageView.backgroundColor = [UIColor clearColor];
        NSString *imageName = [NSString stringWithFormat:@"home%ld_disc_bottom_shadow", _identityFlag];
        _bgImageView.image = [UIImage imageNamed:imageName];
        [self addSubview:_bgImageView];
    }
    return _bgImageView;
}

- (UIImageView *)rotateImageView {
    if (!_rotateImageView) {
        _rotateImageView = [[UIImageView alloc]initWithFrame:CGRectMake(5 * kScaleFit, 5 * kScaleFit, 310 * kScaleFit, 310 * kScaleFit)];
        _rotateImageView.backgroundColor = [UIColor clearColor];
        NSString *imageName = [NSString stringWithFormat:@"home%ld_disc_bottom", _identityFlag];
        _rotateImageView.image = [UIImage imageNamed:imageName];
        [self addSubview:_rotateImageView];
    }
    return _rotateImageView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        BRCircleLayout *layout = [[BRCircleLayout alloc]init];
        _collectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        // 开启分页
        _collectionView.pagingEnabled = YES;
        // 隐藏水平滚动条
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellID"];
        [self addSubview:_collectionView];
    }
    return _collectionView;
}

- (UIImageView *)centerImageView {
    if (!_centerImageView) {
        _centerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 162 * kScaleFit, 162 * kScaleFit)];
        _centerImageView.center = self.collectionView.center;
        _centerImageView.backgroundColor = [UIColor clearColor];
        NSString *imageName = [NSString stringWithFormat:@"home%ld_disc_center", _identityFlag];
        _centerImageView.image = [UIImage imageNamed:imageName];
        [self addSubview:_centerImageView];
    }
    return _centerImageView;
}

- (UILabel *)centerLabel {
    if (!_centerLabel) {
        _centerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80 * kScaleFit, 80 * kScaleFit)];
        _centerLabel.center = self.center;
        _centerLabel.backgroundColor = [UIColor clearColor];
        _centerLabel.textAlignment = NSTextAlignmentCenter;
        _centerLabel.textColor = [UIColor whiteColor];
        _centerLabel.font = [UIFont boldSystemFontOfSize:10.0f * kScaleFit];
        _centerLabel.numberOfLines = 0;
        _centerLabel.layer.cornerRadius = 40.0f * kScaleFit;
        _centerLabel.layer.masksToBounds = YES;
        [self addSubview:_centerLabel];
        _centerLabel.attributedText = self.centerText;
        // label 点击事件
        _centerLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *myTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapCenterLabel)];
        [_centerLabel addGestureRecognizer:myTap];
    }
    return _centerLabel;
}

- (void)didTapCenterLabel {
    // 执行外界传来的block
    self.didTapCenterLabelBlock();
}

- (UILabel *)dateLabel {
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100 * kScaleFit, 20 * kScaleFit)];
        _dateLabel.center = CGPointMake(self.center.x, self.center.y + 100 * kScaleFit);
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.font = [UIFont systemFontOfSize:14.0f * kScaleFit];
        _dateLabel.textColor = [UIColor whiteColor];
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        _dateLabel.text = self.nowDateString;
        [self addSubview:_dateLabel];
    }
    return _dateLabel;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.circleTextArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellID" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    if (self.circleTextArr.count > 0) {
        UILabel *arcTextLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100 * kScaleFit, 100 * kScaleFit)];
        arcTextLabel.backgroundColor = [UIColor clearColor];
        arcTextLabel.font = [UIFont systemFontOfSize:14.0f * kScaleFit];
        arcTextLabel.textColor = [UIColor whiteColor];
        arcTextLabel.textAlignment = NSTextAlignmentCenter;
        arcTextLabel.text = self.circleTextArr[indexPath.item];
        [cell.contentView addSubview:arcTextLabel];
    }
    
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"点击了：%ld, 当前索引：%ld", indexPath.item, self.currentSelIndex);
    if (indexPath.item > 0 && indexPath.item < self.circleTextArr.count - 1) {
        _lastSelIndex = self.currentSelIndex;
        if (indexPath.item <= self.currentSelIndex - 1) {
            NSLog(@"上一页");
            // 滚动到新位置
            [self scrollToItemAtIndex:indexPath.item animated:YES];
            self.currentSelIndex = indexPath.item;
            [self handlerReloadDidScrollEnd];
        }
        if (indexPath.item >= self.currentSelIndex + 1) {
            NSLog(@"下一页");
            [self scrollToItemAtIndex:indexPath.item animated:YES];
            self.currentSelIndex = indexPath.item;
            [self handlerReloadDidScrollEnd];
        }
    }
}

#pragma mark - 滚动到指定位置
/** 滚动到指定位置 */
- (void)scrollToItemAtIndex:(NSInteger)index animated:(BOOL)animated {
    [self.collectionView setContentOffset:CGPointMake(self.collectionView.bounds.size.width * (index - 1), 0) animated:animated];
}

#pragma mark - UIScrollViewDelegate
// 滚动就会触发 这里对滑动的contentOffset进行监控，实现循环滚动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    // 旋转的弧度
    CGFloat radianOffset = offsetX * (M_PI / itemCount) / RADIUS;
    self.rotateImageView.transform = CGAffineTransformMakeRotation(radianOffset);
    // 旋转的角度
    //CGFloat angleOffset = RADIAN_TO_ANGLE(radianOffset);
    //NSLog(@"滚动进行中... offSetX:%f, 旋转角度:%f", offsetX, angleOffset);
    
}

/** 结束减速时触发（滚动停止） */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _lastSelIndex = self.currentSelIndex;
    NSInteger index = roundf(scrollView.contentOffset.x / self.collectionView.bounds.size.width);
    self.currentSelIndex = index + 1;
    [self handlerReloadDidScrollEnd];
}

/** 回调，执行外部刷新 */
- (void)handlerReloadDidScrollEnd {
    NSLog(@"currentSelIndex = %ld， lastSelIndex = %ld", self.currentSelIndex, _lastSelIndex);
    NSLog(@"改变索引：%ld", self.currentSelIndex - _lastSelIndex);
    // 执行回调
    if (self.didScrollEndBlock) {
        if (_identityFlag == 1) {
            self.nowDateString = [NSDate date:self.nowDateString formatter:@"yyyy-MM-dd" addDays:self.currentSelIndex - _lastSelIndex];
            self.dateLabel.text = self.nowDateString;
            // 获取当前日期
            NSLog(@"获取当前日期：%@", self.nowDateString);
            self.didScrollEndBlock(self.nowDateString);
        }
        if (_identityFlag == 2) {
            self.nowDateString = [NSDate date:self.nowDateString formatter:@"M月d日" addDays:self.currentSelIndex - _lastSelIndex];
            self.dateLabel.text = self.nowDateString;
            // 获取当前怀孕周
            NSString *weekStr = [self.circleTextArr objectAtIndex:self.currentSelIndex];
            if ([weekStr containsString:@"周"]) {
                NSString *tempStr = [weekStr componentsSeparatedByString:@"周"][0];
                weekStr = [NSString stringWithFormat:@"%ld", [tempStr IntegerInString]];
            } else {
                weekStr = @"0";
            }
            NSLog(@"获取当前孕周：%@", weekStr);
            self.didScrollEndBlock(weekStr);
        }
        if (_identityFlag == 3) {
            self.nowDateString = [NSDate date:self.nowDateString formatter:@"M月d日" addDays:self.currentSelIndex - _lastSelIndex];
            self.dateLabel.text = self.nowDateString;
            // 获取宝宝出生天数
            NSString *dayStr = [self.circleTextArr objectAtIndex:self.currentSelIndex];
            dayStr = [NSString stringWithFormat:@"%ld", [dayStr IntegerInString]];
            NSLog(@"宝宝出生天数：%@", dayStr);
            self.didScrollEndBlock(dayStr);
        }
    }
}

- (NSArray *)circleTextArr {
    if (!_circleTextArr) {
        _circleTextArr = [NSArray array];
    }
    return _circleTextArr;
}

@end
