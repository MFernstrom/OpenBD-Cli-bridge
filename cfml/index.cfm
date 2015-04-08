<!--- Minimal bridge cfm, for use with the CLI bridge --->
<cftry>
	<cfif structKeyExists( url, "file")>
		<cfsilent>
			<cffile action="read" variable="tf" file="#url.file#">
		</cfsilent>
		<cfoutput>#render(tf)#</cfoutput>
	<cfelseif structKeyExists( url, "version" )>
		<cfoutput>#server.bluedragon.version#</cfoutput>
	</cfif>
	<cfcatch>
		<cfoutput>Error: #cfcatch.message#</cfoutput>
	</cfcatch>
</cftry>