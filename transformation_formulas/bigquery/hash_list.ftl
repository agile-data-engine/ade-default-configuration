<#import "/BIGQUERY/common/transformation/generic/cast_attribute.ftl" as attribute_cast>
TO_HEX(MD5(STRING_AGG(<@attribute_cast.adeSourceAttributeList sourceAttributes=sourceAttributes prefix=prefix physicalDatatype=physicalDatatype/>, '~')
OVER (PARTITION BY <@attribute_cast.adeSourceAttributeList sourceAttributes=keyAttributeList prefix=prefix physicalDatatype=physicalDatatype/>
ORDER BY <@attribute_cast.adeSourceAttributeList sourceAttributes=sourceAttributes prefix=prefix physicalDatatype=physicalDatatype/>
ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)))
