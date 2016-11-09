//
//  Student.m
//  FMDB_JCF_Pro
//
//  Created by jing on 16/11/8.
//  Copyright © 2016年 jing. All rights reserved.
//

#import "Student.h"

@implementation Student
+ (ModelBase *)getOnePeople{
    Student *stu = [[Student alloc] init];
    stu.ID = @"99";
    stu.name = @"学生__99";
    return stu;
}
+ (NSArray *)getFourPeople{
    NSMutableArray *array =[NSMutableArray array];
    for (int i = 0; i<4; i++) {
        Student *stu = [[Student alloc] init];
        stu.ID = [NSString stringWithFormat:@"%d",i];
        stu.name = [@"学生__" stringByAppendingString:stu.ID];
        [array addObject:stu];
    }
    return array;
}
+ (NSArray *)getNewFourPeople{
    NSMutableArray *array =[NSMutableArray array];
    for (int i = 0; i<4; i++) {
        Student *stu = [[Student alloc] init];
        stu.ID = [NSString stringWithFormat:@"%d",i];
        stu.name = [@"小明__" stringByAppendingString:stu.ID];
        [array addObject:stu];
    }
    return array;
}
@end
