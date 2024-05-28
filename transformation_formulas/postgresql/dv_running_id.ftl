<#macro prefixHandler prefix><#if prefix?? && prefix?length &gt; 0>${prefix}.</#if></#macro>
<#macro castClouse attribute prefix>
    <@compress single_line=true>
        <#if attribute.datatype?? && attribute.datatype?lower_case?contains("char")>
            COALESCE(<@prefixHandler prefix/>${attribute.attributeName}, '-1')
        <#elseif attribute.datatype?? && attribute.datatype?lower_case?contains("bool")>
            COALESCE(CAST(CAST(<@prefixHandler prefix/>${attribute.attributeName} AS INT) AS VARCHAR), '-1')
        <#elseif attribute.datatype?? && attribute.datatype?lower_case == "date">
            COALESCE(TO_CHAR(<@prefixHandler prefix/>${attribute.attributeName}, 'YYYY-MM-DD'), '-1')
        <#elseif attribute.datatype?? && attribute.datatype?lower_case == "time">
            COALESCE(TO_CHAR(<@prefixHandler prefix/>${attribute.attributeName}, 'HH24:MI:SS.US'), '-1')
        <#elseif attribute.datatype?? && attribute.datatype?lower_case == "timestamp">
            COALESCE(TO_CHAR(<@prefixHandler prefix/>${attribute.attributeName}, 'YYYY-MM-DD"T"HH24:MI:SS.US'), '-1')
        <#elseif attribute.datatype?? && attribute.datatype?lower_case == "timestamp_tz">
            COALESCE(TO_CHAR(<@prefixHandler prefix/>${attribute.attributeName}, 'YYYY-MM-DD"T"HH24:MI:SS.USOF'), '-1')
        <#else>
            COALESCE(CAST(<@prefixHandler prefix/>${attribute.attributeName} AS VARCHAR), '-1')
        </#if>
    </@compress>
</#macro>
<#macro sourceAttributeList sourceAttributes prefix="">
    <@compress single_line=true>
        <#if sourceAttributes?has_content>
            <#list sourceAttributes as attribute><@castClouse attribute prefix/><#if attribute_has_next> || '~' || </#if></#list>
        <#else>
            null
        </#if>
    </@compress>
</#macro>
<#if sourceAttributes?has_content>
    <#if sourceAttributes?size == 1 >
        <@prefixHandler prefix/>${sourceAttributes[0].attributeName}
    <#else>
        <@sourceAttributeList sourceAttributes=sourceAttributes prefix=prefix />
    </#if>
<#else>
    null
</#if>