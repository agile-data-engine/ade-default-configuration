<#macro prefixHandler prefix><#if prefix?? && prefix?length &gt; 0>${prefix}.</#if></#macro>
<#macro castClouse attribute prefix>
    <@compress single_line=true>
        <#if attribute.datatype?? && attribute.datatype?lower_case?contains("bool")>
            COALESCE(CAST(CAST(<@prefixHandler prefix/>${attribute.attributeName} AS INT) AS STRING), '-1')
        <#elseif attribute.datatype?? && attribute.datatype?lower_case?contains("char")>
            COALESCE(NULLIF(TRIM(<@prefixHandler prefix/>${attribute.attributeName}), ''), '-1')
        <#elseif attribute.datatype?? && attribute.datatype?lower_case == "date">
            COALESCE(DATE_FORMAT(<@prefixHandler prefix/>${attribute.attributeName}, "yyyy-MM-dd"), '-1')
        <#elseif attribute.datatype?? && attribute.datatype?lower_case == "time">
            COALESCE(DATE_FORMAT(<@prefixHandler prefix/>${attribute.attributeName}, "kk:mm:ss.SSSSSS"), '-1')
        <#elseif attribute.datatype?? && attribute.datatype?lower_case == "timestamp">
            COALESCE(DATE_FORMAT(<@prefixHandler prefix/>${attribute.attributeName}, "yyyy-MM-dd['T']kk:mm:ss.SSSSSS"), '-1')
        <#elseif attribute.datatype?? && attribute.datatype?lower_case == "timestamp_tz">
            COALESCE(DATE_FORMAT(<@prefixHandler prefix/>${attribute.attributeName}, "yyyy-MM-dd['T']kk:mm:ss.SSSSSSxxx"), '-1')
        <#elseif attribute.datatype?? && attribute.datatype?lower_case?contains("array")>
            COALESCE(ARRAY_JOIN(<@prefixHandler prefix/>${attribute.attributeName},','), '-1')
        <#elseif attribute.datatype?? && attribute.datatype?lower_case?contains("struct")>
            COALESCE(TO_JSON(<@prefixHandler prefix/>${attribute.attributeName}), '-1')
        <#else>
            COALESCE(NULLIF(TRIM(CAST(<@prefixHandler prefix/>${attribute.attributeName} AS STRING)), ''), '-1')
        </#if>
    </@compress>
</#macro>
<#macro sourceAttributeList sourceAttributes prefix="">
    <@compress single_line=true>
        <#if sourceAttributes?size == 0 >
            null
        <#else>
            <#list sourceAttributes as attribute><@castClouse attribute prefix/><#if attribute_has_next> || '~' || </#if></#list>
        </#if>
    </@compress>
</#macro>
ROW_NUMBER() OVER (
    PARTITION BY MD5(UPPER(<@sourceAttributeList sourceAttributes=sourceAttributes prefix=prefix/>))
    ORDER BY UPPER(<@sourceAttributeList sourceAttributes=sourceAttributes prefix=prefix/>)
)