#include <stdexcept>
#include <iostream>
#include <cmath>
#include <string.h>

#include <libuio.h>
#include <ReadPRBS.hpp>

// for register map: Read_PRBS

/** Opens uio-mapped component by uio device number */
ReadPRBS::ReadPRBS (unsigned int devnum)
{
    m_uioInfo = uio_find_by_uio_num(devnum);
    if (!m_uioInfo)
        throw std::runtime_error("uio_find_by_uio_num with devnum " + std::to_string(devnum) + " failed.");

    std::cout << "ReadPRBS ctr. "
              << "Found requested device with ids: " << uio_get_major(m_uioInfo) << "," << uio_get_minor(m_uioInfo) << std::endl;
    if (uio_open(m_uioInfo))
        throw std::runtime_error("uio_open failed.");
}

/** Opens uio-mapped component by uio device number */
ReadPRBS::ReadPRBS (const std::string& uioDeviceName)
{
    char* c_string;
    c_string = strdup(uioDeviceName.c_str());
    m_uioInfo = uio_find_by_uio_name(c_string);
    if (!m_uioInfo)
        throw std::runtime_error("uio_find_by_uio_name with device name " + uioDeviceName + " failed.");

    std::cout << "ReadPRBS ctr. "
              << "Found requested device with ids: " << uio_get_major(m_uioInfo) << "," << uio_get_minor(m_uioInfo) << std::endl;
    if (uio_open(m_uioInfo))
        throw std::runtime_error("uio_open failed.");
}

ReadPRBS::~ReadPRBS ()
{
    uio_close(m_uioInfo);
}


// at register: magic
uint32_t ReadPRBS::readMagicValue ()
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



// at register: control
void ReadPRBS::writeControlValue (uint32_t value) {
    uint32_t bitWidth = 32;
    uint8_t bitOffset = 0;
    _Value_v = _isolateBitsForWrite(value, bitWidth, bitOffset, _Value_v);

    if (uio_write32 (
                m_uioInfo,
                0 /*map*/,
                4 /* address offset */,
                _Value_v))
    {
        throw std::runtime_error("uio_write32 failed");
    };
}



// at register: status
uint32_t ReadPRBS::readStatusValue ()
{
    uint32_t value (0);
    if (uio_read32 (
                m_uioInfo,
                0 /*map*/,
                8 /* address offset */,
                &value))
    {
        throw std::runtime_error("uio_read32 failed");
    };
    uint32_t bitWidth = 32;
    uint8_t bitOffset = 0;
    return(_isolateBitsForRead(value, bitWidth, bitOffset));
}



// at register: data_prbs
uint32_t ReadPRBS::readDataPrbsValue ()
{
    uint32_t value (0);
    if (uio_read32 (
                m_uioInfo,
                0 /*map*/,
                12 /* address offset */,
                &value))
    {
        throw std::runtime_error("uio_read32 failed");
    };
    uint32_t bitWidth = 32;
    uint8_t bitOffset = 0;
    return(_isolateBitsForRead(value, bitWidth, bitOffset));
}
void ReadPRBS::writeDataPrbsValue (uint32_t value) {
    uint32_t oldValue(0);
    if (uio_read32 (
                m_uioInfo,
                0 /*map*/,
                12 /* address offset */,
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
                12 /* address offset */,
                value))
    {
        throw std::runtime_error("uio_write32 failed");
    };
}


static inline uint32_t make_mask(uint32_t width, uint32_t offset) {
    // Cubre también width > 32 de forma defensiva
    if (width >= 32) return 0xFFFFFFFFu;
    // Asegura el 1 como unsigned de 32 bits y evita UB
    return ((uint32_t{1} << width) - 1u) << offset;
}

uint32_t ReadPRBS::_isolateBitsForRead(uint32_t value, uint32_t bitWidth, uint8_t bitOffset) {
    const uint32_t mask = make_mask(bitWidth, bitOffset);
    return (value & mask) >> bitOffset;
}

uint32_t ReadPRBS::_isolateBitsForWrite(uint32_t value, uint32_t bitWidth, uint8_t bitOffset, uint32_t oldValue) {
    const uint32_t mask = make_mask(bitWidth, bitOffset);
    // Evita overflow al desplazar y recorta al mask
    const uint32_t shifted = (bitOffset == 0) ? value : (value << bitOffset);
    return (oldValue & ~mask) | (shifted & mask);
}
