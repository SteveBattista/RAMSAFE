# RAMSAFE (RAM-based Secure Analysis Forensics Environment) User Guide
If you are interested in building this environment please go here [Build Guide](build_guide.md)<br>
If you use the tools in this repository with a standard linux on a hard-drive they will write files to the disk. This means that if someone looks at that hard-drive these files may be found on them. 

## Quick User guide
1. Purchase a USB drive of at least 8GB.
2. Download RAMSAFE from [Not Downloadable yet](https://ramsafe.org),
3. Plug in USB drive,
4. Use a tool like [RUFUS](https://rufus.ie/en/) if you are in Windows or Startup Disk Creator for Linux (this may require an install of new software in Ubuntu) to load the RAMSAFE.iso to USB.
5. Reboot machine. <br>
    a. While rebooting press the Boot time menu (F12 for Dell)<br>
    b. Follow Prompts for keyboard and network.
    c. No need to update installer as you are not installing this os.
    d. Select try (no need to select install)
    e. This loads a whole new Operating system<br>
    f. Help investigate CSAM perpetrators<br>
    g. end tips to law enforcement<br>
    h. While you work, all work is in memory so it is not kept and it does not write anything to disk<br>
6. Reboot machine.
7. Remove USB.
8. Original operating system is untouched. 

Note: This will work on most machines. It will not work on the newer Mac Machines that use the M series chips as they are ARM based.

## Detailed user guide

### Submission tips:
1. When submitting a url, the recommend format is [here](summary_file.sh)
- You can either assemble this manually using the tools in RAMSAFE use the tool [summary_url.sh](#Summary-of-a-URL)
2. When submitting for a file on your RAMSAFE drive, the recommend format is [here](summary_file.sh)
- You can either assemble this manually tools in RAMSAFE or use the tool [summary_file.sh](#Summary-of-a-File)

### Useful tools 
#### Firefox
From the menu bar on the left select Firefox for general browsing and interaction with websites. When you download images to the operating system, it keeps these in RAM so that they are not written to disk. In the future, there will be a plugin loaded for safe viewing that will blur CSAM so that you can focus on other parts of an image for investigation. This tool will allow users to toggle the blurring off if it gets in the way of investigations. To start firefox:
-Select the firefox icon on the top left bar

#### Image Viewer
The Gnome Image viewer allows you to see image files. It also allows you to examine properties for these images. To run the image viewer :
- Press the Show Apps button on the bottom left, type image in the search bar then select terminal icon

#### VLC video viewer
The Gnome text editor can be used to examine video. This allows a verity of formats. For now, you can not load a video from youtube from the network option such as https://youtu.be/dQw4w9WgXcQ?si=b92IDFkXi-3GzVFY To run VLC:
- Press the Show Apps button on the bottom left, type write in the search bar then select terminal icon

#### Gnome Text Editor
The Gnome text editor can be used for notes. This includes a spell checker in the right click menu. To run the text editor:
- Press the Show Apps button on the bottom left, type write in the search bar then select terminal icon

#### Terminal
Terminal is used for a command line interface. To start a terminal either-
- either press (CTRL- ALT -T)
- pressing the Show Apps button on the bottom left, type terminal in the search bar then select terminal icon

#### Summary of a URL
Run this inside of a terminal. This tool creates a summary for a url you specify. You can copy and paste this into whatever reporting system you use. It asks you for the following:
- an an identifier (name or email)
- any notes you want to add for the url. <br> <br>
- example command `summary_url.sh https://www.geoimgr.com/images/samples/italy-garda-lake-sailing-club-225.jpg`
- output: [here](summary_url.sh.md)


#### Summary of a File
Run this inside of a terminal. This tool creates a summary for a file you specify. You can copy and paste this into whatever reporting system you use. 
It asks you for the following:
- The link you downloaded this file from
- an an identifier (name or email)
- any notes you want to add for the url. <br> <br>
- example command `summary_file.sh ../images/italy-garda-lake-sailing-club.jpg`
- output: [here](summary_file.sh.md)


#### Exiftool
Run this inside of a terminal. This lists any meta-data included in the image. This can be used to find GPS coordinates or images that have the same characteristics that might have been taken with the same type of camera. Many websites strip this things like GPS out of the images. RAMSAFE includes a sample image. rTo test this type the following:
- example command: `exiftool -j ~/Downloads/italy-garda-lake-sailing-club.jpg`
- output : [here](exiftool_output)

### Exact size
Run this in a terminal. The exiftool provides a more user friendly value to the size. This provides the exact size of an image which is useful for ensuring that it has not changed. 
- `stat --format=%s ~/Downloads/italy-garda-lake-sailing-club.jpg`
- output: <br>
813453 
 <br>

#### Standard Hashes
These are all run within a terminal. They provide a fixed string that under most circumstances are unique for identification for a file. If one bit in the image changes, the hash changes. Therefore two similar looking images will have unique hashes The longer the hash in bit size, the higher the probability that it will be unique. In the case of a 256 bit hash matching another file is 1/(256<sup>2</sup>). This is incredibly small. Any change has a 50% chance of changing any bit in the result.
<br>

1. MD5: a 128-bit (32-character hexadecimal) hash value from any input data. MD5 is no longer considered secure for cryptographic purposes due to vulnerabilities to collisions (different inputs producing the same hash).
- example command `md5sum ~/Downloads/italy-garda-lake-sailing-club.jpg`
- output: <br>
e1e51fca9ffcd158696558d1dfe18b7d  /home/ncptf/Downloads/italy-garda-lake-sailing-club.jpg
<br>

2. SHA-1: a 128-bit (32-character hexadecimal) hash value from any input data. SHA-1 is now considered insecure for cryptographic purposes because vulnerabilities have been found that allow attackers to create collisions (different inputs producing the same hash). It is recommended to use stronger hash functions like SHA-256 or SHA-512.
- example command `sha1sum /home/ncptf/Downloads/italy-garda-lake-sailing-club.jpg`
- output:<br>
9b4b1d5070c4e8d0b1945eaf7f7294a5319f4568  /home/ncptf/Downloads/italy-garda-lake-sailing-club.jpg
<br>

3. SHA-256:  a 256-bit (64-character hexadecimal) hash value from any input data. SHA-256 is considered secure and resistant to collisions, making it suitable for modern cryptographic applications.
- example command: `sha256sum /home/ncptf/Downloads/italy-garda-lake-sailing-club.jpg`
- output: <br>
2f71bfe034770fe0283f9fa9d3f045a0f1f40123994a4d6039bcb757229d6efc  /home/ncptf/Downloads/italy-garda-lake-sailing-club.jpg```
<br>

4. SHA-512:   a 512-bit (128 character hexadecimal) hash value from any input data. SHA-512 is considered secure and resistant to collisions, making it suitable for modern cryptographic applications. SHA-512 is 30-40% faster than SHA-256 for large files. The size of the hash is a bit cumbersome to check.
- example command `sha512sum /home/ncptf/Downloads/italy-garda-lake-sailing-club.jpg`
- output: <br>
cf4539d55b7ea1330657febc131cc6aacfcd5d20ed595166a8c319604ac46dc977bcf9ea13f1fa562e0decb454696f77eea389dd46a6857a6aeb27e97f0cf499  /home/ncptf/Downloads/italy-garda-lake-sailing-club.jpg

#### Fuzzy Hashes
ssdeep is a tool that allows you to get a fuzzy hash of a file. This allows you to compare similar files. Creating a fuzzy hash alow anyone to compare the hashes to see if the files are similar. This can be used if the file owner disturbs the files so that the plain hashes are different. Usage can be found [Here](https://ssdeep-project.github.io/ssdeep/usage.html)

1. Creating a fuzzy hash of a file.
- example command `ssdeep ~/Downloads/italy-garda-lake-sailing-club.jpg`
- output:<br>
ssdeep,1.1--blocksize:hash:hash,filename <br>
12288:AkdtAf/s7PeFRsY3QnaGp092YAlhduM30RgbotuKwEOc94hHP9kPcIVvIJGPYt:FIf4ebRDG+cnXeuK+c94XkYEPW,"/home/ncptf/Downloads/italy-garda-lake-sailing-club.jpg"
<br>

2. ssdeep_compare_url is a script that lets you compare two images in a friendly manner given two urls. The higher the number in parentheses the closer the two files are. This is between 0 and 100. Because of inexact nature of fuzzy hashing, note that just because ssdeep indicates that two files match, it does not mean that those files are related. You should examine every pair of matching files individually to see how well they correspond. See paper [Here](https://www.sciencedirect.com/science/article/pii/S1742287606000764?via%3Dihub) for detail on matching score
- example command `ssdeep_compare_urls.sh https://www.geoimgr.com/images/samples/italy-garda-lake-sailing-club.jpg https://www.geoimgr.com/images/samples/italy-garda-lake-sailing-club.jpg`
- output: <br>
/Downloading https://www.geoimgr.com/images/samples/italy-garda-lake-sailing-club.jpg<br>
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current <br>
                                 Dload  Upload   Total   Spent    Left  Speed <br>
100  794k  100  794k    0     0  2913k      0 --:--:-- --:--:-- --:--:-- 2920k <br>
Downloading https://www.geoimgr.com/images/samples/italy-garda-lake-sailing-club.jpg <br>
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current <br>
                                 Dload  Upload   Total   Spent    Left  Speed<br>
100  794k  100  794k    0     0  4600k      0 --:--:-- --:--:-- --:--:-- 4618k<br>
Comparing links https://www.geoimgr.com/images/samples/italy-garda-lake-sailing-club.jpg and https://www.geoimgr.com/images/samples/italy-garda-lake-sailing-club.jpg<br>
/tmp/tmp.WKZ34l9MB4 matches /tmp/tmp.hY95hfgDBw (100)<br>
<br>

3. ssdeep_compare_file is a script that lets you compare two images in a friendly manner given two files. The higher the number in parentheses the closer the two files are. This is between 0 and 100. Because of inexact nature of fuzzy hashing, note that just because ssdeep indicates that two files match, it does not mean that those files are related. You should examine every pair of matching files individually to see how well they correspond. See paper [Here](https://www.sciencedirect.com/science/article/pii/S1742287606000764?via%3Dihub) for detail on matching score
- example command `ssdeep_compare_files.sh ../images/italy-garda-lake-sailing-club.jpg ../images/italy-garda-lake-sailing-club_modified.jpg`
- output: <br>
/home/ncptf/RAMSAFE/images/italy-garda-lake-sailing-club_modified.jpg matches /home/ncptf/RAMSAFE/images/italy-garda-lake-sailing-club.jpg (99)
<br>

4. Comparing multiple directories of images:
- example command `ssdeep -l -r -p Incoming Outgoing Trash`
- output: <br>
Incoming/Budget 2007.doc matches Outgoing/Corporate Espionage/Our Budget.doc (99) <br>
Incoming/Salaries.doc matches Outgoing/Personnel Mayhem/Your Buddy Makes More Than You.doc (45) <br>
Outgoing/Corporate Espionage/Our Budget.doc matches Incoming/Budget 2007.doc (99) <br>
Outgoing/Personnel Mayhem/Your Buddy Makes More Than You.doc matches Incoming/Salaries.doc (45) <br>
Outgoing/Plan for Hostile Takeover.doc matches Trash/DO NOT DISTRIBUTE.doc (88) <br>
Trash/DO NOT DISTRIBUTE.doc matches Outgoing/Plan for Hostile Takeover.doc (88)<br>







