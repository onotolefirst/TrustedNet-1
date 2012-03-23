//
//  StatisticsPanel.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 10/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StatisticsPanel.h"


@implementation StatisticsPanel
@synthesize statCerts;
@synthesize statCrls;
@synthesize statRequests;
@synthesize statUservoice;
@synthesize statProfile;
@synthesize viewCerts;
@synthesize viewCrls;
@synthesize viewRequests;
@synthesize viewUservoice;
@synthesize viewProfile;

@synthesize statisticsHelper;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [statCerts release];
    [statCrls release];
    [statRequests release];
    [statUservoice release];
    [statProfile release];

    [viewCerts release];
    [viewCrls release];
    [viewRequests release];
    [viewUservoice release];
    [viewProfile release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)addView:(UIView*)subview toView:(UIView*)view
{
    subview.frame = view.bounds;
    subview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [view addSubview:subview];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self addView:self.statCerts.view toView:self.viewCerts];
    [self addView:self.statCrls.view toView:self.viewCrls];
    [self addView:self.statRequests.view toView:self.viewRequests];
    [self addView:self.statUservoice.view toView:self.viewUservoice];
    [self addView:self.statProfile.view toView:self.viewProfile];
    
    self.statCerts.titleLabel.text = @"Сертификаты";
    self.statCrls.titleLabel.text = @"Списки отзыва сертификатов";
    self.statRequests.titleLabel.text = @"Запросы";
    self.statUservoice.titleLabel.text = @"Идеи";
    self.statProfile.titleLabel.text = @"Настройки";
    
    statCerts.mainImage.image = [UIImage imageNamed:@"stat-certs.png"];
    statCrls.mainImage.image = [UIImage imageNamed:@"stat-CRL.png"];
    statRequests.mainImage.image = [UIImage imageNamed:@"stat-reauests.png"];
    statUservoice.mainImage.image = [UIImage imageNamed:@"stat-UserVoice.png"];
    statProfile.mainImage.image = [UIImage imageNamed:@"profile.png"];
    
    StatisticsHelper *tmpHelper = [[StatisticsHelper alloc] initWithSomething];
    self.statisticsHelper = tmpHelper;
    [tmpHelper release];
    
    [self reloadData];
}

- (void)viewDidUnload
{
    [self setStatCerts:nil];
    [self setStatCrls:nil];
    [self setStatRequests:nil];
    [self setStatUservoice:nil];
    [self setStatProfile:nil];

    [self setViewCerts:nil];
    [self setViewCrls:nil];
    [self setViewRequests:nil];
    [self setViewUservoice:nil];
    [self setViewProfile:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)refreshContent
{
    [self reloadData];
}

- (void)reloadData
{
    if( !(self.statisticsHelper) )
    {
        return;
    }
    
    [self.statisticsHelper refreshData];
    
    statCerts.upperLabel.text = [NSString stringWithFormat:@"Действительных: %d", [self.statisticsHelper validCerts]];
    statCerts.lowerLabel.text = [NSString stringWithFormat:@"Не действительных: %d", [self.statisticsHelper invalidCerts]];
    statCrls.upperLabel.text = [NSString stringWithFormat:@"Действительных: %d", [self.statisticsHelper validCrls]];
    statCrls.lowerLabel.text = [NSString stringWithFormat:@"Не действительных: %d", [self.statisticsHelper invalidCrls]];
    statRequests.upperLabel.text = [NSString stringWithFormat:@"Обработанных: %d", [self.statisticsHelper processedRequests]];
    statRequests.lowerLabel.text = [NSString stringWithFormat:@"В ожидании: %d", [self.statisticsHelper pendingRequests]];
    statUservoice.upperLabel.text = [NSString stringWithFormat:@"Одобренных: %d", [self.statisticsHelper processedIdeas]];
    statUservoice.lowerLabel.text = [NSString stringWithFormat:@"На рассмотрении: %d", [self.statisticsHelper pendingIdeas]];
    statProfile.upperLabel.text = [NSString stringWithFormat:@"Название: %@", [self.statisticsHelper profileName]];
    statProfile.lowerLabel.text = [NSString stringWithFormat:@"Владелец: %@", [self.statisticsHelper profileOwner]];
}

@end
