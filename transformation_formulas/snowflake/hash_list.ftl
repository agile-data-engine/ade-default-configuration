<#macro prefixHandler prefix><#if prefix?? && prefix?length &gt; 0>${prefix}.</#if></#macro>
<#function resolveAttributePosition sourceEntity="" attributeName="">
    <#local order=0>
    <#if sourceEntity?has_content && sourceEntity.attributes??>
        <#list sourceEntity.attributes as attribute>
            <#if attribute.attributeName == attributeName && attribute.position??>
                <#local order=attribute.position>
                <#break>
            </#if>
        </#list>
    </#if>
    <#return "${'$'}"+order>
</#function>
<#function resolveAttributeDataTypeFromVariant sourceEntity="" attributeName="">
    <#local attribute=''>
    <#if sourceEntity?has_content && sourceEntity.attributes??>
        <#list sourceEntity.attributes as sourceAttribute>
            <#if sourceAttribute.attributeName == attributeName>
                <#local attribute=sourceAttribute>
                <#break>
            </#if>
        </#list>
    <#else>
        <#return null>    
    </#if>
    <#local attribute_reference>GET_IGNORE_CASE(${'$'}1, '${attribute.attributeName}')</#local>
    <#local realOrDouble = ["REAL","DOUBLE"]>
    <#local attribute_result>
    <@compress single_line=true>
    <#if attribute.datatype?? && attribute.datatype = "BOOLEAN">
        TO_BOOLEAN(${attribute_reference})
    <#elseif attribute.datatype?? && attribute.datatype = "BINARY">
        TO_GEOMETRY(${attribute_reference})
    <#elseif attribute.datatype?? && attribute.datatype = "GEOMETRY">
        TO_GEOGRAPHY(${attribute_reference})
    <#elseif attribute.datatype?? && attribute.datatype = "GEOGRAPHY">
        TO_BINARY(${attribute_reference})
    <#elseif attribute.datatype?? && attribute.datatype = "DECIMAL">
        TO_DECIMAL(${attribute_reference},${attribute.dataPrecision!-1},${attribute.dataScale!-1})
    <#elseif attribute.datatype?? && attribute.datatype?lower_case?contains("integer")>
        TO_INTEGER(${attribute_reference})
    <#elseif attribute.datatype?? && attribute.datatype?lower_case?contains("char")>
        TO_VARCHAR(${attribute_reference})
    <#elseif attribute.datatype?? && attribute.datatype = "DATE">
        TO_DATE(${attribute_reference})
    <#elseif attribute.datatype?? && attribute.datatype = "TIME">
        TO_TIME(${attribute_reference})
    <#elseif attribute.datatype?? && attribute.datatype = "TIMESTAMP">
        TO_TIMESTAMP_NTZ(${attribute_reference})
    <#elseif attribute.datatype?? && attribute.datatype = "TIMESTAMP_TZ">
        TO_TIMESTAMP_TZ(${attribute_reference})
    <#elseif attribute.datatype?? && attribute.datatype = "TIMESTAMP_LTZ">
        TO_TIMESTAMP_LTZ(${attribute_reference})
    <#elseif attribute.datatype?? && realOrDouble?seq_contains(attribute.datatype)>
        TO_DOUBLE(${attribute_reference})
    <#elseif attribute.datatype?? && attribute.datatype = "ARRAY">
        TO_ARRAY(${attribute_reference})
    <#elseif attribute.datatype?? && attribute.datatype = "OBJECT">
        TO_OBJECT(${attribute_reference})
    <#else>
        ${attribute_reference}
    </#if>
    </@compress>
    </#local>
    <#return attribute_result>
</#function>
<#macro castClouse attribute prefix sourceEntity="" use_positions=false ext_table_parquet_creation=false>
    <#local attribute_reference=attribute.attributeName>
    <#if use_positions && sourceEntity?has_content>
        <#local attribute_reference=resolveAttributePosition(sourceEntity attribute.attributeName)>
    </#if>
    <#if ext_table_parquet_creation && sourceEntity?has_content>
        <#local attribute_reference=resolveAttributeDataTypeFromVariant(sourceEntity attribute.attributeName)>
    </#if>
    <#if attribute.datatype?? && attribute.datatype?lower_case?contains("bool")>
        CASE WHEN ${attribute_reference} IS NULL THEN '-1' ELSE IFF(<@prefixHandler prefix/>${attribute_reference}, '1','0') END
    <#elseif attribute.datatype?? && attribute.datatype?lower_case?contains("char")>
        NVL(NULLIF(TRIM(<@prefixHandler prefix/>${attribute_reference}), ''), '-1')
    <#elseif attribute.datatype?? && attribute.datatype?lower_case == "date">
        NVL(TO_VARCHAR(<@prefixHandler prefix/>${attribute_reference}, 'YYYY-MM-DD'), '-1')
    <#elseif attribute.datatype?? && attribute.datatype?lower_case?contains("geography")>
        CASE WHEN ${attribute_reference} IS NULL THEN '-1' ELSE st_astext(<@prefixHandler prefix/>${attribute_reference}) END
    <#elseif attribute.datatype?? && attribute.datatype?lower_case == "time">
        NVL(TO_VARCHAR(<@prefixHandler prefix/>${attribute_reference}, 'HH24:MI:SS.FF6'), '-1')
    <#elseif attribute.datatype?? && attribute.datatype?lower_case == "timestamp">
        NVL(TO_VARCHAR(<@prefixHandler prefix/>${attribute_reference}, 'YYYY-MM-DDTHH24:MI:SS.FF6'), '-1')
    <#elseif attribute.datatype?? && attribute.datatype?lower_case == "timestamp_tz">
        NVL(TO_VARCHAR(<@prefixHandler prefix/>${attribute_reference}, 'YYYY-MM-DDTHH24:MI:SS.FF6TZH:TZM'), '-1')
    <#elseif attribute.datatype?? && attribute.datatype?lower_case?contains("array")>
        NVL(ARRAY_TO_STRING(<@prefixHandler prefix/>${attribute_reference},','), '-1')
    <#else>
        NVL(NULLIF(TRIM(CAST(<@prefixHandler prefix/>${attribute_reference} AS VARCHAR)), ''), '-1')
    </#if>
</#macro>
<#macro sourceAttributeList sourceAttributes prefix sourceEntity="" use_positions=false ext_table_parquet_creation=false>
    <@compress single_line=true>
    <#if sourceAttributes?size == 0>
        null
    <#else>
        <#list sourceAttributes as attribute><@castClouse attribute prefix sourceEntity use_positions ext_table_parquet_creation/><#if attribute_has_next> || '~' || </#if></#list>
    </@compress>
</#macro>
MD5(LISTAGG(<@sourceAttributeList sourceAttributes=sourceAttributes prefix=prefix sourceEntity=sourceEntity!"" use_positions=use_positions!false ext_table_parquet_creation=ext_table_parquet_creation!false/>, '~')
    WITHIN GROUP (ORDER BY <@sourceAttributeList sourceAttributes=sourceAttributes prefix=prefix sourceEntity=sourceEntity!"" use_positions=use_positions!false ext_table_parquet_creation=ext_table_parquet_creation!false/> )
    OVER (PARTITION BY <@sourceAttributeList sourceAttributes=keyAttributeList prefix=prefix sourceEntity=sourceEntity!"" use_positions=use_positions!false ext_table_parquet_creation=ext_table_parquet_creation!false/> ))