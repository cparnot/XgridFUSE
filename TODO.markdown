
* Thread safety? The FUSE thread accesses data from the main GridEZ thread (never writes, though) with no protection; I  am not sure if bad things could happen. I tried to access it in a cleaner way by messaging instead to the main thread when accessing the data, but that caused a bad hang that would take down all the user processes and apps (hard reboot, even killing Xgrid FUSE or Xcode via ssh did not help). Future version might try to address the issue (if really issue there is).

* filesystem notifications, for Finder live updates, e.g. icons, jobs downloaded,... How to do that?? I don't have the time to investigate too much.

* Submissions by dropping files on the disk or a grid --> I tried using the objc Fuse APIs, but could not get somehting to work properly. I don't have the time to investigate too much.