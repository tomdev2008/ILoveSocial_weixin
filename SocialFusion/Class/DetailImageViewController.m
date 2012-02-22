//
//  DetailImageViewController.m
//  SocialFusion
//
//  Created by He Ruoyun on 12-1-16.
//  Copyright (c) 2012年 Tongji Apple Club. All rights reserved.
//

#import "DetailImageViewController.h"
#import  <QuartzCore/QuartzCore.h>
#import "Image+Addition.h"
#import "UIImage+Addition.h"
#import "RenrenClient.h"
#import "UIApplication+Addition.h"
#import "UIImageView+Addition.h"

#define IMAGE_MAX_WIDTH     320
#define IMAGE_MAX_HEIGHT    480

@interface DetailImageViewController()
- (void)setImage:(UIImage *)image;
- (void)hideActivityView;
- (void)showActivityView;
@end

@implementation DetailImageViewController

@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;
@synthesize saveButton = _saveButton;
@synthesize activityView = _activityView;

- (void)dealloc {
    NSLog(@"DetailImageViewController dealloc");
    [self.imageView release];
    [_scrollView release];
    [_saveButton release];
    [_activityView release];
    [super dealloc];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.imageView = nil;
    self.scrollView = nil;
    self.saveButton = nil; 
    self.activityView = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer* gesture;
    gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView)];
    [self.scrollView addGestureRecognizer:gesture];
    [gesture release];
}

- (id)init {
    self = [super init];
    if(self) {
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    
    self.imageView.image = image;
    
    CGRect frame = self.imageView.frame;
    CGSize size = self.imageView.image.size;
    
    if(size.width > IMAGE_MAX_WIDTH) {
        size.height *= IMAGE_MAX_WIDTH / size.width;
        size.width = IMAGE_MAX_WIDTH;
    }
    
    frame.size = size;
    self.imageView.frame = frame;
    
    if (size.height <= 480) 
        frame.origin.y = 480/2 - size.height/2;
    else 
        frame.origin.y = 0;
    
    if (size.width <= 320) 
        frame.origin.x = 320/2 - size.width/2;
    else
        frame.origin.x = 0;
    
    self.imageView.frame = frame;
    self.scrollView.contentSize = size;
    
    [self.imageView fadeIn];
}

#pragma mark -
#pragma mark Save image methos

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if(!error) {
        [[UIApplication sharedApplication] presentToast:@"保存成功。" withVerticalPos:kToastBottomVerticalPosition];
    }
    else {
        [[UIApplication sharedApplication] presentToast:@"保存失败。" withVerticalPos:kToastBottomVerticalPosition];
    }
    [self hideActivityView];
}

- (void)saveImageInBackground {
    [self showActivityView];
    UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

#pragma mark -
#pragma mark IBActions

- (IBAction)didClickSaveButton:(id)sender {
    [self performSelectorInBackground:@selector(saveImageInBackground) withObject:nil];
}

#pragma mark -
#pragma mark Dismiss view methods

- (void)dismissView
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [UIView animateWithDuration:0.3f animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        [self release];
    }];
}

#pragma mark -
#pragma mark UIScrollView delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    CGSize size = _imageView.frame.size;
    CGRect frame = self.imageView.frame;
    
    if (size.height <= 480) 
        frame.origin.y = 480/2 - size.height/2;
    else 
        frame.origin.y = 0;
    
    if (size.width <= 320) 
        frame.origin.x = 320/2 - size.width/2;
    else 
        frame.origin.x = 0;

    self.imageView.frame = frame;
    self.scrollView.contentSize = size;
}

- (void)hideActivityView {
    [self.activityView stopAnimating];
    self.activityView.alpha = 1.0f;
    [UIView animateWithDuration:0.3f animations:^(void) {
        self.activityView.alpha = 0;
    }];
}

- (void)showActivityView {
    self.activityView.hidden = NO;
    self.activityView.alpha = 1.0f;
    [self.activityView startAnimating];
}

- (void)loadImageWithURL:(NSString *)url context:(NSManagedObjectContext *)context {
    [self showActivityView];
    Image* image = [Image imageWithURL:url inManagedObjectContext:context];
    if (!image) {
        [UIImage loadImageFromURL:url completion:^{
            Image *image = [Image imageWithURL:url inManagedObjectContext:context];
            [self setImage:[UIImage imageWithData:image.imageData.data]];
            [self hideActivityView];
        } cacheInContext:context];
    }
    else {
        [self setImage:[UIImage imageWithData:image.imageData.data]];
        [self hideActivityView];
    }
}

- (void)loadImageWithRenrenUserID:(NSString *)userID photoID:(NSString *)photoID context:(NSManagedObjectContext *)context {
    [self showActivityView];
    RenrenClient *renren = [RenrenClient client];
    [renren setCompletionBlock:^(RenrenClient *client) {
        if (!client.hasError) {
            NSArray *array = client.responseJSONObject;
            NSDictionary *dict = [array lastObject];
            NSString* bigURL = [dict objectForKey:@"url_large"];
            [self loadImageWithURL:bigURL context:context];
        }
    }];
    [renren getSinglePhoto:userID photoID:photoID];

}

- (void)show {
    self.view.alpha = 0;
    [[UIApplication sharedApplication].keyWindow addSubview:self.view];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [UIView animateWithDuration:0.5f animations:^{
        self.view.alpha = 1;
    }];
}

+ (void)showDetailImageWithURL:(NSString*)bigURL context:(NSManagedObjectContext *)context {
    if(!bigURL)
        return;
    DetailImageViewController *vc = [[DetailImageViewController alloc] init];
    [vc show];
    [vc loadImageWithURL:bigURL context:context];
}

+ (void)showDetailImageWithRenrenUserID:(NSString*)userID photoID:(NSString *)photoID context:(NSManagedObjectContext *)context {
    if(!userID || !photoID)
        return;
    DetailImageViewController *vc = [[DetailImageViewController alloc] init];
    [vc show];
    [vc loadImageWithRenrenUserID:userID photoID:photoID context:context];
}

+ (void)showDetailImageWithImage:(UIImage *)image {
    if(!image)
        return;
    DetailImageViewController *vc = [[DetailImageViewController alloc] init];
    [vc show];
    [vc setImage:image];
}

@end
