//
//  CertUsageHelper.m
//  CryptoARM
//
//  Created by Sergey Mityukov on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CertUsageHelper.h"

#import "DDXML.h"

@implementation CertUsageHelper

@synthesize certUsages;

- (id)init
{
    self = [super init];
    if(self)
    {
        certUsages = [[NSMutableArray array] retain];
        
        curTagType = TT_NONE;
        curUsage = nil;
    }
    return self;
}

- (id)initWithDictionary:(NSString*)dictionaryFileName
{
    self = [self init];
    if(self)
    {
        [self readUsages:dictionaryFileName];
    }
    return self;
}

- (void)dealloc
{
    [certUsages release];
    
    [super dealloc];
}

- (void)addUsage:(CertUsage*)usage
{
    CertUsage *existingUsage = [self checkUsageWithId:usage.usageId];
    if( existingUsage )
    {
        NSLog(@"Usage with this id already exists");
        return;
    }
    
    [certUsages addObject:usage];
    [self sortUsages];
}

//- (void)clearAll
//{
//    [certUsages removeAllObjects];
//}

- (CertUsage*)checkUsageWithId:(NSString*)usageId
{
    NSUInteger objIndex = [certUsages indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if( [((CertUsage*)obj).usageId isEqualToString:usageId] )
        {
            *stop = YES;
            return YES;
        }
        
        return NO;
    }];
    
    if( NSNotFound == objIndex )
    {
        return nil;
    }
    
    return [certUsages objectAtIndex:objIndex];
}

- (void)removeUsageWithId:(NSString*)usageId
{
    CertUsage *usage = [self checkUsageWithId:usageId];
    
    if( !usage )
    {
        return;
    }
    
    [certUsages removeObject:usage];
}

- (BOOL)readUsages:(NSString*)fileName
{
    NSError *dataReadingError = nil;
    NSData *xmlData = [NSData dataWithContentsOfFile:fileName options:NSDataReadingUncached error:&dataReadingError];
    if( dataReadingError )
    {
        NSLog(@"Error: XML file reading error:\n\t%@", dataReadingError);
    }
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
    parser.delegate = self;
    
    [certUsages removeAllObjects];
    BOOL parseResult = [parser parse];
    
    if( !parseResult && parser.parserError )
    {
        NSLog(@"Error: Parsing failed. Error description:\n\t%@", parser.parserError);
    }
    
    [parser release];
    [self sortUsages];
    return parseResult;
}

- (void)writeUsages:(NSString*)fileName
{
    DDXMLElement *rootDictElement = [DDXMLElement elementWithName:TAG_OIDS];
    
    CertUsage *itrUsage = nil;
    for( NSUInteger i = 0; i < [certUsages count]; i++ )
    {
        itrUsage = (CertUsage*)[certUsages objectAtIndex:i];
        [rootDictElement addChild:[itrUsage contructXmlBranch]];
    }
    
    NSError *initError = nil;
    DDXMLDocument *usageDictionary = [[DDXMLDocument alloc] initWithXMLString:rootDictElement.XMLString options:0 error:&initError];
    if( initError )
    {
        NSLog(@"Error iitializing DDXMLDocument with XML string. Error description:\n\t%@", initError);
        [usageDictionary release];
        return;
    }
    
    [usageDictionary.XMLData writeToFile:fileName atomically:YES];
    [usageDictionary release];
}

- (void)sortUsages
{
    [certUsages sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        CertUsage *usg1 = (CertUsage*)obj1, *usg2 = (CertUsage*)obj2;
        return [usg1.usageId compare:usg2.usageId];
    }];
}

#pragma mark - NSXMLParserDelegate support

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if( [elementName compare:TAG_OIDS] == NSOrderedSame )
    {
        //appropriate root tag
        curTagType = TT_OIDS;
    }
    else if( [elementName compare:TAG_OID] == NSOrderedSame )
    {
        curUsage = [[[CertUsage alloc] init] autorelease];
        curTagType = TT_OID;
    }
    else if( [elementName compare:TAG_VALUE] == NSOrderedSame )
    {
        curTagType = TT_VALUE;
    }
    else if( [elementName compare:TAG_FRND_NAME] == NSOrderedSame )
    {
        curTagType = TT_FRND_NAME;
    }
    else
    {
        NSLog(@"Error: Unknown tag found: %@", elementName);
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if( (TT_VALUE == curTagType) || (TT_FRND_NAME == curTagType) )
    {
        curTagType = TT_OID;
    }
    else if( TT_OID == curTagType )
    {
        curTagType = TT_OIDS;
        [self addUsage:curUsage];
        curUsage = nil;
    }
    else if( TT_OIDS == curTagType )
    {
        curTagType = TT_NONE;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if( !curUsage )
    {
        return;
    }
    
    if( TT_VALUE == curTagType )
    {
        curUsage.usageId = string;
    }
    else if( TT_FRND_NAME == curTagType )
    {
        curUsage.usageDescription = string;
    }
//    else
//    {
//        NSLog(@"Warning: characters for unknown tag %u\nCharacters value: \"%@\"", curTagType, string);
//    }
}

//+ (void)fillWithCertUsageDefaultValues:(CertUsageHelper*)certUsagesHelper
//{
//    [certUsagesHelper addUsage:[CertUsage createUsageWithId:@"1.3.6.1.5.5.7.3.1" andDescription:NSLocalizedString(@"CERT_USAGE_OID_NAME_SERVET_AUTH_CERT", @"Сертификат проверки подлинности сервера")]];
//    [certUsagesHelper addUsage:[CertUsage createUsageWithId:@"1.3.6.1.5.5.7.3.2" andDescription:NSLocalizedString(@"CERT_USAGE_OID_NAME_CLIENT_AUTH_CERT", @"Сертификат проверки подлинности клиента")]];
//    [certUsagesHelper addUsage:[CertUsage createUsageWithId:@"1.3.6.1.5.5.7.3.3" andDescription:NSLocalizedString(@"CERT_USAGE_OID_NAME_CODE_SIGNING_CERT", @"Сертификат подписи кода")]];
//    [certUsagesHelper addUsage:[CertUsage createUsageWithId:@"1.3.6.1.5.5.7.3.4" andDescription:NSLocalizedString(@"CERT_USAGE_OID_NAME_EMAIL_SECURITY_CERT", @"Сертификат защиты электронной почты")]];
//    [certUsagesHelper addUsage:[CertUsage createUsageWithId:@"1.3.6.1.5.5.7.3.8" andDescription:NSLocalizedString(@"CERT_USAGE_OID_NAME_TIMESTAMP_SIGNING_CERT", @"Сертификат подписи штампа времени")]];
//    [certUsagesHelper addUsage:[CertUsage createUsageWithId:@"1.3.6.1.5.5.7.3.9" andDescription:NSLocalizedString(@"CERT_USAGE_OID_NAME_OCSP_SESP_SIGNING_CERT", @"Сертификат подписи OCSP ответа")]];
//    [certUsagesHelper addUsage:[CertUsage createUsageWithId:@"1.3.6.1.5.5.7.2.2" andDescription:NSLocalizedString(@"CERT_USAGE_OID_NAME_IKE_MEDIATOR_CERT", @"Сертификат IKE-посредника IP-безопасности")]];
//}

+ (void)fillWithSignUsageDefaultValues:(CertUsageHelper*)signUsagesHelper
{
    [signUsagesHelper addUsage:[CertUsage createUsageWithId:@"1.2.643.6.3.1.0" andDescription:NSLocalizedString(@"PROFILE_PARAMETERS_OID_CREATION", @"Создание")]];
    [signUsagesHelper addUsage:[CertUsage createUsageWithId:@"1.2.643.6.3.1.1" andDescription:NSLocalizedString(@"PROFILE_PARAMETERS_OID_CORRECTED", @"Исправлено")]];
    [signUsagesHelper addUsage:[CertUsage createUsageWithId:@"1.2.643.6.3.1.2" andDescription:NSLocalizedString(@"PROFILE_PARAMETERS_OID_ACQUAINT", @"Ознакомлен")]];
    [signUsagesHelper addUsage:[CertUsage createUsageWithId:@"1.2.643.6.3.1.3" andDescription:NSLocalizedString(@"PROFILE_PARAMETERS_OID_AGREED", @"Согласовано")]];
    [signUsagesHelper addUsage:[CertUsage createUsageWithId:@"1.2.643.6.3.1.4" andDescription:NSLocalizedString(@"PROFILE_PARAMETERS_OID_SIGNED", @"Подписано")]];
    [signUsagesHelper addUsage:[CertUsage createUsageWithId:@"1.2.643.6.3.1.5" andDescription:NSLocalizedString(@"PROFILE_PARAMETERS_OID_AFFIRM", @"Утверждено")]];
}

@end
