//
//  UIImage+TextureAtlas.m
//  ImageTest
//
//  Created by Jamie Kosoy on 2/11/14.
//  Copyright (c) 2014 JKosoy. All rights reserved.
//

#import "UIImage+TextureAtlas.h"

@implementation UIImage (TextureAtlas)

+ (NSDictionary *)atlas:(NSString *)filename {
    static NSMutableDictionary *cache = nil;

    if(!cache) {
        cache = [NSMutableDictionary dictionary];
    }
    
    if(cache[filename]) {
        return cache[filename];
    }
    
    // CGFloat scale = [UIScreen mainScreen].scale;

    NSString* file = [[filename lastPathComponent] stringByDeletingPathExtension];
    NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@.atlasc/%@", file, file] ofType:@"plist"];
    NSDictionary *atlasDictionary = [[NSDictionary alloc] initWithContentsOfFile:path];

    NSMutableDictionary *atlas = [NSMutableDictionary dictionary];

    NSArray *images = atlasDictionary[@"images"];
    [images enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        NSString *imagePath = obj[@"path"];
        NSString *imageFile = [[imagePath lastPathComponent] stringByDeletingPathExtension];
        NSString *imageExtension = [imagePath pathExtension];

        NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@.atlasc/%@", file, imageFile] ofType:imageExtension];
        UIImage *atlasImage = [UIImage imageWithContentsOfFile:path];

        NSArray *subimages = obj[@"subimages"];
        
        CGSize atlasSize = atlasImage.size;
        CGImageRef atlasRef = atlasImage.CGImage;
        
        if(!atlasImage || CGSizeEqualToSize(atlasSize, CGSizeZero)) {
            *stop = YES;
            return;
        }

        [subimages enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
            CGRect textureRect = CGRectFromString(obj[@"textureRect"]);
            CGSize spriteSize = CGSizeFromString(obj[@"spriteSourceSize"]);
            CGPoint spriteOffset = CGPointFromString(obj[@"spriteOffset"]);

            // jk: TO DO :: handle origin and make sure everything is the right size.
            CGImageRef sprite = CGImageCreateWithImageInRect(atlasRef, textureRect); {
                UIImage *spriteImage;
                UIGraphicsBeginImageContext(spriteSize); {
                    CGContextRef ctx = UIGraphicsGetCurrentContext();

                    CGRect rect = CGRectZero;
                    rect.origin = spriteOffset;
                    rect.size = textureRect.size;
                    
                    CGContextDrawImage(ctx, rect, sprite);
                    
                    spriteImage = UIGraphicsGetImageFromCurrentImageContext();
                } UIGraphicsEndImageContext();

                atlas[obj[@"name"]] = spriteImage;
            } CGImageRelease(sprite);
        }];
    }];
    

    cache[filename] = atlas;

    return cache[filename];
}

+ (NSArray *)spritesWithContentsOfAtlas:(NSString *)filename sequence:(NSString *)sequence start:(int)start end:(int)end {
    NSDictionary *atlas = [UIImage atlas:filename];
    
    NSMutableArray *sprites = [NSMutableArray array];

    __block int index = start;
    [atlas enumerateKeysAndObjectsUsingBlock:^(NSString *key, UIImage *obj, BOOL *stop) {
        UIImage *sprite = [atlas objectForKey:[NSString stringWithFormat:sequence, index]];

        if(!sprite) {
            *stop = YES;
            return;
        }
        
        [sprites addObject:sprite];

        index++;

        if(index >= end && end != -1) {
            *stop = YES;
        }
    }];
    
    return sprites;
}

+ (NSArray *)spritesWithContentsOfAtlas:(NSString *)filename sequence:(NSString *)sequence {
    return [UIImage spritesWithContentsOfAtlas:filename sequence:sequence start:0 end:-1];
}


@end