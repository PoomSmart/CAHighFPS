# CAHighFPS

Make your CoreAnimation applications use the highest available FPS.
 
## CADisplayLink
 
Quoting from [Apple](https://developer.apple.com/documentation/quartzcore/cadisplaylink), `CADisplayLink` is a timer object that allows your app to synchronize its drawing to the refresh rate of the display. A5 devices (iPhone 4s and iPad 2) are the first to introduce 60 HZ refresh rate - and that the applications can run at its best at 60 frames per second (FPS).

### Frame Interval

There is a (now-deprecated) property of `CADisplayLink` called `frameInterval` that the developers can set to limit the FPS. If set to `1`, the FPS is 60. This is true according to the underlying logic of `setFrameInterval:` method:

![image](https://user-images.githubusercontent.com/3608783/135698671-df790125-cc65-4f5f-93bc-49744aea50c9.png)

Some applications out there choose `2` as a value, rendering the final FPS at `60/2 = 30` which doesn't sound cool for the devices that are capable of higher FPS.

This is where CAHighFPS enforces the value of `frameInterval` to be `1`.

### Preferred Frames Per Second

It is a substitute `CADisplayLink` property of `frameInterval` (until iOS 15.0), goes by the name `preferredFramesPerSecond`. If set to zero, the system will try to match the FPS to the [highest available refresh rate of the device](https://developer.apple.com/documentation/quartzcore/cadisplaylink/1648421-preferredframespersecond).

Here's the underlying logic of `setPreferredFramesPerSecond:`:

![image](https://user-images.githubusercontent.com/3608783/135698799-90669124-de3f-4e2f-8bcd-81ab5486f521.png)

Again, some applications can explicitly set it to `30` or `60`. Those devices that are capable of higher than that will not be so pleased.

This is where CAHighFPS enforces the value of `preferredFramesPerSecond` to be `0`.
