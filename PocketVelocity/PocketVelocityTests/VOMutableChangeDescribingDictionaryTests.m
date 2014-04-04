//
//  VOMutableChangeDescribingDictionaryTests.m
//  PocketVelocity
//
//  Created by Brian Dewey on 4/2/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "VOChangeDescribingDictionary.h"
#import "VOMutableChangeDescribingDictionary.h"

@interface VOMutableChangeDescribingDictionaryTests : XCTestCase

@end

@implementation VOMutableChangeDescribingDictionaryTests

- (void)setUp
{
  [super setUp];
  // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
  // Put teardown code here. This method is called after the invocation of each test method in the class.
  [super tearDown];
}

- (void)testBasicCopyingAndMutation
{
  VOMutableChangeDescribingDictionary *values = [[VOMutableChangeDescribingDictionary alloc] init];
  
  values[@"brian"] = @(312);
  values[@"alex"]  = @(319);
  
  XCTAssertEqual((NSUInteger)2, values.count, @"");
  
  VOMutableChangeDescribingDictionary *mutableCopy = [values mutableCopy];
  mutableCopy[@"brian"] = @"father";
  mutableCopy[@"patrick"] = @"son";
  
  XCTAssertEqual((NSUInteger)3, mutableCopy.count, @"");
  XCTAssertEqual((NSUInteger)2, values.count, @"");
  XCTAssertEqualObjects(@(312), values[@"brian"], @"");
  XCTAssertEqualObjects(@"father", mutableCopy[@"brian"], @"");
  XCTAssertEqualObjects(@(319), mutableCopy[@"alex"], @"");
  XCTAssertNil(mutableCopy[@"led zeppelin"], @"");
  
  VOChangeDescribingDictionary *immutableCopy = [mutableCopy copy];
  XCTAssertEqualObjects(immutableCopy, mutableCopy, @"");
  [mutableCopy removeObjectForKey:@"brian"];
  XCTAssertNotEqualObjects(immutableCopy, mutableCopy, @"");
  XCTAssertEqual(immutableCopy, [immutableCopy copy], @"");
}
@end
