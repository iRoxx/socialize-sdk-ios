//
//  EntityViewController.m
//  SocializeSDK
//
//  Created by Fawad Haider on 7/26/11.
//  Copyright 2011 Socialize, Inc. All rights reserved.
//

#import "TestGetEntityViewController.h"
#import "LoadingView.h"
#import "UIButton+Socialize.h"

#define SUCCESS @"success"
#define FAIL @"fail"

@implementation TestGetEntityViewController

@synthesize getEntityResultLabel;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _socialize = [[Socialize alloc ] initWithDelegate:self]; 
    }
    return self;
}

- (void)dealloc
{
    [_socialize release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Get Entity";
    resultsView.hidden = YES;

    hiddenButton = [[UIButton alloc] init]; 
    hiddenButton.hidden = YES;
    hiddenButton.accessibilityLabel = @"hiddenButton";
    [self.view addSubview:hiddenButton];

    self.view.backgroundColor = [UIColor lightGrayColor];
    [getButton configureWithoutResizingWithType:AMSOCIALIZE_BUTTON_TYPE_BLACK ];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark IBActions

-(IBAction)getEntity{
    if (!hiddenButton){
        hiddenButton = [[UIButton alloc] init]; 
        hiddenButton.hidden = YES;
        hiddenButton.accessibilityLabel = @"hiddenButton";
        [self.view addSubview:hiddenButton];
    }
        
    _loadingView = [LoadingView loadingViewInView:self.view]; 
    [_socialize getEntityByKey:getEntityTextField.text];
}

#pragma socialize service delegate

// for example unlike would result in this callback
-(void)service:(SocializeService*)service didDelete:(id<SocializeObject>)object{

}

-(void)service:(SocializeService*)service didUpdate:(id<SocializeObject>)object{

}

-(void)service:(SocializeService*)service didFail:(NSError*)error{
    
    [hiddenButton removeFromSuperview];
    [hiddenButton release];
    hiddenButton = nil;
    
    resultTextField.text = FAIL;
    resultsView.hidden = YES;
    resultTextField.accessibilityValue = FAIL;

    [getEntityTextField resignFirstResponder];
    [_loadingView removeView]; 

    UIAlertView *msg;
    msg = [[UIAlertView alloc] initWithTitle:@"Error occurred" message:@"no entity found" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [msg show];
    [msg release];
    
    // setting up labels
}

-(IBAction)backgroundTouched{
    [getEntityTextField resignFirstResponder];
}

#define ACTION_PANE_HEIGHT 44

// getting/retrieving comments or likes would invoke this callback
-(void)service:(SocializeService*)service didFetchElements:(NSArray*)dataArray{

    [hiddenButton removeFromSuperview];
    [hiddenButton release];
    hiddenButton = nil;

    resultTextField.hidden = NO;
    [getEntityTextField resignFirstResponder];
    [_loadingView removeView]; 

    // we have to verify the contents are of type SocializeEntity 
    if ([dataArray count]){
        id<SocializeObject> object = [dataArray objectAtIndex:0];
        if ([object conformsToProtocol:@protocol(SocializeEntity)]){
            
            id<SocializeEntity> entity = (id<SocializeEntity>)object;
            resultTextField.text = SUCCESS;
            resultTextField.accessibilityValue = SUCCESS;
            resultsView.hidden = NO;
            keyLabel.text = entity.key;
            nameLabel.text = entity.name;
            commentsLabel.text = [NSString stringWithFormat:@"%d", entity.comments];
            likesLabel.text = [NSString stringWithFormat:@"%d", entity.likes];
            sharesLabel.text = [NSString stringWithFormat:@"%d", entity.shares];
            
            /*initialize and update the socialize action view*/
            if (!_actionView){
                _actionView = [[SocializeActionView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - ACTION_PANE_HEIGHT, self.view.bounds.size.height,  ACTION_PANE_HEIGHT)];
                [self.view addSubview:_actionView];
            }

            [_actionView updateCountsWithViewsCount:[NSNumber numberWithInt:entity.views] withLikesCount:[NSNumber numberWithInt:entity.likes] isLiked:NO withCommentsCount:[NSNumber numberWithInt:entity.comments]];
        }
    }
    else{
        resultTextField.text = FAIL;
        resultsView.hidden = YES;
        resultTextField.accessibilityValue = FAIL;
    }
}

@end