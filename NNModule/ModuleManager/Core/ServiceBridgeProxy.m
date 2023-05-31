//
//  ServiceBridgeProxy.m
//  NNModule-swift
//
//  Created by NeroXie on 2023/5/29.
//

#import "ServiceBridgeProxy.h"
#import <NNModule_swift/NNModule_swift-Swift.h>

typedef NSMutableDictionary<NSString *, Class> *MethodMirror;

typedef NSMutableDictionary<NSString *, MethodMirror> *MethodMirrorMap;

@interface ServiceBridgeProxy ()

@property (nonatomic, copy) NSString *identifier;

@property (nonatomic, strong) NSMapTable<NSString *, id> *bridgeImplMap;

@end

@implementation ServiceBridgeProxy

- (instancetype)initWithIdentifier:(NSString *)identifier {
    self.identifier = identifier;
  
    return self;
}

+ (instancetype)proxyWithIdentifier:(NSString *)identifier {
    NSString *bridgeName = [NSString stringWithFormat:@"%@_BridgeProxy", identifier];
    Class bridgeClass = objc_allocateClassPair(ServiceBridgeProxy.class, bridgeName.UTF8String, 0);
    objc_registerClassPair(bridgeClass);
    ServiceBridgeProxy *proxy = [[bridgeClass alloc] initWithIdentifier:identifier];
    
    return proxy;
}

- (void)setBridgeClass:(Class)bridgeClass forMethod:(SEL)method isClassMethod:(BOOL)isClassMethod {
    NSString *methodName = NSStringFromSelector(method);
    MethodMirrorMap map = [self.class methodMirrorMap];
    MethodMirror methodMirror = isClassMethod ? map[@"classMethod"] : map[@"instanceMethod"];
    id object = methodMirror[methodName];
    if (object == nil) {
        methodMirror[methodName] = bridgeClass;
    } else {
        NSString *message = [NSString stringWithFormat:@"Method %@ of service %@ have been hooked already!", methodName, self.identifier];
        NSAssert(object == nil, message);
    }
}

- (void)setNativeImpl:(id)nativeImpl {
    _nativeImpl = nativeImpl;
    Class implClass = nativeImpl ? [nativeImpl class] : nil;
    [self.class setNativeImplClass: implClass];
}

- (id)forwardingTargetForSelector:(SEL)selector {
    NSString *methodName = NSStringFromSelector(selector);
    id bridgeImpl = [self.bridgeImplMap objectForKey:methodName];
    if (bridgeImpl) return bridgeImpl;
    
    MethodMirrorMap map = [self.class methodMirrorMap];
    MethodMirror instanceMethodMirror = map[@"instanceMethod"];
    Class bridgeClass = instanceMethodMirror[methodName];
    if (bridgeClass) {
        id newImpl = [Module registerImplOfClass:bridgeClass];
        if (newImpl && [newImpl respondsToSelector:selector]) {
            [self.bridgeImplMap setObject:newImpl forKey:methodName];
            return newImpl;
        }
    }
    
    return self.nativeImpl;
}

+ (id)forwardingTargetForSelector:(SEL)selector {
    MethodMirrorMap map = [self.class methodMirrorMap];
    MethodMirror classMethodMirror = map[@"classMethod"];
    id bridgeClass = classMethodMirror[NSStringFromSelector(selector)];
    id target = (bridgeClass && [bridgeClass respondsToSelector:selector]) ? bridgeClass : [self nativeImplClass];
    
    return target;
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    return [self.nativeImpl conformsToProtocol:aProtocol];
}

- (BOOL)isProxy {
    return YES;
}

+ (Class)nativeImplClass {
    return objc_getAssociatedObject(self, @selector(nativeImplClass));
}

+ (void)setNativeImplClass:(Class)nativeImplClass {
    objc_setAssociatedObject(self, @selector(nativeImplClass), nativeImplClass, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMapTable<NSString *,id> *)bridgeImplMap {
    if (!_bridgeImplMap) _bridgeImplMap = NSMapTable.strongToWeakObjectsMapTable;
    
    return _bridgeImplMap;
}

+ (MethodMirrorMap)methodMirrorMap {
    MethodMirrorMap map = objc_getAssociatedObject(self, @selector(methodMirrorMap));
    if (!map) {
        map = NSMutableDictionary.dictionary;
        map[@"classMethod"] = NSMutableDictionary.dictionary;
        map[@"instanceMethod"] = NSMutableDictionary.dictionary;
        objc_setAssociatedObject(self, @selector(methodMirrorMap), map, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return map;
}

- (NSString *)description {
    NSDictionary *newMethodMap = @{
        @"classMethod": NSMutableDictionary.dictionary,
        @"instanceMethod": NSMutableDictionary.dictionary
    };
    
    [[self.class methodMirrorMap] enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, MethodMirror  _Nonnull methodMirror, BOOL * _Nonnull stop) {
        NSMutableDictionary *dict = newMethodMap[key];
        [methodMirror enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, Class  _Nonnull bridgeClass, BOOL * _Nonnull stop) {
            dict[key] = NSStringFromClass(bridgeClass);
        }];
    }];
    
    NSDictionary *map = @{
        @"identifier": self.identifier,
        @"nativeImplClass": NSStringFromClass([self.class nativeImplClass]) ?: @"",
        @"bridgeMethodMap": newMethodMap
    };
    
    NSData *mapData = [NSJSONSerialization dataWithJSONObject:map options: NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:mapData encoding:NSUTF8StringEncoding];
}

@end
