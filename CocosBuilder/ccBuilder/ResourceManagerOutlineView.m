/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "ResourceManagerOutlineView.h"
#import "CocosBuilderAppDelegate.h"
#import "ResourceManager.h"
#import "PlugInManager.h"

@implementation ResourceManagerOutlineView

- (NSMenu*) menuForEvent:(NSEvent *)evt
{
    NSPoint pt = [self convertPoint:[evt locationInWindow] fromView:nil];
    int row=[self rowAtPoint:pt];
    
    id clickedItem = [self itemAtRow:row];
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:row];
    [self selectRowIndexes:indexSet byExtendingSelection:NO];

    NSMenu* menu = [CocosBuilderAppDelegate appDelegate].menuContextResManager;
    menu.autoenablesItems = NO;
    
    NSArray* items = [menu itemArray];
    for (int i=[items count]-1; i>=0; --i)
    {
        NSMenuItem* item = [items objectAtIndex:i];
        
        if (item.action == @selector(menuCreateSmartSpriteSheet:))
        {
            if ([clickedItem isKindOfClass:[RMResource class]]) {
                RMResource* clickedResource = clickedItem;
                if (clickedResource.type == kCCBResTypeDirectory)
                {
                    RMDirectory* dir = clickedResource.data;

                    if (dir.isDynamicSpriteSheet)
                    {
                        item.title = @"Remove Smart Sprite Sheet";
                    }
                    else
                    {
                        item.title = @"Make Smart Sprite Sheet";
                    }

                    [item setEnabled:YES];
                    item.tag = row;
                }
                else
                {
                    [item setEnabled:NO];
                }
            }
        }
        else if (item.action == @selector(menuEditSmartSpriteSheet:))
        {
            if ([clickedItem isKindOfClass:[RMResource class]]) {
                RMResource* clickedResource = clickedItem;
                [item setEnabled:NO];
                if (clickedResource.type == kCCBResTypeDirectory)
                {
                    RMDirectory* dir = clickedResource.data;
                    if (dir.isDynamicSpriteSheet)
                    {
                        [item setEnabled:YES];
                        item.tag = row;
                    }
                }
            }
        }
        else if (item.action == @selector(menuOpenExternal:))
        {
            item.title = @"Open With External Editor";

            if ([clickedItem isKindOfClass:[RMResource class]]) {
                RMResource* clickedResource = clickedItem;
                if (clickedResource.type == kCCBResTypeCCBFile)
                {
                    [item setEnabled:NO];
                }
                else if (clickedResource.type == kCCBResTypeDirectory)
                {
                    [item setEnabled:YES];
                    item.title = @"Open Folder in Finder";
                }
                else
                {
                    [item setEnabled:YES];
                }
            }
            item.tag = row;
        }
        else if (item.tag < 0)
        {
            [menu removeItemAtIndex:i];
        }
    }
    
    // Update menu
    NSString* extension = nil;
    if ([clickedItem isKindOfClass:[RMResource class]]) {
        NSString* filePath = [(RMResource*)clickedItem filePath];
        extension = [[filePath pathExtension] lowercaseString];
        if (![extension length]) {
            BOOL isDirectory;
            [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
            if (isDirectory) {
                extension = @"folder";
            }
        }
    } else if ([clickedItem isKindOfClass:[RMDirectory class]]) {
        extension = @"folder";
    } else if ([clickedItem isKindOfClass:[RMSpriteFrame class]]) {
        extension = @"spriteframe";
    } else if ([clickedItem isKindOfClass:[RMAnimation class]]) {
        extension = @"animation";
    }
    
    if (extension)
    {
        BOOL hasPlugIn = NO;
        NSMutableArray<NSSet*>* plugInsShellsFilters = [[PlugInManager sharedManager] plugInsShellsFilters];
        for (int i=0; i<[plugInsShellsFilters count]; ++i)
        {
            NSSet* extSet = [plugInsShellsFilters objectAtIndex:i];
            if ([extSet containsObject:extension])
            {
                if (!hasPlugIn)
                {
                    hasPlugIn = YES;
                    NSMenuItem* seperator = [NSMenuItem separatorItem];
                    seperator.tag = INT_MIN;
                    [menu addItem:seperator];
                }
                NSString* plugInName = [[[PlugInManager sharedManager] plugInsShellsTitles] objectAtIndex:i];
                NSMenuItem* item = [[[NSMenuItem alloc] initWithTitle:plugInName action:@selector(runShellForItem:) keyEquivalent:@""] autorelease];
                item.target = [CocosBuilderAppDelegate appDelegate];
                item.tag = -i-1;
                [menu addItem:item];
            }
        }
    }
    
    return menu;
}

@end
