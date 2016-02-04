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

#import "ViewController.h"

#import <CoreLocation/CoreLocation.h>
#import <Mapbox/Mapbox.h>

#import "WindowController.h"

extern NSString *const CentreOnUserLocationNotification;
extern NSString *const HideOverlayNotification;
extern NSString *const ShowOverlayNotification;

@interface ViewController ()<MGLMapViewDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *lastUserLocation;

@property (weak, nonatomic) IBOutlet MGLMapView *map;
@property (strong, nonatomic) MGLPointAnnotation *userLocationAnnotation;

@property (weak, nonatomic) IBOutlet NSView *overlayView;
@property (weak, nonatomic) IBOutlet NSTextField *latitudeTextField;
@property (weak, nonatomic) IBOutlet NSTextField *longitudeTextField;
@property (weak, nonatomic) IBOutlet NSTextField *altitudeTextField;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Map
    
    MGLMapCamera *cam = [MGLMapCamera camera];
    cam.centerCoordinate =
    CLLocationCoordinate2DMake(51.512724, -0.089785);
    cam.altitude = 12743;
    
    self.map.camera = cam;
    self.map.delegate = self;
    
    // Location Manager
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    // Overlay
    
    // Hosted layer
    
    self.overlayView.layer = [CALayer layer];
    self.overlayView.layer.backgroundColor = [[[NSColor grayColor] colorWithAlphaComponent:0.7] CGColor];
    
    [self.overlayView setWantsLayer:YES];
    
    // Notifications

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(centerOnUserLocation)
                                                 name:CentreOnUserLocationNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showOverlay)
                                                 name:ShowOverlayNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideOverlay)
                                                 name:HideOverlayNotification
                                               object:nil];

}

- (void)setRepresentedObject:(id)representedObject {
    
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

#pragma mark - Computed Properties

- (MGLPointAnnotation *)userLocationAnnotation
{
    if (!_userLocationAnnotation) {
        _userLocationAnnotation = [[MGLPointAnnotation alloc] init];
        _userLocationAnnotation.title = @"Current User Location";
    }
    return _userLocationAnnotation;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.lastUserLocation = [locations lastObject];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // Update camera
        
        MGLMapCamera *cam = [MGLMapCamera camera];
        cam.centerCoordinate = self.lastUserLocation.coordinate;
        cam.altitude = 12000;
        
        [self.map setCamera:cam animated:YES];
        
        // Update pin
        
        
        if ([[self.map annotations] containsObject:self.userLocationAnnotation]) {
            [self.map removeAnnotation:self.userLocationAnnotation];
        }
        
        self.userLocationAnnotation.coordinate = self.lastUserLocation.coordinate;
        
        [self.map addAnnotation:self.userLocationAnnotation];
        
    });
    
}

#pragma mark - MGLMapViewDelegate

- (void)mapView:(MGLMapView *)mapView cameraDidChangeAnimated:(BOOL)animated
{
    NSString *formattedLatitude = [NSString stringWithFormat:@"%2.5f", mapView.camera.centerCoordinate.latitude];
    NSString *formattedLongitude = [NSString stringWithFormat:@"%2.5f", mapView.camera.centerCoordinate.longitude];
    NSString *formattedAltitude = [NSString stringWithFormat:@"%.0f",mapView.camera.altitude];
    
    self.latitudeTextField.stringValue = formattedLatitude;
    self.longitudeTextField.stringValue = formattedLongitude;
    self.altitudeTextField.stringValue = formattedAltitude;
    
    // Update constraints as text field sizes may change.
    
    [self.overlayView setNeedsLayout:YES];
    [self.overlayView layoutSubtreeIfNeeded];
    
}

#pragma mark - Notifications

- (void)centerOnUserLocation
{
    MGLMapCamera *cam = [MGLMapCamera camera];
    cam.centerCoordinate = self.lastUserLocation.coordinate;
    cam.altitude = 12000;
    
    [self.map setCamera:cam animated:YES];
}

- (void)showOverlay
{
    self.overlayView.hidden = NO;
}

- (void)hideOverlay
{
    self.overlayView.hidden = YES;
}

@end
