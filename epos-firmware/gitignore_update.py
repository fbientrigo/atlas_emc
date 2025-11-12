# -*- coding: utf-8 -*-
"""
Created on Tue Mar  2 14:48:49 2021

@author: dblascos
"""
# -*- coding: utf-8 -*-
"""
Created on Wed Sep 30 15:46:26 2020

@author: dblascos

Modified on Mon May 27

@modified by: decker
"""

import os

tcl_files = "emp_lpgbt.tcl", "emp-firmware-2023.2.tcl", "empfw_debughub.tcl", "emp_generic_mgt.tcl", "eLink_Interface.tcl"
project_name = "emp_lpgbt", "emp-firmware-2023.2", "empfw_debughub", "emp_generic_mgt", "eLink_Interface_v1"

gitignore_file = ".gitignore"

string1 = "# 2. The following source(s) files that were local or imported into the original project."
string2 = "# 3. The following remote source files that were added to the original project:-"
empty_line = "#\n"
create_project_string = "create_project"
tcl_addition1 = "file rename -force \"${_xil_proj_name_}/${_xil_proj_name_}.srcs\" \"${_xil_proj_name_}/folder_aux\"\n"
tcl_addition2 = "file delete -force \"${_xil_proj_name_}/${_xil_proj_name_}.srcs\""
tcl_addition3 = "file rename -force \"${_xil_proj_name_}/folder_aux\" \"${_xil_proj_name_}/${_xil_proj_name_}.srcs\"\n"
tcl_already_modified_string = "folder_aux"

string_sources_folder = "srcs" # If files are found in another project folder, the script will have to be modified to accept both folders

sources = []

for idx_tcl,tcl_file in enumerate(tcl_files):
    #Using string1 and string2 text pattern, find the lines of the tcl file containing the files we want to add to .gitignore
    file_read = open(tcl_file);
    lines = file_read.readlines()
    for idx,line in enumerate(lines):
        if string1 in line:
            i = idx + 3; #The sources start 3 lines later 
            while lines[i] != empty_line:
                for idx,chars in enumerate(lines[i]): # Find the folder srcs in the absolute file path, so we can reconvert the path to relative
                    pos1 = lines[i].find(string_sources_folder)
                    pos2 = lines[i].find("src")
                    if pos1 != -1:
                        init = pos1 - len(project_name[idx_tcl])*2 - 2 # Get only the relative path
                        final = len(lines[i]) - 2
                        sources.append(lines[i][init:final]) 
                        break;
                    elif pos2 != -1:
                        init = pos2 - len(project_name[idx_tcl]) - 2 # Get only the relative path
                        final = len(lines[i]) - 2
                        sources.append(lines[i][init:final]) 
                        break; 
     
                i = i + 1   # Keep checking sources
            break;
            
    # Now repeat for the second pattern which also contains sources        
    for idx,line in enumerate(lines):
        if string2 in line:
            i = idx + 2; #The sources start 2 lines later 
            while lines[i] != empty_line:
                for idx,chars in enumerate(lines[i]): # Find the folder srcs in the absolute file path, so we can reconvert the path to relative
                    pos1 = lines[i].find(string_sources_folder)
                    pos2 = lines[i].find("src")
                    file = lines[i].find("component.xml")
                    if pos1 != -1:
                        init = pos1 - len(project_name[idx_tcl])*2 - 2 # Get only the relative path
                        final = len(lines[i]) - 2
                        sources.append(lines[i][init:final]) 
                        break;    
                    elif pos2 != -1:
                        init = pos2 - len(project_name[idx_tcl]) - 2 # Get only the relative path
                        final = len(lines[i]) - 2
                        sources.append(lines[i][init:final]) 
                        break;  
                    elif file != -1:
                        init = file - len(project_name[idx_tcl]) - 2 # Get only the relative path
                        final = len(lines[i]) - 2
                        sources.append(lines[i][init:final]) 
                        break;  

     
                i = i + 1   # Keep checking sources
            break;
           
    # Now we will modify the tcl file so it does not delete our srcs directory when creating the project        
    already_modified = False
    for idx,line in enumerate(lines):
        if tcl_already_modified_string in line:
            already_modified = True
            break;
            
    for idx,line in enumerate(lines):
        if create_project_string in line:
            break;
            
    file_read.close() 
    if not already_modified:
        lines.insert(idx,tcl_addition1) #Insert the new tcl lines and rewrite the file
        lines.insert(idx+2,tcl_addition2)
        lines.insert(idx+4,tcl_addition3)
        
        write_file = open(tcl_file,"w")
        write_file.writelines(lines)
        write_file.close()


xgui_dirs = []
for project in project_name:
    project_path = os.path.join(".", project)  # Construct the relative path for the project
    if os.path.isdir(project_path):  # Check if the project directory exists
        xgui_path = os.path.join(project_path, "xgui")  # Construct the path for the xgui directory
        if os.path.isdir(xgui_path):  # Check if the xgui directory exists
            xgui_dirs.append(xgui_path)  # Add it to the list


        
# Now create .gitignore file
write_file = open(gitignore_file,"w+")
write_file.write("# This Gitignore file has been automatically created by gitignore_update.py script\r\n")
write_file.write("# Ignore everything except files mentioned in tcl file and exceptions hard defined \r\n\n")
write_file.write("*\r\n") # Add default options to gitignore
write_file.write("!*/\r\n")
write_file.write("!.gitignore\r\n")
write_file.write("!gitignore_update.py\r\n")
write_file.write("!README.md\r\n")
for tcl_file in tcl_files:
	write_file.write("!%s\r\n" %tcl_file)
for source in sources:
    write_file.write("!%s\r\n" %source)
for xgui_dir in xgui_dirs:
    write_file.write("!%s/*\r\n" % xgui_dir)  # Include all files in the xgui directory

write_file.close()
