##
#
#   Commandline bridge for OpenBD, built in Nim and OpenBD Local
#
#   Gives the ability to run CFML tags/functions, files, and run in a live interpreter mode from the commandline.
#
#   Copyright Marcus Fernstrom, 2015
#   License: GPL V.3
#   Version 0.1
#
##

import httpclient, strutils, unicode, cgi, os, parsecfg, streams

let arguments = commandLineParams()
var serveraddr, serverport, tpage, theThing, theReturn, openbdversion, stringToEval, toClean, interpreterLineMode, intMlModeText: string
var f = newFileStream(getAppDir() & """\settings.ini""", fmRead)

# Defaults
serveraddr = """http://127.0.0.1"""
serverport = "35624"
tpage = """/index.cfm"""
interpreterLineMode = "sl"
intMlModeText = ""

if f != nil:
  var p: CfgParser
  open(p, f, getAppDir() & """\settings.ini""")
  while true:
    var e = next(p)

    case e.kind
    of cfgEof:
      break
      
    of cfgKeyValuePair:
      if e.key == "address":
        serveraddr = e.value
      if e.key == "port":
        serverport = e.value
      if e.key == "page":
        tpage = e.value
        
    of cfgError:
      echo(e.msg)
      
    else:
      discard " "
  close(p)
else:
  echo("Cannot open settings.ini, using default settings")

serveraddr = serveraddr & ":" & serverport & tpage

theReturn = ""


proc displayHelp(): string =
  echo """                                                    """
  echo """                                 ``                 """
  echo """                               ```       ``         """
  echo """                              ``      ```           """
  echo """                            ```     ```             """
  echo """                          ```     ```               """
  echo """                         ```    ````                """
  echo """                        ```   ````                  """
  echo """                       ```   ````                   """
  echo """                      ```   ````                    """
  echo """                     ```  `````                     """
  echo """                    ```` `````                      """
  echo """               ``````````````                       """
  echo """           `````````````````````                    """
  echo """          ``````````````````                        """
  echo """          ````    ````````     ``````````           """
  echo """          ```  ```````````````   ```````````        """
  echo """          ``````````````````````   ```````````      """
  echo """         ````````````````````````   ````````````    """
  echo """         `````````````````````````  `````````````   """
  echo """        ```````````````````````````  `````````````  """
  echo """       ```````````````````  ```````  `````````````` """
  echo """      ``````````````````     ```````  ``````````````"""
  echo """     ``````    `````````     ```````  ``````````````"""
  echo """    `````      ````````      ```````` ``````````````"""
  echo """  ``````        ``````       ````````  `````````````"""
  echo """ ``````         `````        ````````  ````````  ```"""
  echo """ ```  ``        `````        ````````  `````````  ``"""
  echo """````            ````         ````````  `````````   `"""
  echo """              `````         `````````  ``````````   """
  echo """              ````          `````````  ``````````   """
  echo """             ````          ``````````  ```````````  """
  echo """          ``````         ````````````  ``````````` `"""
  echo """            ``          ````````````` ``````  ```` `"""
  echo """                      ``````````````  ``````  ````  """
  echo """                    ````````````````  `````    ```  """
  echo """                 ``````````````````   ````      ``` """
  echo """              `````````````````````  `````  ``  ``` """
  echo """          ````````````````````````   ````   ``  ``` """
  echo """       ``````````````````````````   ````   ```  ``` """
  echo """     ```````````````````````````   ````    ```  ``` """
  echo """   ````````````````````````````   ````    ````   `  """
  echo """ """
  echo "\n\tOpenBD CLI bridge, version 0.1"
  echo "\n\tTo run a cfml file, use openbd -f {filename},\n\tto run a CFML tag or function, use openbd {tag/function}\n\tto run in interpreter mode, use openbd -i"
  echo "\n\tExample: openbd -f myfile.cfm"
  echo "\tExample: openbd hash('myname')"
  echo "\n\tThe available flags are:"
  echo "\t-v\t\tVersion info"
  echo "\t-f\t\tRun a file (openbd -f myfile.cfm)"
  echo "\t-i\t\tInterpreter mode."
  echo "\t-h\t\tDisplays this help message"
  echo "\n\tCLI bridge created by Marcus Fernstrom, copyright 2015\n\tLicense: GPL3\n\tSource available, see http://openbd.org/tools"



proc cleanFinalString(): string =
  theReturn = theReturn.replace("\t", "")
  theReturn = theReturn.replace("\n\n", "\n")
  theReturn = theReturn.replace("  ", " ")
  if contains(theReturn, "  "):
    discard cleanFinalString()
  else:
    theReturn = theReturn.replace("nbsp;", " ")



proc interpreterMode(): string =
  # Running interpreter mode
  stdout.write ">> "
  stringToEval = readLine(stdin)

  if len(stringToEval) > 0:
    case stringToEval:

    # If the user enters q or quit, then quit.
    of "quit":
      echo "Exiting interpreter mode"
      quit()

    of "-q":
      echo "Exiting interpreter mode"
      quit()

    of "-sl":
      interpreterLineMode = "sl"
      echo "Single-line mode active, press Enter to run command\n"

    of "-ml":
      interpreterLineMode = "ml"
      echo "Multi-line mode active, type -run to run commands\n"

    of "-h":
      echo "\n\nSwitch between single-line and multi-line mode with -ml and -sl\nInput is automatically wrapped in cfoutput tags\nQuit by typing -q or quit\n"
      echo "In single-line mode, pressing enter will run the command, in multi-line mode pressing enter will start a new line, type -run to run the commands previously entered\n"
      
    else:
      if interpreterLineMode == "sl":
        # The string is not q or quit, so we evaluate the input
        writeFile( os.getAppDir() & "/tmpfl.cfm", """<cfoutput>""" & stringToEval & """</cfoutput>""" )
        theReturn = strip(getContent(serveraddr & "?file=" & os.getAppDir() & "/tmpfl.cfm"))
        removeFile(os.getAppDir() & """/tmpfl.cfm""")
        discard cleanFinalString()
        echo theReturn & "\n"
      else:
        if stringToEval == "-run":
          # The string is not q or quit, so we evaluate the input
          writeFile( os.getAppDir() & "/tmpfl.cfm", """<cfoutput>""" & intMlModeText & """</cfoutput>""" )
          theReturn = strip(getContent(serveraddr & "?file=" & os.getAppDir() & """/tmpfl.cfm"""))
          removeFile(os.getAppDir() & "/tmpfl.cfm")
          discard cleanFinalString()
          echo theReturn & "\n"
          intMlModeText = ""
        else:
          intMlModeText = intMlModeText & stringToEval & "\n"
          
  # Recurse
  discard interpreterMode()


  
# Test if we can connect to the server
if strip(getContent(serveraddr & "?ver")) != "":
  echo "Server is not running"
  quit()



# If there are no arguments, display the help
if len(arguments) == 0:
  discard displayHelp()



# If there are more than one argument
if len(arguments) > 1:
  if len(arguments) mod 2 != 0:
    echo "Wrong number of commandline arguments"

  if arguments[0] == "-f":
    # User is specifying a file to run
    if contains(arguments[1], """\""") or contains(arguments[1], """/"""):
      # If the input contains a slash or more, we assume it contains a full path to a file.
      theThing = arguments[1]  
      theReturn = strip(getContent(serveraddr & "?file=" & theThing))
    else:
      # If there are no slashes, we assume the file is in the current directory
      theThing = os.getCurrentDir() & """\""" & arguments[1]  
      theReturn = strip(getContent(serveraddr & "?file=" & theThing))



# If there is only one argument, we either have a command or we're using a single flag
if len(arguments) == 1:
  if len(arguments[0]) == 2:
    if arguments[0] == "-v":
      # Display the version information
      openbdversion = strip(getContent(serveraddr & "?version"))
      echo "\nOpenBD version " & openbdversion
      echo "CLI bridge version 0.1"

    # Display help
    if arguments[0] == "-h":
      discard displayHelp()

    # Start the inerpreter
    if arguments[0] == "-i":
      echo "\n\nStarting interpreter in single-line mode, type -h for help\n"
      discard interpreterMode()
            
  else:
    # If the lenght of the argument is more than two chars long, we assume it's a command rather than a flag.
    if len(arguments[0]) > 2:
      writeFile( os.getAppDir() & "/tmpfl.cfm", """<cfoutput>#""" & arguments[0] & """#</cfoutput>""" )
      theReturn = strip(getContent(serveraddr & """?file=""" & os.getAppDir() & "/tmpfl.cfm"))
      removeFile(os.getAppDir() & "/tmpfl.cfm")



# And finally, if theReturn isn't empty, go ahead and display it
if len(theReturn) > 0:
  discard cleanFinalString()
  echo theReturn














  