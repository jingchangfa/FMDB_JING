//
//  JCF_ModelManagerHelper.m
//  FMDB_JCF_Pro
//
//  Created by jing on 16/11/7.
//  Copyright © 2016年 jing. All rights reserved.
//

#import "JCF_ModelManagerHelper.h"
#import <objc/runtime.h>
@interface JCF_ModelManagerHelper ()
/**
 * getPropertysNameByModelClass 获取该类的所有属性
 * PropertysDictionary:
 * key: propertyName
 * value: PropertyType
 * 外部无需访问
 */
- (NSDictionary *)getPropertysDictionaryByModelClass:(Class)modelClass;

@end

@implementation JCF_ModelManagerHelper
/**
 * dbPathByString 根据名称生成数据库的路径
 * tableNameByModelClass 根据class生成表名
 */
- (NSString *)dbPathByString:(NSString *)sqlLibraryName{
    NSString *pathString = [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //拼接document
    NSFileManager *filemanage = [NSFileManager defaultManager];
    pathString = [pathString stringByAppendingPathComponent:@"JCF"];//用公司名比较好
    BOOL isDir;
    BOOL exit =[filemanage fileExistsAtPath:pathString isDirectory:&isDir];
    BOOL success = false;
    if (!exit || !isDir) {
        success = [filemanage createDirectoryAtPath:pathString withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *dbpath = nil;
    if (sqlLibraryName == nil || sqlLibraryName.length == 0) {
        dbpath = [pathString stringByAppendingPathComponent:@"jcf.sqlite"];
    } else {
        dbpath = [pathString stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",sqlLibraryName]];
    }
    return dbpath;
}

- (NSString *)tableNameByModelClass:(Class)modelClass{
    NSString *className = NSStringFromClass(modelClass);
    return className;
}



/**
 * 创建表sql
 * SQLTableHaveByModelClass  判断表存在的sql语句
 * createSQLTableByModelClass 创建表的sql语句
 */

/**
 @param modelClass    class
 @param saveNameArray 表的所有字段名称
 @param block 添加列的block
 
 */
- (void)SQLTableAddProHaveByModelClass:(Class)modelClass WithProSaveArray:(NSArray *)saveNameArray AndSQLBlock:(JCF_AddPropertyBlcok)block{
    NSString *tableName = [self tableNameByModelClass:modelClass];
    NSDictionary *propertysDictionary = [self getPropertysDictionaryByModelClass:modelClass];
    NSArray *properties = propertysDictionary.allKeys;
    
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",saveNameArray];
    NSArray *resultArray = [properties filteredArrayUsingPredicate:filterPredicate];
    for (NSString *column in resultArray) {
        NSString *proType = propertysDictionary[column];
        NSString *fieldSql = [NSString stringWithFormat:@"%@ %@",column,proType];
        NSString *sqlString = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ ",tableName,fieldSql];
        block(sqlString);//返回add列的sql语句
    }
}

- (NSString *)SQLTableHaveByModelClass:(Class)modelClass{
    NSString *tableName = [self tableNameByModelClass:modelClass];

    NSString *sqlString = [NSString stringWithFormat:@"select count(*) as 'count' from sqlite_master where type ='table' and name = %@", tableName];
    
    return sqlString;
}
- (NSString *)createSQLTableByModelClass:(Class)modelClass{
    NSString *tableName = [self tableNameByModelClass:modelClass];
    NSString *mainKeyString = [self mainKeyByClass:modelClass];
    //属性名 字典
    NSDictionary *propertysDictionary = [self getPropertysDictionaryByModelClass:modelClass];
    NSString *columeAndTypeString = [self getColumeAndTypeString:propertysDictionary WithMainKey:mainKeyString];
    
    NSString *sqlString = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(%@);",tableName,columeAndTypeString];
    return sqlString;
}
#pragma mark 获取对象所有属性
/**
 * 类也是一个对象
 * http://blog.csdn.net/yohunl/article/details/51799784 理解
 * - (BOOL)respondsToSelector:(SEL)aSelector; 一个类的实例是否能够响应某个方法
 * + (BOOL)instancesRespondToSelector:(SEL)aSelector; 某个类是否响应其中一个方法
 * - (BOOL)conformsToProtocol:(Protocol *)aProtocol 一个类的实例是否遵循某个协议
 * + (BOOL)conformsToProtocol:(Protocol *)aProtocol 一个类是否遵循某个协议
 */
- (NSDictionary *)getPropertysDictionaryByModelClass:(Class)modelClass{
    NSArray *transientsArray = nil;
    NSMutableDictionary *propertysMuDic = [NSMutableDictionary dictionary];
    if ([modelClass respondsToSelector:@selector(transients)]) {//相应类方法
        transientsArray = [modelClass transients];
    }
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(modelClass, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        //获取属性名
        NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        if ([transientsArray containsObject:propertyName]) {
            continue;
        }
        //获取属性类型等参数
        NSString *propertyType = [NSString stringWithCString: property_getAttributes(property) encoding:NSUTF8StringEncoding];
        /*
         各种符号对应类型，部分类型在新版SDK中有所变化，如long 和long long
         c char         C unsigned char
         i int          I unsigned int
         l long         L unsigned long
         s short        S unsigned short
         d double       D unsigned double
         f float        F unsigned float
         q long long    Q unsigned long long
         B BOOL
         @ 对象类型 //指针 对象类型 如NSString 是@“NSString”
         
         64位下long 和long long 都是Tq
         SQLite 默认支持五种数据类型TEXT、INTEGER、REAL、BLOB、NULL
         因为在项目中用的类型不多，故只考虑了少数类型
         */
        NSString *typeString = nil;
        if ([propertyType hasPrefix:@"T@\"NSString\""]) {
            typeString = SQLTEXT;
        } else if ([propertyType hasPrefix:@"T@\"NSData\""]) {
            typeString = SQLBLOB;
        } else if ([propertyType hasPrefix:@"Ti"]||[propertyType hasPrefix:@"TI"]||[propertyType hasPrefix:@"Ts"]||[propertyType hasPrefix:@"TS"]||[propertyType hasPrefix:@"TB"]||[propertyType hasPrefix:@"Tq"]||[propertyType hasPrefix:@"TQ"]) {
            typeString = SQLINTEGER;
        } else {
            typeString = SQLREAL;
        }
        propertysMuDic[propertyName] = typeString;
    }
    free(properties);
    //放在这里感觉很不合适～～～～
    [self mainKeySetSuccseeful:propertysMuDic AndModelClass:modelClass];
    return propertysMuDic;
}


#pragma mark sql 语句
/**
 * 增加操作
 * 此方法生成sql语句，以及与sql匹配的value数组
 */
- (void)addModelToFmdbWithModel:(NSObject <JCF_ModelProtocol>*)model
                      AndResult:(JCF_SQLAddModelBlock)block{

    NSString *tableName = [self tableNameByModelClass:model.class];
    NSMutableString *keyString = [NSMutableString string];
    NSMutableString *valueString = [NSMutableString string];
    NSMutableArray *insertValues = [NSMutableArray  array];
    
    //属性名 字典
    NSDictionary *propertysDictionary = [self getPropertysDictionaryByModelClass:model.class];
    NSArray *proNamesArray = propertysDictionary.allKeys;
    for (int i = 0; i < proNamesArray.count; i++) {
        NSString *proname = proNamesArray[i];
        [keyString appendFormat:@"%@", proname];
        [valueString appendString:@"?"];
        if(i+1 != proNamesArray.count){
            [keyString appendString:@","];
            [valueString appendString:@","];
        }
        
        id value = [model valueForKey:proname];
        if (!value) {
            value = @"";
        }
        [insertValues addObject:value];
    }
    
    NSString *sqlString = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES (%@);", tableName, keyString, valueString];
    block(sqlString,insertValues);
}
/**
 * 删除操作
 * 通过model的delegate 获取 主键 通过主键删除;
 *
 */
- (void)removeModelToFmdbWithModel:(NSObject <JCF_ModelProtocol>*)model
                          AndResult:(JCF_SQLAddModelBlock)block{
    NSString *tableName = [self tableNameByModelClass:model.class];
    NSString *mainKeyString = [self mainKeyByClass:model.class];
    id value = [model valueForKey:mainKeyString];
    
    
    NSString *sqlString = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?",tableName,mainKeyString];
    block(sqlString,@[value]);
}

/**
 * 修改（根据主键更新）
 * 通过model的delegate获取主键
 *
 *
 */
- (void)updateModelToFmdbWithModel:(NSObject <JCF_ModelProtocol>*)model
                         AndResult:(JCF_SQLAddModelBlock)block{
    NSString *tableName = [self tableNameByModelClass:model.class];
    NSString *mainKeyString = [self mainKeyByClass:model.class];
    NSMutableString *keyString = [NSMutableString string];
    NSMutableArray *updateValues = [NSMutableArray  array];

    //属性名 字典
    NSDictionary *propertysDictionary = [self getPropertysDictionaryByModelClass:model.class];
    NSArray *proNamesArray = propertysDictionary.allKeys;
    
    for (int i = 0; i < proNamesArray.count; i++) {
        NSString *proname = proNamesArray[i];
        
        [keyString appendFormat:@"%@=?", proname];
        if(i+1 != proNamesArray.count){
            [keyString appendString:@","];
        }
        
        id value = [model valueForKey:proname];
        if (!value) {
            value = @"";
        }
        [updateValues addObject:value];
    }
    
    NSString *sqlString = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@ = ?;", tableName, keyString, mainKeyString];
    //别忘了 补上主键对应的————值
    id primaryValue = [model valueForKey:mainKeyString];
    [updateValues addObject:primaryValue];
    block(sqlString,updateValues);
}
/**
 * 查找
 * 1. 生成sql语句
 * 2. 结果转model
 */
- (NSString *)searchModelToFmdbWithModelClass:(Class)modelClass AndInfoDictionary:(NSDictionary *)infoDictionary{
    NSMutableString *sqlString = [NSMutableString string];
    NSArray *proNamesArray = infoDictionary.allKeys;
    NSString *tableName = [self tableNameByModelClass:modelClass];

    //查找全部
    if (!infoDictionary) {
        return [NSString stringWithFormat:@"SELECT * FROM %@",tableName];
    }
    //条件查询
    for (int i = 0; i<proNamesArray.count; i++) {
        NSString *proname = proNamesArray[i];
        id provalue = infoDictionary[proname];
        if ([[provalue class] isSubclassOfClass:[NSString class]]) {
            [sqlString appendFormat:@"SELECT * FROM %@ WHERE %@='%@'",tableName, proname,provalue];
        }else{
            [sqlString appendFormat:@"SELECT * FROM %@ WHERE %@=%@",tableName, proname,provalue];
        }
        if(i+1 != proNamesArray.count)
        {
            [sqlString appendString:@","];
        }
    }
    return sqlString;
}

- (NSObject <JCF_ModelProtocol> *)modelByModelClass:(Class)modelClass AndGetModelValueBlock:(JCF_GetModelValueBlock)block{
    //属性名 字典
    NSDictionary *propertysDictionary = [self getPropertysDictionaryByModelClass:modelClass];
    NSArray *proNamesArray = propertysDictionary.allKeys;
    NSObject <JCF_ModelProtocol> *model = [[modelClass alloc] init];

    for (int i = 0; i<proNamesArray.count; i++) {
        NSString *proname = proNamesArray[i];
        NSString *protype = propertysDictionary[proname];
        if ([protype isEqualToString:SQLTEXT]) {
            [model setValue:block(proname,PROPERTY_TYPE_STRING) forKey:proname];
        } else if ([protype isEqualToString:SQLBLOB]) {
            [model setValue:block(proname,PROPERTY_TYPE_DATA) forKey:proname];
        } else {
            [model setValue:block(proname,PROPERTY_TYPE_LONGLONG) forKey:proname];
        }
    }
    return model;
}


#pragma mark 辅助方法
-(NSString *)getColumeAndTypeString:(NSDictionary *)dictionary WithMainKey:(NSString *)mainKeyString{
    NSMutableString* pars = [NSMutableString string];
    NSArray *proNames = dictionary.allKeys;
    for (int i=0; i< proNames.count; i++) {
        NSString *proname = proNames[i];
        NSString *protype = dictionary[proname];
        if ([proname isEqualToString:mainKeyString]) {
            [pars appendString:[NSString stringWithFormat:@"%@ %@ %@",mainKeyString,protype,PrimaryKey]];
        }else{
            [pars appendFormat:@"%@ %@",proname,protype];
        }
        if(i+1 != proNames.count)
        {
            [pars appendString:@","];
        }
    }
    return pars;
}

- (NSString *)mainKeyByClass:(Class)modelClass{
    if ([modelClass respondsToSelector:@selector(transients)]) {//相应类方法
        return [modelClass mainKey];
    }
    NSString *mainKey = [[[modelClass alloc] init] mainKey];
    //放在这里感觉很不合适～～～～
    if (mainKey.length == 0) {
        //抛出异常
        JCF_Exception(NSStringFromClass(modelClass),@"必须至少实现一个获取主键的方法")
    }
    return mainKey;
}
- (void)mainKeySetSuccseeful:(NSDictionary *)proDictioary AndModelClass:(Class)modelClass{
    NSString *mainKey = [self mainKeyByClass:modelClass];
    if (![proDictioary.allKeys containsObject:mainKey]) {
        //抛出异常
        JCF_Exception(NSStringFromClass(modelClass),@"％@主键的设置")
    }
}
@end


//- (NSString *)sqlBySQLStatus:(SQL_STATUS)status WithPropertyDictionary:(NSDictionary *)propertyDictionary{
//    NSString *sqlString;
//    switch (status) {
//        case SQL_STATUS_ADD:
//            sqlString = [self addSQLStatement];
//            break;
//        case SQL_STATUS_REMOVE:
//            sqlString = [self removeSQLStatement];
//            break;
//        case SQL_STATUS_SEARCH:
//            sqlString = [self searchSQLStatement];
//            break;
//        default:
//            break;
//    }
//    return sqlString;
//}
//
//
//- (NSString *)addSQLStatement{
//    return @"add";
//}
//- (NSString *)searchSQLStatement{
//    return @"search";
//}
//- (NSString *)removeSQLStatement{
//    return @"remove";
//}
