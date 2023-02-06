//
//  RouteParser.h
//  Router
//
//  Created by NeroXie on 2023/2/6.
//

#import <Foundation/Foundation.h>
#import <NNModule_swift/NNModule_swift-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@interface RouteParser : NSObject <URLRouteParserType>

- (instancetype)initWithDefaultScheme:(NSString *)defaultScheme;

@end

NS_ASSUME_NONNULL_END
