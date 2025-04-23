# Information
A Spanish translation of https://github.com/gb-mobile/pokecrystal-mobile-eng
This translation was performed via text dumps and a (somewhat) sophisticated find/replace script and some manual effort.

## Screenshots
![image](https://github.com/user-attachments/assets/a8d32cab-626c-483a-9616-e384502c74ce)
![image](https://github.com/user-attachments/assets/a14dead5-ef9a-402b-a240-9a2083aa5834)
![image](https://github.com/user-attachments/assets/6de5a933-8478-456b-a19a-7f103770f1b8)
![image](https://github.com/user-attachments/assets/8acdc1b3-1355-4808-8c8c-ddb08eddd638)
![image](https://github.com/user-attachments/assets/63952c7c-c0a8-4331-977e-0629f6fcf0ad)
![image](https://github.com/user-attachments/assets/fefcd088-abd6-4ec4-80a2-6d6967cdeea8)
![image](https://github.com/user-attachments/assets/4691ad97-562f-460f-824c-a410db1e1140)
![image](https://github.com/user-attachments/assets/947635fa-3522-4105-9599-0af401298227)
![image](https://github.com/user-attachments/assets/10c0e429-c773-494e-a317-4f4ba8ce2fed)
![image](https://github.com/user-attachments/assets/11c7bce4-8ef1-4bc0-baf5-fd13163aaec4)
![image](https://github.com/user-attachments/assets/4e8bf2bd-b7f8-4c29-a1f7-c30a779f9ab8)
![image](https://github.com/user-attachments/assets/e0ceefce-9574-44d5-8653-c94dfc096a39)
![image](https://github.com/user-attachments/assets/b65e97de-6269-4932-b9b2-4379a8d2ece4)
![image](https://github.com/user-attachments/assets/663f7e04-83d5-408d-9ab9-e89932ed9762)
![image](https://github.com/user-attachments/assets/cef76ebb-5d31-4135-8ec2-69977f86f777)


## Setup [![Build Status][ci-badge]][ci]

For more information, please see [INSTALL.md](INSTALL.md)

After setup has been completed, you can choose which version you wish to build.
To build a specific version, run this command inside the repository directory in cygwin64:

`make`


Other languages can be found here:

https://github.com/gb-mobile/pokecrystal-mobile-eng

https://github.com/gb-mobile/pokecrystal-mobile-fra

https://github.com/gb-mobile/pokecrystal-mobile-ger

https://github.com/gb-mobile/pokecrystal-mobile-ita

## Using Mobile Adapter Features

To take advantage of the Mobile Adapter features, we currently recommend the GameBoy Emulator BGB:
https://bgb.bircd.org/

and libmobile-bgb:
https://github.com/REONTeam/libmobile-bgb/releases

Simply open BGB, right click the ‘screen’ and select `Link > Listen`, then accept the port it provides by clicking `OK`.
Once done, run the latest version of libmobile for your operating system (`mobile-windows.exe` or windows and `mobile-linux` for linux).
Now right click the ‘screen’ on BGB again and select `Load ROM…`, then choose the pokecrystal-mobile `.gbc` file you have built.

## Mobile Adapter Features

A full list of Mobile Adapter features for Pokémon Crystal can be found here:
https://github.com/gb-mobile/pokecrystal-mobile-en/wiki/Pok%C3%A9mon-Crystal-Mobile-Features

## Contributors

- Pret           : Initial disassembly
- Pfero          : Old Spanish disassembly for Pokecrystal
- Matze          : Mobile Restoration & Japanese Code Disassembly
- Idain          : Mobile Spanish Translation & Code
- Fillo			 : Easy Chat Translation
- Damien         : Code
- DS             : GFX & Code
- Ryuzac         : Code & Japanese Translation
- Zumilsawhat?   : Code (Large amounts of work on the EZ Chat system)
- REON Community : Support and Assistance

[ci]: https://github.com/pret/pokecrystal/actions
[ci-badge]: https://github.com/pret/pokecrystal/actions/workflows/main.yml/badge.svg
