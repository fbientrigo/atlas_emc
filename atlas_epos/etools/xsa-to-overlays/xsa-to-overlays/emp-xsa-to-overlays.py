#!/usr/bin/env python3
import sys #argument parser
import os
import glob
import re

def isExecutable(program):
    if(os.path.isfile(program)):
        return True
    else:
        for path in os.environ["PATH"].split(os.pathsep):
            exePath = os.path.join(path, program)
            if(os.path.isfile(exePath) and os.access(exePath, os.X_OK)):
                return True

    return False

def checkArgs():
    # Make sure xsa-file is given as argument
    if len(sys.argv) != 2 or sys.argv[1][-4:] != ".xsa":
        print(f"Usage: {sys.argv[0]} <xsa-file>")
        exit(-1)
    # Make sure file exists:
    if(os.path.isfile(sys.argv[1]) != True):
        print(f"File: {sys.argv[1]} not found.")
        exit(-1)
    # Make sure xsct is in path:
    if(not isExecutable("xsct")):
        print(f"xsct not found in path. Try sourcing Vitis settings.")
        exit(-1)
    if(not isExecutable("bootgen")):
        print(f"bootgen not found in path. Try sourcing Vivado settings.")
        exit(-1)
    if(not isExecutable("dtc")):
        print(f"dtc not found in path.")
        exit(-1)

def main():
    checkArgs()

    xsaFileName = sys.argv[1]
    # Change directory to script location
    scriptDir = os.path.dirname(os.path.realpath(__file__))
    os.chdir(scriptDir)
    
    # Clear old output, make a new and go into the directory.
    os.system("rm -rf output")
    os.system("mkdir output")
    os.system(f"cp {xsaFileName} output/")
    os.chdir("output")
    
    #generate device tree files and extract .bit file
    os.system(f"xsct ../dt_overlay.tcl {xsaFileName} psu_cortexa53_0 ../device-tree-xlnx-xilinx_v2023.2 .")
    # Find what the generated bitstream is called
    bitstreamFileName = glob.glob("./*.bit")
    bitstreamFileName = bitstreamFileName[0][2:] # Remove "./"
    # Write Bitstream.bif file (used by bootgen)
    with open("Bitstream.bif", 'w') as file:
        file.write(f"all:\n{{\n\t[destination_device = pl] {bitstreamFileName} /*Bitstream file name */\n}}") # {{ is an escape for {

    # Make .bit.bin file
    binFileName = xsaFileName[:-4] + ".bit.bin"
    os.system(f"bootgen -image Bitstream.bif -arch zynqmp -o ./{binFileName}")

    print("Correcting pl.dtsi firmware name")
    with open("pl.dtsi", 'r') as file:
        data = file.readlines()
    
    for line in data:
        if("firmware-name = " in line):
            data[data.index(line)] = f'\t\t\tfirmware-name = "{binFileName}";\n'

    with open("pl.dtsi", 'w') as file:
        file.writelines(data)

    answer="y"
    while(not (answer == "y" or answer == "n")):
        answer = str(input('Would you like to fix pl.dtsi to match EMP requirements?. (y/N): ')).lower().strip()
    if(answer == "y"):
        for i in range(len(data)):
            if("emp_lpgbt" in data[i]):
                label = re.search(r"emp_lpgbt_\d{1,2}", data[i]).group() # Finds our emp_lpgbt number
                data[i] = data[i].replace("emp_lpgbt@", label + "@") # Put the number in the node
            if('compatible = "xlnx,emp-lpgbt-1.0";' in data[i]):
                data[i] = '\t\tcompatible = "generic-uio";\n'

            # TODO: agregarle UIO como prefijo a todos los nombres
            # 
            if('compatible = "xlnx,Read-PRBS-regs-1.0";' in data[i]):
                data[i] = '\t\tcompatible = "generic-uio";\n'

        # el fix propuesot para TGC
        for i, line in enumerate(data):
            if 'compatible = "xlnx,tgc' in line:
                data[i] = '\t\tcompatible = "generic-uio";\n'

        with open("pl.dtsi", 'w') as file:
            file.writelines(data)

    answer="y"
    while(not (answer == "y" or answer == "n")):
        answer = str(input('Do you wish to make device tree overlay binary? (y/N): ')).lower().strip()
    if(answer == "y"):
        dtboFileName = xsaFileName[:-4] + ".dtbo"
        os.system(f"dtc -O dtb -I dts -o {dtboFileName} -b 0 -@ pl.dtsi")

    answer="y"
    while(not (answer == "y" or answer == "n")):
        answer = str(input('Do you wish to clean up your output directory? (y/N): ')).lower().strip()
    if(answer == "y"):
        os.system(f'find . -not -name "{binFileName}" -not -name "{dtboFileName}" -not -name "pl.dtsi" -delete')
        

if __name__ == "__main__":
    main()
