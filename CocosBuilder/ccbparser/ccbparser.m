#import <Foundation/Foundation.h>
#import "NSString+RelativePath.h"
#import <assert.h>

NSString *currentCCB = @"";

void parseProp(NSString* name, NSString* type, id serializedValue, NSMutableSet *refs, NSMutableArray *ccbrefs) {
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
        if (!spriteSheetFile || [spriteSheetFile isEqualToString:@""]) {
            [refs addObject:spriteFile];
        } else {
            printf("%-60s %-60s %-10s \n", [currentCCB UTF8String], [spriteSheetFile UTF8String], [spriteFile UTF8String]);
            [refs addObject:spriteSheetFile];
        }
    } else if ([type isEqualToString:@"Animation"]) {
        NSString* animationFile = [serializedValue objectAtIndex:0];
        //NSString* animationName = [serializedValue objectAtIndex:1];
        [refs addObject:animationFile];
    } else if ([type isEqualToString:@"Texture"]) {
        NSString* spriteFile = serializedValue;
        [refs addObject:spriteFile];
    } else if ([type isEqualToString:@"FntFile"]) {
        NSString* fntFile = serializedValue;
        [refs addObject:fntFile];
    } else if ([type isEqualToString:@"FontTTF"]) {
        NSString* str = serializedValue;
        [refs addObject:str];
    } else if ([type isEqualToString:@"CCBFile"]) {
        NSString* ccbFile = serializedValue;
        [refs addObject:ccbFile];
        [ccbrefs addObject:ccbFile];
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

void parseNode(NSDictionary* dict, NSMutableSet *refs, NSMutableArray *ccbrefs) {
    NSArray* props = [dict objectForKey:@"properties"];
    int numProps = [props count];
    for (int i = 0; i < numProps; i++)
    {
        NSDictionary* propInfo = [props objectAtIndex:i];
        NSString* type = [propInfo objectForKey:@"type"];
        NSString* name = [propInfo objectForKey:@"name"];
        id serializedValue = [propInfo objectForKey:@"value"];
        parseProp(name, type, serializedValue, refs, ccbrefs);
    }
    NSArray* children = [dict objectForKey:@"children"];
    for (int i = 0; i < [children count]; i++) {
        parseNode(children[i], refs, ccbrefs);
    }
}

void parseCCB(NSString* resPath, NSString* file, NSMutableSet *refs) {
    NSString* fullPath = [NSString stringWithFormat:@"%@/%@", resPath, file];
    currentCCB = file;
    NSMutableArray *ccbrefs = [NSMutableArray array];
    NSMutableDictionary* doc = [NSMutableDictionary dictionaryWithContentsOfFile:fullPath];
    parseNode(doc[@"nodeGraph"], refs, ccbrefs);
    [doc writeToFile:fullPath atomically:YES];
    for (NSString* ccb in ccbrefs) {
        parseCCB(resPath, ccb, refs);
    }
}

BOOL parse(NSString* fileName, NSDictionary* infos) {
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithContentsOfFile:fileName];
    if (!dict) {
        return NO;
    }
    
    NSString *cmd = infos[@"cmd"];
    if ([cmd isEqualToString:@"ref"]) {
        id resourcePaths = [dict objectForKey:@"resourcePaths"];
        id projectPath = fileName;
        NSArray* resPaths = absoluteResourcePaths(projectPath, resourcePaths);
        for (NSString *resPath in resPaths) {
            NSArray* resDir = [[NSFileManager defaultManager] subpathsAtPath:resPath];
            for (NSString* file in resDir) {
                if (![file hasSuffix:@".ccb"]){
                    continue;
                }
                NSArray *ccbs = infos[@"ccbs"];
                for (NSString *pt in ccbs) {
                    if (![file containsString:pt]) {
                        continue;
                    }
                    NSMutableSet *refs = [NSMutableSet set];
                    parseCCB(resPath, file, refs);
                    printf("\n\n%s\n", [file UTF8String]);
                    
                    NSMutableArray *packedImgs = [NSMutableArray array];
                    for (NSString *res in refs) {
                        if ([res length] <= 0) { continue; }
                        if ([[res pathExtension] isEqualToString:@"plist"]) {
                            NSMutableDictionary* pack = [NSMutableDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", resPath, res]];
                            if (pack && pack[@"metadata"] && pack[@"metadata"][@"textureFileName"]) {
                                NSString *pureName = pack[@"metadata"][@"textureFileName"];
                                NSString *pathName = [NSString stringWithFormat:@"%@/%@", [res stringByDeletingLastPathComponent], pureName];
                                [packedImgs addObject:pathName];
                            }
                        }
                    }
                    [refs addObjectsFromArray:packedImgs];
                    
                    NSArray* sorted = [[refs allObjects] sortedArrayUsingComparator: ^(NSString* string1, NSString* string2)
                                       {
                                           return [string1 localizedCompare: string2];
                                       }];

                    unsigned long long totalSize = 0;
                    for (NSString *res in sorted) {
                        if ([res length] <= 0) { continue; }
                        if ([[res pathExtension] isEqualToString:@"ccb"]) {
                            printf("  %-60s\n", [res UTF8String]);
                        } else {
                            unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:[NSString stringWithFormat:@"%@/%@", resPath, res] error:nil] fileSize];
                            printf("  %-80s [%-4lld kb]\n", [res UTF8String], fileSize / 1000);
                            totalSize += fileSize;
                        }
                    }
                    printf("Total [%.2f kb]\n", totalSize / 1000.0);
                    break;
                }
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
        NSString *config = @"";
        if (args.count == 2) {
            config = args[1];
        } else {
            config = [[args[0] stringByDeletingLastPathComponent] stringByAppendingString:@"/config.json"];
        }
        
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:config];
        if (data) {
            id dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSString *proj = dict[@"proj"];
            parse(proj, dict);
        }

    }
	return 0;
}
















