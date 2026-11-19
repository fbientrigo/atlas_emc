#pragma once
#include <stdint.h>
#include <string> // std::to_string

struct uio_info_t; // forward-decl

// for register map: tgc_readUplink

class TgcReadUplink
{

public:
    /** Opens uio-mapped component by uio device number */
    TgcReadUplink (unsigned int devnum);
    /** Opens uio-mapped component by uio device name */
    TgcReadUplink (const std::string& uioDeviceName);

    virtual ~TgcReadUplink ();


    // at register: magic
    uint32_t readMagicValue ();


    // at register: data_group_0
    uint32_t readDataGroup0Value ();


    // at register: data_group_1
    uint32_t readDataGroup1Value ();


    // at register: data_group_2
    uint32_t readDataGroup2Value ();


    // at register: data_group_3
    uint32_t readDataGroup3Value ();


    // at register: data_group_4
    uint32_t readDataGroup4Value ();


    // at register: data_group_5
    uint32_t readDataGroup5Value ();


    // at register: data_group_6
    uint32_t readDataGroup6Value ();


    // at register: data_group_7
    uint32_t readDataGroup7Value ();


    // at register: data_group_8
    uint32_t readDataGroup8Value ();


    // at register: data_header
    uint32_t readDataHeaderValue ();


    // at register: clk_thresh
    uint32_t readClkThreshValue ();
    void writeClkThreshValue (uint32_t value);


private:
    uio_info_t* m_uioInfo;
    uint32_t _isolateBitsForRead(uint32_t value, uint32_t bitWidth, uint8_t bitOffset);
    uint32_t _isolateBitsForWrite(uint32_t value, uint32_t bitWidth, uint8_t bitOffset, uint32_t oldValue);
};