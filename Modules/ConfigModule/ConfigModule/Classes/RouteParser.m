//
//  RouteParser.m
//  ConfigModule
//
//  Created by NeroXie on 2023/2/6.
//

#import "RouteParser.h"

@interface RouteParser ()

@property (nonatomic, strong) URLRouteParser *parser;

@end

@implementation RouteParser

- (instancetype)init {
    if (self = [super init]) {
        self.parser = [[URLRouteParser alloc] initWithDefaultScheme:@"nn"];
    }
    
    return self;
}

- (instancetype)initWithDefaultScheme:(NSString *)defaultScheme {
    if (self = [super init]) {
        self.parser = [[URLRouteParser alloc] initWithDefaultScheme:defaultScheme];
    }
    
    return self;
}

- (NSString *)defaultScheme {
   return self.parser.defaultScheme;
}

- (NSURL *)urlFromRoute:(NSString *)route {
    return [self.parser urlFromRoute:route];
}

- (RouteURL *)routeUrlFromRoute:(NSString *)route params:(NSDictionary<NSString *,id> *)params {
    return [self.parser routeUrlFromRoute:route params:params];
}

@end
