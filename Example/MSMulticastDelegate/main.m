//
// main.m
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

#import <Foundation/Foundation.h>

#import "MSMulticastDelegate.h"
#import "MSEventHandlerDelegate.h"
#import "MSEventHandlerDelegateImpl.h"
#import "MSDummyMulticastDelegates.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {

        MSMulticastDelegateImpl* multicastDelegate = [MSMulticastDelegateImpl multicastDelegateForProtocol:@protocol(MSEventHandlerDelegate)];
        MSEventHandlerDelegateImpl* delegate1 = [[MSEventHandlerDelegateImpl alloc] init];
        MSEventHandlerDelegateImpl* delegate2 = [[MSEventHandlerDelegateImpl alloc] init];
        MSEventHandlerDelegateImpl* delegate3 = [[MSEventHandlerDelegateImpl alloc] init];
        NSObject* eventHandler = [[NSObject alloc] init];

        [multicastDelegate addObject:delegate1];
        [multicastDelegate addObject:delegate2];
        [multicastDelegate addObject:delegate3];
        [multicastDelegate eventHandler:eventHandler didStartEvent:@"event_name1"];
        [multicastDelegate removeObject:delegate1];
        [multicastDelegate eventHandler:eventHandler didFinishEvent:@"event_name2" withStatus:YES];
        [multicastDelegate removeObject:delegate2];
        [multicastDelegate eventHandler:eventHandler didFinishEvent:@"event_name3" withStatus:NO];
    }
    return 0;
}
