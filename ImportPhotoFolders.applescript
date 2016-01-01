on run
	set folderList to (choose folder with multiple selections allowed)
	
	tell application "Photos"
		activate
		delay 2
	end tell
	
	repeat with baseFolder in folderList
		importEachSubFolder(baseFolder, null)
	end repeat
end run

on importEachSubFolder(aFolder, parentFolder)
	tell application "Finder"
		set albumName to (name of aFolder as text)
		set subFolders to every folder of aFolder
	end tell
	
	if (count of subFolders) > 0 then
		set fotoFolder to createFotoFolder(aFolder, albumName, parentFolder)
		
		repeat with eachFolder in subFolders
			importEachSubFolder(eachFolder, fotoFolder)
		end repeat
	else
		set fotoFolder to parentFolder
	end if
	
	importFotos(aFolder, albumName, fotoFolder)
end importEachSubFolder

on importFotos(aFolder, albumName, parentFolder)
	set imageList to getImageList(aFolder)
	if imageList is {} then return
	
	set fotoAlbum to createFotoAlbum(albumName, parentFolder)
	
	tell application "Photos"
		with timeout of 600 seconds
			import imageList into fotoAlbum skip check duplicates no
			repeat with im in media items in fotoAlbum
				if the filename of im does not start with "DSC" and Â
					the filename of im does not start with "IMG" then
					set longName to the filename of im
					set shortName to text 1 thru ((offset of "." in longName) - 1) of longName
					set the name of im to shortName
					if not (exists (description of im)) then
						set the description of im to albumName
					end if
				end if
			end repeat
		end timeout
	end tell
end importFotos

on createFotoFolder(aFolder, folderName, parentFolder)
	tell application "Photos"
		if parentFolder is null then
			make new folder named folderName
		else
			make new folder named folderName at parentFolder
		end if
	end tell
end createFotoFolder

on createFotoAlbum(albumName, parentFolder)
	tell application "Photos"
		if parentFolder is null then
			make new album named albumName
		else
			make new album named albumName at parentFolder
		end if
	end tell
end createFotoAlbum

on getImageList(aFolder)
	set extensionsList to {"jpg", "png", "tiff", "JPG", "jpeg", "gif", "JPEG", "PNG", "TIFF", "GIF", "MOV", "mov", "MP4", "mp4"}
	tell application "Finder" to set theFiles to every file of aFolder whose name extension is in extensionsList
	
	set imageList to {}
	repeat with i from 1 to number of items in theFiles
		set thisItem to item i of theFiles as alias
		set the end of imageList to thisItem
	end repeat
	
	imageList
end getImageList
