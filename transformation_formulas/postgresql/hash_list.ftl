<#macro prefixHandler prefix><#if prefix?? && prefix?length &gt; 0>${prefix}.</#if></#macro>
<#macro castClouse attribute prefix>
    <@compress single_line=true>
        <#if attribute.datatype?? && attribute.datatype?lower_case?contains("char")>
            COALESCE(NULLIF(TRIM(<@prefixHandler prefix/>${attribute.attributeName}), ''), '-1')
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
            COALESCE(NULLIF(TRIM(CAST(<@prefixHandler prefix/>${attribute.attributeName} AS VARCHAR)), ''), '-1')
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
<#function loadOptWhereCondition loadOptDefined loadOpt >
    <#if loadOptDefined("OPT_WHERE")>
        <#return ["${loadOpt(\"OPT_WHERE\")}"]>
    </#if>
    <#return []>
</#function>
<#function batchCondition useBatchLoading sourceEntity prefix="">
    <#if useBatchLoading>
        <#local batchHandling><#if prefix?length &gt; 0>${prefix}.</#if><sourcerunidattr></#local>
        <#if sourceEntity.containsRunIdAttribute>
            <#local batchHandling><#if prefix?length &gt; 0>${prefix}.</#if>[${sourceEntity.runIdAttributeName}]</#local>
        </#if>
        <#return ["${batchHandling} IN (<loadablerunids>)"]>
    </#if>
    <#return []>
</#function>
<#function batchAndWhereCondition useBatchLoading sourceEntity loadOptDefined loadOpt prefix="">
    <#local whereCondition = batchCondition(useBatchLoading sourceEntity prefix)/>
    <#local whereCondition += loadOptWhereCondition(loadOptDefined loadOpt)>
    <#return whereCondition>
</#function>
<#macro whereClause conditions indentation=0 >
    <#if conditions?has_content>
        <@indent level=indentation content="WHERE" />
        <#list conditions as condition>
            <@indent level=indentation+1 content="${condition?is_first?then('', 'AND\n')}${condition}" />
        </#list>
    </#if>
</#macro>
<#macro collectWhereClause useBatchLoading sourceEntity loadOptDefined loadOpt keyAttributeList>
    <#local valueListAlias="value_list">
    <#local srcEntityAlias="src_entity">
    <#local whereCondition=batchAndWhereCondition(useBatchLoading sourceEntity loadOptDefined loadOpt valueListAlias)>
    <#if keyAttributeList?has_content>
        <#list keyAttributeList as keyAttribute>
            <#local keyAttributeMatch><@castClouse keyAttribute valueListAlias/>=<@castClouse keyAttribute srcEntityAlias/></#local>
            <#local whereCondition += ["${keyAttributeMatch}"]>
        </#list>
    </#if>
    <@whereClause conditions=whereCondition indentation=indentation/>
</#macro>
<#macro indent level content='' ending=''>
<#local indentSize=4/><#lt><#rt>
${''?left_pad(level*indentSize)}${content?replace('\\s*\\Z', '','r')?replace('(\r\n)+|(\n)+', '\n'?right_pad(level*indentSize+1),'r')}${ending}
</#macro>
(
 	SELECT MD5(
    STRING_AGG(<@sourceAttributeList sourceAttributes=sourceAttributes prefix=prefix/>,'~'
    ORDER BY <@sourceAttributeList sourceAttributes=sourceAttributes prefix=prefix/>)
 )
 FROM ${sourceEntity.owner}.${sourceEntity.entityName} value_list
 <@collectWhereClause useBatchLoading=useBatchLoading sourceEntity=sourceEntity loadOptDefined=loadOptDefined loadOpt=loadOpt keyAttributeList=keyAttributeList/>
)