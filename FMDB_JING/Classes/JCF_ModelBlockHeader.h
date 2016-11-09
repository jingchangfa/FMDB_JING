//
//  JCF_ModelBlockHeader.h
//  FMDB_JCF_Pro
//
//  Created by jing on 16/11/7.
//  Copyright © 2016年 jing. All rights reserved.
//

#ifndef JCF_ModelBlockHeader_h
#define JCF_ModelBlockHeader_h

#define JCF_Exception(class,reasion) @throw [NSException exceptionWithName:class reason:reasion userInfo:nil];

/**
 * 成功：返回yes，fireModelArray ＝ nil；
 * 失败：返回no ，fireModelArray ！＝ nil；
 */
typedef void(^JCF_ResultBlock)(BOOL successful,NSArray *fireModelArray);


/**
 * JCF_SQLAddModelBlock  增添
 * 
 *
 */
typedef void(^JCF_SQLAddModelBlock)(NSString *sqlString,NSArray *valueArray);


/**
 * JCF_GetModelValueBlock
 *
 *
 */
typedef NS_ENUM(NSInteger){
    PROPERTY_TYPE_STRING = 1,
    PROPERTY_TYPE_DATA = 2,
    PROPERTY_TYPE_LONGLONG = 3
}PROPERTY_TYPE;
typedef id (^JCF_GetModelValueBlock)(NSString *columeName,PROPERTY_TYPE type);
/**
 * JCF_AddPropertyBlcok 添加 行列的 block
 *
 *
 */
typedef void (^JCF_AddPropertyBlcok)(NSString *sqlString);




#endif /* JCF_ModelBlockHeader_h */
