#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>

struct uio_info_t;

// for register map: tgc_readUplink

struct uio_info_t* tgc_readUplink_open (unsigned int devnum);


// at register: magic

uint32_t tgc_readUplink_read_magic_value (struct uio_info_t* uio_info);


// at register: data_groups

uint32_t tgc_readUplink_read_data_groups_value (struct uio_info_t* uio_info);
void tgc_readUplink_write_data_groups_value (struct uio_info_t* uio_info, uint32_t value);


#ifdef __cplusplus
}
#endif