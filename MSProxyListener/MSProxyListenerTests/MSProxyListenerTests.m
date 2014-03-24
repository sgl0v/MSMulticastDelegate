//
// MSProxyListenerTests.m
// MSProxyListener
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
#import "MSProxyListener.h"
#import "MSListener.h"
#import "MSListenerImpl.h"
#import "MSDummyProxyListeners.h"


@interface MSProxyListenerTests : XCTestCase
@end

@implementation MSProxyListenerTests

- (void)testDesignatedInitializer
{
    // check correct initialization using designated initializer
    MSProxyListener* proxyListener = [[MSProxyListenerImpl alloc] initWithProtocol:@protocol(MSListener)];
    XCTAssertTrue([proxyListener.listeners count] == 0, @"The object is not constructed correctly!");
    XCTAssertEqualObjects(@protocol(MSListener), proxyListener.protocol, @"The object is not constructed correctly!");
}

- (void)testConvenienceConstructors
{
    // check correct object creation using convenience constructor
    MSProxyListener* proxyListener = [MSProxyListenerImpl proxyListenerForProtocol:@protocol(MSListener)];
    XCTAssertTrue([proxyListener.listeners count] == 0, @"The object is not constructed correctly!");
    XCTAssertEqualObjects(@protocol(MSListener), proxyListener.protocol, @"The object is not constructed correctly!");

    // the behavior of convenience constructors should be the same
    MSProxyListener* proxyListenerCreatedExplicitly = [MSProxyListenerImpl proxyListenerForProtocol:@protocol(MSListener)];
    MSProxyListener* proxyListenerCreatedImplicitly = [MSProxyListenerImpl proxyListener];
    XCTAssertEqualObjects(proxyListenerCreatedExplicitly.protocol, proxyListenerCreatedImplicitly.protocol,
                           @"The convenience constructors doesn't work correctly!");
    XCTAssertEqual([proxyListenerCreatedExplicitly.listeners count], [proxyListenerCreatedImplicitly.listeners count],
                           @"The convenience constructors doesn't work correctly!");
}

- (void)testListenersContainer
{
    MSListenerImpl* listener1 = [[MSListenerImpl alloc] init];
    MSListenerImpl* listener2 = [[MSListenerImpl alloc] init];
    MSListenerImpl* listener3 = [[MSListenerImpl alloc] init];
    MSExtendedListenerImpl* extendedListener1 = [[MSExtendedListenerImpl alloc] init];
    MSProxyListenerImpl* proxyListener = [MSProxyListenerImpl proxyListenerForProtocol:@protocol(MSListener)];
    [proxyListener addObject:listener1];
    [proxyListener addObject:listener2];
    [proxyListener addObject:listener3];
    XCTAssertTrue([proxyListener count] == 3, @"The listeners count is not correct!");
    [proxyListener removeObject:listener3];
    XCTAssertTrue([proxyListener count] == 2, @"The object is not removed from the proxy listener's container!");
    [proxyListener removeObject:extendedListener1];
    XCTAssertTrue([proxyListener count] == 2, @"The proxy listener removes an object, that was not added before!");
    [proxyListener addObject:extendedListener1];
    XCTAssertTrue([proxyListener count] == 3, @"The proxy listener doesn't add a valid object!");
    XCTAssertTrue([proxyListener containsObject:extendedListener1], @"The proxy listener doesn't contain an object, that was added before!");
    XCTAssertTrue([proxyListener containsObject:listener1], @"The proxy listener doesn't contain an object, that was added before!");
    [proxyListener removeAllObjects];
    XCTAssertTrue([proxyListener count] == 0, @"The listeners count is not correct!");
}

- (void)testRespondsToSelector
{
    MSProxyListenerImpl* proxyListener = [MSProxyListenerImpl proxyListenerForProtocol:@protocol(MSListener)];
    XCTAssertTrue([proxyListener respondsToSelector:@selector(caller:didStartWithString:)], @"The proxy listener doesn't respond to the valid selector!");
    XCTAssertTrue([proxyListener respondsToSelector:@selector(caller:didEndWithString:booleanFlag:)], @"The proxy listener doesn't respond to the valid selector!");
    XCTAssertFalse([proxyListener respondsToSelector:@selector(requiredCall)], @"The proxy listener responds to the invalid selector!");
}

- (void)testConformsToProtocol
{
    MSProxyListenerImpl* proxyListener = [MSProxyListenerImpl proxyListenerForProtocol:@protocol(MSListener)];
    MSExtendedProxyListenerImpl* extendedProxyListener = [MSExtendedProxyListenerImpl proxyListenerForProtocol:@protocol(MSExtendedListener)];
    XCTAssertTrue([proxyListener conformsToProtocol:@protocol(MSListener)], @"The proxy listener doesn't conform to the valid protocol!");
    XCTAssertTrue([extendedProxyListener conformsToProtocol:@protocol(MSExtendedListener)], @"The proxy listener doesn't conform to the valid protocol!");
    XCTAssertTrue([extendedProxyListener conformsToProtocol:@protocol(MSListener)], @"The proxy listener doesn't conform to the valid protocol!");
    XCTAssertFalse([proxyListener conformsToProtocol:@protocol(MSExtendedListener)], @"The proxy listener conforms to the invalid protocol!");
}

- (void)testListenerBeingCalled
{
    MSListenerImpl* listener = [[MSListenerImpl alloc] init];
    MSProxyListenerImpl* proxyListener = [MSProxyListenerImpl proxyListenerForProtocol:@protocol(MSListener)];
    [proxyListener addObject:listener];

    [proxyListener caller:self didStartWithString:@"test1"];
    XCTAssertEqual(self, listener.caller, @"The delegate %@ call was not handled correctly!", NSStringFromSelector(@selector(caller:didStartWithString:)));
    XCTAssertEqualObjects(@"test1", listener.stringValue, @"The delegate %@ call was not handled correctly!", NSStringFromSelector(@selector(caller:didStartWithString:)));
}

- (void)testCallWithNilledListener
{
    MSProxyListenerImpl* proxyListener = [MSProxyListenerImpl proxyListenerForProtocol:@protocol(MSListener)];
    @autoreleasepool {
        MSListenerImpl* listener = [[MSListenerImpl alloc] init];
        [proxyListener addObject:listener];
    }
    XCTAssertTrue([[proxyListener.listeners allObjects] count] == 0, @"The listeners count is not correct!");
    [proxyListener caller:self didStartWithString:@"test1"];
}

- (void)testRequiredAndOptionalCalls
{
    MSExtendedListenerImpl* extendedListener = [[MSExtendedListenerImpl alloc] init];
    MSExtendedProxyListenerImpl* extendedProxyListener = [MSExtendedProxyListenerImpl proxyListenerForProtocol:@protocol(MSExtendedListener)];
    [extendedProxyListener addObject:extendedListener];
    [extendedProxyListener requiredCall];
    XCTAssertTrue(extendedListener.requierdCallHandled, @"The required call wasn't handled!");
    [extendedProxyListener optionalCall];
    [extendedProxyListener caller:self didStartWithString:@"test"];
    XCTAssertEqual(self, extendedListener.caller, @"The delegate %@ call was not handled correctly!", NSStringFromSelector(@selector(caller:didStartWithString:)));
    XCTAssertEqualObjects(@"test", extendedListener.stringValue, @"The delegate %@ call was not handled correctly!", NSStringFromSelector(@selector(caller:didStartWithString:)));
}

- (void)testPropertyBeingCalled
{
    MSExtendedListenerImpl* extendedListener = [[MSExtendedListenerImpl alloc] init];
    MSExtendedProxyListenerImpl* extendedProxyListener = [MSExtendedProxyListenerImpl proxyListenerForProtocol:@protocol(MSExtendedListener)];
    [extendedProxyListener addObject:extendedListener];
    extendedProxyListener.counter = 3;
    XCTAssertTrue(extendedListener.counter == 3, @"The setter message is not forwarded!");
}

- (void)testCallsForDerivedProtocols
{
    MSListenerImpl* listener = [[MSListenerImpl alloc] init];
    MSExtendedListenerImpl* extendedListener = [[MSExtendedListenerImpl alloc] init];
    MSProxyListenerImpl* proxyListener = [MSProxyListenerImpl proxyListenerForProtocol:@protocol(MSListener)];
    [proxyListener addObject:listener];
    [proxyListener addObject:extendedListener];

    [proxyListener caller:self didStartWithString:@"test1"];
    XCTAssertEqual(self, listener.caller, @"The delegate %@ call was not handled correctly!", NSStringFromSelector(@selector(caller:didStartWithString:)));
    XCTAssertEqualObjects(@"test1", listener.stringValue, @"The delegate %@ call was not handled correctly!", NSStringFromSelector(@selector(caller:didStartWithString:)));
    XCTAssertEqual(self, extendedListener.caller, @"The delegate %@ call was not handled correctly!", NSStringFromSelector(@selector(caller:didStartWithString:)));
    XCTAssertEqualObjects(@"test1", extendedListener.stringValue, @"The delegate %@ call was not handled correctly!", NSStringFromSelector(@selector(caller:didStartWithString:)));

    [proxyListener caller:self didEndWithString:@"test2" booleanFlag:YES];
    XCTAssertEqual(self, listener.caller, @"The delegate %@ call was not handled correctly!", NSStringFromSelector(@selector(caller:didEndWithString:booleanFlag:)));
    XCTAssertEqualObjects(@"test2", listener.stringValue, @"The delegate %@ call was not handled correctly!", NSStringFromSelector(@selector(caller:didEndWithString:booleanFlag:)));
    XCTAssertTrue(listener.booleanFlag, @"The delegate %@ call was not handled correctly!", NSStringFromSelector(@selector(caller:didEndWithString:booleanFlag:)));
    XCTAssertNotEqualObjects(@"test2", extendedListener.stringValue, @"The delegate %@ call was not handled correctly!", NSStringFromSelector(@selector(caller:didEndWithString:booleanFlag:)));
}

@end
