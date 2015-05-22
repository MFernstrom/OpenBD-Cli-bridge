# OpenBD-Cli-bridge

OpenBD CLI Bridge is a utility that lets you run OpenBD commands and files from the Windows command line.

### Installation

Manual installation: Download the <a href="https://github.com/MFernstrom/OpenBD-Cli-bridge">source</a> from GitHub, unzip the .cfm file into a local web server. (I use an instance of OpenBD Local added to autostart, so it's always running)

Drop the .exe and config.ini wherever you want (Keep the .ini and .exe in the same folder), add the .exe to your PATH and edit the config.ini file to point to your webserver.

--
### Default settings

Default config.ini settings:

*#* Server address
address: "http://127.0.0.1"

*#* Port
port: 35624

*#* Page to hit
page: "/index.cfm"

--
### Using

C:\>openbd -v  
OpenBD version 3.1  
CLI bridge version 0.1  


C:\> openbd now()  
{ts '2015-04-06 10:49:21'}
  
C:\>openbd -f test.cfm  
This is a regular cfml file.  
Current timestamp: {ts '2015-04-06 10:51:08'}

C:\>openbd -i  
Starting interpreter in single-line mode, type -h for help

*>>* *#*Hash('OpenBD is awesome')*#*  
5E1DA9EA3980D7BBAC7572C16D3BC083

*>>* -ml  
Multi-line mode active, type -run to run commands

*>>* *#*now()*#*  
*>>* *#*Hash('OpenBD is awesome')*#*  
*>>* -run  
{ts '2015-04-06 10:53:23'}  
5E1DA9EA3980D7BBAC7572C16D3BC083  

*>>* -q  
Exiting interpreter mode
