/*
* Copyright(C) 2011-2011 ООО <<Цифровые технологии>>
*
* Этот файл содержит информацию, являющуюся
* собственностью компании ООО <<Цифровые технологии>>.
*
* Любая часть этого файла не может быть скопирована,
* исправлена, переведена на другие языки,
* локализована или модифицирована любым способом,
* откомпилирована, передана по сети или на
* любую компьютерную систему без предварительного
* заключения соглашения с ООО <<Цифровые технологии>>.
*/

#ifndef CTCOMMON_DEBUG_H__INCLUDED
#define CTCOMMON_DEBUG_H__INCLUDED

// log levels
#define LL_OFF    -1
#define LL_NOT_INITED 0
#define LL_FATAL  1   /* fatal error */
#define LL_ERROR  2   /* error */
#define LL_ASSERT 3   /* failed assertion */
#define LL_WARN   4   /* warning, non critical error */
#define LL_NOTICE 5   /* notice, attention */
#define LL_INFO   6   /* information */
#define LL_DEBUG  7   /* debuging data, small dumps */
#define LL_DUMP   8   /* large dumps */
#define LL_TRACE  9   /* tracing calls */
#define LL_ALL    LL_TRACE
//#define NOT_SET_LOG_LEVEL = -2; - using of default value (LL_NOTICE or LL_INFO?)


#define LOG_ASSERT_ZERO(iLogLevel, x) LOG_ASSERT(iLogLevel, (x) == 0)
#define LOG_ASSERT_NEGATIVE(iLogLevel, x) LOG_ASSERT(iLogLevel, (x) < 0)
#define LOG_ASSERT_POSITIVE(iLogLevel, x) LOG_ASSERT(iLogLevel, (x) > 0)
#define LOG_ASSERT_NOT(iLogLevel, x) LOG_ASSERT(iLogLevel, (!(x)))
#define LOG_ASSERT_NOT_ZERO(iLogLevel, x) LOG_ASSERT(iLogLevel, (x) != 0)
#define LOG_ASSERT_NOT_NEGATIVE(iLogLevel, x) LOG_ASSERT(iLogLevel, (x) >= 0)
#define LOG_ASSERT_NOT_POSITIVE(iLogLevel, x) LOG_ASSERT(iLogLevel, (x) <= 0)
#define LOG_ASSERT_TRUE(iLogLevel, x) LOG_ASSERT(iLogLevel, (x) == TRUE)
#define LOG_ASSERT_FALSE(iLogLevel, x) LOG_ASSERT(iLogLevel, (x) == FALSE)
#define LOG_ASSERT_NULL(iLogLevel, x) LOG_ASSERT(iLogLevel, (x) == NULL)
#define LOG_ASSERT_NOT_NULL(iLogLevel, x) LOG_ASSERT(iLogLevel, (x) != NULL)
#define LOG_ASSERT_HCRYPT_NULL(iLogLevel, x) LOG_ASSERT(iLogLevel, (x) == HCRYPT_NULL)
#define LOG_ASSERT_NOT_HCRYPT_NULL(iLogLevel, x) LOG_ASSERT(iLogLevel, (x) != HCRYPT_NULL)
#define LOG_ASSERT_STRLEN(iLogLevel, x) LOG_ASSERT(iLogLevel, ((x) && (strlen(x) > 0)))


#ifdef DEBUG_LOG

#include <openssl/bio.h>


// LOG_DECLARE_LOCATION should be declared before local variables
#define LOG_DECLARE_LOCATION_NO_TRACE(szLocation) \
	char _szLogLocation[] = szLocation; \
	int _iLogTmp = 0

#define LOG_DECLARE_LOCATION(szLocation) \
	char _szLogLocation[] = szLocation; \
	int _iLogTmp = LOG_log(LL_TRACE, LOG_get_datetime(LL_TRACE), \
		OPENSSL_strdup("in ..."), \
		_szLogLocation, __FILE__, __LINE__)

#define LOG_AVOID_ARTIFACTS \
	(void)(_szLogLocation); \
	(void)(_iLogTmp)

// asserions
#define LOG_ASSERT(iLogLevel, x) \
	(void) ( LOG_check_bool((int)(x)) \
		|| LOG_log(iLogLevel, LOG_get_datetime(iLogLevel), \
			LOG_format(iLogLevel, "Assertion failed: '%s'", #x), \
			_szLogLocation, __FILE__, __LINE__) ); \
	LOG_AVOID_ARTIFACTS

// syntax of "args" in follow macroses: iLogLevel, format, ...
#define LOG_PRINTF(args) \
	{ int iLogLevel = LOG_get_level_arg args; \
		char *pszLogText = LOG_format args; \
		LOG_log(iLogLevel, LOG_get_datetime(iLogLevel), \
			pszLogText, \
			_szLogLocation, __FILE__, __LINE__); } \
		LOG_AVOID_ARTIFACTS
#define LOG_ERRNO(args) \
	{ int iErrno = errno; \
		int iLogLevel = LOG_get_level_arg args; \
		char *pszLogText = LOG_format args; \
		char *szErrnoDesc = strerror(iErrno); \
		pszLogText = LOG_concat( iLogLevel, pszLogText, LOG_format(iLogLevel, " (errno:%d '%s')", iErrno, szErrnoDesc)); \
		LOG_log(iLogLevel, LOG_get_datetime(iLogLevel), \
			pszLogText, \
			_szLogLocation, __FILE__, __LINE__); \
		errno = iErrno; } \
		LOG_AVOID_ARTIFACTS
#define LOG_WINERROR(args) \
	{ int iLogLevel = LOG_get_level_arg args; \
		char *pszLogText = LOG_format args; \
		pszLogText = LOG_concat( iLogLevel, pszLogText, LOG_format(iLogLevel, " (ERROR:0x%08x)", GetLastError())); \
		LOG_log(iLogLevel, LOG_get_datetime(iLogLevel), \
			pszLogText, \
			_szLogLocation, __FILE__, __LINE__); } \
		LOG_AVOID_ARTIFACTS
#define LOG_SECERROR(args) \
	{ int iLogLevel = LOG_get_level_arg args; \
		char *pszLogText = LOG_format_sec args; \
		LOG_log(iLogLevel, LOG_get_datetime(iLogLevel), \
			pszLogText, \
			_szLogLocation, __FILE__, __LINE__); } \
		LOG_AVOID_ARTIFACTS
#define LOG_SQLITEERROR(args) \
	{ int iLogLevel = LOG_get_level_arg args; \
		char *pszLogText = LOG_format_sqlite args; \
		LOG_log(iLogLevel, LOG_get_datetime(iLogLevel), \
			pszLogText, \
			_szLogLocation, __FILE__, __LINE__); } \
		LOG_AVOID_ARTIFACTS


typedef int (* fnLog)(int iLogLevel, const char *szDateTime, const char *szLogLevel, const char *szText,
                      const char *szLocation, const char *szFile, int iLine);

CTCOMMON_API int LOG_register_log_func(fnLog fnForReg);
CTCOMMON_API int LOG_unregister_log_func(fnLog fnForUnreg);

CTCOMMON_API int LOG_get_level();
CTCOMMON_API void LOG_set_level(int iNewValue);

CTCOMMON_API BIO* LOG_get_bio(void);
CTCOMMON_API void LOG_set_bio(BIO* bio);

// private functions
CTCOMMON_API int LOG_get_level_arg(int iLogLevel, const char *format, ...);
CTCOMMON_API const char * LOG_get_level_str(int iLogLevel);
CTCOMMON_API char * LOG_get_datetime(int iLogLevel);
CTCOMMON_API char * LOG_vformat(int iLogLevel, const char *format, va_list args);
CTCOMMON_API char * LOG_format(int iLogLevel, const char *format, ...);
CTCOMMON_API char * LOG_format_sec(int iLogLevel, const char *format, ...);
CTCOMMON_API char * LOG_format_sqlite(int iLogLevel, const char *format, ...);
CTCOMMON_API char * LOG_concat(int iLogLevel, char * szLeft, char * szRight);
CTCOMMON_API int LOG_log(int iLogLevel, char *szDateTime, char *szText,
                         const char *szLocation, const char *szFile, int iLine);

CTCOMMON_API int LOG_check_bool(int bValue);

#else // !DEBUG_LOG

#define LOG_DECLARE_LOCATION_NO_TRACE(szLocation)   int _iLogDummy
#define LOG_DECLARE_LOCATION(szLocation)   LOG_DECLARE_LOCATION_NO_TRACE(szLocation)
#define LOG_AVOID_ARTIFACTS   (void)(_iLogDummy)
#define LOG_ASSERT(iLogLevel, x)   LOG_AVOID_ARTIFACTS
#define LOG_PRINTF(args)   LOG_AVOID_ARTIFACTS
#define LOG_ERRNO(args)   LOG_AVOID_ARTIFACTS
#define LOG_WINERROR(args)   LOG_AVOID_ARTIFACTS
#define LOG_SECERROR(args)   LOG_AVOID_ARTIFACTS
#define LOG_SQLITEERROR(args)   LOG_AVOID_ARTIFACTS

#endif // !DEBUG_LOG

#endif // !CTCOMMON_DEBUG_H__INCLUDED
