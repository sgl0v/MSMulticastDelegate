//
// MSEventHandlerDelegateImpl.h
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

#import "MSEventHandlerDelegate.h"

@interface MSEventHandlerDelegateImpl : NSObject <MSEventHandlerDelegate>

@property (nonatomic, weak) id eventHandler;
@property (nonatomic, strong) NSString* eventName;
@property (nonatomic, assign) BOOL status;

@end

@implementation MSEventHandlerDelegateImpl

- (void)eventHandler:(id)eventHandler didStartEvent:(NSString*)eventName
{
    NSLog(@"<%@ : %p %@> %@", self.class, NSStringFromSelector(_cmd), eventHandler, eventName);
    _eventHandler = eventHandler;
    _eventName = eventName;
}

- (void)eventHandler:(id)eventHandler didFinishEvent:(NSString*)eventName withStatus:(BOOL)status
{
    NSLog(@"<%@ : %p %@> %@ %d", self.class, NSStringFromSelector(_cmd), eventHandler, eventName, status);
    _eventHandler = eventHandler;
    _eventName = eventName;
    _status = status;
}

@end

@interface MSExtendedEventHandlerDelegateImpl : NSObject <MSExtendedEventHandlerDelegate>

@property (nonatomic, weak) id eventHandler;
@property (nonatomic, strong) NSString* eventName;
@property (nonatomic, assign) BOOL requierdCallHandled;
@property (nonatomic, assign) NSInteger counter;

@end

@implementation MSExtendedEventHandlerDelegateImpl

- (void)eventHandler:(id)eventHandler didStartEvent:(NSString*)eventName
{
    NSLog(@"<%@ : %p %@> %@", self.class, NSStringFromSelector(_cmd), eventHandler, eventName);
    _eventHandler = eventHandler;
    _eventName = eventName;
}

- (void)requiredCall
{
    NSLog(@"<%@ : %p %@>", self.class, self, NSStringFromSelector(_cmd));
    _requierdCallHandled = YES;
}

@end
