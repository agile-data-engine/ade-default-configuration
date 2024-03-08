<#macro prefixHandler prefix><#if prefix?? && prefix?length &gt; 0>${prefix}.</#if></#macro>
<#macro castClouse attribute prefix>
    <@compress single_line=true>
        <#if attribute.datatype?? && (attribute.datatype?lower_case == "char" || attribute.datatype?lower_case == "nchar")>
            COALESCE(TRIM(<@prefixHandler prefix/>[${attribute.attributeName}]), '-1')
        <#elseif attribute.datatype?? && attribute.datatype?lower_case?contains("varchar")>
            COALESCE(<@prefixHandler prefix/>[${attribute.attributeName}], '-1')
        <#elseif attribute.datatype?? && attribute.datatype?lower_case?contains("bool")>
            COALESCE(CAST(CAST(<@prefixHandler prefix/>[${attribute.attributeName}] AS INT) AS VARCHAR), '-1')
        <#elseif attribute.datatype?? && attribute.datatype?lower_case == "date">
            COALESCE(FORMAT(<@prefixHandler prefix/>${attribute.attributeName}, 'yyyy-MM-dd'), '-1')
        <#elseif attribute.datatype?? && attribute.datatype?lower_case == "time">
            COALESCE(FORMAT(<@prefixHandler prefix/>${attribute.attributeName}, 'hh\:mm\:ss\.FFFFFF'), '-1')
        <#elseif attribute.datatype?? && attribute.datatype?lower_case == "timestamp">
            COALESCE(FORMAT(<@prefixHandler prefix/>${attribute.attributeName}, 'yyyy-MM-ddTHH:mm:ss.FFFFFF'), '-1')
        <#elseif attribute.datatype?? && attribute.datatype?lower_case == "timestamp_tz">
            COALESCE(FORMAT(<@prefixHandler prefix/>${attribute.attributeName}, 'yyyy-MM-ddTHH:mm:ss.FFFFFFzzz'), '-1')
        <#elseif attribute.datatype?? && attribute.datatype?lower_case == "geography">
            COALESCE(<@prefixHandler prefix/>${attribute.attributeName}.STAsText(), '-1')
        <#else>
            COALESCE(CAST(<@prefixHandler prefix/>[${attribute.attributeName}] AS VARCHAR), '-1')
        </#if>
    </@compress>
</#macro>
<#macro sourceAttributeList sourceAttributes prefix="">
    <@compress single_line=true>
        <#if sourceAttributes?size == 0 >
            null
        <#else>
            <#list sourceAttributes as attribute><@castClouse attribute prefix/><#if attribute_has_next> + '~' + </#if></#list>
        </#if>
    </@compress>
</#macro>
<#if sourceAttributes?size == 0 >
    null
<#elseif sourceAttributes?size == 1 >
    <@prefixHandler prefix/>[${sourceAttributes[0].attributeName}]
<#else>
    <@sourceAttributeList sourceAttributes=sourceAttributes prefix=prefix />
</#if>