<#macro prefixHandler prefix><#if prefix?? && prefix?length &gt; 0>${prefix}.</#if></#macro>
<#macro castClouse attribute prefix>
    <#if attribute.datatype?? && attribute.datatype?lower_case?contains("bool")>
        CASE WHEN ${attribute.attributeName} IS NULL THEN '-1' ELSE IFF(<@prefixHandler prefix/>${attribute.attributeName}, '1','0') END
    <#elseif attribute.datatype?? && attribute.datatype?lower_case?contains("char")>
        NVL(<@prefixHandler prefix/>${attribute.attributeName}, '-1')
    <#elseif attribute.datatype?? && attribute.datatype?lower_case == "date">
        NVL(TO_VARCHAR(<@prefixHandler prefix/>${attribute.attributeName}, 'YYYY-MM-DD'), '-1')
    <#elseif attribute.datatype?? && attribute.datatype?lower_case?contains("geography")>
        CASE WHEN ${attribute.attributeName} IS NULL THEN '-1' ELSE st_astext(<@prefixHandler prefix/>${attribute.attributeName}) END
    <#elseif attribute.datatype?? && attribute.datatype?lower_case == "time">
        NVL(TO_VARCHAR(<@prefixHandler prefix/>${attribute.attributeName}, 'HH24:MI:SS.FF6'), '-1')
    <#elseif attribute.datatype?? && attribute.datatype?lower_case == "timestamp">
        NVL(TO_VARCHAR(<@prefixHandler prefix/>${attribute.attributeName}, 'YYYY-MM-DDTHH24:MI:SS.FF6'), '-1')
    <#elseif attribute.datatype?? && attribute.datatype?lower_case == "timestamp_tz">
        NVL(TO_VARCHAR(<@prefixHandler prefix/>${attribute.attributeName}, 'YYYY-MM-DDTHH24:MI:SS.FF6TZH:TZM'), '-1')
    <#elseif attribute.datatype?? && attribute.datatype?lower_case?contains("array")>
        NVL(ARRAY_TO_STRING(<@prefixHandler prefix/>${attribute.attributeName},','), '-1')
    <#else>
        NVL(CAST(<@prefixHandler prefix/>${attribute.attributeName} AS VARCHAR), '-1')
    </#if>
</#macro>
<#macro sourceAttributeList sourceAttributes prefix>
    <@compress single_line=true>
    <#if sourceAttributes?size == 0>
        null
    <#else>
        <#list sourceAttributes as attribute><@castClouse attribute prefix/><#if attribute_has_next> || '~' || </#if></#list>
    </#if>
    </@compress>
</#macro>
MD5(<@sourceAttributeList sourceAttributes=sourceAttributes prefix=prefix/>)