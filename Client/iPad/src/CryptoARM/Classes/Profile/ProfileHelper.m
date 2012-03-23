//
//  ProfileHelper.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 1/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProfileHelper.h"

#import "PathHelper.h"
#import "Utils.h"
#import "XmlTags.h"

@implementation ProfileHelper

@synthesize profiles;
@synthesize storageFile;

- (BOOL)parseStringToBool:(NSString*)boolString
{
    return !([boolString compare:@"0"] == NSOrderedSame);
}

- (NSData*)hexStringToData:(NSString*)sourceString
{
    NSMutableData *resultData = [[NSMutableData alloc] init];
    
    unsigned int scanResult;
    unsigned char tmpByte;
    
    NSScanner *scanner = [[NSScanner alloc] initWithString:sourceString];
    while (!scanner.isAtEnd)
    {
        [scanner scanHexInt:&scanResult];
        tmpByte = scanResult;
        [resultData appendBytes:&tmpByte length:1];
    }
    
    [scanner release];
    
    return [resultData autorelease];
}

- (id)initEmpty
{
    self = [super init];
    if(self)
    {
        profiles = [[NSMutableArray alloc] init];
        [tagStack addObject:[NSNumber numberWithInt:PTT_NONE]];
        parsingProfile = nil;
        parsingDataAccumulator = nil;
    }
    return self;
}

- (id)initWithStorageFile:(NSString*)sourceFile
{
    self = [super init];
    if(self)
    {
        profiles = [[NSMutableArray alloc] init];
        
        if(sourceFile)
        {
            self.storageFile = sourceFile;
        }
        else
        {
            self.storageFile = [NSString stringWithFormat:@"%@/%@", [PathHelper getOperationalSettinsDirectoryPath], [PathHelper getProfilesFileName]];
        }
        
        [tagStack addObject:[NSNumber numberWithInt:PTT_NONE]];
        [self readStorage:self.storageFile];
        
        parsingProfile = nil;
        parsingDataAccumulator = nil;
    }
    return self;
}

- (void)dealloc
{
    [profiles release];
    [storageFile release];
    
    [super dealloc];
}

- (BOOL)addProfile:(Profile*)newProfile
{
    BOOL result = [self checkIfExistsProfileWithId:newProfile.profileId];
    if( !result )
    {
        [profiles addObject:newProfile];
    }
    return result;
}

- (BOOL)removeProfileWithId:(NSString*)removingId
{
    Profile *profileToRemove = nil;
    for (Profile *curProfile in self.profiles)
    {
        if( [removingId compare:curProfile.profileId] == NSOrderedSame )
        {
            profileToRemove = curProfile;
            break;
        }
    }
    
    if( profileToRemove )
    {
        [self.profiles removeObject:profileToRemove];
        return TRUE;
    }
    
    return FALSE;
}

- (BOOL)removeProfileWithName:(NSString*)removingName
{
    Profile *profileToRemove = nil;
    for (Profile *curProfile in self.profiles)
    {
        if( [removingName compare:curProfile.name] == NSOrderedSame )
        {
            profileToRemove = curProfile;
            break;
        }
    }
    
    if( profileToRemove )
    {
        [self.profiles removeObject:profileToRemove];
        return TRUE;
    }
    
    return FALSE;
}

- (BOOL)checkIfExistsProfileWithId:(NSString*)profileId
{
    for (Profile *curProfile in self.profiles)
    {
        if( [profileId compare:curProfile.name] == NSOrderedSame )
        {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - reading and writing methods

- (void)readStorage
{
    [self readStorage:nil];
}

- (void)readStorage:(NSString*)storageFileName
{
    NSString *currentStorage = (storageFileName ? storageFileName : self.storageFile);
    
    if( !currentStorage )
    {
        NSLog(@"Error: profile storage file name not specified!");
    }
    
    NSError *readingError = nil;
    NSData *storageData = [NSData dataWithContentsOfFile:currentStorage options:NSDataReadingUncached error:&readingError];
    if(readingError)
    {
        NSLog(@"Error reading profiles data from file %@. Error description: %@", currentStorage, readingError);
        return;
    }
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:storageData];
    parser.delegate = self;
    
    [self.profiles removeAllObjects];
    BOOL parseResult = [parser parse];
    
    if( !parseResult && parser.parserError )
    {
        NSLog(@"Warning: Profiles storage parsing failed. Error description:\n\t%@", parser.parserError);
    }
    
    [parser release];
}

- (void)writeStorage
{
    [self writeStorage:nil];
}

- (void)writeStorage:(NSString*)storageFileName
{
    NSString *currentStorage = (storageFileName ? storageFileName : self.storageFile);
    
    if( !currentStorage )
    {
        NSLog(@"Error: profile storage file name not specified!");
    }
    
    DDXMLElement *profilesElement = [DDXMLElement elementWithName:TAG_PROFILES];
    
    for (Profile *curProfile in self.profiles)
    {
        [profilesElement addChild:[curProfile constructXmlBranch]];
    }
    
    DDXMLElement *storeElement = [DDXMLElement elementWithName:TAG_PROFILESTORE];
    DDXMLElement *rootElement = [DDXMLElement elementWithName:TAG_TRUSTEDDESKTOP];
    
    [storeElement addChild:profilesElement];
    [rootElement addChild:storeElement];
    
    NSError *initError = nil;
    DDXMLDocument *profilesStore = [[DDXMLDocument alloc] initWithXMLString:rootElement.XMLString options:0 error:&initError];
    if( initError )
    {
        NSLog(@"Error iitializing DDXMLDocument with XML string. Error description:\n\t%@", initError);
        [profilesStore release];
        return;
    }
    
    [profilesStore.XMLData writeToFile:currentStorage atomically:YES];
    [profilesStore release];
}

#pragma mark - NSXMLParserDelegate support

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if( !tagStack )
    {
        tagStack = [[NSMutableArray alloc] init];
    }
    
    if( [elementName compare:TAG_TRUSTEDDESKTOP] == NSOrderedSame )
    {
        [tagStack addObject:[NSNumber numberWithInt:PTT_TRUSTEDDESKTOP]];
    }
    if( [elementName compare:TAG_PROFILESTORE] == NSOrderedSame )
    {
        [tagStack addObject:[NSNumber numberWithInt:PTT_PROFILESTORE]];
    }
    if( [elementName compare:TAG_PROFILES] == NSOrderedSame )
    {
        [tagStack addObject:[NSNumber numberWithInt:PTT_PROFILES]];
    }
    else if( [elementName compare:TAG_PROFILE] == NSOrderedSame )
    {
        [tagStack addObject:[NSNumber numberWithInt:PTT_PROFILE]];
        parsingProfile = [[Profile alloc] initEmpty];
    }
    else if( [elementName compare:TAG_PROFILE_ID] == NSOrderedSame )
    {
        [tagStack addObject:[NSNumber numberWithInt:PTT_ID]];
    }
    else if( [elementName compare:TAG_NAME] == NSOrderedSame )
    {
        [tagStack addObject:[NSNumber numberWithInt:PTT_NAME]];
    }
    else if( [elementName compare:TAG_DESCRIPTION] == NSOrderedSame )
    {
        [tagStack addObject:[NSNumber numberWithInt:PTT_DESCRIPTION]];
    }
    else if( [elementName compare:TAG_CREATION_DATE] == NSOrderedSame )
    {
        [tagStack addObject:[NSNumber numberWithInt:PTT_CREATION_DATE]];
    }
    else if( [elementName compare:TAG_ENCRYPT_TO_SENDER] == NSOrderedSame )
    {
        [tagStack addObject:[NSNumber numberWithInt:PTT_ENCRYPT_TO_SENDER]];
    }
    else if( [elementName compare:TAG_ENCRYPT_P7M] == NSOrderedSame )
    {
        [tagStack addObject:[NSNumber numberWithInt:PTT_ENCRYPT_P7M]];
    }
    else if( [elementName compare:TAG_ENCRYPT_PEM] == NSOrderedSame )
    {
        [tagStack addObject:[NSNumber numberWithInt:PTT_ENCRYPT_PEM]];
    }
    else if( [elementName compare:TAG_ENCRYPT_CERTIFICATE] == NSOrderedSame )
    {
        [tagStack addObject:[NSNumber numberWithInt:PTT_ENCRYPT_CERTIFICATE]];
        parsingDataAccumulator = [[NSMutableString alloc] init];
    }
    else if( [elementName compare:TAG_ENCRYPT_RECIPIENTS_CERTIFICATE] == NSOrderedSame )
    {
        [tagStack addObject:[NSNumber numberWithInt:PTT_ENCRYPT_RECIPIENTS_CERTIFICATE]];
        parsingDataAccumulator = [[NSMutableString alloc] init];
    }
    else if( [elementName compare:TAG_DECRYPT_CERTIFICATE] == NSOrderedSame )
    {
        [tagStack addObject:[NSNumber numberWithInt:PTT_DECRYPT_CERTIFICATE]];
        parsingDataAccumulator = [[NSMutableString alloc] init];
    }
    else if( [elementName compare:TAG_POLICY_PROFILE] == NSOrderedSame )
    {
        [tagStack addObject:[NSNumber numberWithInt:PTT_POLICY_PROFILE]];
        parsingPolicyProfile = [[PolicyProfileHelper alloc] init];
    }
    else if( [elementName compare:TAG_CERTIFICATE_POLICIES] == NSOrderedSame )
    {
        [tagStack addObject:[NSNumber numberWithInt:PTT_CERTIFICATE_POLICIES]];
    }
    else if( [elementName compare:TAG_POLICY] == NSOrderedSame )
    {
        [tagStack addObject:[NSNumber numberWithInt:PTT_POLICY]];
        [parsingPolicyProfile startPolicy];
    }
    else if( [elementName compare:TAG_POLICY_ID] == NSOrderedSame )
    {
        [tagStack addObject:[NSNumber numberWithInt:PTT_POLICY_ID]];
    }
    else if( [elementName compare:TAG_EKU] == NSOrderedSame )
    {
        [tagStack addObject:[NSNumber numberWithInt:PTT_EKU]];
    }
    else if( [elementName compare:TAG_OID] == NSOrderedSame )
    {
        [tagStack addObject:[NSNumber numberWithInt:PTT_OID]];
        [parsingPolicyProfile startOid];
    }
    else if( [elementName compare:TAG_VALUE] == NSOrderedSame )
    {
        [tagStack addObject:[NSNumber numberWithInt:PTT_VALUE]];
    }
    else if( [elementName compare:TAG_FRND_NAME] == NSOrderedSame )
    {
        [tagStack addObject:[NSNumber numberWithInt:PTT_FRIENDLY_NAME]];
    }
    else if( [elementName compare:TAG_NEW_SIGNATURE] == NSOrderedSame )
    {
        [tagStack addObject:[NSNumber numberWithInt:PTT_NEW_SIGNATURE]];
        parsingPolicyProfile.currentPolicyId = @"";
    }
    else if( [elementName compare:TAG_USE_POLICY] == NSOrderedSame )
    {
        [tagStack addObject:[NSNumber numberWithInt:PTT_USE_POLICY]];
    }
    else if( [elementName compare:TAG_VERIFY_SIGNATURE] == NSOrderedSame )
    {
        [tagStack addObject:[NSNumber numberWithInt:PTT_VERIFY_SIGNATURE]];
        parsingPolicyProfile.currentPolicyId = @"";
    }
    else if( [elementName compare:TAG_DECHIPHER_PARAMETERS] == NSOrderedSame )
    {
        [tagStack addObject:[NSNumber numberWithInt:PTT_DECHIPHER_PARAMETERS]];
        parsingPolicyProfile.currentPolicyId = @"";
    }
    else if( [elementName compare:TAG_ENCHIPHER_PARAMETERS] == NSOrderedSame )
    {
        [tagStack addObject:[NSNumber numberWithInt:PTT_ENCHIPHER_PARAMETERS]];
        parsingPolicyProfile.currentPolicyId = @"";
    }
    else if( [elementName compare:TAG_VERIFIED_CERTIFICATES] == NSOrderedSame )
    {
        [tagStack addObject:[NSNumber numberWithInt:PTT_VERIFIED_CERTIFICATES]];
        parsingDataAccumulator = [[NSMutableString alloc] init];
    }
    else if( [elementName compare:TAG_SIGN_COMMENT] == NSOrderedSame )
    {
        [tagStack addObject:[NSNumber numberWithInt:PTT_SIGN_COMMENT]];
    }
    else if( [elementName compare:TAG_SIGN_CERTIFICATE] == NSOrderedSame )
    {
        [tagStack addObject:[NSNumber numberWithInt:PTT_SIGN_CERTIFICATE]];
        parsingDataAccumulator = [[NSMutableString alloc] init];
    }
    else if( [elementName compare:TAG_SIGN_PIN] == NSOrderedSame )
    {
        [tagStack addObject:[NSNumber numberWithInt:PTT_SIGN_PIN]];
        parsingDataAccumulator = [[NSMutableString alloc] init];
    }
    else if( [elementName compare:TAG_SIGN_HASH_ALGORITHM] == NSOrderedSame )
    {
        [tagStack addObject:[NSNumber numberWithInt:PTT_SIGN_HASH_ALGORITHM]];
    }
    else if( [elementName compare:TAG_SIGN_DETACH] == NSOrderedSame )
    {
        [tagStack addObject:[NSNumber numberWithInt:PTT_SIGN_DETACH]];
    }
    else if( [elementName compare:TAG_SIGN_RESOURCE] == NSOrderedSame )
    {
        [tagStack addObject:[NSNumber numberWithInt:PTT_SIGN_RESOURCE]];
    }
    else if( [elementName compare:TAG_SIGN_RESOURCE_IS_FILE] == NSOrderedSame )
    {
        [tagStack addObject:[NSNumber numberWithInt:PTT_SIGN_RESOURCE_IS_FILE]];
    }
    else if( [elementName compare:TAG_SIGN_P7S] == NSOrderedSame )
    {
        [tagStack addObject:[NSNumber numberWithInt:PTT_SIGN_P7S]];
    }
    else if( [elementName compare:TAG_SIGN_PEM] == NSOrderedSame )
    {
        [tagStack addObject:[NSNumber numberWithInt:PTT_SIGN_PEM]];
    }
    else if( [elementName compare:TAG_SIGN_ARCHIVE_FILES] == NSOrderedSame )
    {
        [tagStack addObject:[NSNumber numberWithInt:PTT_SIGN_ARCHIVE_FILES]];
    }
    else if( [elementName compare:TAG_SIGN_TYPE] == NSOrderedSame )
    {
        [tagStack addObject:[NSNumber numberWithInt:PTT_SIGN_TYPE]];
    }
    else
    {
        [tagStack addObject:[NSNumber numberWithInt:PTT_UNKNOWN]];
        NSLog(@"Information: Unknown tag found: %@", elementName);
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if( !tagStack )
    {
        return;
    }
    
    if( parsingProfile )
    {
        enum profile_tag_type tagType = (enum profile_tag_type)(((NSNumber*)tagStack.lastObject).intValue);
        
        if( tagType == PTT_ENCRYPT_CERTIFICATE || tagType == PTT_ENCRYPT_RECIPIENTS_CERTIFICATE  || tagType == PTT_DECRYPT_CERTIFICATE || tagType == PTT_SIGN_CERTIFICATE )
        {
            NSData *dataWithSST = [self hexStringToData:parsingDataAccumulator];
            
            NSArray *certs = [Utils certificatesFromSST:dataWithSST];
            if( certs && certs.count )
            {
                switch (tagType) {
                    case PTT_SIGN_CERTIFICATE:
                        parsingProfile.signCertificate = (CertificateInfo*)[certs objectAtIndex:0];
                        break;
                        
                    case PTT_ENCRYPT_CERTIFICATE:
                        parsingProfile.encryptCertificate = (CertificateInfo*)[certs objectAtIndex:0];
                        break;
                        
                    case PTT_ENCRYPT_RECIPIENTS_CERTIFICATE:
                        parsingProfile.recieversCertificates = certs;
                        break;
                        
                    case PTT_DECRYPT_CERTIFICATE:
                        parsingProfile.decryptCertificate = (CertificateInfo*)[certs objectAtIndex:0];
                        break;
                        
                    default:
                        break;
                }
            }
            
            [parsingDataAccumulator release];
            parsingDataAccumulator = nil;
        }
        
        if( tagType == PTT_SIGN_PIN )
        {
            NSData *pinData = [self hexStringToData:parsingDataAccumulator];
            parsingProfile.signCertPIN = [Utils decryptPin:pinData];

            [parsingDataAccumulator release];
            parsingDataAccumulator = nil;
        }
        
        if( parsingPolicyProfile )
        {
            switch (tagType) {
                case PTT_POLICY_PROFILE:
                {
                    //TODO: add reading filter for sign certificates
                    parsingProfile.encryptCertFilter = parsingPolicyProfile.oidsForEnchipherParameters;
                    [parsingPolicyProfile release];
                    parsingPolicyProfile = nil;
                }
                    break;
                    
                case PTT_POLICY:
                    [parsingPolicyProfile endPolicy];
                    break;
                    
                case PTT_OID:
                    [parsingPolicyProfile endOid];
                    break;
                    
                case PTT_NEW_SIGNATURE:
                    parsingPolicyProfile.createSignature = parsingPolicyProfile.currentPolicyId;
                    break;
                    
                case PTT_VERIFY_SIGNATURE:
                    parsingPolicyProfile.verifySignature = parsingPolicyProfile.currentPolicyId;
                    break;
                    
                case PTT_DECHIPHER_PARAMETERS:
                    parsingPolicyProfile.dechipherParameters = parsingPolicyProfile.currentPolicyId;
                    break;
                    
                case PTT_ENCHIPHER_PARAMETERS:
                    parsingPolicyProfile.enchipherParameters = parsingPolicyProfile.currentPolicyId;
                    break;
                    
                default:
                    break;
            }
        }
        
        if( tagType == PTT_VERIFIED_CERTIFICATES )
        {
            NSArray *certIds = [parsingDataAccumulator componentsSeparatedByString:@";"];
            [parsingDataAccumulator release];
            parsingDataAccumulator = nil;
            
            NSMutableArray *certsForCrlValidation = [[NSMutableArray alloc] init];
            
            for(NSString *certId in certIds)
            {
                NSRange firstColon = [certId rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
                if( firstColon.location == NSNotFound || firstColon.location == 0 )
                {
                    NSLog(@"Wrong certificate identificator format:\n%@", certId);
                    continue;
                }
                
                NSString *idWithoutVerifyingLevel = [certId substringFromIndex:firstColon.location+firstColon.length];
                
                
                
                NSInteger verifyTypeMask = [[certId substringToIndex:firstColon.location] integerValue];
                //TODO: add mask bits enumeration
                if( verifyTypeMask & 2 )
                {
                    [certsForCrlValidation addObject:idWithoutVerifyingLevel];
                }
            }
            
            if( certsForCrlValidation.count )
            {
                parsingProfile.certsForCrlValidation = certsForCrlValidation;
            }
            
            [certsForCrlValidation release];
        }
    }
    
    [tagStack removeLastObject];
    
    if( parsingProfile && (enum profile_tag_type)(((NSNumber*)tagStack.lastObject).intValue) == PTT_PROFILES )
    {
        [self.profiles addObject:parsingProfile];
        [parsingProfile release];
        parsingProfile = nil;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if( !tagStack )
    {
        return;
    }
    
    switch ((enum profile_tag_type)(((NSNumber*)tagStack.lastObject).intValue)) {
        case PTT_ID:
            parsingProfile.profileId = string;
            break;
            
        case PTT_NAME:
            parsingProfile.name = string;
            break;
            
        case PTT_DESCRIPTION:
            parsingProfile.description = string;
            break;
            
        case PTT_CREATION_DATE:
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss ZZZ";
            parsingProfile.creationDate = [formatter dateFromString:string];
            [formatter release];
        }
            break;
            
        case PTT_ENCRYPT_TO_SENDER:
            parsingProfile.encryptToSender = [self parseStringToBool:string];
            break;
            
        case PTT_ENCRYPT_P7M:
            parsingProfile.encryptFormatType =  [self parseStringToBool:string] ? FT_DER : FT_BASE64;
            break;
            
        case PTT_ENCRYPT_PEM:
            parsingProfile.encryptFormatType = [self parseStringToBool:string] ? FT_BASE64 : FT_DER;
            break;
            
        case PTT_SIGN_CERTIFICATE:
        case PTT_ENCRYPT_CERTIFICATE:
        case PTT_ENCRYPT_RECIPIENTS_CERTIFICATE:
        case PTT_DECRYPT_CERTIFICATE:
        case PTT_SIGN_PIN:
        {
            [parsingDataAccumulator appendString:string];
        }
            break;
            
        case PTT_POLICY_ID:
        case PTT_USE_POLICY:
            parsingPolicyProfile.currentPolicyId = string;
            break;
            
        case PTT_VALUE:
            parsingPolicyProfile.currentOid.usageId = string;
            break;
            
        case PTT_FRIENDLY_NAME:
            parsingPolicyProfile.currentOid.usageDescription = string;
            break;
            
        case PTT_VERIFIED_CERTIFICATES:
            [parsingDataAccumulator appendString:string];
            break;
            
        case PTT_SIGN_COMMENT:
            parsingProfile.signComment = string;
            break;
            
        case PTT_SIGN_HASH_ALGORITHM:
            parsingProfile.signHashAlgorithm = string;
            break;
            
        case PTT_SIGN_DETACH:
            parsingProfile.signDetach = [self parseStringToBool:string];
            break;
            
        case PTT_SIGN_RESOURCE:
            parsingProfile.signResource = string;
            break;
            
        case PTT_SIGN_RESOURCE_IS_FILE:
            parsingProfile.signResourceIsFile = [self parseStringToBool:string];
            break;
            
        case PTT_SIGN_P7S:
            parsingProfile.signFormatType =  [self parseStringToBool:string] ? FT_DER : FT_BASE64;
            break;
            
        case PTT_SIGN_PEM:
            parsingProfile.signFormatType = [self parseStringToBool:string] ? FT_BASE64 : FT_DER;
            break;
            
        case PTT_SIGN_ARCHIVE_FILES:
            parsingProfile.signArchiveFiles = [self parseStringToBool:string];
            break;
            
        case PTT_SIGN_TYPE:
            parsingProfile.signType = string;
            break;

        case PTT_UNKNOWN:
            //NSLog(@"Passing unsupported tag value");
            break;
            
        case PTT_NONE:
        default:
            break;
    }
}


@end
