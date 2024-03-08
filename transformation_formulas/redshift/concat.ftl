<#macro prefixHandler prefix><#if prefix?? && prefix?length &gt; 0>${prefix}.</#if></#macro>
<#macro castClouse attribute prefix>
    <@compress single_line=true>
        <#if attribute.datatype?? && attribute.datatype?lower_case?contains("char")>
            NVL(<@prefixHandler prefix/>${attribute.attributeName}, '-1')
        <#elseif attribute.datatype?? && attribute.datatype?lower_case?contains("bool")>
            NVL(CAST(CAST(<@prefixHandler prefix/>${attribute.attributeName} AS INT) AS VARCHAR), '-1')
        <#elseif attribute.datatype?? && attribute.datatype?lower_case?contains("geo")>
            NVL(ST_AsText(<@prefixHandler prefix/>${attribute.attributeName}), '-1')
        <#elseif attribute.datatype?? && attribute.datatype?lower_case == "date">
            NVL(TO_CHAR(<@prefixHandler prefix/>${attribute.attributeName}, 'YYYY-MM-DD'), '-1')
        <#elseif attribute.datatype?? && attribute.datatype?lower_case == "time">
            NVL(TO_CHAR(<@prefixHandler prefix/>${attribute.attributeName}, 'HH24:MI:SS.US'), '-1')
        <#elseif attribute.datatype?? && attribute.datatype?lower_case == "timestamp">
            NVL(TO_CHAR(<@prefixHandler prefix/>${attribute.attributeName}, 'YYYY-MM-DD"T"HH24:MI:SS.US'), '-1')
        <#elseif attribute.datatype?? && attribute.datatype?lower_case == "timestamp_tz">
            NVL(TO_CHAR(<@prefixHandler prefix/>${attribute.attributeName}, 'YYYY-MM-DD"T"HH24:MI:SS.USOF'), '-1')
        <#elseif attribute.datatype?? && attribute.datatype?lower_case == "variant">
            NVL(JSON_SERIALIZE(<@prefixHandler prefix/>${attribute.attributeName}), '-1')
        <#else>
            NVL(CAST(<@prefixHandler prefix/>${attribute.attributeName} AS VARCHAR), '-1')
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
<#if sourceAttributes?size == 0 >
    null
<#elseif sourceAttributes?size == 1 >
    <@prefixHandler prefix/>${sourceAttributes[0].attributeName}
<#else>
    <@sourceAttributeList sourceAttributes=sourceAttributes prefix=prefix />
</#if>