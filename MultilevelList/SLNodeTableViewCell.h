//
//  SLNodeTableViewCell.h
//  MultilevelList
//
//  Created by 王双龙 on 2019/1/11.
//  Copyright © 2019年 https://www.jianshu.com/u/e15d1f644bea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLNodeModel.h"

NS_ASSUME_NONNULL_BEGIN
@class SLNodeTableViewCell;
@protocol SLNodeTableViewCellDelegate <NSObject>
- (void)nodeTableViewCell:(SLNodeTableViewCell *)cell selected:(BOOL)selected atIndexPath:(NSIndexPath *)indexPath; //选中的代理
- (void)nodeTableViewCell:(SLNodeTableViewCell *)cell expand:(BOOL)expand atIndexPath:(NSIndexPath *)indexPath;  //展开的代理
@end

@interface SLNodeTableViewCell : UITableViewCell

@property (nonatomic, strong) SLNodeModel *node; // 结点
@property (nonatomic, strong) NSIndexPath *cellIndexPath; // cell的位置
@property (nonatomic, assign) CGSize cellSize; // 宽高
@property (nonatomic, weak) id <SLNodeTableViewCellDelegate> delegate;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void)refreshCell;

@end

NS_ASSUME_NONNULL_END
