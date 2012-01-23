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
        certUsages = [[NSMutableArray alloc] init];
        
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
        //NSLog(@"Comparing \"%@\" with \"%@\"", ((CertUsage*)obj).usageDescription, usageId);
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

- (BOOL)readUsages:(NSString*)fileNme
{
    NSError *dataReadingError = nil;
    NSData *xmlData = [NSData dataWithContentsOfFile:fileNme options:NSDataReadingUncached error:&dataReadingError];
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

- (DDXMLElement*)contructUsageWithOid:(NSString*)usageOID andDescription:(NSString*)usageDescription
{
    DDXMLElement *oidRoot = [DDXMLElement elementWithName:TAG_OID];
    
    [oidRoot addChild:[DDXMLElement elementWithName:TAG_VALUE stringValue:usageOID]];
    [oidRoot addChild:[DDXMLElement elementWithName:TAG_FRND_NAME stringValue:usageDescription]];
    
    return oidRoot;
}

- (void)writeUsages:(NSString*)fileName
{
    DDXMLElement *rootDictElement = [DDXMLElement elementWithName:TAG_OIDS];
    
    CertUsage *itrUsage = nil;
    for( NSUInteger i = 0; i < [certUsages count]; i++ )
    {
        itrUsage = (CertUsage*)[certUsages objectAtIndex:i];
        [rootDictElement addChild:[self contructUsageWithOid:itrUsage.usageId andDescription:itrUsage.usageDescription]];
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

@end
