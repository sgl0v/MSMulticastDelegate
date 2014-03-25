MSProxyListener
===============

A simple NSProxy subclass that forwards calls to subscribers. Makes the delegation 
really elegant and very simple, decreases the boilerplate in your code.

[[Overview](#overview) &bull; [Example](#example) &bull; [Licence](#licence)] 

##<a name="overview"></a>Overview

To implement One-to-Many approach of communication between objects we may use delegation. In order to do this we should store the event listeners and notify them notify them about appropriate events:

    for (id<ListenerProtocol> target in self.listeners) {
        if ([target respondsToSelector:@selector(didFinishEvent:withStatus:)]) {
            [target performSelector@selector(didFinishEvent:withStatus:)];
       }
    }

If we use this one-to-many communication all over the project, we will have lots of lines of code, that are almost identical and perform the following actions:

*  add a listener to container,
*  remove a listener from container,
*  notify all listeners on some event.

Wouldn't it be better to handle this logic in one place?

The answer is YES. 

As a solution we should implement a simple NSProxy subclass which stores a list of event listeners. It accepts any message passed to it and notifies all listeners, that respond to this message. Otherwise, it does nothing. The main "trick" with message forwarding does `methodSignatureForSelector:` and `forwardInvocation:` methods:

	- (NSMethodSignature*)methodSignatureForSelector:(SEL)sel
	{
	    for (id target in self.listeners) {
	        if ([target respondsToSelector:sel]) {
	            return [target methodSignatureForSelector:sel];
	        }
	    }
	    // workaround to suppress NSInvalidArgumentException.
	    return [NSMethodSignature signatureWithObjCTypes:"@^v^c"];
	}
	
	- (void)forwardInvocation:(NSInvocation *)invocation
	{
	    for (id target in self.listeners) {
	        if ([target respondsToSelector:invocation.selector]) {
	            [invocation invokeWithTarget:target];
	        }
	    }
	}
	
##<a name="example"></a>Example
Lets assume that we have a listener's protocol:

	protocol MSListener <NSObject>
	
	@optional
	
	- (void)caller:(id)caller didStartWithString:(NSString*)stringValue;
	- (void)caller:(id)caller didEndWithString:(NSString*)stringValue booleanFlag:(BOOL)booleanFlag;
	
	@end	

To use the `MSProxyListener` we should define only one "dummy" class:

	@interface MSProxyListenerImpl : MSProxyListener <MSListener> @end
	@implementation MSProxyListenerImpl @end
	
The typical workflow:

	// create a proxy listener
	MSProxyListenerImpl* listeners = [MSProxyListenerImpl proxyListener];
	
	// add event listeners
	[listeners addObject:listener1];
	[listeners addObject:listener2];
	
	// notify all listeners on some event
	[listeners caller:caller didStartWithString:@"value1"];

 
##<a name="licence"></a>Licence

`MSProxyListener` is MIT-licensed. See `LICENSE`. 