# Default configuration for Agile Data Engine

This repository contains default ADE configuration packages and load transformation formulas.

See [ADE documentation](https://docs.agiledataengine.com/docs/configuring-ade) for more information and instructions about configuring ADE.

**Be careful when making changes to configurations on an existing solution.**

## Configuration packages

- [CONFIG_LOAD_TRANSFORMATIONS](config_packages/config_load_transformations.json)
- [CONFIG_ENTITY_DEFAULTS](config_packages/config_entity_defaults.json)
- [CONFIG_LOAD_TEMPLATES](config_packages/config_load_templates.json)

### Entity types

| Type | Default schema | Default physical type | Prefix | Suffix | Description |
| -- | --- | --- | --- | ---| ---|
| BRIDGE | bdv | TABLE | B_ | | Bridge entity |
| DIM | publish | TABLE | D_ | | Dimension entity |
| FACT | publish | TABLE | F_ | | Fact entity |
| FLAT | publish | TABLE | FL_ | | Flat entity |
| GENERIC | publish | TABLE | | | Generic entity |
| HUB | rdv | TABLE | H_ | | Hub entity |
| LINK | rdv | TABLE | L_ | | Link entity |
| LOGICAL | logical | METADATA_ONLY | | | Logical model entity |
| PIT | bdv | TABLE | P_ | | Point-in-time entity |
| PSA | dw | TABLE | PSA_ | | Persistent staging entity |
| REF | rdv | TABLE | R_ | | Reference entity |
| SAT | rdv | TABLE | S_ | | Satellite entity |
| SAT_C | rdv | VIEW | S_ | _C | Satellite current view |
| SAT_MA | rdv | TABLE | S_MA_ | | Multi-active satellite entity |
| SAT_MA_C | rdv | VIEW | S_MA_ | _C | Multi-active satellite current view |
| SOURCE | src | METADATA_ONLY | | | Source entity |
| STAGE | staging | TABLE | STG_ | | Staging entity |
| S_SAT | bdv | TABLE | STS_ | | Status satellite entity |
| S_SAT_C | bdv | VIEW | STS_ | _C | Status satellite current view |


### Transformation types
...

### Load templates
...

## Transformation formulas
[CONFIG_LOAD_TRANSFORMATIONS](config_packages/config_load_transformations.json) contains load transformation formulas written in FreeMarker syntax. For ease of use, these are also provided separately [here](transformation_formulas/).