//
// MSProxyListener.m
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

#import "MSProxyListener.h"
#import <objc/objc-runtime.h>

@interface MSProxyListener ()

@property(nonatomic, strong) NSHashTable* listeners;
@property(nonatomic, strong) Protocol* protocol;

@end

@implementation MSProxyListener

+ (id)listenersProxyForProtocol:(Protocol *)protocol
{
    return [[MSProxyListener alloc] initWithProtocol:protocol];
}

- (id)initWithProtocol:(Protocol *)protocol
{
    if (self) {
        _listeners = [NSHashTable weakObjectsHashTable];
        _protocol = protocol;
    }
    return self;
}

- (void)addObject:(id)object
{
    if ([object conformsToProtocol:_protocol] && ![_listeners containsObject:object] && object != self) {
        [_listeners addObject:object];
    }
}

- (void)removeAllObjects
{
    [_listeners removeAllObjects];
}

- (BOOL)containsObject:(id)anObject
{
    return [_listeners containsObject:anObject];
}

- (void)removeObject:(id)object
{
    if (![object conformsToProtocol:_protocol]) {
        return;
    }
    [_listeners removeObject:object];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)sel
{
    for (id target in _listeners) {
        if ([target respondsToSelector:sel]) {
            return [target methodSignatureForSelector:sel];
        }
    }
    // workaround to suppress NSInvalidArgumentException.
    return [NSMethodSignature signatureWithObjCTypes:"@^v^c"];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    for (id target in _listeners) {
        if ([target respondsToSelector:invocation.selector]) {
            [invocation invokeWithTarget:target];
        }
    }
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol
{
    return _protocol == aProtocol;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    struct objc_method_description descr = protocol_getMethodDescription(_protocol, aSelector, YES, YES);
    if (descr.name != NULL && descr.types != NULL) {
        return YES;
    }
    descr = protocol_getMethodDescription(_protocol, aSelector, NO, YES);
    return descr.name != NULL && descr.types != NULL;
}

@end
