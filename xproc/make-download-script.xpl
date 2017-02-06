<p:declare-step version="1.0" 
	name="make-download-script"
	type="nla:make-download-script"
	xmlns:p="http://www.w3.org/ns/xproc" 
	xmlns:c="http://www.w3.org/ns/xproc-step" 
	xmlns:cx="http://xmlcalabash.com/ns/extensions"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:nla="tag:conaltuohy.com,2015:nla"
	xmlns:zotero="tag:conaltuohy.com,2015:zotero"
	xmlns:j="http://marklogic.com/json"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:html="http://www.w3.org/1999/xhtml">
	
	<p:input port="parameters" kind="parameter"/><!-- contains "key" parameter -->

	<p:load href="../../australian-generations-ead.xml"/>	
	<p:xslt>
		<p:input port="stylesheet">
			<p:document href="ead-to-download-script.xsl"/>
		</p:input>
	</p:xslt>
	<p:store href="../../download-dao.sh" method="text"/>
		
</p:declare-step>
	
