//
//  JCF_ModelProtocol.h
//  FMDB_JCF_Pro
//
//  Created by jing on 16/11/7.
//  Copyright © 2016年 jing. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JCF_ModelProtocol <NSObject>
/**
 * 如果model类中有一些property不需要创建数据库字段，那么这个方法必须在子类中重写
 * @[@"name",@"age"]; 属性名
 * 避免继承，必须要用类方法
 */
+ (NSArray *)transients;

/**
 * 每个类必须设置主键
 * 主键必须是已经存在的属性  eg: ID
 * 必须实现其中一个
 */
+ (NSString *)mainKey;//优先调用此方法获取

- (NSString *)mainKey;//可继承  例如所有的ID 都是主键 则在base 直接 return @"ID"
@end
