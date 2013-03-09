//
//  JSSMViewController.m
//  SolrMap
//
//  Created by Christopher Judd on 11/30/12.
//  Copyright (c) 2012 Judd Solutions. All rights reserved.
//

#import "JSSMViewController.h"
#import "RestKit.h"

@interface JSSMViewController ()
@property (weak, nonatomic) IBOutlet UITextField *kmField;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation JSSMViewController

- (void)findLocations {
    // need to do this since solr response with "text/plain" rather than "application/json"
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
    
    // map the objects
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[JSSMAnnotation class]];
    [mapping addAttributeMappingsFromDictionary:@{
     @"name":            @"name",
     @"description":     @"description",
     @"coordinates_p":   @"location"
     }];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping pathPattern:nil keyPath:@"response.docs" statusCodes:nil];
    
    NSString* solrUrl = [NSString stringWithFormat:@"http://localhost:8983/solr/collection1/select?q=*:*&fq=%%7B!bbox%%7D&pt=%f,%f&d=%@&sfield=coordinates_p&wt=json&fl=_dist_:geodist(),name,description,coordinates_p", self.mapView.centerCoordinate.latitude, self.mapView.centerCoordinate.longitude, self.kmField.text];
    
    NSURL *url = [NSURL URLWithString:solrUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDescriptor]];
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        
        NSArray* points = [result array];
        [self.mapView addAnnotations: points];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Failed with error: %@", [error localizedDescription]);
    }];
    [operation start];
}

- (void)zoomSanFran {
    CLLocationCoordinate2D sanfranCenterCoordinate = {37.7752,-122.4232};
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(
                                    sanfranCenterCoordinate, 50000, 50000);
    [self.mapView setRegion:region animated:TRUE];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;
    self.kmField.delegate = self;
    [self zoomSanFran];
    //[self testPoint];
}

- (IBAction)findButton:(id)sender {
    [self.kmField resignFirstResponder];
    [self findLocations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self findButton:textField];
    return YES;
}

- (void) testPoint {
    CLLocationCoordinate2D coordinate = {37.7752,-122.4232};
    MKPointAnnotation* point = [MKPointAnnotation alloc];
    point.coordinate = coordinate;
    point.title = @"OSU Statium";
    
    [self.mapView addAnnotation:point];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

@implementation JSSMAnnotation

- (void) setLocation:(NSString *)location {
    _location = [location copy];
    _coordinate = [self convertStringToLatLong:location];
}

- (CLLocationCoordinate2D) convertStringToLatLong:(NSString*)loc
{
    CLLocationCoordinate2D location;
    
    NSArray * locationArray = [loc componentsSeparatedByString: @","];
    
    location.latitude = [[locationArray objectAtIndex:0] doubleValue];
    location.longitude = [[locationArray objectAtIndex:1] doubleValue];
    return location;
}

@end