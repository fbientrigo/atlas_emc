#pragma once
#include <stdint.h>
#include <string> // std::to_string

struct uio_info_t; // forward-decl

// for register map: Read_PRBS

class ReadPRBS
{

public:
    /** Opens uio-mapped component by uio device number */
    ReadPRBS (unsigned int devnum);
    /** Opens uio-mapped component by uio device name */
    ReadPRBS (const std::string& uioDeviceName);

    virtual ~ReadPRBS ();


    // at register: magic
    uint32_t readMagicValue ();


    // at register: control
    void writeControlValue (uint32_t value);


    // at register: status
    uint32_t readStatusValue ();


    // at register: data_prbs
    uint32_t readDataPrbsValue ();
    void writeDataPrbsValue (uint32_t value);


private:
    uio_info_t* m_uioInfo;
    uint32_t _Value_v = 0;
    uint32_t _isolateBitsForRead(uint32_t value, uint32_t bitWidth, uint8_t bitOffset);
    uint32_t _isolateBitsForWrite(uint32_t value, uint32_t bitWidth, uint8_t bitOffset, uint32_t oldValue);
};