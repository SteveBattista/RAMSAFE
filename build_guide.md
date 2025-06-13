# RAMSAFE (RAM-based Secure Analysis Forensics Environment) build guide
If you are interested in the user guide please go to the [User Guide](user_guide.md)
# Build guide
1. Start with an Ubuntu operating system
2. Download an Ubuntu Desktop from here [Ubuntu Desktop](https://ubuntu.com/download/desktop)
3. Run the following command in a terminal:<br>
`sudo apt-add-repository universe` <br>
`sudo apt-add-repository ppa:cubic-wizard/release` <br>
`sudo apt update`<br>
`sudo apt install --no-install-recommends cubic`<br>
Additional instructions can be found [Here](https://github.com/PJ-Singh-001/Cubic)
4. Either select cubic by either
- pressing the Show Apps button on the bottom left, type cubic in the search bar then select cubic icon
- or by running `cubic` in a terminal
- General instructions on how to use cubic are located in [instructions](https://github.com/PJ-Singh-001/Cubic)
5. Select a directory to build ramsafe (I use ramsafe)
6. Get to the virtual environment terminal and type the following
  - `apt install git -y && mkdir /install && cd /install && git clone https://github.com/SteveBattista/RAMSAFE.git && cd RAMSAFE/bin && ./install_script.sh`
7. Select Next
8. Select Boot
9. Replace text "Try or install Ubuntu" with Run RAMSAFE"
8. Select Next
9. Select finish
8. Plug in at least a 8GB USB
9. Use a tool like [RUFUS](https://rufus.ie/en/) if you are in windows or Startup Disk Creator for Linux (this may require an install of new software in Ubuntu) to load RAMSAFE .iso to a USB
10. You now have a useable Live USB item<br>
Notes:<BR>
-  I would recommend a minium of  2 cores, 4GB and 50 GB of space to build this image.
-  The ISO I made the last time I did this was 




