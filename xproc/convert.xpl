<p:declare-step version="1.0" 
	name="australian-generations"
	type="nla:australian-generations"
	xmlns:p="http://www.w3.org/ns/xproc" 
	xmlns:c="http://www.w3.org/ns/xproc-step" 
	xmlns:cx="http://xmlcalabash.com/ns/extensions"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:nla="tag:conaltuohy.com,2015:nla"
	xmlns:zotero="tag:conaltuohy.com,2015:zotero"
	xmlns:j="http://marklogic.com/json"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:ead="urn:isbn:1-931666-22-9"
	xmlns:html="http://www.w3.org/1999/xhtml">
	<p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
	
	<p:input port="parameters" kind="parameter"/><!-- may contain "key" parameter -->
	<p:option name="output-file" select="ead.xml"/><!-- e.g. "ead.xml" -->
	<p:option name="country-code" select=" 'AU' "/><!-- e.g. "AU" -->
	<p:option name="library" select=" 'groups/83731' "/><!-- URI relative to Zotero website e.g. "groups/83731" -->
	
	<!-- https://www.zotero.org/support/dev/web_api/v3/basics#user_and_group_library_urls -->

	<!-- Retrieve the library in Zotero JSON format, converted to MarkLogic JSON-XML -->
	<!--
	<zotero:get-library name="zotero">
		<p:with-option name="library" select="$library"/>
	</zotero:get-library>
	-->
	<p:load name="zotero" href="../../library.xml"/>

	<!-- Transform to EAD -->
	<cx:message message="Transforming Zotero library to EAD ..."/>
	<p:xslt>
		<p:with-param name="country-code" select="$country-code"/>
		<p:with-param name="identifier" select="$output-file"/>
		<p:input port="parameters">
			<p:empty/>
		</p:input>
		<p:input port="stylesheet">
			<p:document href="zotero-library-to-ead.xsl"/>
		</p:input>
	</p:xslt>
	<cx:message message="Transformation complete"/>
	
	<!-- Save embedded Zotero notes as html files -->
	<cx:message message="Moving HTML notes into separate files ..."/>
	<p:viewport match="ead:dao[starts-with(@xlink:href, 'data:text/html;charset=utf-8,')]" name="dao-with-data-uri">
		<p:variable name="filename" select="concat('notes/', lower-case(/ead:dao/@entityref), '.html')"/>
		<!-- decode the URL-encoded HTML -->
		<p:www-form-urldecode name="content">
			<p:with-option name="value" select="
				concat(
					'content=',
					substring-after(/ead:dao/@xlink:href, 'data:text/html;charset=utf-8,')
				)
			"/>
		</p:www-form-urldecode>
		<!-- copy the value of the HTML into an element -->
		<p:template>
			<p:input port="parameters"><p:empty/></p:input>
			<p:input port="template">
				<p:inline>
					<content>{string(/c:param-set/c:param[@name='content']/@value)}</content>
				</p:inline>
			</p:input>
		</p:template>
		<!-- parse the HTML contained in the <content> element and discard the wrapper <content> -->
		<p:unescape-markup content-type="text/html"/>
		<p:unwrap match="/content"/>
		<p:xslt name="repair-html">
			<p:input port="parameters"><p:empty/></p:input>
			<p:input port="stylesheet">
				<p:document href="repair-html.xsl"/>
			</p:input>
		</p:xslt>
		<p:store method="xhtml" doctype-system="html">
			<p:with-option name="href" select="concat('../../', $filename)"/>
		</p:store>
		<p:add-attribute match="/ead:dao" attribute-name="xlink:href">
			<p:with-option name="attribute-value" select="$filename"/>
			<p:input port="source">
				<p:pipe step="dao-with-data-uri" port="current"/>
			</p:input>
		</p:add-attribute>
		<p:delete match="/ead:dao/@entityref"/>
	</p:viewport>

	<!-- Save EAD -->
	<p:store>
		<p:with-option name="href" select="concat('../../', $output-file)"/>
	</p:store>
	
	<!-- temporary files output for debugging / development purposes -->
	
	<!-- a sample -->
	<p:xslt>
		<p:input port="source">
			<p:pipe step="zotero" port="result"/>
		</p:input>
		<p:input port="parameters">
			<p:empty/>
		</p:input>
		<p:input port="stylesheet">
			<p:document href="make-sample.xsl"/>
		</p:input>
	</p:xslt>
	<p:store href="../sample.xml"/>
	
	<!-- a sample -->
	<p:xslt>
		<p:input port="source">
			<p:pipe step="zotero" port="result"/>
		</p:input>
		<p:input port="parameters">
			<p:empty/>
		</p:input>
		<p:input port="stylesheet">
			<p:document href="make-sample.xsl"/>
		</p:input>
	</p:xslt>
	<p:store href="../../sample.xml"/>

	<!-- the full library -->
	<p:store href="../../library.xml">
		<p:input port="source">
			<p:pipe step="zotero" port="result"/>
		</p:input>
	</p:store>
	
	<!-- Retrieve a full Zotero library -->
	<p:declare-step name="get-library" type="zotero:get-library">
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result"/>
		<p:option name="library" required="true"/><!-- e.g. "groups/83731" -->
		<cx:message message="Reading Zotero library...">
			<p:input port="source"><p:empty/></p:input>
		</cx:message>
		<cx:message message="Reading collections..."/>
		<zotero:list>
			<p:with-option name="href" select="
				concat('https://api.zotero.org/', $library, '/collections?start=0&amp;limit=100&amp;format=json&amp;v=3')
			"/>
		</zotero:list>
		<p:wrap-sequence wrapper="collections" name="collections"/>
		<cx:message message="Reading items..."/>
		<zotero:list >
			<p:with-option name="href" select="
				concat('https://api.zotero.org/', $library, '/items?start=0&amp;limit=100&amp;format=json&amp;v=3')
			"/>
		</zotero:list>
		<p:wrap-sequence wrapper="items" name="items"/>
		<p:wrap-sequence wrapper="library">
			<p:input port="source">
				<p:pipe step="collections" port="result"/>
				<p:pipe step="items" port="result"/>
			</p:input>
		</p:wrap-sequence>
		<cx:message message="Finished reading Zotero library"/>
	</p:declare-step>
	
	<!-- List the elements of an array of items or collections from the Zotero web API -->
	<!-- This step generates and unwraps a sequence of c:response documents, producing a sequence of j:item documents -->
	<p:declare-step name="list" type="zotero:list">
		<p:option name="href" required="true"/>
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result" sequence="true"/>
		<zotero:list-responses name="all-partial-lists">
			<p:with-option name="href" select="$href"/>
		</zotero:list-responses>
		<p:for-each name="items">
			<p:iteration-source select="/c:response/c:body/j:json/j:item"/>
			<p:identity name="item"/>
		</p:for-each>
	</p:declare-step>
	
	<!-- List the sequence of HTTP responses which exhaust a list of Zotero items or collections -->
	<!-- This step produces a sequence of c:response objects -->
	<p:declare-step name="list-responses" type="zotero:list-responses">
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result" sequence="true">
			<p:pipe step="initial-request" port="result"/>
			<p:pipe step="subsequent-items" port="result"/>
		</p:output>
		<p:option name="href" required="true"/>
		<cx:message message="Requesting list...">
			<p:input port="source"><p:empty/></p:input>
		</cx:message>
		<!-- make initial request -->
		<zotero:request name="initial-request">
			<p:with-option name="href" select="$href"/>
		</zotero:request>
		<!-- recursively make a request for the remainder of the list -->
		<p:group name="subsequent-items">
			<p:output port="result" sequence="true"/>
			<p:variable name="quote" select="codepoints-to-string(34)"/>
			<p:variable name="next-link" select="concat('&gt;; rel=', $quote, 'next', $quote)"/>
			<p:for-each name="next-request">
				<p:iteration-source select="/c:response/c:header[@name='Link'][contains(@value, $next-link)]"/>
				<zotero:list-responses>
					<p:with-option name="href" select="substring-before(substring-after(/c:header/@value, '&lt;'), $next-link)"/>
				</zotero:list-responses>
			</p:for-each>
		</p:group>
	</p:declare-step>
	
	<p:declare-step name="parse-link-header" type="zotero:parse-link-header">
		<p:input port="source"/>
		<p:output port="result"/>
		<p:xslt>
			<p:input port="parameters">
				<p:empty/>
			</p:input>
			<p:input port="stylesheet">
				<p:inline>
					<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:c="http://www.w3.org/ns/xproc-step">
						<xsl:template match="*">
							<xsl:copy>
								<xsl:copy-of select="@*"/>
								<xsl:apply-templates/>
							</xsl:copy>
						</xsl:template>
						<xsl:template match="c:header[@name='Link']">
							<!-- break link header with multiple parts into single headers -->
							<xsl:analyze-string select="@value" regex="([^,]+)">
								<xsl:matching-substring>
									<c:header name="Link" value="{normalize-space(regex-group(1))}"/>
								</xsl:matching-substring>
							</xsl:analyze-string>
						</xsl:template>
					</xsl:stylesheet>
				</p:inline>
			</p:input>
		</p:xslt>
	</p:declare-step>
	
	<p:declare-step name="request" type="zotero:request">
		<p:input port="parameters" kind="parameter"/>
		<p:output port="result"/>
		<p:option name="href" required="true"/>
		<p:template>
			<p:input port="parameters">
				<p:pipe step="request" port="parameters"/>
			</p:input>
			<p:with-param name="href" select="$href"/>
			<p:input port="source">
				<p:empty/>
			</p:input>
			<p:input port="template">
				<p:inline>
					<c:request detailed="true" method="GET" href="{$href}">
						<c:header name="Authorization" value="Bearer {$key}"/>
					</c:request>
				</p:inline>
			</p:input>
		</p:template>
		<p:http-request/>
		<zotero:parse-link-header/>
		<p:viewport match="/c:response/c:body[@content-type='application/json'][@encoding='base64']">
			<p:unescape-markup content-type="application/json" encoding="base64" charset="UTF-8"/>
		</p:viewport>
		<!-- discard empty JSON objects -->
		<p:delete match="j:*[not(normalize-space())]"/>
	</p:declare-step>
		
</p:declare-step>
	
