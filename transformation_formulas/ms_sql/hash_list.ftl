<#macro prefixHandler prefix><#if prefix?? && prefix?length &gt; 0>${prefix}.</#if></#macro>
<#macro castClouse attribute prefix>
    <@compress single_line=true>
        <#if attribute.datatype?? && attribute.datatype?lower_case?contains("char")>
            COALESCE(NULLIF(TRIM(<@prefixHandler prefix/>[${attribute.attributeName}]), ''), '-1')
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
            COALESCE(NULLIF(TRIM(<@prefixHandler prefix/>${attribute.attributeName}.STAsText()),''), '-1')
        <#else>
            COALESCE(NULLIF(TRIM(CAST(<@prefixHandler prefix/>[${attribute.attributeName}] AS VARCHAR)), ''), '-1')
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
<#macro indent level content='' ending=''>
<#local indentSize=4/><#lt><#rt>
${''?left_pad(level*indentSize)}${content?replace('\\s*\\Z', '','r')?replace('(\r\n)+|(\n)+', '\n'?right_pad(level*indentSize+1),'r')}${ending}
</#macro>
<#macro encapsulateValue value><#if value?length &gt;0>[${value?trim}]</#if></#macro>
<#macro cleanSchema schemaName><#if schemaName?? && schemaName?length &gt; 0>${schemaName?replace("\\[|\\]","",'r')}</#if></#macro>
<#macro encapsulateAllParts entity>
    <#local processedEntity="">
    <#list entity?split(".") as entityPart>
        <#local processedEntity>
            <#compress>${processedEntity}<#if !entityPart?is_first>.</#if><@encapsulateValue value=entityPart/></#compress>
        </#local>
    </#list>
    <#if processedEntity?length &gt; 0>
    <#local processedEntity>${processedEntity}.</#local>
    </#if>
    <@compress single_line=true>
    ${processedEntity?replace("^\\s+|\\s+$|\\n|\\r", "", "rm")}
    </@compress>
</#macro>
<#macro entityNameResolver schemaName entityName>
    <@compress single_line=true>
    <@encapsulateAllParts entity=schemaName/><@encapsulateValue value=entityName/>
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
    <#list keyAttributeList as keyAttribute>
        <#local keyAttributeMatch><@castClouse keyAttribute valueListAlias/>=<@castClouse keyAttribute srcEntityAlias/></#local>
        <#local whereCondition += ["${keyAttributeMatch}"]>
    </#list>
    <@whereClause conditions=whereCondition indentation=indentation/>
</#macro>
(
    SELECT LOWER(CONVERT(VARCHAR(32),HASHBYTES('MD5',
    STRING_AGG(<@sourceAttributeList sourceAttributes=sourceAttributes prefix=prefix/>,'~')
    WITHIN GROUP (ORDER BY <@sourceAttributeList sourceAttributes=sourceAttributes prefix=prefix/>)
    ),2))
    FROM <@entityNameResolver schemaName=sourceEntity.owner entityName=sourceEntity.entityName/> value_list
    <@collectWhereClause useBatchLoading=useBatchLoading sourceEntity=sourceEntity loadOptDefined=loadOptDefined loadOpt=loadOpt keyAttributeList=keyAttributeList/>
)