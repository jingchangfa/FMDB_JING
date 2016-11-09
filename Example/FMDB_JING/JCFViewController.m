//
//  JCFViewController.m
//  FMDB_JING
//
//  Created by jing on 11/09/2016.
//  Copyright (c) 2016 jing. All rights reserved.
//

#import "JCFViewController.h"
#import "JCF_ModelManager.h"
#import "Student.h"
#import "Teacher.h"

@interface JCFViewController ()
@property (nonatomic,strong)JCF_ModelManager *sqlManager;

@end

@implementation JCFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)addAction:(id)sender {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.sqlManager updataModelByType:MODEL_MANAGER_TYPE_ADD WithModel:[Teacher getOnePeople]];
    });
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.sqlManager updataModelByType:MODEL_MANAGER_TYPE_ADD WithModel:[Student getOnePeople]];
    });
}
- (IBAction)addMoreAction:(id)sender {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.sqlManager updateModelsByType:MODEL_MANAGER_TYPE_ADD WithModels:[Teacher getFourPeople] AndFinishBlock:^(BOOL successful, NSArray *fireModelArray) {
            NSLog(@"批量添加%d-----%@",successful,fireModelArray);
        }];
    });
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.sqlManager updateModelsByType:MODEL_MANAGER_TYPE_ADD WithModels:[Student getFourPeople] AndFinishBlock:^(BOOL successful, NSArray *fireModelArray) {
            NSLog(@"批量添加%d-----%@",successful,fireModelArray);
        }];
    });
}




- (IBAction)removeAction:(id)sender {
    [self.sqlManager updataModelByType:MODEL_MANAGER_TYPE_REM WithModel:[Teacher getOnePeople]];
}
- (IBAction)removeMoreAction:(id)sender {
    [self.sqlManager updateModelsByType:MODEL_MANAGER_TYPE_REM WithModels:[Student getFourPeople] AndFinishBlock:^(BOOL successful, NSArray *fireModelArray) {
        NSLog(@"批量删除%d-----%@",successful,fireModelArray);
    }];
}

- (IBAction)updateAction:(id)sender {
    Teacher *teach = (Teacher *)[Teacher getOnePeople];
    teach.name = @"小花";
    [self.sqlManager updataModelByType:MODEL_MANAGER_TYPE_CHANGE WithModel:teach];
}

- (IBAction)updateMoreAction:(id)sender {
    [self.sqlManager updateModelsByType:MODEL_MANAGER_TYPE_CHANGE WithModels:[Student getNewFourPeople] AndFinishBlock:^(BOOL successful, NSArray *fireModelArray) {
        NSLog(@"批量更新%d-----%@",successful,fireModelArray);
    }];
}

- (IBAction)searchAction:(id)sender {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *array = [self.sqlManager searchModelsByModelClass:[Student class] AndSearchPropertyDictionary:@{@"id":@"99"}];
        NSLog(@"%@",array);
    });
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *array = [self.sqlManager searchModelsByModelClass:[Teacher class] AndSearchPropertyDictionary:@{@"teacherID":@"99"}];
        NSLog(@"%@",array);
    });
}
- (IBAction)searchMoreAction:(id)sender {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *array = [self.sqlManager searchModelsByModelClass:[Teacher class] AndSearchPropertyDictionary:@{@"name":@"老师__99"}];
        NSLog(@"%@",array);
    });
}

- (IBAction)searchAll:(id)sender {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *arrayTeacher = [self.sqlManager searchModelsByModelClass:[Teacher class] AndSearchPropertyDictionary:nil];
        NSLog(@"%@",arrayTeacher);
        NSArray *arrayStudent = [self.sqlManager searchModelsByModelClass:[Student class] AndSearchPropertyDictionary:nil];
        NSLog(@"%@",arrayStudent);
    });
}





- (JCF_ModelManager *)sqlManager{
    if (!_sqlManager) {
        _sqlManager = [[JCF_ModelManager alloc] initWithDataBaseName:@""];
    }
    return _sqlManager;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
