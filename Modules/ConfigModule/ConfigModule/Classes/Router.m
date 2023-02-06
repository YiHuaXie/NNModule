//
//  Router.m
//  OCApplicationModule
//
//  Created by NeroXie on 2023/2/5.
//

#import "Router.h"
#import "RouteParser.h"
#import <ModuleServices/ModuleServices-Swift.h>

typedef BOOL(^HandleRouteFactory)(RouteURL *, id<NavigatorType>);

typedef void(^DelayedHandler)(id <URLRouterType>);

@interface Router ()

@property (nonatomic, strong) id<URLRouteParserType> routeParser;

@property (nonatomic, strong) id<NavigatorType> navigator;

@property (nonatomic, weak) id<URLNestingRouterType> upperRouter;

@property (nonatomic, strong) URLRouteRedirector *routeRedirector;

@property (nonatomic, strong) URLRouteInterceptor *routeInterceptor;

@property (nonatomic, strong) NSMutableArray<DelayedHandler> *delayedHandlers;

@property (nonatomic, strong) NSMutableDictionary<NSString *, HandleRouteFactory> *handleRouteFactories;
@end

@implementation Router

- (instancetype)init {
    if (self = [super init]) {
        _delayedHandlers = NSMutableArray.array;
        _handleRouteFactories = NSMutableDictionary.dictionary;
        
        id <ModuleConfigService> configImpl = [Module serivceOfProtocol:@protocol(ModuleConfigService)];
        _routeParser = [[RouteParser alloc] initWithDefaultScheme:configImpl.appScheme];
        _navigator = Navigator.new;
        _routeRedirector = [[URLRouteRedirector alloc] initWithRouteParser:_routeParser];
        _routeInterceptor = [[URLRouteInterceptor alloc] initWithRouteParser:_routeParser];
    }
    
    return self;
}

+ (NSInteger)implPriority {
    return 100;
}

- (id<URLRouteParserType>)routeParser {
   return self.upperRouter.routeParser ?: _routeParser;
}

- (id<NavigatorType>)navigator {
    return self.upperRouter.navigator ?: _navigator;
}

- (URLRouteRedirector *)routeRedirector {
    if ([self.upperRouter conformsToProtocol:@protocol(URLRouterTypeAttach)]) {
        return ((id<URLRouterTypeAttach>)self.upperRouter).routeRedirector;
    }
    
    return _routeRedirector;
}

- (URLRouteInterceptor *)routeInterceptor {
    if ([self.upperRouter conformsToProtocol:@protocol(URLRouterTypeAttach)]) {
        return ((id<URLRouterTypeAttach>)self.upperRouter).routeInterceptor;
    }
    
    return _routeInterceptor;
}

- (void)delayedRegisterRoute:(NSString *)route handleRouteFactory:(BOOL (^)(RouteURL *, id<NavigatorType>))handleRouteFactory {
    [self.delayedHandlers addObject:^(id <URLRouterType> router) {
        [router registerRoute:route handleRouteFactory:handleRouteFactory];
    }];
}

- (void)registerRoute:(NSString *)route handleRouteFactory:(BOOL (^)(RouteURL * _Nonnull, id<NavigatorType> _Nonnull))handleRouteFactory {
    RouteURL *routeUrl = [self.routeParser routeUrlFromRoute:route params:@{}];
    if (!routeUrl) {
        [self _routerLogWithMessage:[NSString stringWithFormat:@"route for (%@) is invalid", route]];
        return;
    }
    
    NSString *key = routeUrl.fullPath;
    if (self.handleRouteFactories[key]) {
        [self _routerLogWithMessage:[NSString stringWithFormat:@"route for (%@) already exist", route]];
        return;
    }
    
    self.handleRouteFactories[key] = handleRouteFactory;
}

- (void)registerRoute:(NSString *)route used:(id<URLNestingRouterType>)subRouter {
    if (!subRouter.upperRouter || subRouter.upperRouter != self) {
        [self _routerLogWithMessage:[NSString stringWithFormat:@"upper router for (%@) is not \(%@)", subRouter, self]];
        return;
    }
    
    RouteURL *routeUrl = [self.routeParser routeUrlFromRoute:route params:@{}];
    if (!routeUrl) {
        [self _routerLogWithMessage:[NSString stringWithFormat:@"route for (%@) is invalid", route]];
        return;
    }
    
    [self registerRoute:routeUrl.combinedRoute handleRouteFactory:^BOOL(RouteURL *routeUrl, id<NavigatorType> navigator) {
        return [subRouter openRoute:routeUrl.fullPath parameters:routeUrl.parameters];
    }];
}

- (void)removeRoute:(NSString *)route {
    RouteURL *routeUrl = [self.routeParser routeUrlFromRoute:route params:@{}];
    if (!routeUrl) {
        [self _routerLogWithMessage:[NSString stringWithFormat:@"route for (%@) is invalid", route]];
        return;
    }
    
    NSString *key = routeUrl.fullPath;
    [self.handleRouteFactories removeObjectForKey:key];
}

- (void)removeAllRoutes {
    [self.handleRouteFactories removeAllObjects];
}

- (BOOL)openRoute:(NSString *)route parameters:(NSDictionary<NSString *,id> *)parameters {
    [self _loadDelayedHandlerIfNeed];
    
    RouteURL *routeUrl = [self.routeParser routeUrlFromRoute:route params:parameters];
    if (!routeUrl) {
        [self _routerLogWithMessage:[NSString stringWithFormat:@"route for (%@) is invalid", route]];
        return NO;
    }
    
    NSString *redirectRoute;
    NSDictionary *redirectParams;
    [self.routeRedirector routeRedirectDataFromRouteUrl:routeUrl redirectRoute:&redirectRoute redirectParams:&redirectParams];
    if (redirectRoute.length != 0) return [self openRoute:redirectRoute parameters:redirectParams];
    
    if (routeUrl.isWebLink) {
        HandleRouteFactory handler = [self _findRouteHandlerWithRouteUrl:routeUrl];
        if (handler) return [self _invokeRouteHandler:handler routeUrl:routeUrl];
        
        RouteURL *webLinkRouteUrl = [self.routeParser routeUrlFromRoute:URLRouter.webLink params:@{}];
        HandleRouteFactory webLinkHandler = [self _findRouteHandlerWithRouteUrl:webLinkRouteUrl];
        if (webLinkHandler) return [self _invokeRouteHandler:webLinkHandler routeUrl:routeUrl];
        
        if (!self.upperRouter) return NO;
        
        return [self.upperRouter openRoute:route parameters:parameters];
    }
    
    HandleRouteFactory handler = [self _findRouteHandlerWithRouteUrl:routeUrl];
    if (handler) return [self _invokeRouteHandler:handler routeUrl:routeUrl];
    
    if (!self.upperRouter) return NO;
    
    return [self.upperRouter openRoute:route parameters:parameters];
}

- (void)_loadDelayedHandlerIfNeed {
    for (DelayedHandler handler in self.delayedHandlers) {
        handler(self);
    }
    
    [self.delayedHandlers removeAllObjects];
}

- (HandleRouteFactory)_findRouteHandlerWithRouteUrl:(RouteURL *)routeUrl {
    if (!routeUrl) return nil;
    
    HandleRouteFactory handler = self.handleRouteFactories[routeUrl.fullPath];
    if (handler) return handler;
    
    if (routeUrl.path.length != 0) {
        RouteURL *combinedRouteUrl = [self.routeParser routeUrlFromRoute:routeUrl.combinedRoute params:@{}];
        HandleRouteFactory combinedHandler = self.handleRouteFactories[combinedRouteUrl.fullPath];
        if (combinedHandler) return combinedHandler;
    }
    
    return nil;
}

- (BOOL)_invokeRouteHandler:(HandleRouteFactory)handler routeUrl:(RouteURL *)routeUrl {
    if (!routeUrl) return NO;
    if ([self.routeInterceptor interceptSuccessfullyFor:routeUrl]) return NO;
    return handler ? handler(routeUrl, self.navigator) : NO;
}

- (void)_routerLogWithMessage:(NSString *)message {
#if DEBUG
    NSLog(@"URLRouter Error ⚠️ :\(%@)", message);
#endif
}

@end
