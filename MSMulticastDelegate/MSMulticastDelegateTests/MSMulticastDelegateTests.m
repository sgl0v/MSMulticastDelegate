//
// MSMulticastDelegateTests.m
// MSMulticastDelegate
//
// The MIT License (MIT)
//
// Copyright (c) 2014 Maksym Shcheglov
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <XCTest/XCTest.h>
#import "MSMulticastDelegate.h"
#import "MSEventHandlerDelegate.h"
#import "MSEventHandlerDelegateImpl.h"
#import "MSDummyMulticastDelegates.h"


@interface MSMulticastDelegateTests : XCTestCase
@end

@implementation MSMulticastDelegateTests

- (void)testDesignatedInitializer
{
    // check correct initialization using designated initializer
    MSMulticastDelegate* multicastDelegate = [[MSMulticastDelegateImpl alloc] initWithProtocol:@protocol(MSEventHandlerDelegate)];
    XCTAssertTrue([multicastDelegate.delegates count] == 0, @"The object is not constructed correctly!");
    XCTAssertEqualObjects(@protocol(MSEventHandlerDelegate), multicastDelegate.protocol, @"The object is not constructed correctly!");
}

- (void)testConvenienceConstructors
{
    // check correct object creation using convenience constructor
    MSMulticastDelegate* multicastDelegate = [MSMulticastDelegateImpl multicastDelegateForProtocol:@protocol(MSEventHandlerDelegate)];
    XCTAssertTrue([multicastDelegate.delegates count] == 0, @"The object is not constructed correctly!");
    XCTAssertEqualObjects(@protocol(MSEventHandlerDelegate), multicastDelegate.protocol, @"The object is not constructed correctly!");

    // the behavior of convenience constructors should be the same
    MSMulticastDelegate* multicastDelegateCreatedExplicitly = [MSExtendedMulticastDelegateImpl multicastDelegateForProtocol:@protocol(MSExtendedEventHandlerDelegate)];
    MSMulticastDelegate* multicastDelegateCreatedImplicitly = [MSExtendedMulticastDelegateImpl multicastDelegate];
    XCTAssertEqualObjects(multicastDelegateCreatedExplicitly.protocol, multicastDelegateCreatedImplicitly.protocol,
                           @"The convenience constructors doesn't work correctly!");
    XCTAssertEqual([multicastDelegateCreatedExplicitly.delegates count], [multicastDelegateCreatedImplicitly.delegates count],
                           @"The convenience constructors doesn't work correctly!");
}

- (void)testInitWithInvalidParameters
{
    XCTAssertThrows([MSMulticastDelegateImpl multicastDelegateForProtocol:@protocol(MSExtendedEventHandlerDelegate)], @"The multicast delegate accepts protocol, that is doesn't conform to");
    XCTAssertThrows([[MSMulticastDelegateImpl alloc] initWithProtocol:@protocol(MSExtendedEventHandlerDelegate)], @"The multicast delegate accepts protocol, that is doesn't conform to");
    XCTAssertThrows([MSMulticastDelegateImpl multicastDelegate], @"The multicast delegate's convenience constructor works only for classes that implement one protocol!");
}

- (void)testDelegatesContainer
{
    MSEventHandlerDelegateImpl* delegate1 = [[MSEventHandlerDelegateImpl alloc] init];
    MSEventHandlerDelegateImpl* delegate2 = [[MSEventHandlerDelegateImpl alloc] init];
    MSEventHandlerDelegateImpl* delegate3 = [[MSEventHandlerDelegateImpl alloc] init];
    MSExtendedEventHandlerDelegateImpl* extendedMulticastDelegate1 = [[MSExtendedEventHandlerDelegateImpl alloc] init];
    MSMulticastDelegateImpl* multicastDelegate = [MSMulticastDelegateImpl multicastDelegateForProtocol:@protocol(MSEventHandlerDelegate)];
    [multicastDelegate addObject:delegate1];
    [multicastDelegate addObject:delegate2];
    [multicastDelegate addObject:delegate3];
    XCTAssertTrue([multicastDelegate count] == 3, @"The delegates count is not correct!");
    [multicastDelegate removeObject:delegate3];
    XCTAssertTrue([multicastDelegate count] == 2, @"The object is not removed from the multicast delegate's container!");
    [multicastDelegate removeObject:extendedMulticastDelegate1];
    XCTAssertTrue([multicastDelegate count] == 2, @"The multicast delegate removes an object, that was not added before!");
    [multicastDelegate addObject:extendedMulticastDelegate1];
    XCTAssertTrue([multicastDelegate count] == 3, @"The multicast delegate doesn't add a valid object!");
    XCTAssertTrue([multicastDelegate containsObject:extendedMulticastDelegate1], @"The multicast delegate doesn't contain an object, that was added before!");
    XCTAssertTrue([multicastDelegate containsObject:delegate1], @"The multicast delegate doesn't contain an object, that was added before!");
    [multicastDelegate removeAllObjects];
    XCTAssertTrue([multicastDelegate count] == 0, @"The delegates count is not correct!");
}

- (void)testRespondsToSelector
{
    MSMulticastDelegateImpl* multicastDelegate = [MSMulticastDelegateImpl multicastDelegateForProtocol:@protocol(MSEventHandlerDelegate)];
    XCTAssertTrue([multicastDelegate respondsToSelector:@selector(eventHandler:didStartEvent:)], @"The multicast delegate doesn't respond to the valid selector!");
    XCTAssertTrue([multicastDelegate respondsToSelector:@selector(eventHandler:didFinishEvent:withStatus:)], @"The multicast delegate doesn't respond to the valid selector!");
    XCTAssertFalse([multicastDelegate respondsToSelector:@selector(requiredCall)], @"The multicast delegate responds to the invalid selector!");
}

- (void)testConformsToProtocol
{
    MSMulticastDelegateImpl* multicastDelegate = [MSMulticastDelegateImpl multicastDelegateForProtocol:@protocol(MSEventHandlerDelegate)];
    MSExtendedMulticastDelegateImpl* extendedProxyDelegate = [MSExtendedMulticastDelegateImpl multicastDelegateForProtocol:@protocol(MSExtendedEventHandlerDelegate)];
    XCTAssertTrue([multicastDelegate conformsToProtocol:@protocol(MSEventHandlerDelegate)], @"The multicast delegate doesn't conform to the valid protocol!");
    XCTAssertTrue([extendedProxyDelegate conformsToProtocol:@protocol(MSExtendedEventHandlerDelegate)], @"The multicast delegate doesn't conform to the valid protocol!");
    XCTAssertTrue([extendedProxyDelegate conformsToProtocol:@protocol(MSEventHandlerDelegate)], @"The multicast delegate doesn't conform to the valid protocol!");
    XCTAssertFalse([multicastDelegate conformsToProtocol:@protocol(MSExtendedEventHandlerDelegate)], @"The multicast delegate conforms to the invalid protocol!");
}

- (void)testDelegateBeingCalled
{
    MSEventHandlerDelegateImpl* delegate = [[MSEventHandlerDelegateImpl alloc] init];
    MSMulticastDelegateImpl* multicastDelegate = [MSMulticastDelegateImpl multicastDelegateForProtocol:@protocol(MSEventHandlerDelegate)];
    [multicastDelegate addObject:delegate];

    [multicastDelegate eventHandler:self didStartEvent:@"event_name"];
    XCTAssertEqual(self, delegate.eventHandler, @"The delegate %@ call was not handled correctly!", NSStringFromSelector(@selector(eventHandler:didStartEvent:)));
    XCTAssertEqualObjects(@"event_name", delegate.eventName, @"The delegate %@ call was not handled correctly!", NSStringFromSelector(@selector(eventHandler:didStartEvent:)));
}

- (void)testCallWithNilledDelegate
{
    MSMulticastDelegateImpl* multicastDelegate = [MSMulticastDelegateImpl multicastDelegateForProtocol:@protocol(MSEventHandlerDelegate)];
    @autoreleasepool {
        MSEventHandlerDelegateImpl* delegate = [[MSEventHandlerDelegateImpl alloc] init];
        [multicastDelegate addObject:delegate];
    }
    XCTAssertTrue([[multicastDelegate.delegates allObjects] count] == 0, @"The delegates count is not correct!");
    [multicastDelegate eventHandler:self didStartEvent:@"test1"];
}

- (void)testRequiredAndOptionalCalls
{
    MSExtendedEventHandlerDelegateImpl* extendedDelegate = [[MSExtendedEventHandlerDelegateImpl alloc] init];
    MSExtendedMulticastDelegateImpl* extendedProxyDelegate = [MSExtendedMulticastDelegateImpl multicastDelegateForProtocol:@protocol(MSExtendedEventHandlerDelegate)];
    [extendedProxyDelegate addObject:extendedDelegate];
    [extendedProxyDelegate requiredCall];
    XCTAssertTrue(extendedDelegate.requierdCallHandled, @"The required call wasn't handled!");
    [extendedProxyDelegate optionalCall];
    [extendedProxyDelegate eventHandler:self didStartEvent:@"event_name"];
    XCTAssertEqual(self, extendedDelegate.eventHandler, @"The delegate %@ call was not handled correctly!", NSStringFromSelector(@selector(eventHandler:didStartEvent:)));
    XCTAssertEqualObjects(@"event_name", extendedDelegate.eventName, @"The delegate %@ call was not handled correctly!", NSStringFromSelector(@selector(eventHandler:didStartEvent:)));
}

- (void)testPropertyBeingCalled
{
    MSExtendedEventHandlerDelegateImpl* extendedDelegate = [[MSExtendedEventHandlerDelegateImpl alloc] init];
    MSExtendedMulticastDelegateImpl* extendedProxyDelegate = [MSExtendedMulticastDelegateImpl multicastDelegateForProtocol:@protocol(MSExtendedEventHandlerDelegate)];
    [extendedProxyDelegate addObject:extendedDelegate];
    extendedProxyDelegate.counter = 3;
    XCTAssertTrue(extendedDelegate.counter == 3, @"The setter message is not forwarded!");
}

- (void)testCallsForDerivedProtocols
{
    MSEventHandlerDelegateImpl* delegate = [[MSEventHandlerDelegateImpl alloc] init];
    MSExtendedEventHandlerDelegateImpl* extendedDelegate = [[MSExtendedEventHandlerDelegateImpl alloc] init];
    MSMulticastDelegateImpl* multicastDelegate = [MSMulticastDelegateImpl multicastDelegateForProtocol:@protocol(MSEventHandlerDelegate)];
    [multicastDelegate addObject:delegate];
    [multicastDelegate addObject:extendedDelegate];

    [multicastDelegate eventHandler:self didStartEvent:@"test1"];
    XCTAssertEqual(self, delegate.eventHandler, @"The delegate %@ call was not handled correctly!", NSStringFromSelector(@selector(eventHandler:didStartEvent:)));
    XCTAssertEqualObjects(@"test1", delegate.eventName, @"The delegate %@ call was not handled correctly!", NSStringFromSelector(@selector(eventHandler:didStartEvent:)));
    XCTAssertEqual(self, extendedDelegate.eventHandler, @"The delegate %@ call was not handled correctly!", NSStringFromSelector(@selector(eventHandler:didStartEvent:)));
    XCTAssertEqualObjects(@"test1", extendedDelegate.eventName, @"The delegate %@ call was not handled correctly!", NSStringFromSelector(@selector(eventHandler:didStartEvent:)));

    [multicastDelegate eventHandler:self didFinishEvent:@"test2" withStatus:YES];
    XCTAssertEqual(self, delegate.eventHandler, @"The delegate %@ call was not handled correctly!", NSStringFromSelector(@selector(eventHandler:didFinishEvent:withStatus:)));
    XCTAssertEqualObjects(@"test2", delegate.eventName, @"The delegate %@ call was not handled correctly!", NSStringFromSelector(@selector(eventHandler:didFinishEvent:withStatus:)));
    XCTAssertTrue(delegate.status, @"The delegate %@ call was not handled correctly!", NSStringFromSelector(@selector(eventHandler:didFinishEvent:withStatus:)));
    XCTAssertNotEqualObjects(@"test2", extendedDelegate.eventName, @"The delegate %@ call was not handled correctly!", NSStringFromSelector(@selector(eventHandler:didFinishEvent:withStatus:)));
}

@end
