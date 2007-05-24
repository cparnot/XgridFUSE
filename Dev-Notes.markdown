# Difference between "Xgrid FUSE" and "xgridfs"

Xgrid FUSE = main app that starts a new instance of xgridfs on each run and then quits

xgridfs = one instance running for each fuse volume - also includes the Xgrid connection panel (if necessary as decided by GridEZ framework, e.g. if connection problem or if password needed)


# Pieces needed to compile Xgrid FUSE targets

## Adding MacFUSE-ObjC.framework

* Built using files from macfuse/filesystems-objc/FUSEObjC
* Framework is embedded (copied) in the final app package, in subdir 'Frameworks', using a 'Copy Files' build phase
* If you downloaded Xgrid FUSE from Xgrid@Stanford, you should also have the application package, that contains the framework already built

## Adding GridEZ.framework

* Download from XGrid@Stanford website
* Read instructions from download
* Framework is embedded (copied) in the final app package, in subdir 'Frameworks', using a 'Copy Files' build phase
* If you downloaded Xgrid FUSE from Xgrid@Stanford, you should also have the application package, that contains the framework already built


# Misc notes about MacFuse and MacFuseObjC

## Subclassing FUSEFileSystem

* This is where one can implement the callbacks listed in FUSEFileSystem.h
* Make the subclass the app delegate in MainMenu.nib
* Override 'shouldStartFuse' to return NO to avoid auto-mounting when app launches
* Call [seld startFuse] on a separate thread to start connection manually
* Only one filesystem can be mounted per application process


## How does FUSEFileSystem superclass work?

* These are my notes to understand how FUSEFileSystem works
* See source code in MacFUSE/macfuse-objc
* respond to applicationDidFinishLaunching:
	* create an instance of FUSEFileSystem, using the class listed in the info.plist
	* start fuse if shouldStartFuse returns YES, otherwise nothing
* the fuse filesystem struct is created via the fuse\_main call, which is the 'lazy' way of doing it: all is needed is a struct fuse\_operations , that lists all the callbacks
* there is one static struct fuse\_operations to list the FUSE callbacks, that are simply forwarded to the sharedManager singleton


## Why only one XgridFS volume?

* The limitation is due to 'struct fuse_operations' that takes a list of functions with very specific format, that won't take the SEL and self parameters of an IMP; thus it is difficult to create a separate struct for each instance of FUSEFileSystem, and populate it with functions that would call back the specific fuse wrapper
* One workaround would be to launch several instances of Xgrid FUSE