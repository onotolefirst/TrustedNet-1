//
//  Profile.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 1/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Profile.h"

#import "Crypto.h"

#import "XmlTags.h"

@implementation Profile

@synthesize profileId;
@synthesize name;
@synthesize description;
@synthesize encryptToSender;
@synthesize encryptFormatType;
@synthesize removeFileAfterEncryption;
@synthesize encryptCertificate;
@synthesize recieversCertificates;
@synthesize decryptCertificate;
@synthesize certsForCrlValidation;
@synthesize signCertFilter;
@synthesize encryptCertFilter;

@synthesize creationDate;

@synthesize signCertificate;
@synthesize signCertPIN;
@synthesize signHashAlgorithm;

@synthesize signDetach;
@synthesize signFormatType;
@synthesize signArchiveFiles;

@synthesize signType;
@synthesize signComment;
@synthesize signResource;
@synthesize signResourceIsFile;

@synthesize encryptArchiveFiles;


- (id)initEmpty
{
    self = [super init];
    if(self)
    {
        self.profileId = [Utils generateUUIDWithBraces:YES];
        self.creationDate = [NSDate date];
        
        self.encryptToSender = NO;
        self.signFormatType = FT_BASE64;
        self.encryptFormatType = FT_BASE64;
        self.encryptArchiveFiles = NO;
    }
    return self;
}

- (id)initProfileWithName:(NSString*)profName description:(NSString*)profDescription creationDate:(NSDate*)createDate id:(NSString*)newId
{
    self = [self initEmpty];
    if( self )
    {
        if( newId )
        {
            self.profileId = newId;
        }
        
        self.name = profName;
        self.description = profDescription;
        
        if( createDate )
        {
            self.creationDate = createDate;
        }
    }
    
    return self;
}

//- (void)dealloc
//{
//}

- (NSString*)creationDateFormatted
{
    NSString *returningDate = [NSDateFormatter localizedStringFromDate:self.creationDate dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    
    return returningDate;
}

- (NSArray*)getCertificateInfoByCertificateIdentificators:(NSArray*)certIdentificators
{
    return nil;
}

- (NSString*)bool2IntString:(BOOL)val
{
    return ( val ? @"1" : @"0" );
}

- (NSString*)dataToHexString:(NSData*)sourceData
{
    NSMutableString *result = [[NSMutableString alloc] init];
    
    for( NSUInteger i = 0; i < sourceData.length; i++ )
    {
        [result appendFormat:@"%02x%@", ((unsigned char*)sourceData.bytes)[i], (((i+1)%16) ? (@" ") : (@"\n"))];
    }
    
    return [result autorelease];
}

+ (NSString*)certificateIdForValidationFromCert:(CertificateInfo*)cert
{
    NSString *subject = [Profile getDnStringInMSStyle:cert.subject];
    NSString *issuer = [Profile getDnStringInMSStyle:cert.issuer];
    
    NSMutableString *serial = [NSMutableString stringWithString:cert.serialNumber];
    [serial replaceOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange(0, serial.length)];
    
    return [NSString stringWithFormat:@"\"%@\",\"%@\",\"%@\"", subject, [serial uppercaseString], issuer];
}

+ (NSString*)getDnStringInMSStyle:(X509_NAME*) expandingName
{
    int entryCount = X509_NAME_entry_count(expandingName);
    NSMutableString *resultString = nil;
    NSString *undefString = [[NSString alloc] initWithCString:SN_undef encoding:NSASCIIStringEncoding];
    for( int i = entryCount-1; i >= 0; i-- )
    {
        X509_NAME_ENTRY *nameEntry = X509_NAME_get_entry(expandingName, i);
        ASN1_STRING *entryAsnString = X509_NAME_ENTRY_get_data(nameEntry);
        
        unsigned char *outBuffer;
        int length = ASN1_STRING_to_UTF8(&outBuffer, entryAsnString);
        NSString *valueString = [[NSString alloc] initWithBytes:outBuffer length:length encoding:NSUTF8StringEncoding];
        OPENSSL_free(outBuffer);
        
        //Support CryptoARM quotes processing
        NSRange firstQuote = [valueString rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
        if( firstQuote.location != NSNotFound )
        {
            NSMutableString *tmpString = [[NSMutableString alloc] initWithString:valueString];
            [tmpString replaceOccurrencesOfString:@"\"" withString:@"\"\"" options:0 range:NSMakeRange(0, valueString.length)];
            [valueString release];
            valueString = [[NSString alloc] initWithFormat:@"\"%@\"", tmpString];
            [tmpString release];
        }
        
        ASN1_OBJECT *obj = X509_NAME_ENTRY_get_object(nameEntry);
        NSString *objectString = nil;
        
        int currentNid = OBJ_obj2nid(obj);
        if( NID_stateOrProvinceName == currentNid )
        {
            //Supporting MS format "features"
            objectString = @"S";
        }
        else if( NID_pkcs9_emailAddress == currentNid )
        {
            objectString = @"E";
        }
        else
        {
            objectString = [NSString stringWithCString:OBJ_nid2sn(OBJ_obj2nid(obj)) encoding:NSUTF8StringEncoding];
            
            if( [objectString compare:undefString] == NSOrderedSame )
            {
                objectString = [Crypto convertAsnObjectToString:obj noName:YES];
            }
        }
        
        if( resultString )
        {
            [resultString appendFormat:@",%@=%@", objectString, valueString];
        }
        else
        {
            resultString = [NSMutableString stringWithFormat:@"%@=%@", objectString, valueString];
        }
        
        [valueString release];
    }
    
    [undefString release];
    
    return resultString;
}

+ (BOOL)isCertificate:(CertificateInfo*)certificate correspondsToIdString:(NSString*)validationIdString
{
    NSString *checkingCertificateId = [Profile certificateIdForValidationFromCert:certificate];
    return ([validationIdString compare:checkingCertificateId] == NSOrderedSame);
}

- (DDXMLElement*)constructXmlBranch
{
    DDXMLElement *profileRoot = [DDXMLElement elementWithName:TAG_PROFILE];
    
    [profileRoot addChild:[DDXMLElement elementWithName:TAG_PROFILE_ID stringValue:self.profileId]];
    [profileRoot addChild:[DDXMLElement elementWithName:TAG_NAME stringValue:self.name]];
    [profileRoot addChild:[DDXMLElement elementWithName:TAG_DESCRIPTION stringValue:self.description]];
    [profileRoot addChild:[DDXMLElement elementWithName:TAG_CREATION_DATE stringValue:self.creationDate.description]];
    
    [profileRoot addChild:[DDXMLElement elementWithName:TAG_ENCRYPT_TO_SENDER stringValue:[self bool2IntString:self.encryptToSender]]];
    [profileRoot addChild:[DDXMLElement elementWithName:TAG_ENCRYPT_P7M stringValue:[self bool2IntString:(self.encryptFormatType == FT_DER)]]];
    [profileRoot addChild:[DDXMLElement elementWithName:TAG_ENCRYPT_PEM stringValue:[self bool2IntString:(self.encryptFormatType == FT_BASE64)]]];
    
    if( self.encryptCertificate )
    {
        NSData *sst = [Utils packCertsOnlyIntoSST:[NSArray arrayWithObject:self.encryptCertificate]];
        [profileRoot addChild:[DDXMLElement elementWithName:TAG_ENCRYPT_CERTIFICATE stringValue:[self dataToHexString:sst]]];
    }
    
    if( self.recieversCertificates )
    {
        NSData *sst = [Utils packCertsOnlyIntoSST:self.recieversCertificates];
        [profileRoot addChild:[DDXMLElement elementWithName:TAG_ENCRYPT_RECIPIENTS_CERTIFICATE stringValue:[self dataToHexString:sst]]];
    }
    
    if( self.decryptCertificate )
    {
        NSData *sst = [Utils packCertsOnlyIntoSST:[NSArray arrayWithObject:self.decryptCertificate]];
        [profileRoot addChild:[DDXMLElement elementWithName:TAG_DECRYPT_CERTIFICATE stringValue:[self dataToHexString:sst]]];
    }
    
    if( self.encryptCertFilter || self.signCertFilter )
    {
        PolicyProfileHelper *policyHelper = [[PolicyProfileHelper alloc] init];
        
        policyHelper.oidsForEnchipherParameters = (self.encryptCertFilter ? self.encryptCertFilter : [NSArray array]);
        policyHelper.dechipherParameters = policyHelper.enchipherParameters;
        
        policyHelper.oidsForCreateSignature = (self.signCertFilter ? self.signCertFilter : [NSArray array]);
        policyHelper.verifySignature = policyHelper.createSignature;
        
        [profileRoot addChild:[policyHelper generateXmlBranch]];
        [policyHelper release];
    }
    
    if( self.certsForCrlValidation )
    {
        NSMutableString *validationCerts = [[NSMutableString alloc] init];
        for (NSString *certIdString in self.certsForCrlValidation)
        {
            [validationCerts appendFormat:@"2:%@;", certIdString];
        }
        
        //TODO: gather validation types. It's possible to implement with dictionary by certId key and validation mask value
        
        [profileRoot addChild:[DDXMLElement elementWithName:TAG_VERIFIED_CERTIFICATES stringValue:validationCerts]];
        [validationCerts release];
    }
    
    [profileRoot addChild:[DDXMLElement elementWithName:TAG_SIGN_COMMENT stringValue:self.signComment]];
    
    if( self.signCertificate )
    {
        NSData *sst = [Utils packCertsOnlyIntoSST:[NSArray arrayWithObject:self.signCertificate]];
        [profileRoot addChild:[DDXMLElement elementWithName:TAG_SIGN_CERTIFICATE stringValue:[self dataToHexString:sst]]];
    }
    
    if( self.signCertPIN && self.signCertPIN.length )
    {
        NSString *encodedPin = [self dataToHexString:[Utils encryptPin:self.signCertPIN]];
        [profileRoot addChild:[DDXMLElement elementWithName:TAG_SIGN_PIN stringValue:encodedPin]];
    }
    
    [profileRoot addChild:[DDXMLElement elementWithName:TAG_SIGN_HASH_ALGORITHM stringValue:self.signHashAlgorithm]];
    [profileRoot addChild:[DDXMLElement elementWithName:TAG_SIGN_DETACH stringValue:[self bool2IntString:self.signDetach]]];
    [profileRoot addChild:[DDXMLElement elementWithName:TAG_SIGN_RESOURCE stringValue:self.signResource]];
    [profileRoot addChild:[DDXMLElement elementWithName:TAG_SIGN_RESOURCE_IS_FILE stringValue:[self bool2IntString:self.signResourceIsFile]]];
    
    [profileRoot addChild:[DDXMLElement elementWithName:TAG_SIGN_P7S stringValue:[self bool2IntString:(self.signFormatType == FT_DER)]]];
    [profileRoot addChild:[DDXMLElement elementWithName:TAG_SIGN_PEM stringValue:[self bool2IntString:(self.signFormatType == FT_BASE64)]]];
    
    [profileRoot addChild:[DDXMLElement elementWithName:TAG_SIGN_ARCHIVE_FILES stringValue:[self bool2IntString:self.signArchiveFiles]]];
    [profileRoot addChild:[DDXMLElement elementWithName:TAG_ENCRYPT_ARCHIVE_FILES stringValue:[self bool2IntString:self.encryptArchiveFiles]]];
    [profileRoot addChild:[DDXMLElement elementWithName:TAG_SIGN_TYPE stringValue:self.signType]];
    
    [profileRoot addChild:[DDXMLElement elementWithName:TAG_ENCRYPT_DEL_SRC_FILE stringValue:[self bool2IntString:self.removeFileAfterEncryption]]];
    
    //[profileRoot addChild:[DDXMLElement elementWithName:<#(NSString *)#> stringValue:<#(NSString *)#>]];
    //[profileRoot addChild:[DDXMLElement elementWithName:<#(NSString *)#> stringValue:[self bool2IntString:<#(BOOL)#>]]];
    
    return profileRoot;
}

#pragma mark Copying protocol support

//Warning: should look after result profile
//It's possible to change some objects contained in arrays, such as CertUsages
- (id)copyWithZone:(NSZone *)zone
{
    Profile* newProfile = [[Profile alloc] initProfileWithName:self.name description:self.description creationDate:[[self.creationDate copyWithZone:zone] autorelease] id:self.profileId];
    
    if( self.signCertificate )
    {
        newProfile.signCertificate = [[[CertificateInfo alloc] initWithX509:self.signCertificate.x509] autorelease];
    }
    if( self.signCertPIN )
    {
        newProfile.signCertPIN = [[self.signCertPIN copyWithZone:zone] autorelease];
    }
    if( self.signHashAlgorithm )
    {
        newProfile.signHashAlgorithm = [[self.signHashAlgorithm copyWithZone:zone] autorelease];
    }
    
    newProfile.signDetach = self.signDetach;
    newProfile.signFormatType = self.signFormatType;
    newProfile.signArchiveFiles = self.signArchiveFiles;
    
    if( self.signType )
    {
        newProfile.signType = [[self.signType copyWithZone:zone] autorelease];
    }
    if( self.signComment )
    {
        newProfile.signComment = [[self.signComment copyWithZone:zone] autorelease];
    }
    if( self.signResource )
    {
        newProfile.signResource = [[self.signResource copyWithZone:zone] autorelease];
    }
    if( self.signResourceIsFile )
    {
        newProfile.signResourceIsFile = self.signResourceIsFile;
    }
    
    if( self.encryptCertificate )
    {
        newProfile.encryptCertificate = [[[CertificateInfo alloc] initWithX509:self.encryptCertificate.x509] autorelease];
    }
    //if certificate object does not change, then it should not be copied
    if( self.recieversCertificates )
    {
        newProfile.recieversCertificates = [[self.recieversCertificates copyWithZone:zone] autorelease];
    }
    
    if( self.decryptCertificate )
    {
        newProfile.decryptCertificate = [[[CertificateInfo alloc] initWithX509:self.decryptCertificate.x509] autorelease];
    }
    
    newProfile.encryptToSender = self.encryptToSender;
    newProfile.encryptFormatType = self.encryptFormatType;
    newProfile.encryptArchiveFiles = self.encryptArchiveFiles;
    
    // Cert policies
    if( self.signCertFilter )
    {
        newProfile.signCertFilter = [[self.signCertFilter copyWithZone:zone] autorelease];
    }
    if( self.encryptCertFilter )
    {
        newProfile.encryptCertFilter = [[self.encryptCertFilter copyWithZone:zone] autorelease];
    }
    if( self.certsForCrlValidation )
    {
        newProfile.certsForCrlValidation = [[self.certsForCrlValidation copyWithZone:zone] autorelease];
    }
    
    newProfile.removeFileAfterEncryption = self.removeFileAfterEncryption;
    
    return newProfile;
}

@end
