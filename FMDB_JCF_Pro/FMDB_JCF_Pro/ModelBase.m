//
//  ModelBase.m
//  FMDB_JCF_Pro
//
//  Created by jing on 16/11/8.
//  Copyright © 2016年 jing. All rights reserved.
//

#import "ModelBase.h"

@implementation ModelBase

+ (NSString *)mainKey{
    return @"ID";
}

+(NSArray *)transients{
    return nil;
}

-(NSString *)mainKey{
    return @"ID";
}
@end
