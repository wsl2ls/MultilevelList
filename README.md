# MultilevelList
tableView多级列表

简书地址：https://www.jianshu.com/p/075d6a0c72fa

![TableView多级列表的实现效果预览图](https://upload-images.jianshu.io/upload_images/1708447-b7a40a35835084d5.gif?imageMogr2/auto-orient/strip)

* ### 需求

> TableView多级列表：分级展开或合并，逐级获取并展示其子级数据，可以设置最大的层级数，支持多选、单选、取消选择。
[示例Demo：MultilevelList](https://github.com/wsl2ls/MultilevelList.git)

* ### 思路

>  由需求和示意图可知，这些数据元素之间存在着一对多关系，很符合 [数据结构与算法 -- 树形结构](https://www.jianshu.com/p/c545c93f2585) 的特征。那么，我们就用树形结构中的结点(Node)来作为存储和关联数据的模型(NodeModel)。
 
```

//每个结点信息，采用的是树状结构模型
 关于树状结构不了解的可以看看我的这篇文章 https://www.jianshu.com/p/c545c93f2585

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

```

* ### 实现

>  **层级状态：**  根据传入的层级数来调整层级UI状态。


>  **展开或合并：**  通过插入或删除cell的方式来实现。(示例中的数据都是假数据，随机生成的。)
 >> 插入和删除的位置以及范围可通过点击的结点的位置、层级、子结点ID(当前结点ID)与子结点的层级或父节点相比较来确定。可以的话，做一下缓存处理，**优化不分大小，从点滴做起**。

```

/**
 获取并展开父结点的子结点数组 数量随机产生
 @param level 父结点的层级
 @param indexPath 父结点所在的位置
 */
- (void)expandChildrenNodesLevel:(int)level atIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray * insertNodeRows = [NSMutableArray array];
    int insertLocation = (int)indexPath.row + 1;
    for (int i = 0; i < arc4random()%9; i++) {
        SLNodeModel * node = [[SLNodeModel alloc] init];
        node.parentID = @"";
        node.childrenID = @"";
        node.level = level + 1;
        node.name = [NSString stringWithFormat:@"第%d级结点",node.level];
        node.leaf = (node.level < MaxLevel) ? NO : YES;
        node.root = NO;
        node.expand = NO;
        node.selected = NO;
        [self.dataSource insertObject:node atIndex:insertLocation + i];
        [insertNodeRows addObject:[NSIndexPath indexPathForRow:insertLocation + i inSection:0]];
    }
    
    //插入cell
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithArray:insertNodeRows] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    
    //更新新插入的元素之后的所有cell的cellIndexPath
    NSMutableArray * reloadRows = [NSMutableArray array];
    int reloadLocation = insertLocation + (int)insertNodeRows.count;
    for (int i = reloadLocation; i < self.dataSource.count; i++) {
        [reloadRows addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [self.tableView reloadRowsAtIndexPaths:reloadRows withRowAnimation:UITableViewRowAnimationNone];
}

/**
 获取并隐藏父结点的子结点数组
 @param level 父结点的层级
 @param indexPath 父结点所在的位置
 */
- (void)hiddenChildrenNodesLevel:(int)level atIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray * deleteNodeRows = [NSMutableArray array];
    int length = 0;
    int deleteLocation = (int)indexPath.row + 1;
    for (int i = deleteLocation; i < self.dataSource.count; i++) {
        SLNodeModel * node = self.dataSource[i];
        if (node.level > level) {
            [deleteNodeRows addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            length++;
        }else{
            break;
        }
    }
    [self.dataSource removeObjectsInRange:NSMakeRange(deleteLocation, length)];
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:deleteNodeRows withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    
    //更新删除的元素之后的所有cell的cellIndexPath
    NSMutableArray * reloadRows = [NSMutableArray array];
    int reloadLocation = deleteLocation;
    for (int i = reloadLocation; i < self.dataSource.count; i++) {
        [reloadRows addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [self.tableView reloadRowsAtIndexPaths:reloadRows withRowAnimation:UITableViewRowAnimationNone];
}

```

> **选中：**  会更新当前结点下所有子结点的选中状态。
>> 选中的位置以及范围可通过点击的结点的位置、层级、子结点ID(当前结点ID)与子结点的层级或父节点相比较来确定。可以的话，做一下缓存处理，**优化不分大小，从点滴做起**。

```

/**
 更新当前结点下所有子节点的选中状态
 @param level 选中的结点层级
 @param selected 是否选中
 @param indexPath 选中的结点位置
 */
- (void)selectedChildrenNodes:(int)level selected:(BOOL)selected atIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray * selectedNodeRows = [NSMutableArray array];
    int deleteLocation = (int)indexPath.row + 1;
    for (int i = deleteLocation; i < self.dataSource.count; i++) {
        SLNodeModel * node = self.dataSource[i];
        if (node.level > level) {
            node.selected = selected;
            [selectedNodeRows addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }else{
            break;
        }
    }
    [self.tableView reloadRowsAtIndexPaths:selectedNodeRows withRowAnimation:UITableViewRowAnimationNone];
}

```

![新年快乐](https://upload-images.jianshu.io/upload_images/1708447-287235549412c45f.gif?imageMogr2/auto-orient/strip)


![加油](https://upload-images.jianshu.io/upload_images/1708447-81aed880d08b4ef9.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

