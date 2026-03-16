---
title: "The Haversine Formula"
date: 2026-03-01T21:01:44-08:00
description: "I had no idea this existed, but I've also always wondered how GPS coordinates' distances were calculated."
draft: false
toc: false
images:
keywords:
  - Haversine formula
  - GPS calculation
tags:
  - Haversine
  - GPS
  - Math
---
While doing some reading tonight, I came across a question.

**How do you calculate the distances between two GPS coordinates?**

Turns out it's by using a function called the [Haversine formula](https://en.wikipedia.org/wiki/Haversine_formula). And let me tell you, it looks kind of crazy at first.

I [ride bikes a lot](https://www.bicyclewatercooler) and use a GPS computer to track my rides - I've always wondered how a device, likely emitting data points every second or so - kept track of this information. And then additionally, how services like [Strava](https://www.strava.com) or Garmin actually overlay that information on to a map to show you where you've gone, how fast, at what elevation, etc.

So I found some code references on how to use this formula, but it didn't really make much sense to me. At least not until I found [this video](https://youtu.be/t6NkBRQ2Fz0?si=OuzGW_EjGF3vcDBA) (which gets pretty heavy right in the last 30 seconds).

**GPS Coordinates aren't exactly like x, y coordinates.**

You can do some basic calculations between two GPS coordinates when they share a common numerical value, but that's not a very real-world example.

At first I thought, _maybe I could treat this like a Pythagorean Theorem problem_, until I realized that that assumption relied on things being in a flat plane.

And surely we have a better way to handle this than that. Earth isn't flat!

The better way to think about this is calculating the "arc" that is created between two similar points. Then, you can see this as a trigonometric problem, using the Earth's average radius as a data point.

With enough math, you can figure out this arc value "length", aka distance. Basically you can use the trigonometric functions of a unit circle (with Earth's radius as its "unit") if you imagine taking a slice of the Earth at the longitude you're comparing. 

**Remember radians? I had nearly forgotten!**

Where things get more interesting though is when you want to compare two GPS points _from anywhere_.

The Haversine formula takes this into account. And it does so by imagining a similar "unit circle slice" but oriented differently, i.e., NOT along latitudinal or longitudial lines.

Really cool! The video above explains it a bit better and with visuals.

**So I decided to write up a small Golang function to calculate this value between two data points.**

Using a type that includes both a `Lat` and `Lng` value to combine values into a singular "point", it looks a bit like this.
```
type TrackPoint struct {
  Lat float64
  Lng float64
}

func haversine(t1, t2 TrackPoint) float64 {
  // Earth's approx radius in meters
  const earthRadius = 6371000
	
  var (
    // radian calculations
    rLat1 = t1.Lat * math.Pi / 180.0
    rLat2 = t2.Lat * math.Pi / 180.0
    
    // delta values, converted to radians
    dLat  = (t2.Lat - t1.Lat) * math.Pi / 180.0
    dLng  = (t2.Lng - t1.Lng) * math.Pi / 180.0
  )
	
  // account for going over from -179 to +179 degrees
  // a simple subtraction would make this look like -358 degrees
  if dLng > math.Pi {
    dLng -= 2 * math.Pi
  } else if dLng < -math.Pi {
    dLng += 2 * math.Pi
  }
  // this is kind of like a mod function that helps 
  // when numbers wrap around a boundary, except it
  // +/- two radians / 360 degrees.

  // the math
  a := math.Pow(math.Sin(dLat/2), 2) + 
    math.Pow(math.Sin(dLng/2), 2) *
    math.Cos(rLat1) *
    math.Cos(rLat2)
	
  c := 2 * math.Atan2(math.Sqrt(a), math.Sqrt(1-a))
	
  // turns out this is equivalent to above, and its been
  // way too long since Calculus 2 for me to know why
  //c := 2 * math.Asin(math.Sqrt(a))

  return earthRadius * c
}
```
Which can then be called via a main function:
```
func main() {
  // Big Ben in London (51.5007° N, 0.1246° W)
  // New York (40.6892° N, 74.0445° W)
  // Expected distance: 5574.840457 km
  var (
    london = TrackPoint{Lat: 51.5007, Lng: 0.1246}
    nyc    = TrackPoint{Lat: 40.6892, Lng: 74.0445}
  )

  fmt.Printf("Haversine distance between NYC and London: %f\n", 
    haversine(nyc, london))
}
```
Which then shows us:

> Haversine distance between NYC and London: 5574840.456849

I find things like this particularly fascinating because, despite its complexity, it's something that's used in every day functions without anyone really realizing it.