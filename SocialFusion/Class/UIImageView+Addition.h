//
//  UIImageView+Addition.h
//  SocialFusion
//
//  Created by Blue Bitch on 12-2-4.
//  Copyright (c) 2012年 TJU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Addition)

- (void)fadeIn;
- (void)halfFadeIn;

- (void)setImageFromUrl:(NSString*)urlString;
- (void)setImageFromUrl:(NSString*)urlString 
             completion:(void (^)(void))completion;

- (void)loadImageFromURL:(NSString *)urlString 
              completion:(void (^)())completion 
          cacheInContext:(NSManagedObjectContext *)context;

@end
