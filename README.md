# OpenBD-Cli-bridge

OpenBD CLI Bridge is a utility that lets you run OpenBD commands and files from the Windows command line.

Manual installation: Download the <a href="https://github.com/MFernstrom/OpenBD-Cli-bridge">source</a> from GitHub, unzip the .cfm file into a local web server. (I use an instance of OpenBD Local added to autostart, so it's always running)

Drop the .exe and config.ini wherever you want (Keep the .ini and .exe in the same folder), add the .exe to your PATH and edit the config.ini file to point to your webserver.

--

Default config.ini settings:

*#* Server address
address: "http://127.0.0.1"

*#* Port
port: 35624

*#* Page to hit
page: "/index.cfm"
