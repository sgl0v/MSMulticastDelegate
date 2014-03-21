//
// main.m
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

#import <Foundation/Foundation.h>

#import "MSProxyListener.h"

@protocol DelegateProtocol <NSObject>

- (void)didStart:(id)sender value:(NSString*)key;
- (void)didEnd:(id)sender value:(NSString*)key success:(BOOL)success;

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wprotocol"

@interface Listeners : MSProxyListener <DelegateProtocol> @end
@implementation Listeners @end

#pragma clang diagnostic pop

@interface ListenerImpl : NSObject <DelegateProtocol>

@end

@implementation ListenerImpl

- (void)didStart:(id)sender value:(NSString*)value
{
    NSLog(@"<%@ : %p %@> %@ %@", self.class, self, NSStringFromSelector(_cmd), sender, value);
}

- (void)didEnd:(id)sender value:(NSString*)value success:(BOOL)success
{
    NSLog(@"<%@ : %p %@> %@ %@ %d", self.class, self, NSStringFromSelector(_cmd), sender, value, success);
}

@end


int main(int argc, const char * argv[])
{

    @autoreleasepool {

        Listeners* listeners = [Listeners proxyListener];
        ListenerImpl* listener1 = [[ListenerImpl alloc] init];
        ListenerImpl* listener2 = [[ListenerImpl alloc] init];
        ListenerImpl* listener3 = [[ListenerImpl alloc] init];
        NSObject* caller = [[NSObject alloc] init];

        [listeners addObject:listener1];
        [listeners addObject:listener2];
        [listeners addObject:listener3];
        [listeners didStart:caller value:@"value1"];
        [listeners removeObject:listener1];
        [listeners didEnd:caller value:@"value2" success:YES];
        [listeners removeObject:listener2];
        [listeners didEnd:caller value:@"value3" success:NO];
    }
    return 0;
}
