#import <Foundation/Foundation.h>
#import "NSString+RelativePath.h"

void parseProp(NSString* name, NSString* type, id serializedValue) {
    /*if ([type isEqualToString:@"Position"]) {
    } else if ([type isEqualToString:@"Point"] || [type isEqualToString:@"PointLock"]) {
    } else if ([type isEqualToString:@"Size"]) {
    } else if ([type isEqualToString:@"Scale"] || [type isEqualToString:@"ScaleLock"]) {
    } else if ([type isEqualToString:@"FloatXY"])  {
    } else if ([type isEqualToString:@"Float"] || [type isEqualToString:@"Degrees"]) {
    } else if ([type isEqualToString:@"FloatScale"]) {
    } else if ([type isEqualToString:@"FloatVar"]) {
    } else if ([type isEqualToString:@"Integer"] || [type isEqualToString:@"IntegerLabeled"] || [type isEqualToString:@"Byte"]) {
    } else if ([type isEqualToString:@"Check"]) {
    } else if ([type isEqualToString:@"Flip"]) {
    } else if ([type isEqualToString:@"Color3"]) {
    } else if ([type isEqualToString:@"Color4FVar"]) {
    } else if ([type isEqualToString:@"Blendmode"]) {
    } else if ([type isEqualToString:@"Text"] || [type isEqualToString:@"String"]) {
    } else if ([type isEqualToString:@"Block"]) {
    } else if ([type isEqualToString:@"BlockCCControl"]) {
    } else */
        
        
    if ([type isEqualToString:@"SpriteFrame"]) {
        NSString* spriteSheetFile = [serializedValue objectAtIndex:0];
        NSString* spriteFile = [serializedValue objectAtIndex:1];
        if (!spriteFile) {
            spriteFile = @"";
        }
        if (!spriteSheetFile || [spriteSheetFile isEqualToString:@""]) {
            spriteSheetFile = @"regular file";
        }
        NSLog(@"sheet: %@ %@", spriteSheetFile, spriteFile);
    } else if ([type isEqualToString:@"Animation"]) {
        NSString* animationFile = [serializedValue objectAtIndex:0];
        NSString* animationName = [serializedValue objectAtIndex:1];
        if (!animationFile) animationFile = @"";
        if (!animationName) animationName = @"";
        NSLog(@"anim: %@ %@", animationFile, animationName);
    } else if ([type isEqualToString:@"Texture"]) {
        NSString* spriteFile = serializedValue;
        if (!spriteFile) {
            spriteFile = @"";
        }
        NSLog(@"texture: %@", spriteFile);
    } else if ([type isEqualToString:@"FntFile"]) {
        NSString* fntFile = serializedValue;
        if (!fntFile) fntFile = @"";
        NSLog(@"fnt: %@", fntFile);
    } else if ([type isEqualToString:@"FontTTF"]) {
        NSString* str = serializedValue;
        if (!str) str = @"";
        NSLog(@"ttf: %@", str);
    } else if ([type isEqualToString:@"CCBFile"]) {
        NSString* ccbFile = serializedValue;
        if (!ccbFile) ccbFile = @"";
        NSLog(@"ccb: %@", ccbFile);
    }
}

NSArray* absoluteResourcePaths(NSString*projectPath, NSArray* resourcePaths) {
    NSString* projectDirectory = [projectPath stringByDeletingLastPathComponent];
    
    NSMutableArray* paths = [NSMutableArray array];
    
    for (NSDictionary* dict in resourcePaths)
    {
        NSString* path = [dict objectForKey:@"path"];
        NSString* absPath = [path absolutePathFromBaseDirPath:projectDirectory];
        [paths addObject:absPath];
    }
    
    if ([paths count] == 0)
    {
        [paths addObject:projectDirectory];
    }
    
    return paths;
}

void parseNode(NSDictionary* dict) {
//    NSString* cls = dict[@"baseClass"];
    NSArray* props = [dict objectForKey:@"properties"];

    int numProps = [props count];
    for (int i = 0; i < numProps; i++)
    {
        NSDictionary* propInfo = [props objectAtIndex:i];
        NSString* type = [propInfo objectForKey:@"type"];
        NSString* name = [propInfo objectForKey:@"name"];
        id serializedValue = [propInfo objectForKey:@"value"];
        parseProp(name, type, serializedValue);
    }

    NSArray* children = [dict objectForKey:@"children"];
    for (int i = 0; i < [children count]; i++) {
        parseNode(children[i]);
    }
}

BOOL parse(NSString* fileName) {
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithContentsOfFile:fileName];
    if (!dict) {
        return NO;
    }
    
    id resourcePaths = [dict objectForKey:@"resourcePaths"];
    id projectPath = fileName;
    NSArray* resPaths = absoluteResourcePaths(projectPath, resourcePaths);
    
    if (resPaths.count > 0) {
        NSString* resPath = [resPaths objectAtIndex:0];
        NSArray* resDir = [[NSFileManager defaultManager] subpathsAtPath:resPath];
        for (NSString* file in resDir) {
            if ([file hasSuffix:@".ccb"]){
                NSString* full = [NSString stringWithFormat:@"%@/%@", resPath, file];
                NSMutableDictionary* doc = [NSMutableDictionary dictionaryWithContentsOfFile:full];
                parseNode(doc[@"nodeGraph"]);
            }
        }
    }
    return YES;
}

int	main(int argc, const char **argv) {
    @autoreleasepool {
        NSMutableArray *args = [NSMutableArray array];
        
        for (int i = 0; i < argc; ++i) {
            [args addObject:[NSString stringWithUTF8String:argv[i]]];
        }
        if (args.count == 2) {
            parse(args[1]);
        } else {
            printf("Usage: ./ccbparser PATH_TO_CCBPROJ\n");
        }
    }
	return 0;
}
