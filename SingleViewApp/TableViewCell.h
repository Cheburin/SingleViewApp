//
//  TableViewCell.h
//  SingleViewApp
//
//  Created by Cheburin Yura on 17/09/2019.
//  Copyright © 2019 Cheburin Yura. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *id;
@property (weak, nonatomic) IBOutlet UILabel *changeId;
@property (weak, nonatomic) IBOutlet UILabel *text;
@end

NS_ASSUME_NONNULL_END
