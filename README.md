UIImage+TextureAtlas
=================
UIImage category to convert XCode generated Texture Atlas files into UIImages. Useful for animations outside of SpriteKit.

Setting Up
=================
Via Cocoapods

	pod 'UIImage+TextureAtlas', '~> 0.1'

Example Usage
=================

- Add your images to a directory named .atlas. Don't worry about creating a sprite sheet, XCode will automatically do that for you.
- Import them to your project.
- In your project Build Settings, locate **Enable Texture Atlas Generation** and set it to **Yes**.
- Import the category at the top of your source where you wish to use an atlas.

		import <UIImage+TextureAtlas/UIImage+TextureAtlas.h>

- Load a sequence using the following syntax:

	    NSArray *sequence = [UIImage spritesWithContentsOfAtlas:@"myAtlasName.plist" sequence:@"NameOfFiles__%04d.png"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:sequence[0]];
        imageView.animationImages = sequence;
        imageView.animationRepeatCount = 0;
        imageView.animationDuration = 1.0f;

        [imageView startAnimating];

        // add the imageView to a subview.

Usage
-------

### + (NSDictionary *)atlas:(NSString *)filename;

Return an NSDictionary with the keys representing the original filenames of your atlas and values being the correct UIImage.

Example: 

	// assuming you had a folder named myAtlasName.atlas with an image in there named Foo.png.

	NSDictionary *atlas = [UIImage atlas:@"myAtlastName.plist"];
	UIImage *foo = atlas[@"Foo.png"];

### + (NSArray *)spritesWithContentsOfAtlas:(NSString *)filename sequence:(NSString *)sequence;

Returns an NSArray with a list of UIImages. Great for using in conjunction with a UIImageView. This assumes you have files named in sequential order beginning with 0.

Example:

	// assuming you had a folder named myAtlasName.atlas with the following images inside of it:
	// MySequence__0000.png
	// MySequence__0001.png
	// MySequence__0002.png
	// MySequence__0003.png
	// ....
	// MySequence__0099.png

	NSArray *sequence = [UIImage spritesWithContentsOfAtlas:@"myAtlasName.plist" sequence:@"MySequence__%04d.png"];

	UIImageView *imageView = [UIImageView alloc] initWithImage:sequence[0]];
	imageView.animationImages = sequence;
	imageView.animationDuration = 1.0;
	imageView.animationRepeatCount = 0;

	[imageView startAnimating];

### + (NSArray *)spritesWithContentsOfAtlas:(NSString *)filename sequence:(NSString *)sequence start:(int)start end:(int)end;

As above but limits the return array to a sequence of images with a start and end frame specified.

	// assuming you had a folder named myAtlasName.atlas with the following images inside of it:
	// MySequence__0001.png
	// MySequence__0002.png
	// MySequence__0003.png
	// MySequence__0004.png
	// MySequence__0005.png

	NSArray *sequence = [UIImage spritesWithContentsOfAtlas:@"myAtlasName.plist" sequence:@"MySequence__%04d.png" start:1 end:5];

	UIImageView *imageView = [UIImageView alloc] initWithImage:sequence[0]];
	imageView.animationImages = sequence; 
	imageView.animationDuration = 1.0;
	imageView.animationRepeatCount = 0;

	[imageView startAnimating];

####You do **not** need to import the SpriteKit framework for this to work.

-----

To Do
=================
- Demo projects.
- Handle retina vs. non-retina graphics. Right now this assumes one atlas without looking at scale.
- Handle if images are rotated when generated. Right now the atlas plist states that this is possible but we've yet to encounter a case where that happens.

-----

Version History
=================
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