// certificate container field class
#import <Foundation/Foundation.h>

#include "time.h"
#include <Openssl/bio.h>
#include <Openssl/sha.h>
#include <Openssl/x509.h>
#include <Openssl/safestack.h>
#include <Openssl/asn1.h>
#include <Openssl/x509v3.h>
#include <Openssl/symhacks.h>
#include <Openssl/objects.h>
#include <Openssl/pem.h>
#include <Openssl/rsa.h>
#include <Openssl/ec.h>

#include "../Utils/Utils.h"

enum CERT_SIMPLIFYED_STATUS {
    CSS_VALID = 0,
    CSS_INVALID = 1,
    CSS_INSUFFICIENT_INFO = 2
    };

@interface CertificateInfo : NSObject
{
    NSString* serialNumber;
    EVP_PKEY *private_key;
    X509_NAME* issuer;
    X509_NAME* subject;
    time_t validFrom;
    time_t validTo;
    NSString* version;
    NSString* signatureAlg;
    NSString* signature;
    NSString* signatureParam;
    NSString* publicKey;
    NSString* keyUsageString;
    NSString* skid;
    NSString* akid;
    NSDictionary* authorityInformationAccess; // key - access method, value - URL
    NSArray* cdpURLs; // array of CRL Distribution Point URLs
    NSArray* eku;
    bool isEKUCritical;
    bool isKeyUsageCritical;
    bool isSKIDCritical;
    bool isAKIDCritical;
    bool isAuthorityAccessInfoCritical;
    bool isCDPCritical;
    int keyUsage;
    @public X509 *x509;
    
    BOOL needToFreeX509;
}

// to init with copy of some class object. Please use it instead simple assignment
- (id) initFromCopy:(CertificateInfo*)cert;
- (id) initWithX509:(X509 *)cert doNotCopy:(BOOL)noCopyFlag;
- (id) initWithX509:(X509 *)cert;

@property (nonatomic, retain) NSString* serialNumber;
@property (nonatomic, retain) NSString* keyUsageString;
@property (nonatomic, retain) NSString* signatureAlg;
@property (nonatomic, retain) NSString* signature;
@property (nonatomic, retain) NSString* version;
@property (nonatomic, retain) NSString* signatureParam;
@property (nonatomic, retain) NSString* publicKey;
@property (nonatomic, retain) NSString* skid;
@property (nonatomic, retain) NSString* akid;
@property (nonatomic, retain) NSDictionary* authorityInformationAccess;
@property (nonatomic, retain) NSArray* cdpURLs;
@property (nonatomic, retain) NSArray* eku;

@property (nonatomic, assign) X509_NAME* issuer;
@property (nonatomic, assign) X509 *x509;
@property (nonatomic, assign) X509_NAME* subject;
@property (nonatomic, assign) EVP_PKEY *private_key;
@property (nonatomic, assign) time_t validFrom;
@property (nonatomic, assign) time_t validTo;
@property (nonatomic, assign) bool isKeyUsageCritical;
@property (nonatomic, assign) bool isEKUCritical;
@property (nonatomic, assign) bool isSKIDCritical;
@property (nonatomic, assign) bool isAKIDCritical;
@property (nonatomic, assign) bool isAuthorityAccessInfoCritical;
@property (nonatomic, assign) bool isCDPCritical;
@property (nonatomic, assign) int keyUsage;

@property (nonatomic, retain) NSData* privateKeyId;

- (int)verify;

+ (enum CERT_SIMPLIFYED_STATUS)simplifyedStatusByDetailedStatus:(int)detailedStatus;
+ (NSString*)getCertStatusDescriptionForCertStatus:(int)certStatus withDetails:(BOOL)withDetails;

@end