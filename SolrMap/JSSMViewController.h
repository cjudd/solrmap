//
//  JSSMViewController.h
//  SolrMap
//
//  Created by Christopher Judd on 11/30/12.
//  Copyright (c) 2012 Judd Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface JSSMViewController : UIViewController <MKMapViewDelegate, UITextFieldDelegate>

@end

@interface JSSMAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, copy) NSString *location;

@end