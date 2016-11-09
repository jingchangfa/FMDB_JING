//
//  JCF_ModelManagerHelper.h
//  FMDB_JCF_Pro
//
//  Created by jing on 16/11/7.
//  Copyright © 2016年 jing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JCF_ModelProtocol.h"
#import "JCF_ModelBlockHeader.h"

//typedef NS_ENUM(NSInteger){
//    SQL_STATUS_ADD = 1,
//    SQL_STATUS_REMOVE = 2,
//    SQL_STATUS_UPDATA = 3,
//    SQL_STATUS_SEARCH = 4
//}SQL_STATUS;


/** SQLite五种数据类型 */
#define SQLTEXT     @"TEXT"
#define SQLINTEGER  @"INTEGER"
#define SQLREAL     @"REAL"
#define SQLBLOB     @"BLOB"
#define SQLNULL     @"NULL"
//sql 关键字
#define PrimaryKey  @"primary key"


@interface JCF_ModelManagerHelper : NSObject
/**
 * 生成name
 */
- (NSString *)dbPathByString:(NSString *)sqlLibraryName;//根据名称生成数据库的路径

- (NSString *)tableNameByModelClass:(Class)modelClass;//根据class生成表名

/**
 * 创建表sql
 * SQLTableAddProHaveByModelClass 判断是否需要生成新列，若有block(sqlstring);
 * SQLTableHaveByModelClass  判断表存在的sql语句
 * createSQLTableByModelClass 创建表的sql语句
 */
- (void)SQLTableAddProHaveByModelClass:(Class)modelClass WithProSaveArray:(NSArray *)saveNameArray AndSQLBlock:(JCF_AddPropertyBlcok)block;
- (NSString *)SQLTableHaveByModelClass:(Class)modelClass;
- (NSString *)createSQLTableByModelClass:(Class)modelClass;


/**
 * 增加操作
 * 此方法生成sql语句，以及与sql匹配的value数组
 */
- (void)addModelToFmdbWithModel:(NSObject <JCF_ModelProtocol>*)model
                      AndResult:(JCF_SQLAddModelBlock)block;
/**
 * 删除操作 （通过主键删除）
 * 通过model的delegate获取主键
 */
- (void)removeModelToFmdbWithModel:(NSObject <JCF_ModelProtocol>*)model
                               AndResult:(JCF_SQLAddModelBlock)block;

/**
 * 修改（根据主键更新）
 * 通过model的delegate获取主键
 *
 * 
 */
- (void)updateModelToFmdbWithModel:(NSObject <JCF_ModelProtocol>*)model
                         AndResult:(JCF_SQLAddModelBlock)block;

/**
 * 查找
 * 1. 生成sql语句
 * 2. 结果转model
 */
- (NSString *)searchModelToFmdbWithModelClass:(Class)modelClass AndInfoDictionary:(NSDictionary *)infoDictionary;

- (NSObject <JCF_ModelProtocol> *)modelByModelClass:(Class)modelClass AndGetModelValueBlock:(JCF_GetModelValueBlock)block;

/**
 * 添加额外的sql语句
 */

@end

/**
 */
///**
// * sql语句
// *
// *
// */
//- (NSString *)sqlBySQLStatus:(SQL_STATUS)status WithPropertyDictionary:(NSDictionary *)propertyDictionary;
