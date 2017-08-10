//
//  Person.h
//  JXUnitTest
//
//  Created by mac on 17/8/10.
//  Copyright © 2017年 JXIcon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSInteger age;

+ (instancetype)personWithDict:(NSDictionary *)dict;

+ (void)loadPersonWithCompletion:(void (^)(Person *))completion;
@end
