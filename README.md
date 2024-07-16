# TrimUI Smart Pro Tool

![image](https://github.com/user-attachments/assets/f2ece30c-c5ff-495c-9813-f6fb26bd4aac)


## Getting ready to use
1. Turn off the TSP main unit completely. (Setting > System > Power off).
2. Remove the SD card from the unit and connect it to the PC. (The drive must be recognized)
3. Run the TRIMUI.exe file to bring up the screen. (The reference position will be set automatically)
4. If the reference position is not set automatically, press the ... button to select the SD card drive.
5. When the emulators are listed, they are ready for normal use. Please select the emulator you want to work with.

## To add a rom
1. Select the location where you want to add the rom. (Folder in the bottom left corner, no need to select a subfolder)
2. Right-click and select Add Rom or select Add Rom from the File menu.
3. Select the rom you want to add and click the Open button to add it to the list.
4. If you want to add all the roms that exist in the current emulator's rom folder, click the Regenerate Cache button. (If the Rom shortened filename is checked, it will automatically import the full name)

## Image Scraping
1. To scrape a screenshot, select the rom name from the list and click the Scrape button.
2. If "shortname" is checked in the details, only one will be scraped, and if it is unchecked, four will be scraped. (Rom shortened filename is an arcade filename, so don't uncheck it, and if you want to scrape more, enter a search term to search in the scrape search term and scrape it to get 4 images unconditionally)
   - Emulators with Rom shortened filename checked will get images from adb.arcadeitalia.net, and other emulators will get images from yahoo.com. You may get strange images, so choose the one you like the most. If you don't like all of them, please enter another search term in the scrape search box and press the scrape button.
3. Additionally, you can click on the scraped images to replace them with your own.
4. You can search and download your own images in a web browser and drag the files to TRIMUI Tool to add them.
5. Scrape All Emulators from the Scraper menu will scrape all the roms present in the rom (except if the images already exist), press ESC if you want to cancel the scraping.

## Rename Rom
1. Select a specific Rom from the Rom list and click it once again with the mouse or press F2 after selecting it to rename it.
2. You can also rename it in Korean and the changes will be saved to the SD card immediately. (The filename will not be changed.)
3. If you want to change the file name, please change the file name of the rom in Explorer and then click Generate cache.​

## Create a subfolder
1. Right-click on the folder icon in the bottom left corner and click New folder.
2. Enter a name for the folder and click OK.
3. You can drag a rom from the parent folder to the folder (the rom from the physical SD card will be moved to the folder).

## Managing gamelist.xml
1. Clicking "Create a game list using gamelist.xml" from the XML menu will generate a list from the contents of gamelist.xml. (It will also recognize folder tags and save subfolder information.)
2. Clicking "Generate gamelist.xml" from the XML menu will save the contents of the current list as a gamelist.xml file and specify the gamelist entries in the details.

## TIP. What is "Generate cache"?
 1. TSP stock OS creates and uses cache files of sqlite3 DB internally. Because of this, simply copying a rom file to an SD card will not be recognized.
 2. TRIMUI Tool manages file lists and images by modifying this cache.
 3. Therefore, if you click Refresh Roms in the TSP internal menu, the changed rom name will be changed to the original filename.
 4. Please do not use the Refresh Roms function on TSP when managing the list with TRIMUI Tool.
