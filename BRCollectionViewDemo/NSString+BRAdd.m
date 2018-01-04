//
//  NSString+BRAdd.m
//  BRCollectionViewDemo
//
//  Created by 任波 on 2018/1/4.
//  Copyright © 2018年 renb. All rights reserved.
//

#import "NSString+BRAdd.h"

@implementation NSString (BRAdd)

#pragma mark - 扫瞄器（NSScanner），获取字符串中的数字
- (NSInteger)IntegerInString {
    NSScanner *scanner = [NSScanner scannerWithString:self];
    [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:nil];
    int number;
    [scanner scanInt:&number];
    return number;
}

@end
