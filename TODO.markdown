EASY:

* open and select window with volume after volume is mounted

* add button to toolbar : needs some work in GridEZ to provide APIs





If you read this, this means you downloaded the code, and are curious about it. Well, maybe you can help with those problems:

TRICKY:

* Submissions by dropping files on the disk or a grid --> I tried using the objc Fuse APIs, but could not get somehting to work properly. I am not familiar enough with the FUSE APIs. There are a bunch of different IO calls, and I am not sure how each call should respond during addition of a file. When is a file considered existing? When is the file data considered available?... I will have to look at exisiting code in Fuse-based projects, and will likely need some info from Fuse or MacFuse developers.

* Thread safety? The ObjC wrapper runs FUSE in a separate thread. Is it necessary? The reason is probably that it would otherwise hijack the runloop in the main thread, I have to check the code. The Xgrid stuff needs an NSRunLoop, in any case. My current problem: the FUSE thread accesses data from the main GridEZ thread with no protection. When I use an SQLite store backend, I get worrisome error messages in the console with out of order operations going on, not sure what it means. But the store likely gets stuff in and out of disk (fault creations and firings) in both threads at the same time, and that could be the issue. With an in-memroy store, I don't see any apparent problems at runtime. But I am not sure if bad things could still happen with in-memory stores. I tried to access it in a cleaner way by messaging instead to the main thread when accessing the data, but that caused a bad bad bad hang that would take down all the user processes and apps (hard reboot, even killing Xgrid FUSE or Xcode via ssh did not help). Future version should try to address the issue. Maybe a single lock on a global generic object such as an NSDictionary to move the data from the main thread to the FUSE thread. Or maybe I don't need 2 threads??

	––> this is all mostly moot now with the division Xgrid FUSE / xgridfs. The only remaining concern is: can bad things happen when accessing an in memory store from a different thread than the one it was set up in?

	--> this is going to be hard, because of the way GridEZ works. It needs to run in a thread with a run loop, and thus can't be with MacFuse.

HARD:

* filesystem notifications, for Finder live updates, e.g. icons, jobs downloaded,... I just need to find the time to identify the APIs. Hopefully, that should be relatively easy. Update: it turns out it is not. See MacFUSE developer Google group postings.


