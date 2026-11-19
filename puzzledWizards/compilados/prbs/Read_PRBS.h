#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>

struct uio_info_t;

// for register map: Read_PRBS

struct uio_info_t* Read_PRBS_open (unsigned int devnum);


// at register: magic

uint32_t Read_PRBS_read_magic_value (struct uio_info_t* uio_info);


// at register: control

void Read_PRBS_write_control_value (struct uio_info_t* uio_info, uint32_t value);


// at register: status

uint32_t Read_PRBS_read_status_value (struct uio_info_t* uio_info);


// at register: data_prbs

uint32_t Read_PRBS_read_data_prbs_value (struct uio_info_t* uio_info);
void Read_PRBS_write_data_prbs_value (struct uio_info_t* uio_info, uint32_t value);


#ifdef __cplusplus
}
#endif