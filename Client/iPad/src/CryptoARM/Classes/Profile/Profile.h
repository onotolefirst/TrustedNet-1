//
//  Profile.h
//  CryptoARM
//
//  Created by Sergey Mityukov on 1/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Certificate.h"
#import "DDXML.h"
#import "PolicyProfileHelper.h"

enum ENM_FORMAT_TYPE {
    FT_DER = 0,
    FT_BASE64 = 1
};


@interface Profile : NSObject <NSCopying>

@property (retain, nonatomic) NSString *profileId;
@property (retain, nonatomic) NSString *name;
@property (retain, nonatomic) NSString *description;
@property (retain, nonatomic) NSDate *creationDate;

// Signing
@property (retain, nonatomic) CertificateInfo *signCertificate;
@property (retain, nonatomic) NSString *signCertPIN;
@property (retain, nonatomic) NSString *signHashAlgorithm;

@property BOOL signDetach;
@property enum ENM_FORMAT_TYPE signFormatType;
@property BOOL signArchiveFiles;

@property (retain, nonatomic) NSString *signType;
@property (retain, nonatomic) NSString *signComment;
@property (retain, nonatomic) NSString *signResource;
@property BOOL signResourceIsFile;

// Encryption
@property (retain, nonatomic) CertificateInfo *encryptCertificate;
@property (retain, nonatomic) NSArray *recieversCertificates;

@property (retain, nonatomic) CertificateInfo *decryptCertificate;

@property BOOL encryptToSender;
@property enum ENM_FORMAT_TYPE encryptFormatType;

@property BOOL removeFileAfterEncryption;
@property BOOL encryptArchiveFiles;

// Cert policies
@property (retain, nonatomic) NSArray *signCertFilter;
@property (retain, nonatomic) NSArray *encryptCertFilter;
@property (retain, nonatomic) NSArray *certsForCrlValidation;

- (id)initEmpty;
- (id)initProfileWithName:(NSString*)profName description:(NSString*)profDescription creationDate:(NSDate*)createDate id:(NSString*)newId;

- (NSString*)creationDateFormatted;

- (NSArray*)getCertificateInfoByCertificateIdentificators:(NSArray*)certIdentificators;

- (DDXMLElement*)constructXmlBranch;

+ (NSString*)certificateIdForValidationFromCert:(CertificateInfo*)cert;
+ (NSString*)getDnStringInMSStyle:(X509_NAME*) expandingName;
+ (BOOL)isCertificate:(CertificateInfo*)certificate correspondsToIdString:(NSString*)validationIdString;

@end
