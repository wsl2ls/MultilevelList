//
//  ViewController.m
//  MultilevelList
//
//  Created by 王双龙 on 2019/1/11.
//  Copyright © 2019年 https://www.jianshu.com/u/e15d1f644bea. All rights reserved.
//

#import "ViewController.h"
#import "SLNodeModel.h"
#import "SLNodeTableViewCell.h"

static int const MaxLevel = 4; //最大的层级数

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, SLNodeTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray * dataSource;
@property (strong, nonatomic) NSMutableArray * selectedSource;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"TableView 多级列表";
    self.dataSource = [NSMutableArray array];
    self.selectedSource = [NSMutableArray array];
    [self setDataSOurce];
}

#pragma mark - DataSouce

// 获取并初始化 树根结点数组
- (void)setDataSOurce {
    for (int i = 0; i < 4; i++) {
        SLNodeModel * node = [[SLNodeModel alloc] init];
        node.parentID = @"";
        node.childrenID = @"";
        node.level = 1;
        node.name = [NSString stringWithFormat:@"第%d级结点",node.level];
        node.leaf = 0;
        node.root = YES;
        node.expand = NO;
        node.selected = NO;
        [self.dataSource addObject:node];
    }
}

/**
 获取并展开父结点的子结点数组 数量随机产生
 @param level 父结点的层级
 @param indexPath 父结点所在的位置
 */
- (void)expandChildrenNodesLevel:(int)level atIndexPath:(NSIndexPath *)indexPath {
    
    SLNodeModel * nodeModel = self.dataSource[indexPath.row];
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
        node.selected = nodeModel.selected;
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

/**
 更新当前结点下所有子结点的选中状态
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

#pragma mark - UITableViewDelegate  UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SLNodeTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (cell == nil) {
        cell = [[SLNodeTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cellID"];
    }
    SLNodeModel * node = self.dataSource[indexPath.row];
    cell.node = node;
    cell.delegate = self;
    cell.cellSize = CGSizeMake(self.view.frame.size.width, 44);
    cell.cellIndexPath = indexPath;
    [cell refreshCell];
    return cell;
}

- (void )tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - SLNodeTableViewCellDelegate

- (void)nodeTableViewCell:(SLNodeTableViewCell *)cell selected:(BOOL)selected atIndexPath:(NSIndexPath *)indexPath {
    //    [self.dataSource replaceObjectAtIndex:indexPath.row withObject:cell.node];
    [self selectedChildrenNodes:cell.node.level selected:selected atIndexPath:indexPath];
}

- (void)nodeTableViewCell:(SLNodeTableViewCell *)cell expand:(BOOL)expand atIndexPath:(NSIndexPath *)indexPath {
    //    [self.dataSource replaceObjectAtIndex:indexPath.row withObject:cell.node];
    if (expand) {
        [self expandChildrenNodesLevel:cell.node.level atIndexPath:indexPath];
    }else{
        [self hiddenChildrenNodesLevel:cell.node.level atIndexPath:indexPath];
    }
}

@end
