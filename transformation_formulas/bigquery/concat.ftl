<#macro prefixHandler prefix><#if prefix?? && prefix?length &gt; 0>${prefix}.</#if></#macro>
<#macro castClouse attribute prefix>
    <#if attribute.datatype?? && attribute.datatype?lower_case?contains("bool")>
        COALESCE(CAST(CAST(<@prefixHandler prefix/>${attribute.attributeName} AS INT64) AS STRING), '-1')
    <#elseif attribute.datatype?? && attribute.datatype?lower_case?contains("char")>
        COALESCE(<@prefixHandler prefix/>${attribute.attributeName}, '-1')
    <#elseif attribute.datatype?? && attribute.datatype?lower_case?contains("geography")>
        COALESCE(ST_ASTEXT(<@prefixHandler prefix/>${attribute.attributeName}), '-1')
    <#elseif attribute.datatype?? && attribute.datatype?lower_case?contains("json")>
        COALESCE(NULLIF(TO_JSON_STRING(<@prefixHandler prefix/>${attribute.attributeName}), 'null'), '-1')
    <#elseif attribute.datatype?? && attribute.datatype?lower_case == "date">
        COALESCE(FORMAT_DATE('%Y-%m-%d',<@prefixHandler prefix/>${attribute.attributeName}), '-1')
    <#elseif attribute.datatype?? && attribute.datatype?lower_case == "time">
        COALESCE(FORMAT_TIME('%H:%M:%E6S',<@prefixHandler prefix/>${attribute.attributeName}), '-1')
    <#elseif attribute.datatype?? && attribute.datatype?lower_case == "timestamp_tz">
        COALESCE(FORMAT_TIMESTAMP('%Y-%m-%dT%H:%M:%E6S%Ez', <@prefixHandler prefix/>${attribute.attributeName}), '-1')
    <#elseif attribute.datatype?? && attribute.datatype?lower_case == "timestamp">
        COALESCE(FORMAT_DATETIME('%Y-%m-%dT%H:%M:%E6S', <@prefixHandler prefix/>${attribute.attributeName}), '-1')
    <#elseif attribute.datatype?? && attribute.datatype?lower_case == "decimal">
        COALESCE(TRIM(FORMAT('%${attribute.dataPrecision}.${attribute.dataScale}f', <@prefixHandler prefix/>${attribute.attributeName})), '-1')       
    <#elseif attribute.datatype?? && attribute.datatype?lower_case?contains("array")>
        COALESCE(NULLIF(ARRAY_TO_STRING(<@prefixHandler prefix/>${attribute.attributeName},','),''), '-1')
    <#elseif attribute.datatype?? && attribute.datatype?lower_case?contains("struct")>
        COALESCE(NULLIF(TO_JSON_STRING(TO_JSON(<@prefixHandler prefix/>${attribute.attributeName})), 'null'), '-1')
    <#elseif attribute.datatype?? && attribute.datatype?lower_case?contains("variant")>
        COALESCE(NULLIF(TO_JSON_STRING(<@prefixHandler prefix/>${attribute.attributeName}), 'null'), '-1')
    <#else>
        COALESCE(CAST(<@prefixHandler prefix/>${attribute.attributeName} AS STRING), '-1')
    </#if>
</#macro>
<#macro sourceAttributeList sourceAttributes prefix="" physicalDatatype="">
    <@compress single_line=true>
        <#if sourceAttributes?size == 0 && physicalDatatype?has_content>
            CAST(null AS ${physicalDatatype})
        <#elseif sourceAttributes?size == 0 >
            null
        <#elseif sourceAttributes?size == 1 >
            <@castClouse sourceAttributes[0] prefix/>
        <#else>
            CONCAT(<#list sourceAttributes as attribute><@castClouse attribute prefix/><#if attribute_has_next>,'~',</#if></#list>)
        </#if>
    </@compress>
</#macro>
<#if sourceAttributes?size == 0 && physicalDatatype?has_content>
cast(null AS ${physicalDatatype})
<#elseif sourceAttributes?size == 0>
null
<#elseif sourceAttributes?size == 1 >
<@prefixHandler prefix/>${sourceAttributes[0].attributeName}
<#else>
<@sourceAttributeList sourceAttributes=sourceAttributes prefix=prefix physicalDatatype=physicalDatatype/>
</#if>