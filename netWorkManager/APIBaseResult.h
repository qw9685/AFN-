//
//  APIBaseResult.h
//  JZJSClub-dietitian
//
//  Created by foxdingding on 2019/6/5.
//  Copyright © 2019年 tdy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface APIBaseResult : NSObject

@property(nonatomic,strong) NSDictionary *response;
@property(nonatomic,strong) NSError  *error;
@property(nonatomic,assign) CGFloat progress;//上传 下载进度

@property (nonatomic, assign, readonly) NSInteger requestID;//请求唯一标识

@end

NS_ASSUME_NONNULL_END
