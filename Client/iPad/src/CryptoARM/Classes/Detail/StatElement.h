//
//  StatElement.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 10/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface StatElement : UIViewController {
    UILabel *titleLabel;
    UIImageView *mainImage;
    UILabel *upperLabel;
    UILabel *lowerLabel;
}

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UIImageView *mainImage;
@property (nonatomic, retain) IBOutlet UILabel *upperLabel;
@property (nonatomic, retain) IBOutlet UILabel *lowerLabel;

@end
