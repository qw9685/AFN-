//
//  APIBaseConfig.h
//  JZJSClub-Client
//
//  Created by foxdingding on 2019/6/5.
//  Copyright © 2019年 tdy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define KreachabilityStatus @"reachabilityStatus"//网络监测通知

typedef NS_ENUM(NSInteger, loadType) {
    loadType_Post = 0,
    loadType_Get,
    loadType_DoneLoad,
    loadType_Upload,
};

@interface APIBaseConfig : NSObject

@property(nonatomic,strong) NSString *url;
@property(nonatomic,strong) NSDictionary *parms;//数据
@property(nonatomic,strong) NSDictionary *header;//请求头

@property(nonatomic,strong) NSString *downLoadPath;//下载路径

/**
 * 单个上传/下载
 */
@property(nonatomic,strong) NSString *uploadPath;//上传文件路径
@property(nonatomic,strong) NSString *fileName;//上传文件名称
@property(nonatomic,strong) NSString *file;//上传文件字段名称

/**
 * 多张文件上传/下载
 */
@property(nonatomic,strong) NSArray <NSData*>*fileDatas;//文件二进制数组
@property(nonatomic,strong) NSArray *fileNames;//上传文件名称数组
@property(nonatomic,strong) NSArray *files;//上传文件字段名称数组

@property(nonatomic,assign) loadType loadType;//请求类型
@property(nonatomic,assign) int timeoutInterval;//请求超时时间 默认15s

@end

NS_ASSUME_NONNULL_END
