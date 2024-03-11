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

| Type | Description |
| -- | --- |
| CUSTOM | User defined transformation for the attribute in DBMS specific SQL dialect. Can contain environment variables. |
| HASH_KEY | Hash key: case-insensitive, trimmed, empty strings nulled, nulls converted to '-1', datatypes BOOL, DATE, GEOGRAPHY, TIME, TIMESTAMP, TIMESTAMP_TZ converted to an explicit VARCHAR format<sup>*</sup>, concatenated with '~' as separator, hashed with MD5. |
| HASH_DIFF | Comparison hash: case-sensitive, nulls converted to '-1', datatypes BOOL, DATE, GEOGRAPHY, TIME, TIMESTAMP, TIMESTAMP_TZ converted to an explicit VARCHAR format<sup>*</sup>, concatenated with '~' as separator, hashed with MD5. |
| BUSINESS_KEY | Non-hashed key: case-insensitive, trimmed, empty strings nulled, nulls converted to '-1', datatypes BOOL, DATE, GEOGRAPHY, TIME, TIMESTAMP, TIMESTAMP_TZ converted to an explicit VARCHAR format, concatenated with '~' as separator. |
| CONCAT | Concatenation of mapped attributes: case-sensitive, nulls converted to '-1', datatypes BOOL, DATE, GEOGRAPHY, TIME, TIMESTAMP, TIMESTAMP_TZ converted to an explicit VARCHAR format<sup>*</sup>, concatenated with '~' as separator. |
| RUN_ID | Inserts a unique RUN_ID for each transaction. Used with Run ID Logic. |
| CURRENT_TS | Current timestamp, UTC if available. |
| LOAD_NAME | Inserts load name as metadata. |
| PACKAGE_VERSION | Inserts package version as metadata. Allows tracing which package version was installed when rows were inserted. |
| DV_STATUS | Data Vault status satellite activity indicator (1 or 0). |
| DV_RUNNING_ID | DV_RUNNING_ID transformation used in Data Vault multi-active satellites. |
| HASH_LIST | HASH_LIST transformation used in Data Vault multi-active satellites. |
| ST_ASTEXT | GEOGRAPHY/GEOMETRY to WKT format. |
| ST_ASBINARY | GEOGRAPHY/GEOMETRY to WKB format. |
| ST_GEOGFROMTEXT | WKT formatted spatial information to GEOGRAPHY. |
| ST_GEOGFROMWKB | WKB formatted spatial information to GEOGRAPHY. |
| ST_GEOGFROMTEXT_FLAT | WKT format spatial information to GEOMETRY. |
| ST_GEOGFROMWKB_FLAT | WKB formatted spatial information to GEOMETRY. |
| DELETE_TS | Deletion timestamp. |
| HASH | Legacy hash transformation. |
| DV_BUSINESS_KEY | Legacy business key transformation. |

><sup>*</sup>Note that it cannot be guaranteed that the HASH_KEY and HASH_DIFF transformations will produce the same result in all supported target databases even though the string conversion format is explicit. Databases have differences and exceptions in how they handle datatypes and type conversions. Understanding these differences is particularly important when migrating from one database product to another.

Supported target databases:
- Amazon Redshift
- Azure SQL Database
- Azure Synapse SQL
- Databricks SQL
- Google BigQuery
- Microsoft Fabric
- Snowflake

### Load templates

| Template | Description |
| -- | --- |
| PSA_HISTORIZED_BY_DATAHASH_AS_INSERT | Default load template for the PSA entity type. Sets load option OPT_HISTORIZED_BY_DATAHASH_AS_INSERT = true. |

## Transformation formulas

[CONFIG_LOAD_TRANSFORMATIONS](config_packages/config_load_transformations.json) contains load transformation formulas written in FreeMarker syntax. For ease of use, these are also provided separately [here](transformation_formulas/).