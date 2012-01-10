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

#ifndef CTCOMMON_STACK_H__INCLUDED
#define CTCOMMON_STACK_H__INCLUDED

#ifndef CTCOMMON_H__INCLUDED
#error "Do not include ctcommon_stack.h directly"
#endif


// for standard types (in alphabetical order)
#define sk_BN_new(cmp) SKM_sk_new(BIGNUM, (cmp))
#define sk_BN_new_null() SKM_sk_new_null(BIGNUM)
#define sk_BN_free(st) SKM_sk_free(BIGNUM, (st))
#define sk_BN_num(st) SKM_sk_num(BIGNUM, (st))
#define sk_BN_value(st, i) SKM_sk_value(BIGNUM, (st), (i))
#define sk_BN_set(st, i, val) SKM_sk_set(BIGNUM, (st), (i), (val))
#define sk_BN_zero(st) SKM_sk_zero(BIGNUM, (st))
#define sk_BN_push(st, val) SKM_sk_push(BIGNUM, (st), (val))
#define sk_BN_unshift(st, val) SKM_sk_unshift(BIGNUM, (st), (val))
#define sk_BN_find(st, val) SKM_sk_find(BIGNUM, (st), (val))
#define sk_BN_find_ex(st, val) SKM_sk_find_ex(BIGNUM, (st), (val))
#define sk_BN_delete(st, i) SKM_sk_delete(BIGNUM, (st), (i))
#define sk_BN_delete_ptr(st, ptr) SKM_sk_delete_ptr(BIGNUM, (st), (ptr))
#define sk_BN_insert(st, val, i) SKM_sk_insert(BIGNUM, (st), (val), (i))
#define sk_BN_set_cmp_func(st, cmp) SKM_sk_set_cmp_func(BIGNUM, (st), (cmp))
#define sk_BN_dup(st) SKM_sk_dup(BIGNUM, st)
#define sk_BN_pop_free(st, free_func) SKM_sk_pop_free(BIGNUM, (st), (free_func))
#define sk_BN_shift(st) SKM_sk_shift(BIGNUM, (st))
#define sk_BN_pop(st) SKM_sk_pop(BIGNUM, (st))
#define sk_BN_sort(st) SKM_sk_sort(BIGNUM, (st))
#define sk_BN_is_sorted(st) SKM_sk_is_sorted(BIGNUM, (st))

#define sk_BUF_MEM_new(cmp) SKM_sk_new(BUF_MEM, (cmp))
#define sk_BUF_MEM_new_null() SKM_sk_new_null(BUF_MEM)
#define sk_BUF_MEM_free(st) SKM_sk_free(BUF_MEM, (st))
#define sk_BUF_MEM_num(st) SKM_sk_num(BUF_MEM, (st))
#define sk_BUF_MEM_value(st, i) SKM_sk_value(BUF_MEM, (st), (i))
#define sk_BUF_MEM_set(st, i, val) SKM_sk_set(BUF_MEM, (st), (i), (val))
#define sk_BUF_MEM_zero(st) SKM_sk_zero(BUF_MEM, (st))
#define sk_BUF_MEM_push(st, val) SKM_sk_push(BUF_MEM, (st), (val))
#define sk_BUF_MEM_unshift(st, val) SKM_sk_unshift(BUF_MEM, (st), (val))
#define sk_BUF_MEM_find(st, val) SKM_sk_find(BUF_MEM, (st), (val))
#define sk_BUF_MEM_find_ex(st, val) SKM_sk_find_ex(BUF_MEM, (st), (val))
#define sk_BUF_MEM_delete(st, i) SKM_sk_delete(BUF_MEM, (st), (i))
#define sk_BUF_MEM_delete_ptr(st, ptr) SKM_sk_delete_ptr(BUF_MEM, (st), (ptr))
#define sk_BUF_MEM_insert(st, val, i) SKM_sk_insert(BUF_MEM, (st), (val), (i))
#define sk_BUF_MEM_set_cmp_func(st, cmp) SKM_sk_set_cmp_func(BUF_MEM, (st), (cmp))
#define sk_BUF_MEM_dup(st) SKM_sk_dup(BUF_MEM, st)
#define sk_BUF_MEM_pop_free(st, free_func) SKM_sk_pop_free(BUF_MEM, (st), (free_func))
#define sk_BUF_MEM_shift(st) SKM_sk_shift(BUF_MEM, (st))
#define sk_BUF_MEM_pop(st) SKM_sk_pop(BUF_MEM, (st))
#define sk_BUF_MEM_sort(st) SKM_sk_sort(BUF_MEM, (st))
#define sk_BUF_MEM_is_sorted(st) SKM_sk_is_sorted(BUF_MEM, (st))

#define sk_EVP_PKEY_new(cmp) SKM_sk_new(EVP_PKEY, (cmp))
#define sk_EVP_PKEY_new_null() SKM_sk_new_null(EVP_PKEY)
#define sk_EVP_PKEY_free(st) SKM_sk_free(EVP_PKEY, (st))
#define sk_EVP_PKEY_num(st) SKM_sk_num(EVP_PKEY, (st))
#define sk_EVP_PKEY_value(st, i) SKM_sk_value(EVP_PKEY, (st), (i))
#define sk_EVP_PKEY_set(st, i, val) SKM_sk_set(EVP_PKEY, (st), (i), (val))
#define sk_EVP_PKEY_zero(st) SKM_sk_zero(EVP_PKEY, (st))
#define sk_EVP_PKEY_push(st, val) SKM_sk_push(EVP_PKEY, (st), (val))
#define sk_EVP_PKEY_unshift(st, val) SKM_sk_unshift(EVP_PKEY, (st), (val))
#define sk_EVP_PKEY_find(st, val) SKM_sk_find(EVP_PKEY, (st), (val))
#define sk_EVP_PKEY_find_ex(st, val) SKM_sk_find_ex(EVP_PKEY, (st), (val))
#define sk_EVP_PKEY_delete(st, i) SKM_sk_delete(EVP_PKEY, (st), (i))
#define sk_EVP_PKEY_delete_ptr(st, ptr) SKM_sk_delete_ptr(EVP_PKEY, (st), (ptr))
#define sk_EVP_PKEY_insert(st, val, i) SKM_sk_insert(EVP_PKEY, (st), (val), (i))
#define sk_EVP_PKEY_set_cmp_func(st, cmp) SKM_sk_set_cmp_func(EVP_PKEY, (st), (cmp))
#define sk_EVP_PKEY_dup(st) SKM_sk_dup(EVP_PKEY, st)
#define sk_EVP_PKEY_pop_free(st, free_func) SKM_sk_pop_free(EVP_PKEY, (st), (free_func))
#define sk_EVP_PKEY_shift(st) SKM_sk_shift(EVP_PKEY, (st))
#define sk_EVP_PKEY_pop(st) SKM_sk_pop(EVP_PKEY, (st))
#define sk_EVP_PKEY_sort(st) SKM_sk_sort(EVP_PKEY, (st))
#define sk_EVP_PKEY_is_sorted(st) SKM_sk_is_sorted(EVP_PKEY, (st))

// for private types (in alphabetical order)
#define sk_PROPERTY_STORE_ENTRY_new(cmp) SKM_sk_new(PROPERTY_STORE_ENTRY, (cmp))
#define sk_PROPERTY_STORE_ENTRY_new_null() SKM_sk_new_null(PROPERTY_STORE_ENTRY)
#define sk_PROPERTY_STORE_ENTRY_free(st) SKM_sk_free(PROPERTY_STORE_ENTRY, (st))
#define sk_PROPERTY_STORE_ENTRY_num(st) SKM_sk_num(PROPERTY_STORE_ENTRY, (st))
#define sk_PROPERTY_STORE_ENTRY_value(st, i) SKM_sk_value(PROPERTY_STORE_ENTRY, (st), (i))
#define sk_PROPERTY_STORE_ENTRY_set(st, i, val) SKM_sk_set(PROPERTY_STORE_ENTRY, (st), (i), (val))
#define sk_PROPERTY_STORE_ENTRY_zero(st) SKM_sk_zero(PROPERTY_STORE_ENTRY, (st))
#define sk_PROPERTY_STORE_ENTRY_push(st, val) SKM_sk_push(PROPERTY_STORE_ENTRY, (st), (val))
#define sk_PROPERTY_STORE_ENTRY_unshift(st, val) SKM_sk_unshift(PROPERTY_STORE_ENTRY, (st), (val))
#define sk_PROPERTY_STORE_ENTRY_find(st, val) SKM_sk_find(PROPERTY_STORE_ENTRY, (st), (val))
#define sk_PROPERTY_STORE_ENTRY_find_ex(st, val) SKM_sk_find_ex(PROPERTY_STORE_ENTRY, (st), (val))
#define sk_PROPERTY_STORE_ENTRY_delete(st, i) SKM_sk_delete(PROPERTY_STORE_ENTRY, (st), (i))
#define sk_PROPERTY_STORE_ENTRY_delete_ptr(st, ptr) SKM_sk_delete_ptr(PROPERTY_STORE_ENTRY, (st), (ptr))
#define sk_PROPERTY_STORE_ENTRY_insert(st, val, i) SKM_sk_insert(PROPERTY_STORE_ENTRY, (st), (val), (i))
#define sk_PROPERTY_STORE_ENTRY_set_cmp_func(st, cmp) SKM_sk_set_cmp_func(PROPERTY_STORE_ENTRY, (st), (cmp))
#define sk_PROPERTY_STORE_ENTRY_dup(st) SKM_sk_dup(PROPERTY_STORE_ENTRY, st)
#define sk_PROPERTY_STORE_ENTRY_pop_free(st, free_func) SKM_sk_pop_free(PROPERTY_STORE_ENTRY, (st), (free_func))
#define sk_PROPERTY_STORE_ENTRY_shift(st) SKM_sk_shift(PROPERTY_STORE_ENTRY, (st))
#define sk_PROPERTY_STORE_ENTRY_pop(st) SKM_sk_pop(PROPERTY_STORE_ENTRY, (st))
#define sk_PROPERTY_STORE_ENTRY_sort(st) SKM_sk_sort(PROPERTY_STORE_ENTRY, (st))
#define sk_PROPERTY_STORE_ENTRY_is_sorted(st) SKM_sk_is_sorted(PROPERTY_STORE_ENTRY, (st))


DECLARE_STACK_OF(EVP_PKEY)

#endif // !CTCOMMON_STACK_H__INCLUDED
