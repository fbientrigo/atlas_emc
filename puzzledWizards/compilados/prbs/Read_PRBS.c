#include <libuio.h>
#include <stdio.h>
#include <stdlib.h>

#include <Read_PRBS.h>

// for register map: Read_PRBS

struct uio_info_t*  Read_PRBS_open (unsigned int devnum)
{
    struct uio_info_t* uio_info = uio_find_by_uio_num(devnum);
    if (!uio_info)
    {
        printf ("ERROR on uio_find_by_uio_num failed: %x\n ", uio_info);
        return 0;
    }
    printf ("Found device on device ids: %d:%d\n", uio_get_major(uio_info), uio_get_minor(uio_info));
    if (uio_open(uio_info))
    {
        printf ("ERROR on uio_open!");
        return 0;
    }
    return uio_info;
}


// at register: magic

uint32_t Read_PRBS_read_magic_value (struct uio_info_t* uio_info)
{
    uint32_t value;
    if (uio_read32 (
                uio_info,
                0 /*map*/,
                0 /* address offset */,
                &value))
    {
        printf("problem reading");
        abort();
    };
    return value;
}


// at register: control

void Read_PRBS_write_control_value (struct uio_info_t* uio_info, uint32_t value)
{
    uio_write32 (
        uio_info,
        0 /*map*/,
        4 /* address offset */,
        value);
}


// at register: status

uint32_t Read_PRBS_read_status_value (struct uio_info_t* uio_info)
{
    uint32_t value;
    if (uio_read32 (
                uio_info,
                0 /*map*/,
                8 /* address offset */,
                &value))
    {
        printf("problem reading");
        abort();
    };
    return value;
}


// at register: data_prbs

uint32_t Read_PRBS_read_data_prbs_value (struct uio_info_t* uio_info)
{
    uint32_t value;
    if (uio_read32 (
                uio_info,
                0 /*map*/,
                12 /* address offset */,
                &value))
    {
        printf("problem reading");
        abort();
    };
    return value;
}
void Read_PRBS_write_data_prbs_value (struct uio_info_t* uio_info, uint32_t value)
{
    uio_write32 (
        uio_info,
        0 /*map*/,
        12 /* address offset */,
        value);
}
