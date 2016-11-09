//
//  JCF_ModelManager.h
//  FMDB_JCF_Pro
//
//  Created by jing on 16/11/7.
//  Copyright © 2016年 jing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>//fmdb
#import "JCF_ModelManagerHelper.h"
typedef NS_ENUM(NSInteger) {
    MODEL_MANAGER_TYPE_ADD = 0,
    MODEL_MANAGER_TYPE_REM = 1,
    MODEL_MANAGER_TYPE_CHANGE = 2
}MODEL_MANAGER_TYPE;
/**
 *
 * 一个manager 对应一个数据库;
 *
 */
@interface JCF_ModelManager : NSObject

// 删除是通过主键删除的，若想条件删除则（更新也是一样）
// 1.search
// 2.批量删除

#pragma mark 初始化___数据库的名字
// 建议：
// 在ViewControllerBase建一个属性
// 所有的controller统一使用一个JCF_ModelManager
- (instancetype)initWithDataBaseName:(NSString *)name;

#pragma mark 批量___增删改
- (BOOL)updataModelByType:(MODEL_MANAGER_TYPE)type
                            WithModel:(NSObject <JCF_ModelProtocol>*)model;

#pragma mark 单个___增删改
- (void)updateModelsByType:(MODEL_MANAGER_TYPE)type
                WithModels:(NSArray <NSObject <JCF_ModelProtocol>*> *)models
            AndFinishBlock:(JCF_ResultBlock)block;

#pragma mark 条件查找
- (NSArray *)searchModelsByModelClass:(Class)modelClass AndSearchPropertyDictionary:(NSDictionary *)propertyDictionary;

/**
 * 查找
 * modelClass model的class
 * propertyDictionary = @{
 @"属性名":value,
 @"属性名":value,
 };
 propertyDictionary = nil 全部数据；
 * SoreArray 条件排序
 */

#pragma mark 额外add

/**
 * 添加额外的sql操作
 */


@end
