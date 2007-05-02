
# Xcode project setup

This is what I had to do to get the project to compile even before adding a FUSEFileSystem subclass:

* Install MacFUSE-Core
* Create a new Cocoa application
* **Copy** files from macfuse/filesystems-objc/FUSEObjC
* Remove FUSEMain.m
* Remove MainMenu.nib
* Add Carbon.framework to the target
* Add libfuse.dylib (/usr/local/lib) to the target
* Modify the Build settings of the Target inspector as follows (for "All Configurations"):
	* Add /usr/local/include to the "Header Search Paths" 
	* Add /usr/local/lib to the "Library Search Paths"
	* Add _FILE_OFFSET_BITS=64 to "Preprocessor Macros"
	* Enable "Enable Objective-C exception handling"


# Adding GridEZ.framework

* Download from XGrid@Stanford website
* Read instructions from download
* Framework is embedded (copied) in the final app package


# Subclassing FUSEFileSystem

* This is where one can implement the callbacks listed in FUSEFileSystem.h
* Make the subclass the app delegate in MainMenu.nib
* Override 'shouldStartFuse' to return NO to avoid auto-mounting when app launches
* Call [seld startFuse] on a separate thread to start connection manually
* Only one filesystem can be mounted per application process



# How does FUSEFileSystem superclass work?

* respond to applicationDidFinishLaunching:
	* create an instance of FUSEFileSystem, using the class listed in the info.plist
	* start fuse if shouldStartFuse returns YES, otherwise nothing
* the fuse filesystem struct is created via the fuse\_main call, which is the 'lazy' way of doing it: all is needed is a struct fuse\_operations , that lists all the callbacks
* there is one static struct fuse\_operations to list the FUSE callbacks, that are simply forwarded to the sharedManager singleton


# Why only one XgridFS volume?

* The limitation is due to 'struct fuse_operations' that takes a list of functions with very specific format, that won't take the SEL and self parameters of an IMP; thus it is difficult to create a separate struct for each instance of FUSEFileSystem, and populate it with functions that would call back the specific fuse wrapper