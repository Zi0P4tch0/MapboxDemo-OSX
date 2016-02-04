/////////////////////////////////////////////////////////////////////////////////////
//                                                                                 //
//  The MIT License (MIT)                                                          //
//                                                                                 //
//  Copyright (c) 2016 Matteo Pacini                                               //
//                                                                                 //
//  Permission is hereby granted, free of charge, to any person obtaining a copy   //
//  of this software and associated documentation files (the "Software"), to deal  //
//  in the Software without restriction, including without limitation the rights   //
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      //
//  copies of the Software, and to permit persons to whom the Software is          //
//  furnished to do so, subject to the following conditions:                       //
//                                                                                 //
//  The above copyright notice and this permission notice shall be included in     //
//  all copies or substantial portions of the Software.                            //
//                                                                                 //
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     //
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       //
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    //
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         //
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  //
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN      //
//  THE SOFTWARE.                                                                  //
//                                                                                 //
/////////////////////////////////////////////////////////////////////////////////////

#import "WindowController.h"

NSString *const CentreOnUserLocationNotification = @"CentreOnUserLocationNotification";
NSString *const HideOverlayNotification = @"HideOverlayNotification";
NSString *const ShowOverlayNotification = @"ShowOverlayNotification";

static NSString *const ToolbarItemCentreOnUseLocation = @"ToolbarItemCentreOnUseLocation";
static NSString *const ToolbarItemHideOverlay = @"ToolbarItemHideOverlay";
static NSString *const ToolbarItemShowOverlay = @"ToolbarItemShowOverlay";

@interface WindowController ()<NSToolbarDelegate>

@property (strong, nonatomic) NSToolbar *toolbar;

@end

@implementation WindowController

- (void)windowDidLoad {
   
    [super windowDidLoad];
    
    self.window.titleVisibility = NSWindowTitleHidden;
    
    [self.window setToolbar:[self toolbar]];
}

#pragma mark - Computer Properties

- (NSToolbar *)toolbar
{
    if (!_toolbar) {
        _toolbar = [[NSToolbar alloc] initWithIdentifier:@"MapboxDemoToolbar"];
        _toolbar.delegate = self;
    }
    return _toolbar;
}

#pragma mark - NSToolbarDelegate

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar
     itemForItemIdentifier:(NSString *)itemIdentifier
 willBeInsertedIntoToolbar:(BOOL)flag
{
    if ([itemIdentifier isEqualToString:ToolbarItemCentreOnUseLocation]) {
        
        return [self toolbarItemWithTitle:@"Center On User Location"
                               identifier:ToolbarItemCentreOnUseLocation
                                 selector:@selector(centreOnUserLocation)];
        
    } else if ([itemIdentifier isEqualToString:ToolbarItemHideOverlay]) {
        
        return [self toolbarItemWithTitle:@"Hide Overlay"
                               identifier:ToolbarItemHideOverlay
                                 selector:@selector(hideOverlay)];
        
    } else if ([itemIdentifier isEqualToString:ToolbarItemShowOverlay]) {
        
        return [self toolbarItemWithTitle:@"Show Overlay"
                               identifier:ToolbarItemShowOverlay
                                 selector:@selector(showOverlay)];

        
    }
    
    return nil;
}

- (NSArray<NSString*> *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
    return @[ToolbarItemCentreOnUseLocation, ToolbarItemShowOverlay, ToolbarItemHideOverlay];
}

- (NSArray<NSString*> *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
    return @[ToolbarItemCentreOnUseLocation, ToolbarItemHideOverlay];
}

#pragma mark - Utility

- (NSToolbarItem *)toolbarItemWithTitle:(NSString *)title
                          identifier:(NSString *)identifier
                            selector:(SEL)selector
{
    NSButton *button = [[NSButton alloc] init];
    [button setBezelStyle:NSTexturedRoundedBezelStyle];
    [button setTitle:title];
    [button sizeToFit];
    
    NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
    item.view = button;
    item.target = self;
    item.action = selector;
    return item;
}

#pragma mark - Callbacks

- (void)centreOnUserLocation
{    
    [[NSNotificationCenter defaultCenter] postNotificationName:CentreOnUserLocationNotification
                                                        object:nil];
}

- (void)hideOverlay
{
    [[NSNotificationCenter defaultCenter] postNotificationName:HideOverlayNotification
                                                        object:nil];
    
    [self.toolbar removeItemAtIndex:1];
    [self.toolbar insertItemWithItemIdentifier:ToolbarItemShowOverlay atIndex:1];
}

- (void)showOverlay
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ShowOverlayNotification
                                                        object:nil];
    
    [self.toolbar removeItemAtIndex:1];
    [self.toolbar insertItemWithItemIdentifier:ToolbarItemHideOverlay atIndex:1];
}

@end
