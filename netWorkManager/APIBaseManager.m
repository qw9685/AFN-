//
//  APIBaseManager.m
//  JZJSClub-Client
//
//  Created by foxdingding on 2019/6/5.
//  Copyright © 2019年 tdy. All rights reserved.
//

#import "APIBaseManager.h"
#import "AFNetworking.h"

@interface APIBaseManager ()

@property (nonatomic, strong) AFHTTPSessionManager* networkManager;
@property (nonatomic, strong) NSMutableArray <NSURLSessionTask*>*sessionTasks;//存放session

@end

@implementation APIBaseManager

-(instancetype)init{
    if (self = [super init]) {
        self.baseConfig.timeoutInterval = 15;
    }
    return self;
}

#pragma mark -------------- publicMethod --------------
- (BOOL)checkNetworkConnection{
    struct sockaddr zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sa_len = sizeof(zeroAddress);
    zeroAddress.sa_family = AF_INET;
    
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags) {
        printf("Error. Count not recover network reachability flags\n");
        return NO;
    }
    
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    return (isReachable && !needsConnection) ? YES : NO;
}

- (void)startMonitoring{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未知的网络状态");
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"没有网络");
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"蜂窝移动网络");
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WIFI网络");
                break;
            default:
                break;
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:KreachabilityStatus object:@(status)];
    }];
    // 开始检测网络状态
    [manager startMonitoring];
}


// cancel
- (void)cancelAllRequests{
    [self.networkManager.tasks enumerateObjectsUsingBlock:^(NSURLSessionTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
        [task cancel];
        [self.sessionTasks removeObject:task];
    }];
}

- (BOOL)cancelRequestWithRequestId:(NSURLSessionTask*)sessionTask{
    
    [sessionTask cancel];
    __block BOOL success = NO;
    [self.networkManager.tasks enumerateObjectsUsingBlock:^(NSURLSessionTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
        if (sessionTask.taskIdentifier == task.taskIdentifier) {
            [self.sessionTasks removeObject:task];
            success = YES;
            *stop = YES;
        }
    }];
    return success;
}

- (NSURLSessionTask*)loadData{
    
    if (self.baseConfig.header) {
        for (NSString *httpHeaderField in self.baseConfig.header.allKeys) {
            NSString *value = self.baseConfig.header[httpHeaderField];
            [self.networkManager.requestSerializer setValue:value forHTTPHeaderField:httpHeaderField];
        }
    }
    
    NSURLSessionTask* sessionTask;
    switch (self.baseConfig.loadType) {
        case loadType_Post:
            sessionTask = [self loadDataWithPostType];
            break;
        case loadType_Get:
            sessionTask = [self loadDataWithGetType];
            break;
        case loadType_DoneLoad:
            NSCAssert(self.baseConfig.downLoadPath != nil, @"self.baseConfig.downLoadPath == nil");
            sessionTask = [self loadDataWithDoneLoadType];
            break;
        case loadType_Upload:
//            NSCAssert(self.baseConfig.uploadPath != nil, @"self.baseConfig.uploadPath == nil");
//            NSCAssert(self.baseConfig.fileName != nil, @"self.baseConfig.fileName == nil");
            sessionTask = [self upLoadDataWithDoneLoadType];
            break;
            
        default:
            break;
    }
    return sessionTask;
}

- (BOOL)isLoadingWithRequestId:(NSURLSessionTask*)sessionTask{
    __block BOOL success = YES;
    [self.networkManager.tasks enumerateObjectsUsingBlock:^(NSURLSessionTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
        if (sessionTask.taskIdentifier == task.taskIdentifier) {
            [self.sessionTasks removeObject:task];
            success = NO;
            *stop = YES;
        }
    }];
    return success;
}

//post请求
- (NSURLSessionTask*)loadDataWithPostType{
    
    self.networkManager.requestSerializer.timeoutInterval = self.baseConfig.timeoutInterval;
    
    NSURLSessionDataTask* task = [self.networkManager POST:self.baseConfig.url parameters:self.baseConfig.parms progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self.sessionTasks removeObject:task];
        self.result.response = responseObject;
        
        if ([self.delegate respondsToSelector:@selector(managerCallAPIDidSuccess:)]) {
            [self.delegate managerCallAPIDidSuccess:self];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self.sessionTasks removeObject:task];
        self.result.error = error;
        
        if ([self.delegate respondsToSelector:@selector(managerCallAPIDidFailed:)]) {
            [self.delegate managerCallAPIDidFailed:self];
        }
    }];
    //设定标识
    [self.sessionTasks addObject:task];
    return task;
}

//get请求
- (NSURLSessionTask*)loadDataWithGetType{
    
    self.networkManager.requestSerializer.timeoutInterval = self.baseConfig.timeoutInterval;
    
    NSURLSessionDataTask* task = [self.networkManager GET:self.baseConfig.url parameters:self.baseConfig.parms progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self.sessionTasks removeObject:task];;
        self.result.response = responseObject;
        
        if ([self.delegate respondsToSelector:@selector(managerCallAPIDidSuccess:)]) {
            [self.delegate managerCallAPIDidSuccess:self];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self.sessionTasks removeObject:task];;
        self.result.error = error;
        
        if ([self.delegate respondsToSelector:@selector(managerCallAPIDidFailed:)]) {
            [self.delegate managerCallAPIDidFailed:self];
        }
    }];
    //设定标识
    [self.sessionTasks addObject:task];
    return task;
}

//下载
- (NSURLSessionTask*)loadDataWithDoneLoadType{
    
    NSURLRequest* quest = [NSURLRequest requestWithURL:[NSURL URLWithString:self.baseConfig.url]];
    
    NSURLSessionDownloadTask * task;
    
    task = [self.networkManager downloadTaskWithRequest:quest progress:^(NSProgress * _Nonnull downloadProgress) {
        
        NSString* progress = [NSString stringWithFormat:@"%f",1.0 * downloadProgress.completedUnitCount/downloadProgress.totalUnitCount];
        self.result.progress = [progress floatValue];
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        return [NSURL fileURLWithPath:self.baseConfig.downLoadPath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        if (error) {
            self.result.error = error;
            if ([self.delegate respondsToSelector:@selector(managerCallAPIDidFailed:)]) {
                [self.delegate managerCallAPIDidFailed:self];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(managerCallAPIDidSuccess:)]) {
                [self.delegate managerCallAPIDidSuccess:self];
            }
        }
        
        [self.sessionTasks removeObject:task];;
        
    }];
    
    //设定标识
    [self.sessionTasks addObject:task];
    
    [task resume];
    
    return task;
}

//上传
- (NSURLSessionTask*)upLoadDataWithDoneLoadType{

    NSURLSessionDataTask* task = [self.networkManager POST:self.baseConfig.url parameters:self.baseConfig.parms constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        if (self.baseConfig.fileDatas) {
            
            [self.baseConfig.fileDatas enumerateObjectsUsingBlock:^(NSData* data, NSUInteger idx, BOOL * _Nonnull stop) {
                [formData appendPartWithFileData:data name:self.baseConfig.files[idx] fileName:self.baseConfig.fileNames[idx] mimeType:@"application/octet-stream"];
            }];
            
        }else{
            //单个文件
            [formData appendPartWithFileURL:[NSURL fileURLWithPath:self.baseConfig.uploadPath] name:self.baseConfig.file fileName:self.baseConfig.fileName mimeType:@"application/octet-stream" error:nil];
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        NSString* progress = [NSString stringWithFormat:@"%f",1.0 * uploadProgress.completedUnitCount/uploadProgress.totalUnitCount];
        self.result.progress = [progress floatValue];
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        self.result.response = responseObject;
        [self.sessionTasks removeObject:task];;
        
        if ([self.delegate respondsToSelector:@selector(managerCallAPIDidSuccess:)]) {
            [self.delegate managerCallAPIDidSuccess:self];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        self.result.error = error;
        [self.sessionTasks removeObject:task];;
        
        if ([self.delegate respondsToSelector:@selector(managerCallAPIDidFailed:)]) {
            [self.delegate managerCallAPIDidFailed:self];
        }
    }];
    
      //设定标识
     [self.sessionTasks addObject:task];
    return task;
}


#pragma mark -------------- set&get --------------

-(APIBaseConfig *)baseConfig{
    if (!_baseConfig) {
        _baseConfig = [[APIBaseConfig alloc] init];
    }
    return _baseConfig;
}

-(APIBaseResult *)result{
    if (!_result) {
        _result = [[APIBaseResult alloc] init];
    }
    return _result;
}

-(AFHTTPSessionManager *)networkManager{
    if (!_networkManager) {
        _networkManager = [AFHTTPSessionManager manager];
        
        _networkManager.responseSerializer = [AFJSONResponseSerializer serializer];
        _networkManager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    return _networkManager;
}

-(NSMutableArray *)sessionTasks{
    if (!_sessionTasks) {
        _sessionTasks = [NSMutableArray array];
    }
    return _sessionTasks;
}
@end

