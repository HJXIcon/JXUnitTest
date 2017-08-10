//
//  JXUnitTestTests.m
//  JXUnitTestTests
//
//  Created by mac on 17/8/10.
//  Copyright © 2017年 JXIcon. All rights reserved.
//


// http://liuyanwei.jumppo.com/2016/03/10/iOS-unit-test.html

/**!
 单元测试类继承自XCTestCase，他有一些重要的方法，其中最重要的有3个， setUp ,tearDown,measureBlock
 
 //每次测试前调用，可以在测试之前创建在test case方法中需要用到的一些对象等
 - (void)setUp ;
 //每次测试结束时调用tearDown方法
 - (void)tearDown ;
 
 //性能测试方法，通过测试block中方法执行的时间，比对设定的标准值和偏差觉得是否可以通过测试
 measureBlock
 
 
 ////>>>>>> 断言
 大部分的测试方法使用断言决定的测试结果。所有断言都有一个类似的形式：比较，表达式为真假，强行失败等。
 //通用断言
 XCTAssert(expression, format...)
 //常用断言：
 XCTAssertTrue(expression, format...)
 XCTAssertFalse(expression, format...)
 XCTAssertEqual(expression1, expression2, format...)
 XCTAssertNotEqual(expression1, expression2, format...)
 XCTAssertEqualWithAccuracy(expression1, expression2, accuracy, format...)
 XCTAssertNotEqualWithAccuracy(expression1, expression2, accuracy, format...)
 XCTAssertNil(expression, format...)
 XCTAssertNotNil(expression, format...)
 
 XCTFail(format...) //直接Fail的断言
 
 
 快捷键：
 cmd + 5 切换到测试选项卡后会看到很多小箭头，点击可以单独或整体测试
 cmd + U 运行整个单元测试
 
 */


#import <XCTest/XCTest.h>
#import "Person.h"

@interface JXUnitTestTests : XCTestCase

@property(nonatomic, strong) UIButton *button;
@end

@implementation JXUnitTestTests

- (void)setUp {
    
    // 实例化需要测试的类
//    self.vc = [[ViewController alloc] init];
    
    [super setUp];
    
}

- (void)tearDown {
    
    //清空
    // self.vc = nil;
    self.button = nil;
    
    
    [super tearDown];
}

// 从这也能看出一个测试用例比较规范的写法，1：定义变量和预期，2：执行方法得到实际值，3：断言
- (void)testExample {
    //设置变量和设置预期值
    NSUInteger a = 10; NSUInteger b = 15;
    NSUInteger expected = 25;
    //执行方法得到实际值
    NSUInteger actual = [self add:a b:b];
    //断言判定实际值和预期是否符合
    XCTAssertEqual(expected, actual,@"add方法错误！");
    
}

- (NSUInteger)add:(NSUInteger)a b:(NSUInteger)b{
    return a+b;
}


// 性能测试主要使用 measureBlock 方法 ，用于测试一组方法的执行时间，通过设置baseline（基准）和stddev（标准偏差）来判断方法是否能通过性能测试。
- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        //你的性能测试的代码放在这里
    }];
}




#pragma mark <期望>
// 举个栗子
- (void)testAsynExample {
    XCTestExpectation *exp = [self expectationWithDescription:@"这里可以是操作出错的原因描述。。。"];
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperationWithBlock:^{
        //模拟这个异步操作需要2秒后才能获取结果，比如一个异步网络请求
        sleep(2);
        //模拟获取的异步操作后，获取结果，判断异步方法的结果是否正确
        XCTAssertEqual(@"a", @"a");
        //如果断言没问题，就调用fulfill宣布测试满足
        [exp fulfill];
    }];
    
    //设置延迟多少秒后，如果没有满足测试条件就报错
    [self waitForExpectationsWithTimeout:3 handler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

/*!
 这个测试肯定是通过的，因为设置延迟为3秒，而异步操作2秒就除了一个正确的结果，并宣布了条件满足 [exp fulfill]，但是当我们把延迟改成1秒，这个测试用例就不会成功，错误原因是expectationWithDescription:@"这里可以是操作出错的原因描述。。。
 
 测试异步除了使用expectationWithDescription以外，还可以使用expectationForPredicate和expectationForNotification
 
 这个下面例子使用expectationForPredicate 测试方法，代码来自于AFNetworking，测试用于backgroundImageForState方法
 
 */


- (void)testThatBackgroundImageChanges {
    XCTAssertNil([self.button backgroundImageForState:UIControlStateNormal]);
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(UIButton  * _Nonnull button, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [button backgroundImageForState:UIControlStateNormal] != nil;
    }];
    
    [self expectationForPredicate:predicate
              evaluatedWithObject:self.button
                          handler:nil];
    [self waitForExpectationsWithTimeout:20 handler:nil];
}

/**！
 利用谓词计算，按钮是否正确的获得了将backgroundImage，如果正确20秒内正确获得则通过测试，否则失败。
 expectationForNotification 方法，方法监听一个通知，如规定时间内正确收到通知则测试通过。
 */

- (void)testAsynExample1 {
    [self expectationForNotification:(@"监听通知的名称xxx") object:nil handler:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"监听通知的名称xxx" object:nil];
    
    //设置延迟多少秒后，如果没有满足测试条件就报错
    [self waitForExpectationsWithTimeout:3 handler:nil];
}

/**!
 例子这个也。可以用expectationWithDescription实现，只是多些很多代码而已，但是可以这个帮助你更好的理解expectationForNotification方法状语从句：expectationWithDescription的区别。同理，expectationForPredicate方法也。可以使用expectationWithDescription实现。


func testAsynExample1() {
    let expectation = expectationWithDescription("监听通知的名称xxx")
    let sub = NSNotificationCenter.defaultCenter().addObserverForName("监听通知的名称xxx", object: nil, queue: nil) { (not) -> Void in
        expectation.fulfill()
    }
    NSNotificationCenter.defaultCenter().postNotificationName("监听通知的名称xxx", object: nil)
    waitForExpectationsWithTimeout(1, handler: nil)
    NSNotificationCenter.defaultCenter().removeObserver(sub)
}
 */

#pragma mark - **** 注意点
/**!
 
 1:该类中以test开头的方法且void返回类型的方法都会变成单元测试用例
 2:单元测试类继承自XCTestCase，他有一些重要的方法，其中最重要的有3个， setUp ,tearDown,measureBlock
 3:使用pod的项目中，在XC测试框架中测试内容包括第三方包时，需要手动去设置标题搜索路径才能找到头文件，还需要设置测试目标的PODS_ROOT。
 4:xcode7要使用真机做跑测试时，证书必须配对，会否则报错exc_breakpoint错误
 5:XCTestExpectation的实现方法只能调用一次，系统不会帮你检查，如果你调用两次就会出错，而且你经常都找不到错在哪里。

 */




#pragma mark - 测试各个断言的用法都列举出来了
/* 测试各个断言 */
- (void)testAssert {
    
    //     XCTFail(format…) 生成一个失败的测试；
    //    XCTFail(@"Fail");
    
    
    // XCTAssertNil(a1, format...) 为空判断， a1 为空时通过，反之不通过；
    //    XCTAssertNil(@"not nil string", @"string must be nil");
    
    
    // XCTAssertNotNil(a1, format…) 不为空判断，a1不为空时通过，反之不通过；
    //    XCTAssertNotNil(@"not nil string", @"string can not be nil");
    
    
    // XCTAssert(expression, format...) 当expression求值为TRUE时通过；
    //    XCTAssert((2 > 2), @"expression must be true");
    
    
    // XCTAssertTrue(expression, format...) 当expression求值为TRUE时通过；
    //    XCTAssertTrue(1, @"Can not be zero");
    
    
    // XCTAssertFalse(expression, format...) 当expression求值为False时通过；
    //    XCTAssertFalse((2 < 2), @"expression must be false");
    
    
    // XCTAssertEqualObjects(a1, a2, format...) 判断相等， [a1 isEqual:a2] 值为TRUE时通过，其中一个不为空时，不通过；
    //    XCTAssertEqualObjects(@"1", @"1", @"[a1 isEqual:a2] should return YES");
    //    XCTAssertEqualObjects(@"1", @"2", @"[a1 isEqual:a2] should return YES");
    
    
    //     XCTAssertNotEqualObjects(a1, a2, format...) 判断不等， [a1 isEqual:a2] 值为False时通过，
    //    XCTAssertNotEqualObjects(@"1", @"1", @"[a1 isEqual:a2] should return NO");
    //    XCTAssertNotEqualObjects(@"1", @"2", @"[a1 isEqual:a2] should return NO");
    
    
    // XCTAssertEqual(a1, a2, format...) 判断相等（当a1和a2是 C语言标量、结构体或联合体时使用,实际测试发现NSString也可以）；
    // 1.比较基本数据类型变量
    //    XCTAssertEqual(1, 2, @"a1 = a2 shoud be true"); // 无法通过测试
    //    XCTAssertEqual(1, 1, @"a1 = a2 shoud be true"); // 通过测试
    
    // 2.比较NSString对象
    //    NSString *str1 = @"1";
    //    NSString *str2 = @"1";
    //    NSString *str3 = str1;
    //    XCTAssertEqual(str1, str2, @"a1 and a2 should point to the same object"); // 通过测试
    //    XCTAssertEqual(str1, str3, @"a1 and a2 should point to the same object"); // 通过测试
    
    // 3.比较NSArray对象
    //    NSArray *array1 = @[@1];
    //    NSArray *array2 = @[@1];
    //    NSArray *array3 = array1;
    //    XCTAssertEqual(array1, array2, @"a1 and a2 should point to the same object"); // 无法通过测试
    //    XCTAssertEqual(array1, array3, @"a1 and a2 should point to the same object"); // 通过测试
    
    
    // XCTAssertNotEqual(a1, a2, format...) 判断不等（当a1和a2是 C语言标量、结构体或联合体时使用）；
    
    
    // XCTAssertEqualWithAccuracy(a1, a2, accuracy, format...) 判断相等，（double或float类型）提供一个误差范围，当在误差范围（+/- accuracy ）以内相等时通过测试；
    //    XCTAssertEqualWithAccuracy(1.0f, 1.5f, 0.25f, @"a1 = a2 in accuracy should return YES");
    
    
    // XCTAssertNotEqualWithAccuracy(a1, a2, accuracy, format...) 判断不等，（double或float类型）提供一个误差范围，当在误差范围以内不等时通过测试；
    //    XCTAssertNotEqualWithAccuracy(1.0f, 1.5f, 0.25f, @"a1 = a2 in accuracy should return NO");
    
    
    // XCTAssertThrows(expression, format...) 异常测试，当expression发生异常时通过；反之不通过；（很变态）
    
    
    // XCTAssertThrowsSpecific(expression, specificException, format...) 异常测试，当expression发生 specificException 异常时通过；反之发生其他异常或不发生异常均不通过；
    
    // XCTAssertThrowsSpecificNamed(expression, specificException, exception_name, format...) 异常测试，当expression发生具体异常、具体异常名称的异常时通过测试，反之不通过；
    
    
    // XCTAssertNoThrow(expression, format…) 异常测试，当expression没有发生异常时通过测试；
    
    
    // XCTAssertNoThrowSpecific(expression, specificException, format...)异常测试，当expression没有发生具体异常、具体异常名称的异常时通过测试，反之不通过；
    
    
    // XCTAssertNoThrowSpecificNamed(expression, specificException, exception_name, format...) 异常测试，当expression没有发生具体异常、具体异常名称的异常时通过测试，反之不通过
}



#pragma mark - <针对Person测试>
#pragma mark 逻辑测试
/// 测试实例化 Person 对象
- (void)testNewPerson {
    [self checkPersonWithDict:@{@"name": @"zhangsan", @"age": @19}];
    [self checkPersonWithDict:@{@"name": @"zhangsan"}];
    [self checkPersonWithDict:@{}];
    [self checkPersonWithDict:@{@"name": @"zhangsan", @"age": @101}];
    [self checkPersonWithDict:@{@"name": @"zhangsan", @"age": @-1}];
}

- (void)checkPersonWithDict:(NSDictionary *)dict {
    
    Person *person = [Person personWithDict:dict];
    
    if (dict[@"name"] == nil) {
        XCTAssertNil(person.name, @"name应该为 nil");
    } else {
        XCTAssert([person.name isEqualToString:dict[@"name"]], @"姓名不匹配");
    }
    
    NSInteger age = [dict[@"age"] integerValue];
    if (age > 100 || age < 0) {
        XCTAssert(person.age == 0, @"年龄不正确");
    } else {
        XCTAssert(person.age == [dict[@"age"] integerValue], @"年龄不正确");
    }
}

#pragma mark 性能测试
- (void)testNewPersonPerformance {
    
    [self measureBlock:^{
        for (NSInteger i = 0; i < 10000; i++) {
            [Person personWithDict:@{@"name": @"zhangsan", @"age": @19}];
        }
    }];
}

#pragma mark 异步测试
- (void)testLoadPerson {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"测试异步"];
    
    [Person loadPersonWithCompletion:^(Person *person) {
        XCTAssertNotNil(person.name, @"姓名为空");
        XCTAssert(person.age > 0, @"年龄不正确");
        
        [expectation fulfill];
    }];
    
     //设置延迟多少秒后，如果没有满足测试条件就报错
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

/**!
 单元测试是一种通过代码检测代码的开发手段，常用于敏捷开发和测试驱动开发
 代码检测通常需要(预先/预想)设置边界条件，因为 UI 测试的时候，很多边界条件不容易满足
 单元测试主要针对业务逻辑代码进行测试！不适合做 UI(ViewController) 的测试！
 MVVM 的设计模式，把几乎所有重要的业务逻辑全部封装在视图模型，通过单元测试就很方便检测条件以及代码质量！
 测试覆盖率，有很多人会讨论到底多少代码应该测试！
 需要针对业务逻辑的对外开发的函数重点测试！如果有局部复杂的业务逻辑小函数，可以临时测试！
 通常公司的代码测试覆盖率从 50% - 70%不等
 Xcode 的单元测试，还能够做性能测试
 Xcode 可以利用性能测试，对某一段代码，重复测试 10 次！
 
 
 单元测试：
 什么时候用到单元测试
 1.写完代码以后：想要验证一下自己写的代码是否有问题；
 2.写代码之前：就是写代码之前所有的功能分模块的设计好，测试通过了再写；
 3.修复某个bug后：一般修复某个bug，为了确保修复是否成功，会写测试；
 
 怎么写单元测试：
 为了更方便地进行单元测试，业务代码应避免以下情况：
 存在太多条件逻辑 构造函数中做的事情太多 存在太多全局状态 混杂了太多无关的逻辑 存在太多静态方法 存在过多外部依赖

 
 
 
 */




@end
