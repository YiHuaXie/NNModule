//
//  ModuleConfigServiceImpl.m
//  ConfigModule
//
//  Created by NeroXie on 2023/2/6.
//

#import "ModuleConfigServiceImpl.h"

@interface ModuleConfigServiceImpl()

@property (nonatomic, copy) NSString *appScheme;

@property (nonatomic, strong) Class tabBarControllerType;

@property (nonatomic, copy) NSArray<NSString *> *tabBarItems;


@end

@implementation ModuleConfigServiceImpl

- (instancetype)init {
    if (self = [super init]) {
        // 模拟从配置文件中读取
        
        self.appScheme = @"nero";
        self.tabBarControllerType = NSClassFromString(@"TabBarController.TabBarController");
        self.tabBarItems = @[@"example", @"house", @"user"];
    }
    
    return self;
}

@end
