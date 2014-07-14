MSMulticastDelegate
===============
[![Build Status](https://travis-ci.org/nullp0inter/MSMulticastDelegate.svg?branch=master)](https://travis-ci.org/nullp0inter/MSMulticastDelegate)

The NSProxy subclass that forwards calls to subscribers. Makes the delegation 
really elegant and very simple, decreases the boilerplate in your code.

[[Overview](#overview) &bull; [Example](#example) &bull; [Licence](#licence)] 

##<a name="overview"></a>Overview

To implement One-to-Many approach of communication between objects we may use delegation. In order to do this we should store the delegates and notify them notify them about appropriate events:

    for (id<DelegateProtocol> target in self.delegates) {
        if ([target respondsToSelector:@selector(eventHandler:didFinishEvent:)]) {
            [target performSelector:@selector(eventHandler:didFinishEvent:) withObject:eventHandler didFinishEvent:event];
       }
    }

If we use this one-to-many communication all over the project, we will have lots of lines of code, that are almost identical and perform the following actions:

*  add a delegate to container,
*  remove a delegate from container,
*  notify all delegates on some event.

Wouldn't it be better to handle this logic in one place?

The answer is YES. 

As a solution we should implement the NSProxy subclass which stores a list of delegates. It accepts any message passed to it and notifies all delegates, that respond to this message. Otherwise, it does nothing. The main "trick" with message forwarding does `methodSignatureForSelector:` and `forwardInvocation:` methods:

	- (NSMethodSignature*)methodSignatureForSelector:(SEL)sel
	{
	    for (id delegate in self.delegates) {
	        if ([delegate respondsToSelector:sel]) {
	            return [delegate methodSignatureForSelector:sel];
	        }
	    }
	    // workaround to suppress NSInvalidArgumentException.
	    return [NSMethodSignature signatureWithObjCTypes:"@^v^c"];
	}
	
	- (void)forwardInvocation:(NSInvocation *)invocation
	{
	    for (id delegate in self.delegates) {
	        if ([delegate respondsToSelector:invocation.selector]) {
	            [invocation invokeWithTarget:delegate];
	        }
	    }
	}
	
##<a name="example"></a>Example
Lets assume that we have a dalegate's protocol:

	protocol MSEventHandlerDelegate <NSObject>
	
	@optional
	
	- (void)eventHandler:(id)eventHandler didStartEvent:(NSString*)eventName;
	- (void)eventHandler:(id)eventHandler didFinishEvent:(NSString*)eventName;
	
	@end	

To use the `MSMulticastDelegate` we should define only one "dummy" class:

	@interface MSMulticastDelegateImpl : MSMulticastDelegate <MSEventHandlerDelegate> @end
	@implementation MSMulticastDelegateImpl @end
	
The typical workflow:

	// create a multicast delegate
	MSMulticastDelegateImpl* multicastDelegate = [MSMulticastDelegateImpl multicastDelegate];
	
	// add some delegates
	[multicastDelegate addObject:delegate1];
	[multicastDelegate addObject:delegate2];
	
	// notify all delegates on some event
	[multicastDelegate eventHandler:eventHandler didStartEvent:eventName];

 
##<a name="licence"></a>Licence

`MSMulticastDelegate` is MIT-licensed. See `LICENSE`. 