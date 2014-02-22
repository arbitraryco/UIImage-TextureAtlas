//
//  MainViewController.m
//  Demo
//
//  Created by Jamie Kosoy on 2/14/14.
//  Copyright (c) 2014 Arbitrary. All rights reserved.
//

#import "MainViewController.h"
#import "UIImage+TextureAtlas.h"

@interface MainViewController ()

@property (nonatomic) int currentFrame;
@property (nonatomic) int totalFrames;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        CGRect screenFrame = [UIScreen mainScreen].bounds;

        // example loading in an animation sequence from an atlas
        NSArray *sprites = [UIImage spritesWithContentsOfAtlas:@"Sprites" sequence:@"Animation%04d.png" start:1];

        UIImageView *animatedImageView = [[UIImageView alloc] initWithImage:sprites[0]];
        animatedImageView.animationImages = sprites;
        animatedImageView.animationDuration = 1.0;
        animatedImageView.animationRepeatCount = 0;
        [animatedImageView startAnimating];
        
        // example loading a single PNG from the same atlas.
        NSDictionary *atlas = [UIImage atlas:@"Sprites.atlas"];
        UIImageView *staticImageView = [[UIImageView alloc] initWithImage:atlas[@"Static.png"]];
        staticImageView.frame = CGRectMake(0, CGRectGetHeight(screenFrame) - CGRectGetHeight(staticImageView.frame), CGRectGetWidth(staticImageView.frame), CGRectGetHeight(staticImageView.frame));

        [self.view addSubview:animatedImageView];
        [self.view addSubview:staticImageView];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
