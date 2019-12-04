
//
//  APIBaseManagerProtocol.h
//  JZJSClub-dietitian
//
//  Created by foxdingding on 2019/6/5.
//  Copyright © 2019年 tdy. All rights reserved.
//

#import <Foundation/Foundation.h>
@class APIBaseManager;

@protocol APIBaseManagerProtocol <NSObject>

- (void)managerCallAPIDidSuccess:(APIBaseManager *)manager;
- (void)managerCallAPIDidFailed:(APIBaseManager *)manager;

- (void)managerCallAPIProgress:(APIBaseManager *)manager;//上传下载进度

@end
