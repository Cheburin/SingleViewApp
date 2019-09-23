//
//  ViewController.m
//  SingleViewApp
//
//  Created by Cheburin Yura on 17/09/2019.
//  Copyright © 2019 Cheburin Yura. All rights reserved.
//

#import "ViewController.h"
#import "TableViewCell.h"

@implementation RDocument
@end

@interface ViewController ()
@end

@implementation ViewController
- (void)longPollingData {
    NSURL *url = [NSURL URLWithString:@"http://127.0.0.1:5984/test/_changes?feed=continuous"];
    NSURLRequest *UrlString = [[NSURLRequest alloc] initWithURL:url];
    
    NSURLConnection *connection = [[NSURLConnection alloc]
                                   initWithRequest:UrlString
                                   delegate:self];
    
    [connection start];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // Create space for containing incoming data
    // This method may be called more than once if you're getting a multi-part mime
    // message and will be called once there's enough date to create the response object
    // Hence do  a check if _responseData already there
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    // Append the new data
    NSMutableString *strData = [[NSMutableString alloc]
                                initWithData:data
                                encoding:NSUTF8StringEncoding];
    
    int braceCounter = 0;
    
    unsigned long len = [strData length];
    
    for (unsigned long i = 0; i<len; i++) {
        unichar _char = [strData characterAtIndex:i];
        if (_char == '{') {
            braceCounter++;
        }
        if (_char == '}') {
            braceCounter--;
        }
        if ((i + 2)<len && braceCounter==0) {
            [strData insertString:@"," atIndex:i + 1];
            i = i + 2;
            len++;
        }
    }
    
    [strData insertString:@"{ \"result\": [" atIndex:0];
    len = [strData length];
    [strData insertString:@"]} " atIndex:len];
    
    NSData *normalizeData = [strData dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error;
    
    NSDictionary *rawCouchDocContainer = nil;
    rawCouchDocContainer = [NSJSONSerialization JSONObjectWithData:normalizeData
                                                           options:0
                                                             error:&error];
    
    NSArray *rawCouchDocuments = rawCouchDocContainer[@"result"];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    for (unsigned int i = 0; i<rawCouchDocuments.count; i++) {
        NSDictionary *rawCouchDocument = rawCouchDocuments[i];
        
        if ([rawCouchDocument objectForKey:@"id"] == nil)
            continue;
        
        NSString *wh = [NSString stringWithFormat:@"id == \"%@\"", rawCouchDocument[@"id"]];
        RDocument *couchDocument = [[RDocument objectsWhere:wh] firstObject];
        
        if (couchDocument==nil && [rawCouchDocument objectForKey:@"deleted"] == nil) {
            RDocument *document = [[RDocument alloc] init];
            document.id = rawCouchDocument[@"id"];
            [realm transactionWithBlock:^ {
                [realm addObject:document];
            }];
        }
        
        if (couchDocument!=nil && [rawCouchDocument objectForKey:@"deleted"] != nil) {
            [realm beginWriteTransaction];
            [realm deleteObject:couchDocument];
            [realm commitWriteTransaction];
        }
    }

    [self.tableView reloadData];
    RLMResults<RDocument *> *Objs = [RDocument allObjects];
    self.recordCountLabel.text = [NSString stringWithFormat:@"Records Count %lu", Objs.count];
    
    self.memo.text = strData;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // Parse the stuff in your instance variable now
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self longPollingData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    RLMResults<RDocument *> *Objs = [RDocument allObjects];
    return Objs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *tbId = @"TableViewCell";
    
    TableViewCell *cell = (TableViewCell *)[tableView dequeueReusableCellWithIdentifier:tbId];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle]
                        loadNibNamed:@"TableViewCell"
                        owner:self
                        options:nil];
        
        cell = [nib objectAtIndex:0];
    }
   
    RLMResults<RDocument *> *Objs = [RDocument allObjects];
    
    cell.id.text = Objs[indexPath.row].id;
    cell.changeId.text = Objs[indexPath.row].changeId;
    cell.text.text = Objs[indexPath.row].text;

    return cell;
}
@end
