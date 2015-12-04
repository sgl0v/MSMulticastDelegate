//
// MSMulticastDelegate.h
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

/**
 *  The \c MSMulticastDelegate is the proxy class, that stores weak references for delegates and forwards calls to them.
 *  Uses \link NSHashTable \endlink instance as a container.
 */
@interface MSMulticastDelegate : NSProxy

/**
 *  The internal HashTable. Stores weak references for delegates, that implement specified protocol.
 */
@property(nonatomic, strong, readonly) NSHashTable* delegates;

/**
 * The protocol all delegates should conform to.
 */
@property(nonatomic, strong, readonly) Protocol* protocol;

/**
 *  The convenience constructor. Uses objc runtime to deduct the delegate's protocol.
 *
 *  @return An initialized object.
 */
+ (instancetype)multicastDelegate;

/**
 *  The convenience constructor.
 *
 *  @param protocol The protocol all delegates should conform to.
 *
 *  @return An initialized object.
 */
+ (instancetype)multicastDelegateForProtocol:(Protocol *)protocol;

/**
 *  The designated initializer. \c protocol can't be nil.
 *
 *  @param protocol The protocol all delegates should conform to.
 *
 *  @return An initialized object.
 */
- (instancetype)initWithProtocol:(Protocol *)protocol;

/**
 *  Adds a given object to the delegate's container. Ignores the object, if it doesn't conform to the delegate's protocol.
 *
 *  @param object The object to add to the delegate's container.
 */
- (void)addObject:(id)object;

/**
 *  Removes a given object from the delegate's container.
 *
 *  @param object The object to remove from the delegate's container.
 */
- (void)removeObject:(id)object;

/**
 *  Removes all delegates from the container.
 */
- (void)removeAllObjects;

/**
 *  Tests whether the delegate's container contains a given object.
 *
 *  @param anObject The object to test for membership in the delegate's container.
 *
 *  @return YES if the container contains anObject, otherwise NO.
 */
- (BOOL)containsObject:(id)anObject;

/**
 *  Returns the number of delegates in the container.
 *
 *  @return The number of elements in the container.
 */
- (NSUInteger)count;

@end
