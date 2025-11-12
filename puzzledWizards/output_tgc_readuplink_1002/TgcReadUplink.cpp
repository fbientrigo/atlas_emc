#include <stdexcept>
#include <iostream>
#include <cmath>
#include <string.h>

#include <libuio.h>
#include <TgcReadUplink.hpp>

// for register map: tgc_readUplink

/** Opens uio-mapped component by uio device number */
TgcReadUplink::TgcReadUplink (unsigned int devnum)
{
    m_uioInfo = uio_find_by_uio_num(devnum);
    if (!m_uioInfo)
        throw std::runtime_error("uio_find_by_uio_num with devnum " + std::to_string(devnum) + " failed.");

    std::cout << "TgcReadUplink ctr. "
              << "Found requested device with ids: " << uio_get_major(m_uioInfo) << "," << uio_get_minor(m_uioInfo) << std::endl;
    if (uio_open(m_uioInfo))
        throw std::runtime_error("uio_open failed.");
}

/** Opens uio-mapped component by uio device number */
TgcReadUplink::TgcReadUplink (const std::string& uioDeviceName)
{
    char* c_string;
    c_string = strdup(uioDeviceName.c_str());
    m_uioInfo = uio_find_by_uio_name(c_string);
    if (!m_uioInfo)
        throw std::runtime_error("uio_find_by_uio_name with device name " + uioDeviceName + " failed.");

    std::cout << "TgcReadUplink ctr. "
              << "Found requested device with ids: " << uio_get_major(m_uioInfo) << "," << uio_get_minor(m_uioInfo) << std::endl;
    if (uio_open(m_uioInfo))
        throw std::runtime_error("uio_open failed.");
}

TgcReadUplink::~TgcReadUplink ()
{
    uio_close(m_uioInfo);
}


// at register: magic
uint32_t TgcReadUplink::readMagicValue ()
{
    uint32_t value (0);
    if (uio_read32 (
                m_uioInfo,
                0 /*map*/,
                0 /* address offset */,
                &value))
    {
        throw std::runtime_error("uio_read32 failed");
    };
    uint32_t bitWidth = 32;
    uint8_t bitOffset = 0;
    return(_isolateBitsForRead(value, bitWidth, bitOffset));
}



// at register: data_groups
uint32_t TgcReadUplink::readDataGroupsValue ()
{
    uint32_t value (0);
    if (uio_read32 (
                m_uioInfo,
                0 /*map*/,
                4 /* address offset */,
                &value))
    {
        throw std::runtime_error("uio_read32 failed");
    };
    uint32_t bitWidth = 32;
    uint8_t bitOffset = 0;
    return(_isolateBitsForRead(value, bitWidth, bitOffset));
}
void TgcReadUplink::writeDataGroupsValue (uint32_t value) {
    uint32_t oldValue(0);
    if (uio_read32 (
                m_uioInfo,
                0 /*map*/,
                4 /* address offset */,
                &oldValue))
    {
        throw std::runtime_error("uio_read32 failed");
    };
    uint32_t bitWidth = 32;
    uint8_t bitOffset = 0;
    value = _isolateBitsForWrite(value, bitWidth, bitOffset, oldValue);

    if (uio_write32 (
                m_uioInfo,
                0 /*map*/,
                4 /* address offset */,
                value))
    {
        throw std::runtime_error("uio_write32 failed");
    };
}



// Takes value and returns the isolated bits specified by bitWidth and bitOffset. Shifts the bits to 0th position.
uint32_t TgcReadUplink::_isolateBitsForRead(uint32_t value, uint32_t bitWidth, uint8_t bitOffset) {
    // Patched: safe mask generation
    uint64_t bitMask = ((1ULL << bitWidth) - 1ULL);
    if (bitWidth >= 32) bitMask = 0xFFFFFFFFULL;
    bitMask <<= bitOffset;
    return static_cast<uint32_t>((value & bitMask) >> bitOffset);
}

// Takes and old value and replaces the specified bits defined by value, bitWidth and bitOffset.
uint32_t TgcReadUplink::_isolateBitsForWrite(uint32_t value, uint32_t bitWidth, uint8_t bitOffset, uint32_t oldValue) {
    // Patched: safe mask generation
    uint64_t bitMask = ((1ULL << bitWidth) - 1ULL);
    if (bitWidth >= 32) bitMask = 0xFFFFFFFFULL;
    bitMask <<= bitOffset;
    return static_cast<uint32_t>((oldValue & ~bitMask) | ((static_cast<uint64_t>(value) << bitOffset) & bitMask));
}