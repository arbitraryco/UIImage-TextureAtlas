UIImage+TextureAtlas
=================
UIImage category to convert XCode generated Texture Atlas files into UIImages. Useful for animations outside of SpriteKit.

### Features
- Caches atlases in memory for fast access later on. Or delete the atlases from the cache once completed. Your choice.
- No need to use the SpriteKit framework. Use PNG sequences with UIImageViews, or just compress all your app artwork into a single spritesheet using Apple tools!

Setting Up
=================
Via Cocoapods

```
pod 'UIImage+TextureAtlas', '~> '1.0'
```

Example Usage
=================

- Add your images to a directory named .atlas. Don't worry about creating a sprite sheet, XCode will automatically do that for you.
- Import them to your project.
- In your project Build Settings, locate **Enable Texture Atlas Generation** and set it to **Yes**.
- Import the category at the top of your source where you wish to use an atlas.

```obj-c
import <UIImage+TextureAtlas/UIImage+TextureAtlas.h>
````

- Load a sequence using the following syntax:

```obj-c
NSArray *sequence = [UIImage spritesWithContentsOfAtlas:@"myAtlasName" sequence:@"NameOfFiles__%04d.png"];
UIImageView *imageView = [[UIImageView alloc] initWithImage:sequence[0]];
imageView.animationImages = sequence;
imageView.animationRepeatCount = 0;
imageView.animationDuration = 1.0f;

[imageView startAnimating];

// add the imageView to a subview.
```

Usage
-------

### + (NSDictionary *)atlas:(NSString *)filename;

Return an NSDictionary with the keys representing the original filenames of your atlas and values being the correct UIImage.

Example: 

```obj-c
// assuming you had a folder named myAtlasName.atlas with an image in there named Foo.png.

NSDictionary *atlas = [UIImage atlas:@"myAtlastName"];
UIImage *foo = atlas[@"Foo.png"];
```

### + (NSArray *)spritesWithContentsOfAtlas:(NSString *)filename sequence:(NSString *)sequence;

Returns an NSArray with a list of UIImages. Great for using in conjunction with a UIImageView. This assumes you have files named in sequential order beginning with 0.

Example:

```obj-c
// assuming you had a folder named myAtlasName.atlas with the following images inside of it:
// MySequence__0000.png
// MySequence__0001.png
// MySequence__0002.png
// MySequence__0003.png
// ....
// MySequence__0099.png

NSArray *sequence = [UIImage spritesWithContentsOfAtlas:@"myAtlasName" sequence:@"MySequence__%04d.png"];

UIImageView *imageView = [UIImageView alloc] initWithImage:sequence[0]];
imageView.animationImages = sequence;
imageView.animationDuration = 1.0;
imageView.animationRepeatCount = 0;

[imageView startAnimating];
```

### + (NSArray *)spritesWithContentsOfAtlas:(NSString *)filename sequence:(NSString *)sequence start:(int)start end:(int)end;

As above but limits the return array to a sequence that starts with a start frame of your choosing.

```obj-c
// assuming you had a folder named myAtlasName.atlas with the following images inside of it:
// MySequence__0021.png
// MySequence__0022.png
// MySequence__0023.png
// MySequence__0024.png
// MySequence__0025.png
// ...
// MySequence__0099.png

NSArray *sequence = [UIImage spritesWithContentsOfAtlas:@"myAtlasName" sequence:@"MySequence__%04d.png" start:21];

UIImageView *imageView = [UIImageView alloc] initWithImage:sequence[0]];
imageView.animationImages = sequence; 
imageView.animationDuration = 1.0;
imageView.animationRepeatCount = 0;

[imageView startAnimating];
```


### + (NSArray *)spritesWithContentsOfAtlas:(NSString *)filename sequence:(NSString *)sequence start:(int)start end:(int)end;

As above but limits the return array to a sequence of images with a start and end frame specified.

```obj-c
// assuming you had a folder named myAtlasName.atlas with the following images inside of it:
// MySequence__0001.png
// MySequence__0002.png
// MySequence__0003.png
// MySequence__0004.png
// MySequence__0005.png

NSArray *sequence = [UIImage spritesWithContentsOfAtlas:@"myAtlasName" sequence:@"MySequence__%04d.png" start:1 end:5];

UIImageView *imageView = [UIImageView alloc] initWithImage:sequence[0]];
imageView.animationImages = sequence; 
imageView.animationDuration = 1.0;
imageView.animationRepeatCount = 0;

[imageView startAnimating];
```

### + (void)removeAtlasFromCache:(NSString *)filename;

Removes a dictionary from the cache.

Note: Calling any of the methods documented above will subsequently force your application to reload and reparse a Texture Atlas.

```obj-c
NSDictionary *myAtlas = [UIImage atlas:@"myAtlasName"];

// ...

[UIImage removeAtlasFromCache:@"myAtlasName"];
```


-----

Known Issues
=================
- Files marked with an iPad suffix (~ipad) aren't supported.

-----

Version History
=================
#### 1.0
- First major release.
- Rewritten to solve orientation issues.
- Optimized. No longer creating unnneccessary UIImages.
- Demo project added.
- Added method to remove a cached atlas.

#### 0.4
- Updated documentation. Added To Do List.

#### 0.3
- Fixed warnings, validation.

#### 0.2
- Added license file.

#### 0.1
- Initial version of the pod. Testing to insure everything works properly before public release.

License
=================
MIT License