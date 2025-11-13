# atlas_emc
EMC EMP System Development, this contains logs and tools to work with the system, 

## Folder structure
- `ChargeMonitoringSystem_obsidian`: contains all notes and logs on the development, also has references to the official docs and hardware information
- `àtlas_epos`: collection of tools, copied from the official [AtlasEpos repo at Gitlab](https://gitlab.cern.ch/atlas-dcs-emp), contains the tools create from an .xsa into a .dtbo in order to load it on the EMP
- `epos-firmware`: Contains the necessary tools in order the Vivado 2023.2 project epos_firmware
- `puzzledWizards`: Tools from [Gitlab](https://gitlab.cern.ch/atlas-dcs-fpga-soc/PuzzledLizardWizard) use the register map created from [AirHDL](https://indico.cern.ch/event/952288/contributions/4005653/attachments/2116548/3561545/AirHdl_and_PuzzledLizardWizard_for_register_map_handling.pdf) thats implemented into the firmware, puzzledWizard allows to create a C++ library.

## Links
- [LpGBT](https://gitlab.cern.ch/gbt-fpga/lpgbt-fpga)
- [Documentation LpGbt](https://lpgbt-fpga.web.cern.ch/doc/html/)
