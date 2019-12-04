//
//  APIBaseManager.h
//  JZJSClub-Client
//
//  Created by foxdingding on 2019/6/5.
//  Copyright © 2019年 tdy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIBaseConfig.h"
#import "APIBaseManagerProtocol.h"
#import "APIBaseResult.h"


NS_ASSUME_NONNULL_BEGIN

@interface APIBaseManager : NSObject

@property(nonatomic,strong) APIBaseConfig *baseConfig;//基础网络配置
@property(nonatomic,strong) APIBaseResult *result;//返回结果

@property (nonatomic, weak) id <APIBaseManagerProtocol> delegate;

- (NSURLSessionTask*)loadData;//返回requestID

- (void)cancelAllRequests;//取消所有请求
- (BOOL)cancelRequestWithRequestId:(NSURLSessionTask*)sessionTask;//取消指定请求

- (BOOL)checkNetworkConnection;//验证是否有网
- (void)startMonitoring;//实时网络检测

- (BOOL)isLoadingWithRequestId:(NSURLSessionTask*)sessionTask;//查询是否正在请求

@end

NS_ASSUME_NONNULL_END
