# ADR-00X: Land surface tile data

# Status

Proposed

# Last Updated

19.03.2026

# Context

### Background

Land surface tiling is a technique used in numerical weather prediction models to represent sub-grid scale heterogeneity of surface characteristics within a single grid box. Instead of representing each grid box with a single uniform surface type, tiling schemes divide the grid box into multiple surface types (tiles), each with its own fraction of coverage and potentially different attributes. This allows models to better capture the diversity of land surfaces and their distinct meteorological responses.

For example, a single grid box might contain ocean, urban areas, and forest, each occupying different fractions of the grid box area. Parameters such as 2-meter temperature (2t) can vary significantly across these different surface types and encoding them separately provides more detailed and accurate information than a single grid box average.

We introduced new product definition templates (4.113, 4.114, 4.115, and 4.116) to support generalised tile encoding. These templates include several key metadata elements:

- **Tile Classification** (Code Table 4.242): Specifies the land cover survey used (e.g., ECOCLIMAP-SG, GLCC v2.0 BATS)
- **Type of Tile** (Code Table 4.252): The specific tile type within the survey (e.g., 1001 for Sea and Oceans, 1502 for Non-forest grouping)
- **Attribute of Tile** (Code Table 4.241): Additional attributes that modify the tile state (e.g., UNMOD (Unmodified), ICE, SNOW, AGG (Aggregated), ITCW (With intercepted water))
- **Number of Used Spatial Tiles**: Total number of different tile types in the configuration
- **Number of Used Tile Attribute Combinations**: How many tile + attribute combinations exist for the specific tile type
- **UUID of Data Group**: Unique identifier linking related tile messages together

See the full specification at: <https://github.com/wmo-im/GRIB2/issues/191>

In the context of Destination Earth on-demand-extremes-dt, part of the output portfolio is to provide data on tiles. Here, two different tile schemes are run simultaneously to capture both a simple tile configuration, as well as one which is more granular and captures more details.

In the context of CARRA2 project, extensive regional reanalyses dataset is ready to be archived in the production. As a part of that dataset, there are parameters produced on tiles which would be archived using a single, set tile scheme.

In the context of IFS, there is interest in producing tile output in GRIB2 for future cycles (e.g. cy51r1). As a part of that dataset, there would be parameters produced on tiles which would be archived using a single, set tile scheme (whilst rd expvers would be used for experimentation).

### MARS archiving approach

For archiving tile data in MARS, we have an existing mapping of the GRIB2 tile keys to MARS indexing keys as follows:

- **`tile`**: Maps to "Type of Tile" from Code Table 4.252\
  Examples:
  - `SEAO` (Sea and oceans)
  - `GNATU` (Nature grouping)
  - `GLCZU` (Urban grouping)
  - `GIWAT` (Inland water grouping)
- **`tileattribute`**: Maps to "Attribute of Tile" from Code Table 4.241\
  Examples:
  - `UNMOD` (Unmodified)
  - `ICE` (Ice-covered)
  - `ICE_SNOW` (Ice-covered + snow-covered) (concatenated attributes)

We propose an additional indexing key as follows:

- **`tilescheme`**: A new key to distinguish between different tile scheme configurations\
  Examples (more details below):
  - `simple` (Simple grouping scheme used)
  - `granular` (More detailed, granular grouping scheme used)

The `tile` and `tileattribute` keys are the minimum required to uniquely identify which surface type and state a parameter value represents.

### Tile scheme examples

Different model configurations may use different levels of granularity in their tiling schemes. We illustrate two common approaches.

Both schemes use the same ocean, urban and inland water representation but differ in how they handle natural vegetation. The simple scheme aggregates all nature into one tile (1501), while the granular scheme separates it into forest (1503) and non-forest (1502) components.

#### Simple Tile Scheme

A simple configuration groups vegetation types into a single broad nature category:

| **Type Code** | **Description**   | **Attribute** | **Description**                              | **Example Parameter** |
|---------------|-------------------|---------------|----------------------------------------------|-----------------------|
| SEAO; 1001    | Sea and oceans    | UNMOD         | Plain / unmodified                           | 2t                    |
| SEAO; 1001    | Sea and oceans    | ICE           | Ice-covered                                  | 2t                    |
| SEAO; 1001    | Sea and oceans    | ICE_SNOW      | Ice-covered + snow-covered                   | 2t                    |
| GNATU; 1501   | Nature grouping   | AGG           | Tile attributes aggregated across group      | 2t                    |
| GLCZU; 1523   | Urban grouping    | AGG           | Tile attributes aggregated across group      | 2t                    |
| GIWAT; 1524   | Inland water grouping | AGG       | Tile attributes aggregated across group      | 2t                    |

#### Granular Tile Scheme

A more detailed configuration separates natural vegetation into forest and non-forest components:

| **Type Code** | **Description**      | **Attribute** | **Description**                              | **Example Parameter** |
|---------------|----------------------|---------------|----------------------------------------------|-----------------------|
| SEAO; 1001    | Sea and oceans       | UNMOD         | Plain / unmodified                           | 2t                    |
| SEAO; 1001    | Sea and oceans       | ICE           | Ice-covered                                  | 2t                    |
| SEAO; 1001    | Sea and oceans       | ICE_SNOW      | Ice-covered + snow-covered                   | 2t                    |
| GFORE; 1502   | Forest grouping      | AGG           | Tile attributes aggregated across group      | 2t                    |
| GNOFO; 1503   | Non-forest grouping  | AGG           | Tile attributes aggregated across group      | 2t                    |
| GLCZU; 1523   | Urban grouping       | AGG           | Tile attributes aggregated across group      | 2t                    |
| GIWAT; 1524   | Inland water grouping | AGG          | Tile attributes aggregated across group      | 2t                    |

#### Tile Distribution example:

![Comparison of land surface tile schemes](./images/tile_schemes_comparison.png)

#### Possible tile schemes:

The full options of different schemes are below — each column in the second diagram represents a possible tile scheme becoming more granular from right to left:

![A black and white chart with red text](./images/tile_scheme_details_1.png)

![A colorful grid with numbers](./images/tile_scheme_details_2.png)

#### CARRA2:

In the frame of CARRA2 project, extensive regional reanalyses dataset is ready to be archived in the production. As a part of that dataset, there are eleven parameters produced on tiles:

- 167 - 2 metre temperature
- 174096 - 2 metre specific humidity
- 207 - 10 metre wind speed
- 228032 - Snow albedo
- 228141 - Snow depth water equivalent
- 260038 - Snow cover
- 260199 - Volumetric soil moisture
- 260242 - 2 metre relative humidity
- 260360 - Soil temperature
- 260644 - Volumetric soil ice
- 3066 - Snow depth

Regarding the tile scheme, only a single tile scheme is used, thus no need for `tilescheme` key.

Comparing to DestinE tile scheme, CARRA2 includes two "patches" (vegetation split in two) instead of DestinE's three ones.

# Options Considered

### 1. Always include `tilescheme` key

Archive all tile data with an explicit `tilescheme` key, even when only one scheme exists in a dataset.

#### Advantages:

- Provides future-proofing if additional schemes are added later
- Makes the data structure uniform across all tile datasets
- Explicit metadata about configuration is always available

#### Disadvantages:

- Adds an unnecessary indexing dimension when only one scheme is present
- Increases MARS catalogue size with redundant entries
- May confuse users with an extra key that only ever has one value in certain contexts

### 2. Include `tilescheme` only when multiple schemes exist

Add the `tilescheme` key only for datasets where multiple tile configurations need to coexist (e.g., datasets which output both simple & granular schemes).

#### Advantages:

- Keeps MARS structure as simple as possible
- Only introduces complexity where it's genuinely needed
- Avoids adding unnecessary entries in the MARS index

#### Disadvantages:

- Data structure becomes inconsistent between datasets
- Adding a second scheme later requires data restructuring
- Users must know whether `tilescheme` exists before querying

### 3. Alternative Key Names

Regardless of when the key is included, several naming options could be considered:

- `tilescheme`: Short and descriptive (proposed)
- `tileconfig(uration)`: More explicit but longer
- `tilesetup`: Alternative descriptive name

# Analysis

The `tile` and `tileattribute` keys are fundamental and must always be present to properly identify the tile type and corresponding attribute. The question is whether an additional `tilescheme` dimension is always necessary.

### Examining typical use cases:

- **On-Demand Extremes DT**: Will run with two different tile schemes simultaneously with the same output portfolio. Adding `tilescheme` will allow simultaneous archiving of both sets of data to serve both use cases.
- **CARRA2**: Will run with a single, set tile scheme with a single output portfolio. Adding `tilescheme` would create an extra index dimension with only one value (e.g., `tilescheme=simple` for all data).
- **ECMWF operational forecasting**: Would run with a single, set tile scheme with a single output portfolio. Adding `tilescheme` would create an extra index dimension with only one value (e.g., `tilescheme=simple` for all data).
- **Research and development**: May compare multiple tile schemes side-by-side. In this case the typical experimental workflow can be used running different experiment (`expver`) for different tile schemes.

### Recommendation: Option 2 (Conditional Inclusion)

We recommend including the `tilescheme` key only for datasets where multiple tile configurations genuinely need to be distinguished. This approach:

- Only necessary for on-demand-extremes. IFS & CARRA2 do not need this.
- Keeps operational archives clean and simple
- Avoids unnecessary indexing dimension
- Provides the flexibility to add scheme when projects or datasets require it
- Follows the principle of minimal necessary metadata
- In research/development, different experiments (expvers) can be run to achieve testing different tile schemes.

### Proposed Key Name: `tilescheme`

Among the naming options, `tilescheme` is:

- Concise and clear
- Consistent with existing tile-related key names (`tile`, `tileattribute`)
- Self-documenting (users understand it refers to the tile scheme)
- Shorter than `tileconfiguration` while avoiding ambiguity

The key `tileconfig` also has these properties and so could also be considered.

### Proposed Local Code Table Values:

When `tilescheme` is needed, values:

- **1 (simple)**: Simple tile scheme configuration with most-grouped tiles
- **2 (granular)**: Granular tile scheme configuration with separated tile types
- Additional values reserved for future tile schemes

### Encoding example

An encoding example for 2-metre temperature on the forest grouping tile with aggregated attribute:

```
8-9       productDefinitionTemplateNumber = 113 [Generalised tiles at a horizontal level...]
10        parameterCategory = 0 [Temperature]
11        parameterNumber = 0 [Temperature (K)]
12        tileClassification = 4 [ECOCLIMAP-SG]
13-14     typeOfTile = 1503 [Forest grouping]
15        numberOfUsedSpatialTiles = 7
16        numberOfUsedTileAttributeCombinations = 1
17        numberOfUsedTileAttributes = 1
18        attributeOfTile = 7 [Aggregated]
19        totalNumberOfTileAttributeCombinations = 7
20        tileIndex = 5
21-36     uuidOfDataGroup = [16-byte UUID]
...
```

MARS namespace:

<pre><code>{
  "messages": [
    {
      "domain": "g",
      "date": 20260211,
      "time": 1200,
      "expver": "0001",
      "class": "od",
      "type": "fc",
      "stream": "oper",
      "step": 6,
      "levtype": "sfc",
      <strong>"tile": "gfor",</strong>
      <strong>"tileattribute": "agg",</strong>
      <strong>"tilescheme": "granular",</strong> # On-demand extremes-dt only
      "param": 167
    }
  ]
}
</code></pre>

Note: In this example, `tilescheme=granular` is used because the dataset contains both simple and granular schemes, as will be used in e.g. DestinE on-demand-extremes-dt.

Within the context of the MARS catalogue, the presence of the keywords `tile` and `tileattribute` will be used to create a corresponding `paramtype=tile` entry in the catalogue.

# Decision

Meeting was held on 19/03/2026 to discuss the proposal with:

- Simon Smart
- Emanuele Danovaro
- Manuel Fuentes
- Robert Osinski
- Richard Mladek
- Paul Dando
- Gabriele Arduini

Everyone was happy with the proposal and the recommendations as above, in particular:

- Underscore is acceptable as joining character for attributes.
- Consensus on `tilescheme` as additional key only in DestinE context.
- Happy with construction of tile and tileattribute keys.

We will proceed with the implementation, which will include a modification:

- Lower case for grouping names and attributes.

# Consequences

- Lower case for grouping names and attributes – change in ecCodes
- Changes to metkit language file, enumeration of possible values.
- Changes to metkit axes (no massaging rules whilst traversing axis).
- Changes to FDB schema(s) and build rules.
- C client comparison list of keywords.
- Evaluate need for additional C classes on mars-server side (not expected).



# References

- WMO GRIB2 Issue #191: New section 4 templates for advanced surface tiling <https://github.com/wmo-im/GRIB2/issues/191>
- GRIB2 Code Table 4.252: Type of Tile
- GRIB2 Code Table 4.241: Attribute of Tile
- GRIB2 Code Table 4.242: Tile Classification
- GRIB2 Templates 4.113, 4.114, 4.115, 4.116

# Authors

- Sebastien Villaume
- Matthew Griffith
- Richard Mladek
- Robert Osinski