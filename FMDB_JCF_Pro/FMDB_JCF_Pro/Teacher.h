//
//  Teacher.h
//  FMDB_JCF_Pro
//
//  Created by jing on 16/11/8.
//  Copyright © 2016年 jing. All rights reserved.
//

#import "ModelBase.h"

@interface Teacher : ModelBase
@property (nonatomic,strong) NSString *teacherID;
@property (nonatomic,strong) NSString *name;
+ (ModelBase *)getOnePeople;
+ (NSArray *)getFourPeople;
+ (NSArray *)getNewFourPeople;
@end
