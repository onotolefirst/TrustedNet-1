
#import "Certificate.h"

#include "Crypto.h"
#include "CertificateStore.h"

@implementation CertificateInfo

@synthesize serialNumber, issuer, subject, validFrom, validTo, signatureAlg, version, signatureParam,
publicKey, signature, isKeyUsageCritical,cdpURLs,keyUsageString, keyUsage, skid, akid, isSKIDCritical, private_key,
isAKIDCritical, authorityInformationAccess, isAuthorityAccessInfoCritical, isCDPCritical, isEKUCritical, eku, x509;

-(id) init {
    self = [super init];
    
    self.isKeyUsageCritical = false;
    self.isSKIDCritical = false;
    self.isAKIDCritical = false;
    self.isAuthorityAccessInfoCritical = false;
    self.isCDPCritical = false;
    self.isEKUCritical = false;
    
    private_key = EVP_PKEY_new();
    authorityInformationAccess = [[NSDictionary alloc] init];
    cdpURLs = [[NSArray alloc] init];
    eku = [[NSArray alloc] init];
    
    return self;
}

-(id) initFromCopy:(CertificateInfo*)cert {
    self = [super init];

    self.serialNumber = cert.serialNumber;
    self.issuer = cert.issuer;
    self.subject = cert.subject;
    self.validFrom = cert.validFrom;
    self.validTo = cert.validTo;
    self.version = cert.version;
    self.signatureAlg = cert.signatureAlg;
    self.signature = cert.signature;
    self.signatureParam = cert.signatureParam;
    self.publicKey = cert.publicKey;
    self.keyUsageString = cert.keyUsageString;
    self.skid = cert.skid;
    self.akid = cert.akid;
    self.authorityInformationAccess = cert.authorityInformationAccess;
    self.cdpURLs = cert.cdpURLs;
    self.isKeyUsageCritical = cert.isKeyUsageCritical;
    self.isSKIDCritical = cert.isSKIDCritical;
    self.isAKIDCritical = cert.isAKIDCritical;
    self.isAuthorityAccessInfoCritical = cert.isAuthorityAccessInfoCritical;
    self.isCDPCritical = cert.isCDPCritical;
    self.keyUsage = cert.keyUsage;
    self.eku = cert.eku;
    self.isEKUCritical = cert.isEKUCritical;
    self.private_key = cert.private_key;
    self.x509 = cert.x509;

    return self;
}

-(id) initWithX509:(X509 *)cert
{
    return [self initWithX509:cert doNotCopy:NO];
}

-(id) initWithX509:(X509 *)cert doNotCopy:(BOOL)noCopyFlag {
    self = [super init];
    
    private_key = EVP_PKEY_new();
    authorityInformationAccess = [[NSDictionary alloc] init];
    cdpURLs = [[NSArray alloc] init];
    eku = [[NSArray alloc] init];

    if (nil == cert)
    {
        return self;
    }
    
    needToFreeX509 = noCopyFlag;
    if( noCopyFlag )
    {
        self.x509 = cert;
    }
    else
    {
        self.x509 = X509_dup(cert);
        { //TODO: remove copy crutch
            NSData* keyIdData = self.privateKeyId;
            if( keyIdData && keyIdData.length )
            {
                X509_keyid_set1(self.x509, (unsigned char*)keyIdData.bytes, keyIdData.length);
            }
            
            int aliasLen = 0;
            unsigned char *szAlias = NULL;
            szAlias = X509_alias_get0(cert, &aliasLen);
            if( szAlias )
            {
                X509_alias_set1(self.x509, szAlias, aliasLen);
            }
        }
    }
    
    self.subject = X509_get_subject_name(self.x509);    
    self.issuer = X509_get_issuer_name(self.x509);
    self.validTo = [Utils getTimeFromASN1:(X509_get_notAfter(self.x509))]; // cert expires date
    self.validFrom = [Utils getTimeFromASN1:(X509_get_notBefore(self.x509))]; // cert expires date
    //public_key = X509_get_pubkey(cert->x509);
    static const char* szPrivateKey =
    "-----BEGIN RSA PRIVATE KEY-----\n"                                                                                                                                                                                                                                               
    "MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAK06MyXJDtu5gBeD\n"
    "UYPXNNVvcxlpy9EuOq3FpifIID44gWbwBy8b5o+LElQftzaBLo4ZyTZjltiJO2Xf\n"
    "DClcWVNSGLltndRw8i1dqnBQ8uDzqr/SU75nij42lR8IHveG8Mzay8eIayfqOpgH\n"
    "D67DY35RkS5GM7PbOLJghgkyFz37AgMBAAECgYBjLOv1mRvBnn2AeLVlpwNfoxQh\n"
    "m5mOJEqCDKOpKQGUveMQHSHvzah9zCBtO084jFMsFgVF91R4mnEATOf4kh+tCxMt\n"
    "Bw7Tzddp24BIlUlmew/cu4ue2dYY/C1XFDsBq0Xh3BHmhOKy/ECivMe3qdNxANeN\n"
    "5hqspbs3i0mULBRFsQJBAOgB19JlySjAAt9l6Sl7rF4yc5t9cJUMV/LvKI1Svs2l\n"
    "6bM1r1OGW8SV5m1XZNKqDvO6+4u2YEpgrpaa+P4nhDMCQQC/JDggD4tq1YVHUoVi\n"
    "FnBGFzCGObCPMQxTuH+tKBXGeHMKva76tP9aUzqibfbsTWx4wz790EDEHlDGOCpG\n"
    "elcZAkEAtWw7iJtvoh4EIQ1gNsAvGbn6DS0aTHNKkv3RiDGcYtPK3AivAXGfcSqG\n"
    "9hnRDatN5enhqm8C/SZ9X+fvrU7ZYQJAT+hOZmjZOhKFo2mGRZln2oV7TcH0ZAh3\n"
    "RNDO347we4aDYawm6LyePB6rVphuMB+2B05omSdkzBh4YEW+trQSkQJBAMRNr1B4\n"
    "+RC6HDV2PaTIa9W/xjIK5SW+HuMiRNPluGbL9mcW0iOaaiO0CV4+R00a6I9V4noX\n"
    "VEpSG6XUWwvqoaM=\n"
    "-----END RSA PRIVATE KEY-----\n";

    BIO* tempBioPrivateKey = BIO_new_mem_buf((void *)szPrivateKey, -1);
    RSA * rsaPrivateKey = PEM_read_bio_RSAPrivateKey(tempBioPrivateKey, 0, 0, 0);
    EVP_PKEY_assign_RSA(private_key, rsaPrivateKey);     
    BIO_free(tempBioPrivateKey);

    
    
    
    
    if (nil != x509->cert_info->serialNumber)
    {
        self.serialNumber = [Utils hexDataToString:x509->cert_info->serialNumber->data length:x509->cert_info->serialNumber->length isNeedSpacing:true];
    }
    
    // extract certificate version
    BIGNUM *bnVersion = ASN1_INTEGER_to_BN(x509->cert_info->version, NULL);
    self.version = [NSString stringWithFormat:@"%u", (*bnVersion->d+1)]; // certificate version is numerated from 0

    // signature algorithm
    char *szAlg = (char*)malloc(100);
    szAlg[0] = '\0';
    OBJ_obj2txt(szAlg, 100, x509->cert_info->signature->algorithm,0);
    self.signatureAlg = [NSString stringWithCString:szAlg encoding:NSASCIIStringEncoding];
    free(szAlg);
    
    if ((nil != x509->cert_info->signature->parameter)
        && (nil != x509->cert_info->signature->parameter->value.asn1_string))
    {
        // if signature parameters are presented
        self.signatureParam = [Utils asn1StringToNSString:x509->cert_info->signature->parameter->value.asn1_string];
    }
    else
    {
        self.signatureParam = NSLocalizedString(@"NO", @"NO");
    }

    if (nil != x509->cert_info->key->public_key)
    {
        self.publicKey = [Utils hexDataToString:x509->cert_info->key->public_key->data
                                    length:x509->cert_info->key->public_key->length isNeedSpacing:true];
    }
    
    self.signature = [Utils hexDataToString:x509->signature->data length:x509->signature->length isNeedSpacing:true];

    // find key usage extension(with nid=83)
    X509_EXTENSION *keyUsageEx = nil;
    int iIndKeyUsage = X509_get_ext_by_NID(x509, NID_key_usage, -1);
    if((iIndKeyUsage >= 0) && (nil != (keyUsageEx = X509_get_ext(x509, iIndKeyUsage))))
    {
        // check critical bit
        isKeyUsageCritical = X509_EXTENSION_get_critical(keyUsageEx) > 0 ? true : false;
        
        // check bit mask on the last byte of key usage octet_string value
        keyUsage = (int)X509_EXTENSION_get_data(keyUsageEx)->data[X509_EXTENSION_get_data(keyUsageEx)->length-1];
        NSMutableString *mutableKeyUsage = [[NSMutableString alloc] init];

        // then decode the key usage mask:
        if (X509v3_KU_DIGITAL_SIGNATURE & keyUsage)
        {
            if ([mutableKeyUsage length])
            {
                [mutableKeyUsage appendString:@", "];
            }
            [mutableKeyUsage appendString:NSLocalizedString(@"KU_DIGITAL_SIGNATURE", @"KU_DIGITAL_SIGNATURE")];
        }
        
        if (X509v3_KU_NON_REPUDIATION & keyUsage)
        {
            if (mutableKeyUsage)
            {
                [mutableKeyUsage appendString:@", "];
            }
            [mutableKeyUsage appendString:NSLocalizedString(@"KU_NON_REPUDIATION", @"KU_NON_REPUDIATION")];
        }
        
        if (X509v3_KU_KEY_ENCIPHERMENT & keyUsage)
        {
            if (mutableKeyUsage)
            {
                [mutableKeyUsage appendString:@", "];
            }
            [mutableKeyUsage appendString:NSLocalizedString(@"KU_KEY_ENCIPHERMENT", @"KU_KEY_ENCIPHERMENT")];
        }
        
        if (X509v3_KU_DATA_ENCIPHERMENT & keyUsage)
        {
            if (mutableKeyUsage)
            {
                [mutableKeyUsage appendString:@", "];
            }
            [mutableKeyUsage appendString:NSLocalizedString(@"KU_DATA_ENCIPHERMENT", @"KU_DATA_ENCIPHERMENT")];
        }
        
        if (X509v3_KU_KEY_AGREEMENT & keyUsage)
        {
            if (mutableKeyUsage)
            {
                [mutableKeyUsage appendString:@", "];
            }
            [mutableKeyUsage appendString:NSLocalizedString(@"KU_KEY_AGREEMENT", @"KU_KEY_AGREEMENT")];
        }
        
        if (X509v3_KU_KEY_CERT_SIGN & keyUsage)
        {
            if (mutableKeyUsage)
            {
                [mutableKeyUsage appendString:@", "];
            }
            [mutableKeyUsage appendString:NSLocalizedString(@"KU_KEY_CERT_SIGN", @"KU_KEY_CERT_SIGN")];
        }
        
        if (X509v3_KU_CRL_SIGN & keyUsage)
        {
            if (mutableKeyUsage)
            {
                [mutableKeyUsage appendString:@", "];
            }
            [mutableKeyUsage appendString:NSLocalizedString(@"KU_CRL_SIGN", @"KU_CRL_SIGN")];
        }
        
        if (X509v3_KU_ENCIPHER_ONLY & keyUsage)
        {
            if (mutableKeyUsage)
            {
                [mutableKeyUsage appendString:@", "];
            }
            [mutableKeyUsage appendString:NSLocalizedString(@"KU_ENCIPHER_ONLY", @"KU_ENCIPHER_ONLY")];
        }

        if (!mutableKeyUsage)
        {
            self.keyUsageString = NSLocalizedString(@"KU_UNDEF", @"KU_UNDEF");
        }
        else
        {
            self.keyUsageString = [NSString stringWithString:mutableKeyUsage];
        }
        [mutableKeyUsage release];
    }

    // find extended key usage extension(with nid=126)
    X509_EXTENSION *extKeyUsageEx = nil;
    int iIndExtKeyUsage = X509_get_ext_by_NID(x509, NID_ext_key_usage, -1);
    if((iIndExtKeyUsage >= 0) && (nil != (extKeyUsageEx = X509_get_ext(x509, iIndExtKeyUsage))))
    {
        // check critical bit
        isEKUCritical = X509_EXTENSION_get_critical(extKeyUsageEx) > 0 ? true : false;
        EXTENDED_KEY_USAGE *extKU = X509_get_ext_d2i(x509, NID_ext_key_usage, NULL, NULL);
        NSMutableArray* mutableEKU = [[NSMutableArray alloc] init];
        
        for(int i = 0; i < sk_ASN1_OBJECT_num(extKU); i++)
        {
            ASN1_OBJECT *obj = sk_ASN1_OBJECT_value(extKU, i);
            char *extval = (char*)malloc(100);
            extval[0] = '\0';
            i2t_ASN1_OBJECT(extval, 100, obj);
            [mutableEKU addObject:[NSString stringWithCString:extval encoding:NSASCIIStringEncoding]];
            
            free(extval);
        }
        
        eku = [mutableEKU copy];
    }
    
    // find Subject key identifier(skid)
    X509_EXTENSION *exSKID = nil;
    int iIndSKID = X509_get_ext_by_NID(x509, NID_subject_key_identifier, -1);
    if((iIndSKID >= 0) && (nil != (exSKID = X509_get_ext(x509, iIndSKID))))
    {
        ASN1_OCTET_STRING *skidDecoded = X509V3_EXT_d2i(exSKID);
        self.skid = [Utils hexDataToString:skidDecoded->data length:skidDecoded->length isNeedSpacing:true];
        isSKIDCritical = X509_EXTENSION_get_critical(exSKID) > 0 ? true : false;
    }
    
    // find Authority key identifier(akid)    
    X509_EXTENSION *exAKID = nil;
    int iIndAKID = X509_get_ext_by_NID(x509, NID_authority_key_identifier, -1);
    if((iIndAKID >= 0) && (nil != (exAKID = X509_get_ext(x509, iIndAKID))))
    {
        isAKIDCritical = X509_EXTENSION_get_critical(exAKID) > 0 ? true : false;
        
        AUTHORITY_KEYID *akidDecoded = X509_get_ext_d2i(x509, NID_authority_key_identifier, NULL, NULL);
        if (nil != akidDecoded)
        {
            self.akid = [Utils hexDataToString:akidDecoded->keyid->data length:akidDecoded->keyid->length isNeedSpacing:true];
        }
    }
    
    // find Authority information access
    X509_EXTENSION *exAuthorityAccessInfo = nil;
    int iIndAIA = X509_get_ext_by_NID(x509, NID_info_access, -1);
    if((iIndAIA >= 0) && (nil != (exAuthorityAccessInfo = X509_get_ext(x509, iIndAIA))))
    {
        AUTHORITY_INFO_ACCESS *authorityAccessInfoDecoded = X509_get_ext_d2i(x509, NID_info_access, NULL, NULL);
        NSMutableDictionary* aia = [[NSMutableDictionary alloc] init];     
    
        STACK_OF(CONF_VALUE) *ret = nil;
        
        for(int i = 0; i < sk_ACCESS_DESCRIPTION_num(authorityAccessInfoDecoded); i++) {
            ACCESS_DESCRIPTION *desc = sk_ACCESS_DESCRIPTION_value(authorityAccessInfoDecoded, i);
            ret = i2v_GENERAL_NAME(NULL, desc->location, ret);
            
            if(!ret) break;
            CONF_VALUE *vtmp = sk_CONF_VALUE_value(ret, i);
            if(!vtmp) break;

            if (NID_ad_OCSP == OBJ_obj2nid(desc->method))
            {
                [aia setValue:NSLocalizedString(@"AM_OCSP", @"AM_OCSP") forKey:[NSString stringWithCString:vtmp->value encoding:NSASCIIStringEncoding]];
            }
            else if (NID_ad_ca_issuers == OBJ_obj2nid(desc->method))
            {
                [aia setValue:NSLocalizedString(@"AM_CA_ISSUER", @"AM_CA_ISSUER") forKey:[NSString stringWithCString:vtmp->value encoding:NSASCIIStringEncoding]];                
            }
            else
            {
                NSMutableString *accessMethod;
                char objoid[30],objname[50];
                objoid[0] = '\0'; objname[0] = '\0';
                
                OBJ_obj2txt(objoid, sizeof(objoid), desc->method, 1);
                i2t_ASN1_OBJECT(objname, sizeof(objname), desc->method);
                
                if (strlen(objname))
                {
                    accessMethod = [NSMutableString stringWithCString:objname encoding:NSASCIIStringEncoding];
                    [accessMethod appendString:@"("];
                    [accessMethod appendString:[NSString stringWithCString:objoid encoding:NSASCIIStringEncoding]];
                    [accessMethod appendString:@")"];
                }
                else
                {
                    accessMethod = [NSString stringWithCString:objoid encoding:NSASCIIStringEncoding];                    
                }
                
                [aia setValue:accessMethod forKey:[NSString stringWithCString:vtmp->value encoding:NSASCIIStringEncoding]];                                
            }
        }
        
        isAuthorityAccessInfoCritical = X509_EXTENSION_get_critical(exAuthorityAccessInfo) > 0 ? true : false;
        authorityInformationAccess = [aia copy];
        
        [aia release];
    }
    
    // find CRL Distribution Point(CDP) information
    X509_EXTENSION *exCDP = nil;
    int iIndCDP = X509_get_ext_by_NID(x509, NID_crl_distribution_points, -1);
    if((iIndCDP >= 0) && (nil != (exCDP = X509_get_ext(x509, iIndCDP))))
    {
        CRL_DIST_POINTS *cdpArray = X509_get_ext_d2i(x509, NID_crl_distribution_points, NULL, NULL);
        NSMutableArray* mutableURLs = [[NSMutableArray alloc] init];
        STACK_OF(CONF_VALUE) *ret = nil;
        
        for(int i = 0; i < sk_DIST_POINT_num(cdpArray); i++)
        {
            DIST_POINT *desc = sk_DIST_POINT_value(cdpArray, i);
            ret = i2v_GENERAL_NAMES(NULL, desc->distpoint->name.fullname, ret);
            if(!ret) break;
            
            for (int j = 0; j < sk_CONF_VALUE_num(ret); j++)
            {
                CONF_VALUE *vtmp = sk_CONF_VALUE_value(ret, j);
                if(!vtmp) break;
                [mutableURLs addObject:[NSString stringWithCString:vtmp->value encoding:NSASCIIStringEncoding]];
            }
        }
        
        isCDPCritical = X509_EXTENSION_get_critical(exCDP) > 0 ? true : false;
        cdpURLs = [mutableURLs copy];
        
        [mutableURLs release];
    }
    
    return self;
}

- (void)dealloc
{
    EVP_PKEY_free(private_key);
    
    if( needToFreeX509 )
    {
        X509_free(x509);
    }
    
    [super dealloc];
}

- (NSData*)privateKeyId
{
    int idLength = 0;
    unsigned char *keyIdData = X509_keyid_get0(self.x509, &idLength);
    
    if( !keyIdData || !idLength )
    {
        return nil;
    }
    
    return [NSData dataWithBytes:keyIdData length:idLength];
}

- (void)setPrivateKeyId:(NSData *)privateKeyIdData
{
    X509_keyid_set1(self.x509, (unsigned char*)privateKeyIdData.bytes, privateKeyIdData.length);
}

- (int)verify
{
    X509_LOOKUP_METHOD *m = NULL;
    X509_STORE_CTX ctx = {0};
    
    ENGINE *workingEngine = ENGINE_by_id(CTIOSRSA_ENGINE_ID);
    
    //TODO: Why macro not resolves by preprocessor?
    //if( workingEngine && (CTIOSRSA_ENGINE_get_x509_lookup_method(workingEngine, &m) <= 0) )
    if( workingEngine && (ENGINE_ctrl(workingEngine, 570+1, 0, &m, 0) <= 0) )
    {
        NSLog(@"Unable to get lookup method");
        return X509_V_ERR_APPLICATION_VERIFICATION;
    }	
    
    X509_STORE *x509store = X509_STORE_new();
    if( !X509_STORE_add_lookup(x509store, m) )
    {
        NSLog(@"Unable to add lookup method into store");
        return X509_V_ERR_APPLICATION_VERIFICATION;
    }
    
    if( !X509_STORE_CTX_init(&ctx, x509store, self.x509, NULL) )
    {
        NSLog(@"Unable to init store context");
        return X509_V_ERR_APPLICATION_VERIFICATION;
    }

    unsigned long verifyFlags = X509_V_FLAG_CHECK_SS_SIGNATURE;
    // Do not check CRL for self signed certificates
    if( X509_check_issued(self.x509, self.x509) )
    {
        verifyFlags |= X509_V_FLAG_CRL_CHECK | X509_V_FLAG_CRL_CHECK_ALL;
    }
    
    X509_STORE_CTX_set_flags(&ctx, verifyFlags);

    int verifyResult = X509_verify_cert(&ctx);
    int errCode = X509_STORE_CTX_get_error(&ctx);
    
    if( verifyResult <= 0 )
    {
        NSLog(@"Certificate verification failed (code = %d '%s')\n", errCode, X509_verify_cert_error_string(errCode));
    }
    
    return errCode;
}

+ (enum CERT_SIMPLIFYED_STATUS)simplifyedStatusByDetailedStatus:(int)detailedStatus
{
    switch (detailedStatus) {
            // Valid
        case X509_V_OK:
            return CSS_VALID;
            break;
            
            // Invalid
        case X509_V_ERR_UNABLE_TO_GET_ISSUER_CERT:
        case X509_V_ERR_UNABLE_TO_DECRYPT_CERT_SIGNATURE:
        case X509_V_ERR_UNABLE_TO_DECODE_ISSUER_PUBLIC_KEY:
        case X509_V_ERR_CERT_SIGNATURE_FAILURE:
        case X509_V_ERR_CERT_NOT_YET_VALID:
        case X509_V_ERR_CERT_HAS_EXPIRED:
        case X509_V_ERR_ERROR_IN_CERT_NOT_BEFORE_FIELD:
        case X509_V_ERR_ERROR_IN_CERT_NOT_AFTER_FIELD:
        case X509_V_ERR_UNABLE_TO_GET_ISSUER_CERT_LOCALLY:
        case X509_V_ERR_UNABLE_TO_VERIFY_LEAF_SIGNATURE:
        case X509_V_ERR_CERT_CHAIN_TOO_LONG:
        case X509_V_ERR_CERT_REVOKED:
        case X509_V_ERR_INVALID_CA:
        case X509_V_ERR_PATH_LENGTH_EXCEEDED:
        case X509_V_ERR_INVALID_PURPOSE:
        case X509_V_ERR_CERT_UNTRUSTED:
        case X509_V_ERR_CERT_REJECTED:
            return CSS_INVALID;
            break;
            
            // Insufficient info
        case X509_V_ERR_UNABLE_TO_DECRYPT_CRL_SIGNATURE:
        case X509_V_ERR_CRL_SIGNATURE_FAILURE:
        case X509_V_ERR_CRL_NOT_YET_VALID:
        case X509_V_ERR_CRL_HAS_EXPIRED:
        case X509_V_ERR_ERROR_IN_CRL_LAST_UPDATE_FIELD:
        case X509_V_ERR_ERROR_IN_CRL_NEXT_UPDATE_FIELD:
        case X509_V_ERR_APPLICATION_VERIFICATION:
        default:
            return CSS_INSUFFICIENT_INFO;
            break;
            
            
            //TODO: place following statuses into previous cases
        
        //case X509_V_ERR_OUT_OF_MEM:
        //case X509_V_ERR_DEPTH_ZERO_SELF_SIGNED_CERT:
        //case X509_V_ERR_SELF_SIGNED_CERT_IN_CHAIN:
        
        //// informational statuses
        //case X509_V_ERR_SUBJECT_ISSUER_MISMATCH:
        //case X509_V_ERR_AKID_SKID_MISMATCH:
        //case X509_V_ERR_AKID_ISSUER_SERIAL_MISMATCH:
        //case X509_V_ERR_KEYUSAGE_NO_CERTSIGN:
        //case X509_V_ERR_UNABLE_TO_GET_CRL_ISSUER:
        //case X509_V_ERR_UNHANDLED_CRITICAL_EXTENSION:
        //case X509_V_ERR_KEYUSAGE_NO_CRL_SIGN:
        //case X509_V_ERR_UNHANDLED_CRITICAL_CRL_EXTENSION:
        //case X509_V_ERR_INVALID_NON_CA:
        //case X509_V_ERR_PROXY_PATH_LENGTH_EXCEEDED:
        //case X509_V_ERR_KEYUSAGE_NO_DIGITAL_SIGNATURE:
        //case X509_V_ERR_PROXY_CERTIFICATES_NOT_ALLOWED:
        //case X509_V_ERR_INVALID_EXTENSION:
        //case X509_V_ERR_INVALID_POLICY_EXTENSION:
        //case X509_V_ERR_NO_EXPLICIT_POLICY:
        //case X509_V_ERR_DIFFERENT_CRL_SCOPE:
        //case X509_V_ERR_UNSUPPORTED_EXTENSION_FEATURE:
        //case X509_V_ERR_UNNESTED_RESOURCE:
        //case X509_V_ERR_PERMITTED_VIOLATION:
        //case X509_V_ERR_EXCLUDED_VIOLATION:
        //case X509_V_ERR_SUBTREE_MINMAX:
        //case X509_V_ERR_UNSUPPORTED_CONSTRAINT_TYPE:
        //case X509_V_ERR_UNSUPPORTED_CONSTRAINT_SYNTAX:
        //case X509_V_ERR_UNSUPPORTED_NAME_SYNTAX:
        //case X509_V_ERR_CRL_PATH_VALIDATION_ERROR:
    }
    
    return CSS_INSUFFICIENT_INFO;
}

+ (NSString*)getCertStatusDescriptionForCertStatus:(int)certStatus withDetails:(BOOL)withDetails
{
    NSString *simpleStatusDescription = nil;
    switch ([CertificateInfo simplifyedStatusByDetailedStatus:certStatus]) {
        case CSS_VALID:
            simpleStatusDescription = NSLocalizedString(@"CERT_VALID", @"Действителен");
            break;
            
        case CSS_INVALID:
            simpleStatusDescription = NSLocalizedString(@"CERT_INVALID", @"Не действителен");
            break;
            
        case CSS_INSUFFICIENT_INFO:
        default:
            simpleStatusDescription = NSLocalizedString(@"CERT_UNKNOWN_STATUS", @"Статус неизвестен");
            break;
    }
    
    if( !withDetails )
    {
        return simpleStatusDescription;
    }
    
    NSString *detailedDescription = nil;
    
    NSLocale *curUsrLoacale = [NSLocale autoupdatingCurrentLocale];
    NSRange searchResult = [curUsrLoacale.localeIdentifier rangeOfString:@"en"];
    if( searchResult.location != NSNotFound )
    {
        detailedDescription = [NSString stringWithUTF8String:X509_verify_cert_error_string(certStatus)];
    }
    else
    {
        //TODO: Complete the description
        switch (certStatus) {
                //case VS_VALID:
            case X509_V_OK:
                detailedDescription = @"Должно быть всё в порядке...";
                break;
                
                //case VS_INVALID:
            case X509_V_ERR_UNABLE_TO_GET_ISSUER_CERT:
                return @"Не удается получить сертификат издателя";
                break;
                
                
            case X509_V_ERR_UNABLE_TO_GET_CRL:
                detailedDescription = @"Не удалось извлечь СОС";
                break;
                
            case X509_V_ERR_UNABLE_TO_DECRYPT_CERT_SIGNATURE:
                detailedDescription = @"Не удалось проверить подпись сертфииката";
                break;
                
            case X509_V_ERR_UNABLE_TO_DECRYPT_CRL_SIGNATURE:
                detailedDescription = @"Не удалось проверить подпись СОС";
                break;
                
            case X509_V_ERR_UNABLE_TO_DECODE_ISSUER_PUBLIC_KEY:
                detailedDescription = @"Не удалось декодировать открытый ключ издателя";
                break;
                
            case X509_V_ERR_CERT_SIGNATURE_FAILURE:
                detailedDescription = @"Ошибка проверки подписи сертификата";
                break;
                
            case X509_V_ERR_CRL_SIGNATURE_FAILURE:
                detailedDescription = @"Ошибка проверки подписи СОС";
                break;
                
            case X509_V_ERR_CERT_NOT_YET_VALID:
                detailedDescription = @"Срок действия сертификата еще не наступил";
                break;
                
            case X509_V_ERR_CERT_HAS_EXPIRED:
                detailedDescription = @"Срок действия сертификата истек";
                break;
                
            case X509_V_ERR_CRL_NOT_YET_VALID:
                detailedDescription = @"Срок дейстявия СОС еще не наступил";
                break;
                
            case X509_V_ERR_CRL_HAS_EXPIRED:
                detailedDescription = @"Срок действия СОС истек";
                break;
                
            case X509_V_ERR_ERROR_IN_CERT_NOT_BEFORE_FIELD:
                detailedDescription = @"Поле сертификата \"Действителен с\" содержит некорректное значение";
                break;
                
            case X509_V_ERR_ERROR_IN_CERT_NOT_AFTER_FIELD:
                detailedDescription = @"Поле сертификата \"Действителен до\" содержит некорректное значение";
                break;
                
            case X509_V_ERR_ERROR_IN_CRL_LAST_UPDATE_FIELD:
                detailedDescription = @"В СОС ошибка в поле \"Последнее обновление\"";
                break;
                
            case X509_V_ERR_ERROR_IN_CRL_NEXT_UPDATE_FIELD:
                detailedDescription = @"В СОС ошибка в поле \"Следующее обновление\"";
                break;
                
            case X509_V_ERR_OUT_OF_MEM:
                detailedDescription = @"Недостаточно памяти";
                break;
                
            case X509_V_ERR_DEPTH_ZERO_SELF_SIGNED_CERT:
                detailedDescription = @"Проверяемый самоподписанный сертификат не установлен в хранилище доверенных корневых сертификатов.";
                break;
                
            case X509_V_ERR_SELF_SIGNED_CERT_IN_CHAIN:
                detailedDescription = @"Цепочка сертификатов может быть построена с использованием ненадежных сертификатов, но корневой сертификат не может быть найден локально.";
                break;
                
            case X509_V_ERR_UNABLE_TO_GET_ISSUER_CERT_LOCALLY:
                detailedDescription = @"Не удалось получить сертификат издателя";
                break;
                
            case X509_V_ERR_UNABLE_TO_VERIFY_LEAF_SIGNATURE:
                detailedDescription = @"Не удалось проверить подпись, поскольку она содержит только один сертификат и он не является самоподписанным.";
                break;
                
            case X509_V_ERR_CERT_CHAIN_TOO_LONG:
                detailedDescription = @"Слишком длинная цепочка сертификации";
                break;
                
            case X509_V_ERR_CERT_REVOKED:
                detailedDescription = @"Сертификат отозван";
                break;
                
            case X509_V_ERR_INVALID_CA:
                detailedDescription = @"Неверный сертификат центра сертификации. Так же возможно что данный сертификат не является сертификатом УЦ или расширения не соответствуют требуемым назначениям.";
                break;
                
            case X509_V_ERR_PATH_LENGTH_EXCEEDED:
                detailedDescription = @"Превышена длина пути (имени)";
                break;
                
            case X509_V_ERR_INVALID_PURPOSE:
                detailedDescription = @"Неверное назначение";
                break;
                
            case X509_V_ERR_CERT_UNTRUSTED:
                detailedDescription = @"Отсутствует доверие к сертификату. Корневой центр сертификации не помечен как доверенный для указанного назначения.";
                break;
                
            case X509_V_ERR_CERT_REJECTED:
                detailedDescription = @"Сертификат отвергнут";
                break;
                
                
                
                //info
            case X509_V_ERR_SUBJECT_ISSUER_MISMATCH:
                detailedDescription = @"Несоответствие имени издателя";
                break;
                
            case X509_V_ERR_AKID_SKID_MISMATCH:
                detailedDescription = @"Несоответствие идентификаторов ключей издателя и владельца";
                break;
                
            case X509_V_ERR_AKID_ISSUER_SERIAL_MISMATCH:
                detailedDescription = @"Несоответствие серифного номера издателя";
                break;
                
            case X509_V_ERR_KEYUSAGE_NO_CERTSIGN:
                detailedDescription = @"Отсутствует назначение \"Подпись сертификатов\"";
                break;
                
            case X509_V_ERR_UNABLE_TO_GET_CRL_ISSUER:
                detailedDescription = @"Невозможно получить имя издателя СОС";
                break;
                
            case X509_V_ERR_UNHANDLED_CRITICAL_EXTENSION:
                detailedDescription = @"Неизвестное критическое расширение сертификата";
                break;
                
            case X509_V_ERR_KEYUSAGE_NO_CRL_SIGN:
                detailedDescription = @"Отсутствует подьпись в СОС";
                break;
                
            case X509_V_ERR_UNHANDLED_CRITICAL_CRL_EXTENSION:
                detailedDescription = @"Неизвестное критическое расширение СОС";
                break;
                
            case X509_V_ERR_INVALID_NON_CA:
                detailedDescription = @"";
                break;
                
            case X509_V_ERR_PROXY_PATH_LENGTH_EXCEEDED:
                detailedDescription = @"";
                break;
                
            case X509_V_ERR_KEYUSAGE_NO_DIGITAL_SIGNATURE:
                detailedDescription = @"Отсутствует назначение  \"Цифровая подпись\"";
                break;
                
            case X509_V_ERR_PROXY_CERTIFICATES_NOT_ALLOWED:
                detailedDescription = @"Промежуточные сертификаты запрещены";
                break;
                
            case X509_V_ERR_INVALID_EXTENSION:
                detailedDescription = @"Неверное расширение";
                break;
                
            case X509_V_ERR_INVALID_POLICY_EXTENSION:
                detailedDescription = @"Неверное расширение политик";
                break;
                
            case X509_V_ERR_NO_EXPLICIT_POLICY:
                detailedDescription = @"";
                break;
                
            case X509_V_ERR_DIFFERENT_CRL_SCOPE:
                detailedDescription = @"";
                break;
                
            case X509_V_ERR_UNSUPPORTED_EXTENSION_FEATURE:
                detailedDescription = @"Неподдерживаемая ошибка расширения";
                break;
                
            case X509_V_ERR_UNNESTED_RESOURCE:
                detailedDescription = @"";
                break;
                
            case X509_V_ERR_PERMITTED_VIOLATION:
                detailedDescription = @"";
                break;
                
            case X509_V_ERR_EXCLUDED_VIOLATION:
                detailedDescription = @"";
                break;
                
            case X509_V_ERR_SUBTREE_MINMAX:
                detailedDescription = @"";
                break;
                
            case X509_V_ERR_UNSUPPORTED_CONSTRAINT_TYPE:
                detailedDescription = @"";
                break;
                
            case X509_V_ERR_UNSUPPORTED_CONSTRAINT_SYNTAX:
                detailedDescription = @"";
                break;
                
            case X509_V_ERR_UNSUPPORTED_NAME_SYNTAX:
                detailedDescription = @"";
                break;
                
            case X509_V_ERR_CRL_PATH_VALIDATION_ERROR:
                detailedDescription = @"";
                break;
                
                
            case X509_V_ERR_APPLICATION_VERIFICATION:
            default:
                return NSLocalizedString(@"CERT_UNKNOWN_STATUS", @"Статус неизвестен");
                break;
        }
        
        if( !detailedDescription || !detailedDescription.length )
        {
            detailedDescription = [NSString stringWithUTF8String:X509_verify_cert_error_string(certStatus)];
        }
    }
    
    return [NSString stringWithFormat:@"%@ (%@)", simpleStatusDescription, detailedDescription];
}

@end