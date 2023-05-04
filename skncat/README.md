# skncat

Client-Server command-line tool following [rderik's rdncat](https://github.com/rderik/rdncat)

<br>

the server keeps a listener that listens for new connections on its port 
and the client initiates a new connection to the server using the server's (listener's) port

<br>

to test, 
1. build the project
2. click the `Product` tab in the menu bar
3. `Show Build Folder in Finder` -> `Products` -> `Debug` 
4. drag the `skncat` executable on the terminal to get its path
5. to run server add `-l <PORT>` after the path
6. to run client add `<SERVER_NAME> <PORT>` after the path
