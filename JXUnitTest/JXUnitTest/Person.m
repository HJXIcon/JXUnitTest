//
//  Person.m
//  JXUnitTest
//
//  Created by mac on 17/8/10.
//  Copyright © 2017年 JXIcon. All rights reserved.
//

#import "Person.h"

@implementation Person

+ (instancetype)personWithDict:(NSDictionary *)dict {
    Person *obj = [[self alloc] init];
    
    [obj setValuesForKeysWithDictionary:dict];
    
    if (obj.age < 0 || obj.age > 100) {
        obj.age = 0;
    }
    
    return obj;
}


+ (void)loadPersonWithCompletion:(void (^)(Person *))completion {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        [NSThread sleepForTimeInterval:1.0];
        
        NSDictionary *dict = @{@"name": @"zhangsan", @"age": @20};
        Person *person = [self personWithDict:dict];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(person);
        });
    });
}



@end
