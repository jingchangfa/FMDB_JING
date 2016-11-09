//
//  Teacher.m
//  FMDB_JCF_Pro
//
//  Created by jing on 16/11/8.
//  Copyright © 2016年 jing. All rights reserved.
//

#import "Teacher.h"

@implementation Teacher
+ (ModelBase *)getOnePeople{
    Teacher *tea = [[Teacher alloc] init];
    tea.teacherID = @"99";
    tea.name = @"老师__99";
    return tea;
}
+ (NSArray *)getFourPeople{
    NSMutableArray *array =[NSMutableArray array];
    for (int i = 0; i<4; i++) {
        Teacher *tea = [[Teacher alloc] init];
        tea.teacherID = [NSString stringWithFormat:@"%d",i];
        tea.name = [@"老师__" stringByAppendingString:tea.teacherID];
        if (i == 3) {
            tea.name = @"老师__99";
        }
        [array addObject:tea];
    }
    return array;
}
+ (NSArray *)getNewFourPeople{
    NSMutableArray *array =[NSMutableArray array];
    for (int i = 0; i<4; i++) {
        Teacher *tea = [[Teacher alloc] init];
        tea.teacherID = [NSString stringWithFormat:@"%d",i];
        tea.name = [@"西红老师__" stringByAppendingString:tea.teacherID];
        if (i == 3) {
            tea.name = @"老师__99";
        }
        [array addObject:tea];
    }
    return array;
}



+(NSString *)mainKey{
    return @"teacherID";
}
@end
