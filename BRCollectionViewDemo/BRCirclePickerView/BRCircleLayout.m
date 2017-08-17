//
//  BRCircleLayout.m
//  AiBaoYun
//
//  Created by 任波 on 2017/6/6.
//  Copyright © 2017年 aby. All rights reserved.
//

#import "BRCircleLayout.h"

#define angular 60

@interface BRCircleLayout ()
// item 的大小
@property (nonatomic, assign) CGSize itemSize;
// item 中心点围成的圆的半径
@property (nonatomic, assign) NSInteger radius;
// item 的个数
@property (nonatomic, assign) NSInteger itemCount;

@end

@implementation BRCircleLayout

/** 用来做布局的初始化操作 */
- (void)prepareLayout {
    [super prepareLayout];
    // 初始化布局
    [self setupLayout];
}

// 初始化布局
- (void)setupLayout {
    self.itemSize = CGSizeMake(100 * kScaleFit, 100 * kScaleFit);
    self.radius = (self.collectionView.frame.size.width - self.itemSize.width) / 2;
    self.itemCount = [self.collectionView numberOfItemsInSection:0];
}

// 设置内容区域的大小
- (CGSize)collectionViewContentSize {
    return CGSizeMake(self.collectionView.bounds.size.width + (self.itemCount - 180 / angular) * self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
}

/** 这个方法的返回值是一个数组,数组里面存放着rect范围内所有元素的布局排布 */
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *attributes = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.itemCount; i++) {
        UICollectionViewLayoutAttributes *attribute = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        if (CGRectContainsRect(rect, attribute.frame) || CGRectIntersectsRect(rect, attribute.frame)) {
            [attributes addObject:attribute];
        }
    }
    return attributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat visibleItemIndex = indexPath.item - self.collectionView.contentOffset.x / (self.collectionView.bounds.size.width * 1.0f);
    UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attribute.size = self.itemSize;
    attribute.hidden = YES;
    attribute.center = CGPointMake(self.collectionView.contentOffset.x + self.collectionView.frame.size.width / 2, self.collectionView.frame.size.height / 2);
    CGFloat angle = visibleItemIndex * (angular / 180.0 * M_PI);
    //NSLog(@"angle[%ld] = %f", indexPath.item, angle);
    CGAffineTransform transform = CGAffineTransformIdentity;
    if (angle < M_PI && angle > - M_PI / 3) {
        if (angle > 2 * M_PI / 3 && angle < M_PI) {
            attribute.alpha = (M_PI - angle) / (M_PI / 3);
            attribute.hidden = NO;
        } else if (angle > - M_PI / 3 && angle < 0) {
            attribute.alpha = 1 - (0 - angle) / (M_PI / 3);
            attribute.hidden = NO;
        } else {
            attribute.alpha = 1;
            attribute.hidden = NO;
        }
        // 1.位移移动，平移 (CGFloat tx, CGFloat ty), 起始位置 x 会加上tx , y 会加上 ty
        CGFloat tx = -(self.radius - 18 * kScaleFit) * cos(angle + M_PI / 6);
        CGFloat ty = (self.radius - 18 * kScaleFit) * sin(angle + M_PI / 6);
        transform = CGAffineTransformMakeTranslation(tx, ty);
        // 2.设置每个item相对于自己中心点旋转的角度
        transform = CGAffineTransformRotate(transform, -(angle - M_PI / 3));
    }
    
    attribute.transform = transform;
    
    return attribute;
}

// 返回yes，当collectionView的显示范围发生改变的时候，就会重新刷新布局
// 一旦重新刷新布局，就会重新调用下面的方法：prepareLayout、layoutAttributesForElementsInRect:方法
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

@end
