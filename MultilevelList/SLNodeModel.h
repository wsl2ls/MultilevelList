//
//  SLNodeModel.h
//  MultilevelList
//
//  Created by 王双龙 on 2019/1/11.
//  Copyright © 2019年 https://www.jianshu.com/u/e15d1f644bea. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//每个结点信息，采用的是树状结构模型 关于树状结构不了解的可以看看我的这篇文章 https://www.jianshu.com/p/c545c93f2585

@interface SLNodeModel : NSObject

@property (nonatomic, strong) NSString *parentID; // 父结点ID 即当前结点所属的的父结点ID

@property (nonatomic, strong) NSString *childrenID; //子结点ID 即当前结点的ID

@property (nonatomic, strong) NSString *name; //结点名字

@property (nonatomic, assign) int level; // 结点层级 从1开始

@property (nonatomic, assign) BOOL leaf;  // 树叶(Leaf) If YES：此结点下边没有结点咯；

@property (nonatomic, assign) BOOL root;  // 树根((Root) If YES: parentID = nil

@property (nonatomic, assign) BOOL expand; // 是否展开

@property (nonatomic, assign) BOOL selected; // 是否选中

@end

NS_ASSUME_NONNULL_END
