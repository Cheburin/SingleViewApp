//
//  ViewController.h
//  SingleViewApp
//
//  Created by Cheburin Yura on 17/09/2019.
//  Copyright © 2019 Cheburin Yura. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Realm/Realm.h>

@interface RDocument : RLMObject
@property NSString *id;
@property NSString *changeId;
@property NSString *text;
@end

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *recordCountLabel;
@property (weak, nonatomic) IBOutlet UITextView *memo;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
