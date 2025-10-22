# The CHS plug-in for IDL/SPEDAS

The CHS plug-in can be used with IDL/SPEDAS (https://spedas.org/wiki/index.php) to load data of the SUSANOO-SW. 

## Currently supported
  * Solar wind datasets

## Installation 
First of all you need to install the **Interactive Data Language (IDL)** to your Windows PC / Mac / Linux machines. The **IDL/SPEDAS package** also need to be properly installed. For detailed instructions, see "Downloads and Installation" in the SPEDAS wiki at https://spedas.org/wiki/index.php.

Finally you have to install the **CHS plug-in**, which can be downloaded from https://github.com/ergsc-devel/ergsc_plugin/susanoo with either the git command or as a zip file; Please click the "Code" button on top right of the website. It is recommended to save the plug-in package in a sub-directory of your own library directory for IDL, not the IDL system library directory. The last thing to do is to set the command search path properly so that IDL can find the plug-in code. If you use a command-line environment (e.g., on Linux or Mac), you only have to insert the following line in the initialization script of your environment, such as .bash_profile:
`export IDL_PATH=PLUGIN_DIR:${IDL_PATH}`
Here "PLUGIN_DIR" should be replaced with the actual directory path where you have installed the plug-in files. If using IDL workbench (GUI-based IDL), you should be able to do the same setting through GUI. 
