#import "Utils.h"

#import "Certificate.h"

@implementation Utils
const NSString *productGUID = @"0AA8B7A5-0B41-4B53-9B18-B38B475CE41D";

-(id) init {
    self = [super init];
    
    return self;
}

+ (void) initialize
{
}

+ (time_t) getTimeFromASN1:(ASN1_TIME *)aTime
{
	time_t lResult = 0;
    
	char lBuffer[24];
	char * pBuffer = lBuffer;
    
	size_t lTimeLength = aTime->length;
	char * pString = (char *)aTime->data;
    
	if (aTime->type == V_ASN1_UTCTIME)
	{
		if ((lTimeLength < 11) || (lTimeLength > 17))
        {
            return 0;
        }
        
		memcpy(pBuffer, pString, 10);
		pBuffer += 10;
		pString += 10;
	}
	else
	{
		if (lTimeLength < 13)
        {
            return 0;
        }
        
		memcpy(pBuffer, pString, 12);
		pBuffer += 12;
		pString += 12;
	}
    
	if ((*pString == 'Z') || (*pString == '-') || (*pString == '+'))
	{
		*(pBuffer++) = '0';
		*(pBuffer++) = '0';
	}
	else
	{
		*(pBuffer++) = *(pString++);
		*(pBuffer++) = *(pString++);
		// Skip any fractional seconds...
		if (*pString == '.')
		{
			pString++;
			while ((*pString >= '0') && (*pString <= '9'))
            {
                pString++;
            }
		}
	}
    
	*(pBuffer++) = 'Z';
	*(pBuffer++) = '\0';
    
	time_t lSecondsFromUCT;
	if (*pString == 'Z')
	{
		lSecondsFromUCT = 0;
	}
	else
	{
		if ((*pString != '+') && (pString[5] != '-'))
        {
			return 0;
        }
        
		lSecondsFromUCT = ((pString[1]-'0') * 10 + (pString[2]-'0')) * 60;
		lSecondsFromUCT += (pString[3]-'0') * 10 + (pString[4]-'0');
		if (*pString == '-')
		{
			lSecondsFromUCT = -lSecondsFromUCT;
		}
	}
    
	struct tm lTime = {};
    lTime.tm_sec  = ((lBuffer[10] - '0') * 10) + (lBuffer[11] - '0');
	lTime.tm_min  = ((lBuffer[8] - '0') * 10) + (lBuffer[9] - '0');
	lTime.tm_hour = ((lBuffer[6] - '0') * 10) + (lBuffer[7] - '0');
	lTime.tm_mday = ((lBuffer[4] - '0') * 10) + (lBuffer[5] - '0');
	lTime.tm_mon  = (((lBuffer[2] - '0') * 10) + (lBuffer[3] - '0')) - 1;
	lTime.tm_year = ((lBuffer[0] - '0') * 10) + (lBuffer[1] - '0');
    if (lTime.tm_year < 50)
    {
        lTime.tm_year += 100; // RFC 2459
    }
	lTime.tm_wday = 0;
	lTime.tm_yday = 0;
	lTime.tm_isdst = 0;  // No DST adjustment requested
    
    lResult = mktime(&lTime);
    if ((time_t)-1 != lResult)
    {
        if (0 != lTime.tm_isdst)
        {
            lResult -= 3600;  // mktime may adjust for DST  (OS dependent)
        }
        lResult += lSecondsFromUCT;
    }
    else
    {
        lResult = 0;
    }
    
	return lResult;
}

+ (NSString*) hexDataToString:(unsigned char*)data length:(int)length isNeedSpacing:(bool)bIsSpacing{
    NSMutableString *hex = [NSMutableString string];
    char temp[3];
    for (int i = 0; i < length; i++) {
        temp[0] = '\0';
        sprintf(temp, "%02x", data[i]);
        [hex appendString:[NSString stringWithUTF8String: temp]];
        
        if ( bIsSpacing && (i+1 < length) )
        {
            [hex appendString:@" "];
        }
    }
    
    return hex;
}

+ (NSString*) asn1StringToNSString:(ASN1_STRING *)asn1str
{
    if ( (asn1str == nil) || (asn1str->length <= 0) )
    {
        return @"";
    }
    else if (asn1str->type == V_ASN1_UTF8STRING)
    {
        // UTF8
        return [NSString stringWithCString:(const char *)asn1str->data encoding:NSUTF8StringEncoding];
    }
    else
    {
        bool bIsUTF16 = false;
    
        for(int j = 0; j < asn1str->length; j++)
        {
            if ( asn1str->data[j] < '\x020' )
            {
                bIsUTF16 = true;
                break;
            }
        }

        return [NSString stringWithCString:(const char *)asn1str->data encoding:(bIsUTF16 ? NSUTF16BigEndianStringEncoding : NSASCIIStringEncoding)];
    }
}

+ (const NSString *) getProductGUID
{
    return productGUID;
}

+ (NSString *)formattedFileSize:(unsigned long long)size
{
	NSString *formattedStr = nil;

    if (size == 0)
		formattedStr = NSLocalizedString(@"EMPTY_PREFIX", @"EMPTY_PREFIX");
	else 
		if (size > 0 && size < 1024) 
			formattedStr = [NSString stringWithFormat:@"%qu %@", size, NSLocalizedString(@"BYTE_PREFIX", @"BYTE_PREFIX")];
        else 
            if (size >= 1024 && size < pow(1024, 2)) 
                formattedStr = [NSString stringWithFormat:@"%.1f %@", (float)size / 1024, NSLocalizedString(@"KBYTE_PREFIX", @"KBYTE_PREFIX")];
            else 
                if (size >= pow(1024, 2) && size < pow(1024, 3))
                    formattedStr = [NSString stringWithFormat:@"%.2f %@", ((float)size / pow(1024, 2)), NSLocalizedString(@"MBYTE_PREFIX", @"MBYTE_PREFIX")];
                else 
                    if (size >= pow(1024, 3)) 
                        formattedStr = [NSString stringWithFormat:@"%.3f GB", ((float)size / pow(1024, 3)), NSLocalizedString(@"GBYTE_PREFIX", @"GBYTE_PREFIX")];
	
	return formattedStr;
}

+ (struct SST_Entry*)getNextEntry:(struct SST_Entry*)currentEntry
{
    struct SST_Entry *resultEntry = (struct SST_Entry*)(currentEntry->data + currentEntry->length);
    if( SSTEntryIsTerminating(resultEntry) )
    {
        return nil;
    }
    
    return resultEntry;
}

+ (NSArray*)certificatesFromSST:(NSData*)sstData
{
    //TODO: Extract key, key container and provider data from SST?
    
    if( !sstData || !(sstData.length) )
    {
        NSLog(@"Information: income SST data is empty");
        return [NSArray array];
    }
    
    struct SST_Entry *currentEntry = (struct SST_Entry*)((char*)sstData.bytes + 8);
    if( SSTEntryIsTerminating(currentEntry) )
    {
        currentEntry = nil;
    }
    
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    
    while (currentEntry)
    {
        if( currentEntry->id == 0x20 && currentEntry->encodingType == 0x1 )
        {
            const unsigned char *dataPointer = currentEntry->data;
            X509 *newCert = d2i_X509(NULL, &dataPointer, currentEntry->length);
            CertificateInfo *newCertInfo = [[CertificateInfo alloc] initWithX509:newCert];
            
            [resultArray addObject:newCertInfo];
            
            [newCertInfo release];
            X509_free(newCert);
        }
        
        currentEntry = [Utils getNextEntry:currentEntry];
    }
    
    return [resultArray autorelease];
}

+ (NSData*)createSSTEntryWithId:(UInt32)entryId coding:(UInt32)entryCoding andValue:(NSData*)entryData
{
    if( !entryId || !entryData )
    {
        return [NSMutableData dataWithLength:12];
    }
    
    NSMutableData *resultData = [[NSMutableData alloc] initWithLength:(entryData.length + 12)];
    struct SST_Entry *resultEntry = (struct SST_Entry*)resultData.bytes;
    resultEntry->id = entryId;
    resultEntry->encodingType = entryCoding;
    resultEntry->length = entryData.length;
    memcpy(resultEntry->data, entryData.bytes, entryData.length);
    
    return [resultData autorelease];
}

+ (NSData*)packCertsOnlyIntoSST:(NSArray*)certificatesArray
{
    if( !certificatesArray )
    {
        return nil;
    }
    
    NSMutableArray *arrayOfSstEntries = [[NSMutableArray alloc] initWithCapacity:certificatesArray.count];
    unsigned char *dataBuffer = NULL;
    int dataLength;
    for (CertificateInfo *currentCert in certificatesArray) {
        dataBuffer = NULL;
        dataLength = i2d_X509(currentCert.x509, &dataBuffer);
        if( dataLength )
        {
            [arrayOfSstEntries addObject:[Utils createSSTEntryWithId:0x20 coding:0x1 andValue:[NSData dataWithBytes:dataBuffer length:(NSUInteger)dataLength]]];
            OPENSSL_free(dataBuffer);
        }
    }
    
    NSMutableData *resultData = [NSMutableData dataWithBytes:(void*)("\0\0\0\0CERT") length:8];
    for (NSData *currentEntry in arrayOfSstEntries)
    {
        [resultData appendData:currentEntry];
    }
    
    const char terminatingBytes[12] = {0};
    [resultData appendBytes:(const void*)terminatingBytes length:12];
    
    [arrayOfSstEntries release];
    return resultData;
}

+ (NSString*)generateUUIDWithBraces:(BOOL)addBraces
{
    CFUUIDRef newUuid = CFUUIDCreate(kCFAllocatorDefault);
    
    NSString *uuidString = (NSString*)CFUUIDCreateString(kCFAllocatorDefault, newUuid);
    NSString *resultString = [NSString stringWithFormat:(addBraces ? @"{%@}" : @"%@"), uuidString];

    CFRelease(newUuid);
    [uuidString release];
    
    return resultString;
}

+ (NSString*)generateUUID
{
    return [Utils generateUUIDWithBraces:NO];
}

//Functions for decrypting and encrypting PIN imorted from Windows CryptoARM
//wchar replaced by unichar, blob by NSData and CStdStringW by NSString
+ (NSData*)encryptPin:(NSString*)encodingPin
{
    NSMutableData *resultData = [[NSMutableData alloc] init];
    
    if( encodingPin && encodingPin.length )
	{
		srand( (unsigned)time(NULL) );
        
        unichar wchXorOrig = uchEncryptPinMagicNumberXor;
		wchXorOrig ^= (rand() & 0xff);
		wchXorOrig ^= ((rand() & 0xff) << 8);
        
        unichar wchXor = wchXorOrig;
		int iSum = 0;
        for ( size_t i = 0, uiLast = encodingPin.length - 1; i <= uiLast; i++ )
		{
			if ( i == uiLast )
			{
                [resultData appendBytes:&wchXorOrig length:sizeof(unichar)];
			}
            
            wchXor += (uchEncryptPinMagicNumberAdd + (unichar)iSum);
            unichar tmpChar = ([encodingPin characterAtIndex:i]) ^ wchXor;
            [resultData appendBytes:&tmpChar length:sizeof(unichar)];
			if ( i % 3 == 0 )
			{
                iSum += ([encodingPin characterAtIndex:i]) ^ wchXor;
			}
		}
	}
    
    return [resultData autorelease];
}

+ (NSString*)decryptPin:(NSData*)pinData
{
    NSString *codedPin = [NSString stringWithCharacters:pinData.bytes length:pinData.length/sizeof(unichar)];
    NSMutableString *resultString = [[NSMutableString alloc] init];
    
    size_t uiSize = pinData.length/sizeof(unichar);
	if ( uiSize > 1 )
	{
		size_t uiXor = uiSize - 2;
        unichar wchXor = [codedPin characterAtIndex:uiXor];
		int iSum = 0;
		for ( size_t i = 0; i < uiSize; i++ )
		{
			if ( i != uiXor )
			{
                wchXor += uchEncryptPinMagicNumberAdd + (unichar)iSum;
                
                unichar tmpChar = ([codedPin characterAtIndex:i] ^ wchXor);
                [resultString appendString:[NSString stringWithCharacters:&tmpChar length:1]];
				if ( i % 3 == 0 )
				{
                    iSum += [codedPin characterAtIndex:i];
				}
			}
		}
	}
    
    return [resultString autorelease];
}

@end