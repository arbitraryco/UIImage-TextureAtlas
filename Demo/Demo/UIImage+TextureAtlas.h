//
//  UIImage+TextureAtlas.h
//  ImageTest
//
//  Created by Jamie Kosoy on 2/11/14.
//  Copyright (c) 2014 JKosoy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (TextureAtlas)

+ (NSDictionary *)atlas:(NSString *)filename;
+ (NSArray *)spritesWithContentsOfAtlas:(NSString *)filename sequence:(NSString *)sequence;
+ (NSArray *)spritesWithContentsOfAtlas:(NSString *)filename sequence:(NSString *)sequence start:(int)start end:(int)end;

@end
