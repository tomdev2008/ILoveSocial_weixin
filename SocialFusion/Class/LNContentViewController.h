//
//  LNContentViewController.h
//  SocialFusion
//
//  Created by Blue Bitch on 12-1-19.
//  Copyright (c) 2012年 Tongji Apple Club. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;
@interface LNContentViewController : UIViewController {
    NSMutableArray *_contentViewControllerHeap;
    NSUInteger _currentContentIndex;
    NSMutableArray *_contentViewIdentifierHeap;
    
    UIScrollView *_scrollView;
}

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain, readonly) NSMutableArray *contentViewControllerHeap;
@property (nonatomic) NSUInteger currentContentIndex;
@property (nonatomic, readonly) NSUInteger contentViewCount;

- (id)initWithlabelIdentifiers:(NSArray *)identifiers andUsers:(NSDictionary *)userDict;
- (void)setContentViewAtIndex:(NSUInteger)index forIdentifier:(NSString *)identifier;
- (void)addUserContentViewWithIndentifier:(NSString *)identifier andUsers:(NSDictionary *)userDict;
- (void)removeContentViewAtIndex:(NSUInteger)index;
- (NSString *)currentContentIdentifierAtIndex:(NSUInteger)index;

@end
