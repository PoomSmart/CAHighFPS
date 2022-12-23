# CAHighFPS

Make your CoreAnimation applications use the highest available FPS.
 
## Part 1: CADisplayLink
 
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

### Preferred Framerate Range

Introduced in [iOS 15](https://developer.apple.com/documentation/quartzcore/cadisplaylink/3875343-preferredframeraterange?language=objc), this is now their main way of dictating the effective FPS. As we want to ensure the maximum FPS, the `maximum` and `preferred` properties of `CAFrameRateRange` can just be `120`. The devices that support up to 60 FPS will only go up to 60 FPS. 

## Part 2: CAMetalLayer

Metal has been a thing since iOS 8. While I played around games that use Metal engine, I noticed that the FPS doesn't go up to 120 FPS on the 120 Hz display. Then, through using FLEX, I discovered a pair of properties that need to be set as follows:

```objc
metalLayer.allowsNextDrawableTimeout = NO; // iOS 11+
metalLayer.drawableTimeoutSeconds = 0; // private, iOS ~12+
```

Games like Asphalt 8 and 9, they might have gotten better but that might be just me. It looks promising, however, on games like Jelly Defense.

## Everything Else

### Battery: Does it drain your battery?

Because CAHighFPS enforces the highest available FPS for the apps, it's only natural that this will consume more energy. Draining may be significant or else. YMMV.

### ProMotion Display: iPhone 13 compatibility

You may ask whether this tweak works with these devices. According to my simple analysis of iOS 15.0 QuartzCore simulator binary, although Apple introduced `CAFrameRateRange` that aims to step the FPS up or down depending on situations, CAHighFPS will still be able to override those logics. At any rates, only a real testing speaks.
