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

- (void)didStart:(NSString*)value key:(NSString*)key;
- (void)didEnd:(NSString*)value key:(NSString*)key success:(BOOL)success;

@end

@interface SomeObj : NSObject <DelegateProtocol>

@end

@interface Listeners : MSProxyListener <DelegateProtocol> @end

@implementation SomeObj

- (void)didStart:(NSString*)value key:(NSString*)key
{
    NSLog(@"call1: %@ %@", value, key);
}

- (void)didEnd:(NSString*)value key:(NSString*)key success:(BOOL)success
{
    NSLog(@"call2: %@ %@ %d", value, key, success);
}

@end


int main(int argc, const char * argv[])
{

    @autoreleasepool {

        Listeners* listeners = [MSProxyListener listenersProxyForProtocol:@protocol(DelegateProtocol)];
        SomeObj* obj1 = [[SomeObj alloc] init];
        SomeObj* obj2 = [[SomeObj alloc] init];
        SomeObj* obj3 = [[SomeObj alloc] init];

        [listeners addObject:obj1];
        [listeners addObject:obj2];
        [listeners addObject:obj3];
        [listeners didStart:@"val" key:@"key"];
        [listeners didEnd:@"val" key:@"key" success:YES];
        [listeners removeObject:obj1];
        [listeners removeObject:obj2];
        [listeners removeObject:obj3];
        [listeners didEnd:@"val" key:@"key" success:NO];
    }
    return 0;
}
