//
//  JCF_ModelManager.m
//  FMDB_JCF_Pro
//
//  Created by jing on 16/11/7.
//  Copyright © 2016年 jing. All rights reserved.
//

#import "JCF_ModelManager.h"
@interface JCF_ModelManager ()
/**
 * FMDB对象
 */
@property (nonatomic,strong)FMDatabaseQueue *dbQueue;
/**
 * 辅助方法类
 * 生成sql语句
 * 搜索结果 转 model
 */
@property (nonatomic,strong)JCF_ModelManagerHelper *helping;
//
@property (nonatomic,strong)NSString *name;
//用来存储class的数组
@property (nonatomic,strong)NSMutableArray *classNameArray;
#pragma mark 建表
- (BOOL)createTableByClass:(Class)modelClass;
#pragma mark 增删改
- (BOOL)addModel:(NSObject <JCF_ModelProtocol>*)model;
- (BOOL)removeModel:(NSObject <JCF_ModelProtocol>*)model;
- (BOOL)updateModel:(NSObject <JCF_ModelProtocol>*)model;


@end
@implementation JCF_ModelManager

#pragma mark 初始化___数据库的名字
- (instancetype)initWithDataBaseName:(NSString *)name{
    self = [super init];
    if (self) {
        self.name = name;//数据库名称的一部分，忘记就会丢库～～
    }
    return self;
}
#pragma mark 单个___增删改
- (BOOL)updataModelByType:(MODEL_MANAGER_TYPE)type
                WithModel:(NSObject <JCF_ModelProtocol>*)model{
    //建表或更新列(内部做了判断，一个类只会调用一次)
    [self createTableByClass:model.class];
    
    BOOL res = NO;
    switch (type) {
        case MODEL_MANAGER_TYPE_ADD:
            res = [self addModel:model];
            break;
        case MODEL_MANAGER_TYPE_REM:
            res = [self removeModel:model];
            break;
        case MODEL_MANAGER_TYPE_CHANGE:
            res = [self updateModel:model];
            break;
    }
    return res;
}

#pragma mark 批量___增删改
- (void)updateModelsByType:(MODEL_MANAGER_TYPE)type
                WithModels:(NSArray <NSObject <JCF_ModelProtocol>*> *)models
            AndFinishBlock:(JCF_ResultBlock)block{
    __weak typeof(self) weakSelf = self;
    
    BOOL(^swithBlock)(MODEL_MANAGER_TYPE type,NSObject<JCF_ModelProtocol> *model,FMDatabase *db) = ^(MODEL_MANAGER_TYPE type,NSObject<JCF_ModelProtocol> *model,FMDatabase *db){
        BOOL res = NO;
        switch (type) {
            case MODEL_MANAGER_TYPE_ADD:
              res = [weakSelf addAction:db withModel:model];
                break;
            case MODEL_MANAGER_TYPE_REM:
              res = [weakSelf removeAction:db withModel:model];
                break;
            case MODEL_MANAGER_TYPE_CHANGE:
              res = [weakSelf updateAction:db withModel:model];
                break;
        }
        return res;
    };
    
    NSMutableArray *fairModelArray = [NSMutableArray array];
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (NSObject<JCF_ModelProtocol> *model in models) {
            //建表
            [weakSelf createTableAction:db WithRollback:rollback AndClass:model.class];
            //不同的操作
            BOOL success = swithBlock(type,model,db);
            if (!success) [fairModelArray addObject:model];
        }
    }];
    if (fairModelArray.count == 0){
        block(YES,nil);
    }else{
        block(NO,fairModelArray);
    }
}

#pragma mark 条件查找
- (NSArray *)searchModelsByModelClass:(Class)modelClass AndSearchPropertyDictionary:(NSDictionary *)propertyDictionary{
    //建表或更新列(内部做了判断，一个类只会调用一次)
    [self createTableByClass:modelClass];
    
    NSMutableArray *models = [NSMutableArray array];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sqlString = [self.helping searchModelToFmdbWithModelClass:modelClass AndInfoDictionary:propertyDictionary];
        FMResultSet *resultSet = [db executeQuery:sqlString];
        while ([resultSet next]) {
            NSObject <JCF_ModelProtocol> *model = [self.helping modelByModelClass:modelClass AndGetModelValueBlock:^id(NSString *columeName, PROPERTY_TYPE type) {
                switch (type) {
                    case PROPERTY_TYPE_STRING:
                        return [resultSet stringForColumn:columeName];
                    case PROPERTY_TYPE_DATA:
                        return [resultSet dataForColumn:columeName];
                    case PROPERTY_TYPE_LONGLONG:
                        return @([resultSet longLongIntForColumn:columeName]);
                }
            }];
            [models addObject:model];
            FMDBRelease(model);
        }
    }];
    return models;
}

/**
 * 建表
 * createTableAction 为了解决 addmodels 导致的嵌套死锁
 */
- (BOOL)createTableAction:(FMDatabase *)db WithRollback:(BOOL *)rollback AndClass:(Class)modelClass{
    __block BOOL res = YES;
    NSString *tableName = [self.helping tableNameByModelClass:modelClass];
    //不包含则 更新表 或者 创建表
    if ([self.classNameArray containsObject:tableName]) {
        return YES;
    }
    
    NSString *tableHaveSQLString = [self.helping SQLTableHaveByModelClass:modelClass];
    FMResultSet *rs = [db executeQuery:tableHaveSQLString];
    BOOL isCreate = NO;
    while ([rs next]) {
        NSInteger count = [rs intForColumn:@"count"];
        if (count != 0) isCreate = YES;
    }
    if (isCreate) {
        //已经创建：添加tab的 新列
        NSArray *columns = [self dataBaseProertyByFMDatabase:db AndTableName:tableName];
        [self.helping SQLTableAddProHaveByModelClass:modelClass WithProSaveArray:columns AndSQLBlock:^(NSString *sqlString) {//此处会多次执行
            if (![db executeUpdate:sqlString]) {
                res = NO;
                *rollback = YES;
//                return ;
            }
        }];
    }else{
        //未被创建：创建tab
        NSString *tableCreateSQLString = [self.helping createSQLTableByModelClass:modelClass];
        if (![db executeUpdate:tableCreateSQLString]) {
            res = NO;
            *rollback = YES;
        };
    }
    
    //成功的话存储一下class
    if (res) {
        [self.classNameArray addObject:tableName];
    }
    return res;
}
- (BOOL)createTableByClass:(Class)modelClass{
    __block BOOL res = YES;
    __weak typeof(self) weakSelf = self;
    //1. 判断表是否存在，存在则继续执行第二步,（不存在不需要执行第二步）
    //2. 判断是否属性有删减，
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        res = [weakSelf createTableAction:db WithRollback:rollback AndClass:modelClass];
    }];
    return res;
}


/**
 * 增
 * 批量增
 * 单个增
 *
 */
- (BOOL)addModel:(NSObject <JCF_ModelProtocol>*)model{
    __block BOOL res = NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
       res = [self addAction:db withModel:model];
    }];
    NSLog(@"-------%@",res?@"成功":@"失败");
    return res;
}

- (BOOL)addAction:(FMDatabase *)db
        withModel:(NSObject <JCF_ModelProtocol>*)model{
    __block BOOL res = NO;
    [self.helping addModelToFmdbWithModel:model AndResult:^(NSString *sqlString, NSArray *valueArray) {
        res = [db executeUpdate:sqlString withArgumentsInArray:valueArray];
        NSLog(@"%@,%@",res?@"成功":@"失败",sqlString);
    }];
    return res;
}
/**
 * 删
 * 批量删
 * 单个删
 *
 */
- (BOOL)removeModel:(NSObject <JCF_ModelProtocol>*)model{
    __block BOOL res = NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        res = [self removeAction:db withModel:model];
    }];
    return res;
}

- (BOOL)removeAction:(FMDatabase *)db
           withModel:(NSObject <JCF_ModelProtocol>*)model{
    __block BOOL res = NO;
    [self.helping removeModelToFmdbWithModel:model AndResult:^(NSString *sqlString, NSArray *valueArray) {
        res = [db executeUpdate:sqlString withArgumentsInArray:valueArray];
        NSLog(@"%@,%@",res?@"成功":@"失败",sqlString);
    }];
    return res;
}
/**
 * 改
 * 批量改
 * 单个改
 * 注意：加上这个需求（如果是model以前没存在则自动add）
 */

- (BOOL)updateModel:(NSObject <JCF_ModelProtocol>*)model{
    __block BOOL res = NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        res = [self updateAction:db withModel:model];
    }];
    return res;
}

- (BOOL)updateAction:(FMDatabase *)db
           withModel:(NSObject <JCF_ModelProtocol>*)model{
    __block BOOL res = NO;
    [self.helping updateModelToFmdbWithModel:model AndResult:^(NSString *sqlString, NSArray *valueArray) {
        res = [db executeUpdate:sqlString withArgumentsInArray:valueArray];
        NSLog(@"%@,%@",res?@"成功":@"失败",sqlString);
    }];
    return res;
}
/**
 * 查找
 * modelClass model的class
 * propertyDictionary = @{
 @"属性名":value,
 @"属性名":value,
 };
 * SoreArray 条件排序
 */
// AndSoreArray  以后在添加排序






#pragma mark 辅助方法。
- (NSArray *)dataBaseProertyByFMDatabase:(FMDatabase *)db AndTableName:(NSString *)tableName{
    NSMutableArray *columns = [NSMutableArray array];
    FMResultSet *resultSet = [db getTableSchema:tableName];
    while ([resultSet next]) {
        NSString *column = [resultSet stringForColumn:@"name"];
        [columns addObject:column];
    }
    return columns;
}
#pragma mark get 方法
-(JCF_ModelManagerHelper *)helping{
    if (!_helping) {
        _helping = [[JCF_ModelManagerHelper alloc] init];
    }
    return _helping;
}
-(FMDatabaseQueue *)dbQueue{
    if (!_dbQueue) {
        _dbQueue = [[FMDatabaseQueue alloc] initWithPath:[self.helping dbPathByString:self.name]];
    }
    return _dbQueue;
}
-(NSMutableArray *)classNameArray{
    if (!_classNameArray) {
        _classNameArray = [NSMutableArray array];
    }
    return _classNameArray;
}
@end
