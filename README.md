# CAHighFPS

Makes your CoreAnimation applications use the highest available FPS, or a custom rate you choose.

## Settings

Open **Settings → CAHighFPS**:

- **FPS**: Slider from 0 to 120. `0` (default) uses the highest refresh rate of the device. Any other value is forced for enabled apps and clamped to the display's maximum.
- **Systemwide**: Applies the chosen FPS to every app except SpringBoard and those in Blacklisted Apps. Off by default, so existing per-app selections keep working.
- **Applications**: Whitelist used when Systemwide is off. Only these apps get the chosen FPS.
- **Blacklisted Apps**: Apps skipped when Systemwide is on.

Reopen an app after changing settings.

## Part 1: CADisplayLink
 
Quoting from [Apple](https://developer.apple.com/documentation/quartzcore/cadisplaylink), `CADisplayLink` is a timer object that allows your app to synchronize its drawing to the refresh rate of the display. A5 devices (iPhone 4s and iPad 2) are the first to introduce 60 HZ refresh rate - and that the applications can run at its best at 60 frames per second (FPS).

### Frame Interval

There is a (now-deprecated) property of `CADisplayLink` called `frameInterval` that the developers can set to limit the FPS. If set to `1`, the FPS is 60. This is true according to the underlying logic of `setFrameInterval:` method:

![image](https://user-images.githubusercontent.com/3608783/135698671-df790125-cc65-4f5f-93bc-49744aea50c9.png)

Some applications out there choose `2` as a value, rendering the final FPS at `60/2 = 30` which doesn't sound cool for the devices that are capable of higher FPS.

This is where CAHighFPS enforces `frameInterval` so the effective rate matches the chosen FPS (`1` when using the display maximum).

### Preferred Frames Per Second

It is a substitute `CADisplayLink` property of `frameInterval` (until iOS 15.0), goes by the name `preferredFramesPerSecond`. If set to zero, the system will try to match the FPS to the [highest available refresh rate of the device](https://developer.apple.com/documentation/quartzcore/cadisplaylink/1648421-preferredframespersecond).

Here's the underlying logic of `setPreferredFramesPerSecond:`:

![image](https://user-images.githubusercontent.com/3608783/135698799-90669124-de3f-4e2f-8bcd-81ab5486f521.png)

Again, some applications can explicitly set it to `30` or `60`. Those devices that are capable of higher than that will not be so pleased.

This is where CAHighFPS enforces `preferredFramesPerSecond` to `0` (display maximum) or to the custom FPS you set.

### Preferred Framerate Range

Introduced in [iOS 15](https://developer.apple.com/documentation/quartzcore/cadisplaylink/3875343-preferredframeraterange?language=objc), this is now their main way of dictating the effective FPS. By default, `preferred` and `maximum` of `CAFrameRateRange` are set to the highest supported FPS by the device. A custom FPS pins `minimum`, `preferred`, and `maximum` to that value.

## Part 2: CAMetalLayer

Metal has been a thing since iOS 8. For some reasons, there are not a lot of discussions about optimizing Metal apps for ProMotion display. The best I found are to override `-[CAMetalLayer maximumDrawableCount]` ([reference](https://blog.csdn.net/ByteDanceTech/article/details/123437098)) and `-[CAMetalDrawable presentAfterMinimumDuration:]` to allow for ideal ProMotion FPS.

## Everything Else

### Battery: Does it drain your battery?

Because CAHighFPS can enforce a higher FPS than an app chose, it's only natural that this will consume more energy. Draining may be significant or else. YMMV.
