# Architectural Decision Record 002: GRIB2 data in flight levels in MARS and FDB

## Status
[**Proposed** | <s>Accepted</s> | <s>Deprecated</s> | <s>Superseded by [ADR-XXX]</s>]

## Last Updated
2026-01-23

## Context
Flight levels are a standardized way of expressing an aircraft’s altitude, primarily used during cruise flight at higher altitudes. Instead of referencing height above sea level directly, flight levels are based on the International Standard Atmosphere (ISA), which assumes a mean sea level pressure of 1013.25 hPa, a temperature of 15 °C at sea level, etc. This ensures that all aircraft in the same airspace use a common reference, maintaining safe vertical separation regardless of local pressure variations. Flight levels are expressed in hundreds of feet, so Flight Level 350 (FL350) corresponds to approximately 35,000 feet. 

In ecCharts, Clear-Air-Turbulence (CAT) is provided on a set of different flight levels, and this data should be produced in GRIB2 in 50r1. [See an example of CAT on flight levels in ecCharts](https://charts.ecmwf.int/products/medium-cat?flight_level=9144&projection=opencharts_europe)

 The Barometric Formula allows for the conversion from the pressure levels to flight levels and vice-versa under the assumption of standard ISA conditions.  This is the list of the flight levels in pressure (Pa) with their corresponding flight levels:
84310 (FL050), 81200 (FL060), 78190 (FL070), 75260 (FL080), 72430 (FL090), 69680 (FL100), 67020 (FL110), 64440 (FL120), 61940 (FL130), 59520 (FL140), 57180 (FL150), 54920 (FL160), 52720 (FL170), 50600 (FL180), 48550 (FL190), 46560 (FL200), 44650 (FL210), 42790 (FL220), 41000 (FL230), 39270 (FL240), 37600 (FL250), 35990 (FL260), 34430 (FL270), 32930 (FL280), 31490 (FL290), 30090 (FL300), 28740 (FL310), 27450 (FL320), 26200 (FL330), 25000 (FL340), 23840 (FL350), 22730 (FL360), 21660 (FL370), 20650 (FL380), 19680 (FL390), 18750 (FL400), 17870 (FL410), 17040 (FL420), 16240 (FL430), 15470 (FL440), 14750 (FL450)

There is no existing mechanism to encode flight levels directly in GRIB2.


### Options Considered
1. Pressure levels: The data could be encoded using pressure levels following the barometric formula conversion. For instance, FL340 would be encoded using typeOfLevel=pressure with a combined scale value and scaled factor equal to 25000Pa. However, archiving them under levtype=pl is not very good, as this would introduce new pressure levels with unusual values for a standard user. These new pressure levels would contain only a single parameter, which is Clear-Air-Turbulence creating a fair amount of unused entry in the MARS layout and introducing invalid combination of parameter/levelist in the MARS catalogue. This is also a very specific application so it is probably good to have the parameter(s) for aviation purposes on a separate levtype so that pl contains parameters for a wider user group. This can be achieved in ecCodes using the same mechanism which put 2m and 10m parameters on levtype=sfc.
2. Height levels would be another option, but flight levels are not a ‘real’ height as this relates to the assumption of having the standardized atmospheric conditions.  For instance, FL350 would be encoded using typeOfLevel=height with a combined scale value and scaled factor equal to 10668m (35,000 feet). All other parameters are referenced to the earth’s surface. This is also a very specific application why it is probably good to have the parameter(s) for aviation purposes on a separate levtype so that hl contains parameters for a wider user group. As for the pressure level option, this can also be achieved in ecCodes using the remapping mechanism.
3. Creating a new typeOfLevel “Flight levels” is the third possible option. For now, we would use a local entry in the GRIB2 message and encode the flight level in the GRIB record. FL340 would get typeOfFirstFixedSurface=flight level and level=340 instead of pressure level and 25,000Pa. In parallel, we would propose a new code table entry in the coming WMO Fast-track for flight levels. This means that with the availability of an official code table entry, the only change in the meta-data of the data would be just a change of the code number in typeOfFirstFixedSurface. In terms of high-level keys, there would be no change in behaviour. For the MARS language, we propose to map the new TypeOfLevel to a new levtype value “fl” (flight level) which would work together with the corresponding flight level value encoded in the MARS levelist keyword. 

### Analysis
We considered encoding the flight levels as pressure levels mapped to levtype=fl but we noted the possible clashes with existing pressure levels already produced under levtype=pl. This is indeed the case for FL340 clashing with PL250. We also considered encoding the flight levels as height above ground levels mapped to levtype=fl. With height levels, the risk for clashes is virtually non-existant because the lowest flight level FL100 corresponds to a height of 3048m. However, flight levels are defined with respect to an abstract reference assuming a standard atmosphere, while height levels are referenced to the Earth’s surface, resulting in a discrepancy between them. The third option, i.e. creating a new type of level does not lead to potential clashes with existing data but it requires proposing them to WMO with an official solution only available in November 2026. 
Considering all options, we recommend option 3, i.e. to archive the data under newly created flight levels. This allows to add more parameters for aviation meteorology in the future which are currently also produced under the standard pressure levels under the flight levels.
An encoding example:
```bash
8-9	productDefinitionTemplateNumber = 1 [Individual ensemble forecast, … ]
10	parameterCategory= 19 [Physical atmospheric properties (grib2/tables/35/4.1.0.table) ]
11	parameterNumber = 29 [Clear air turbulence (CAT) (m2/3 s-1) … ]
12	typeOfGeneratingProcess = 4 [Ensemble forecast (grib2/tables/35/4.3.table) ]
13	backgroundProcess = 255
14	generatingProcessIdentifier = 161
15-16	hoursAfterDataCutoff = MISSING
17	minutesAfterDataCutoff = MISSING
18	indicatorOfUnitForForecastTime = 1 [Hour (grib2/tables/35/4.4.table) ]
19-22	forecastTime = 0
23	typeOfFirstFixedSurface = 193 [Flight level (ft) (grib2/tables/35/4.5.table , grib2/tables/local/ecmf/1/4.5.table) ]
24	scaleFactorOfFirstFixedSurface = 0
25-28	scaledValueOfFirstFixedSurface = 350
29	typeOfSecondFixedSurface = 255 [Missing (grib2/tables/35/4.5.table , grib2/tables/local/ecmf/1/4.5.table) ]
30	scaleFactorOfSecondFixedSurface = MISSING
31-34	scaledValueOfSecondFixedSurface = MISSING
35	typeOfEnsembleForecast = 6 [Perturbed forecast (grib2/tables/35/4.6.table) ]
36	perturbationNumber = 1
37	numberOfForecastsInEnsemble = 51
```

with the mars namespace:
```bash
{ "messages" : [
  {
    "domain": "g",
    "date": 20070323,
    "time": 1200,
    "expver": "0001",
    "class": "od",
    "type": "pf",
    "stream": "enfo",
    "step": 0,
    "levelist": 350,
    "levtype": "fl",
    "number": 1,
    "param": 260290
  }
]}
```

## Decision



### Related Decisions

## Consequences


## References

## Authors
- Sebastien Villaume
- Robert Osinski

