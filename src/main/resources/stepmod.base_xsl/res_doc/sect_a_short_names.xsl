<?xml version="1.0" encoding="utf-8"?>
<!-- <?xml-stylesheet type="text/xsl" href="./document_xsl.xsl" ?> -->

<!--
$Id: sect_a_short_names.xsl,v 1.10 2018/01/18 20:20:21 mike Exp $
	Author:  Rob Bodington, Eurostep Limited
	Owner:   Developed by Eurostep and supplied to NIST under contract.
	Purpose:
		 
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
								version="1.0">

	<!-- <xsl:import href="resource.xsl"/> -->

	<!-- 
			 the stylesheet that allows different stylesheets to be applied 
			 -->
	<!-- <xsl:import href="resource_clause.xsl"/>


	<xsl:output method="html"/> -->

	<!-- overwrites the template declared in resource.xsl -->
	<xsl:template match="resource" mode="annex_a">
		<xsl:call-template name="annex_header">
			<xsl:with-param name="annex_no" select="'A'"/>
			<xsl:with-param name="heading" select="'Short names of entities'"/>
			<xsl:with-param name="aname" select="'annexa'"/>
			<xsl:with-param name="informative" select="'normative'"/>
		</xsl:call-template>


		<!-- check that all the entities have short names declared NOT DONE -->
		<xsl:variable name="resdoc_dir">
			<xsl:call-template name="resdoc_directory">
				<xsl:with-param name="resdoc" select="@name"/>
			</xsl:call-template>
		</xsl:variable>


		<xsl:variable name="shortnames" select="/resource/shortnames/shortname"/>
		
		<xsl:for-each select="schema">
			<xsl:variable name="resource_dir">
				<xsl:call-template name="resource_directory">
					<xsl:with-param name="resource" select="./@name"/>            
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="express_xml" select="document(concat($resource_dir,'/',@name,'.xml'))"/>  
			<xsl:for-each select="$express_xml/express/schema/entity">
				<xsl:variable name="entity" select="@name"/>
				<!--<xsl:if test="not($shortnames[@entity=$entity])">
					<xsl:call-template name="error_message">
						<xsl:with-param 
							name="message" 
							select="concat('Error sn1: the entity ',$entity,
										' has not had a shortname declared.')"/>
					</xsl:call-template>
				</xsl:if>-->
			</xsl:for-each>
		</xsl:for-each>
		<xsl:choose>
			<xsl:when test="shortnames">
				<xsl:apply-templates select="shortnames"/>
			</xsl:when>

			<xsl:otherwise>
				<!--<p>
					Entity names in this part of ISO 10303 have been defined in other
					parts of ISO 10303. Requirements on the use of the short names are
					found in the implementation methods included in ISO 10303.  
				</p> MWD 2018-01-10 http://wikistep.org/bugzilla/show_bug.cgi?id=6456 -->
				<!-- <p> -->
				<xsl:call-template name="insertParagraph">
					<xsl:with-param name="text">
						Requirements on the use of the short names are found in the implementation methods included in ISO 10303. EXPRESS entity names and the equivalent short names are available from:
						<!-- </p> -->
					</xsl:with-param>
				</xsl:call-template>
				
				<!-- added MWD 2018-01-10 http://wikistep.org/bugzilla/show_bug.cgi?id=6456 -->
				<!--
				<p class="note">
					<small>
						NOTE&#160;&#160;The EXPRESS entity names are available from
						the following URL:<br/>
					<xsl:variable name="UPPER"
						select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
					<xsl:variable name="LOWER"
						select="'abcdefghijklmnopqrstuvwxyz'"/>
					<xsl:variable name="mim_schema"
						select="translate(concat(@name,'_mim'),$LOWER, $UPPER)"/>
					<xsl:variable name="names_url"
						select="'http://www.tc184-sc4.org/Short_Names/'"/>
					<p class="center">
						&lt;
						<a href="{$names_url}">
							<xsl:value-of select="$names_url"/>
						</a>
						&gt;
					</p>
				 </small>
			 </p> -->
				
				<!-- <p align="center">
					<small>
						<xsl:variable name="names_url" select="'http://standards.iso.org/iso/10303/tech/short_names/short-names.txt'"/>
						<a href="{$names_url}" target="_blank">
							<xsl:value-of select="$names_url"/>
						</a>
					</small>
				</p> -->
				<xsl:text>[align=center]</xsl:text>
				<xsl:text>&#xa;</xsl:text>
				<xsl:variable name="names_url" select="'http://standards.iso.org/iso/10303/tech/short_names/short-names.txt'"/>
				<xsl:call-template name="insertParagraph">
					<xsl:with-param name="text">
						
						<xsl:call-template name="insertHyperlink">
							<xsl:with-param name="a">
								<a href="{$names_url}" target="_blank">
									<xsl:value-of select="$names_url"/>
								</a>
							</xsl:with-param>
							<xsl:with-param name="asText">true</xsl:with-param>
						</xsl:call-template>
									
					</xsl:with-param>
				</xsl:call-template>
				
		 </xsl:otherwise>
	 </xsl:choose>
	</xsl:template>

	<xsl:template match="shortnames">
		<!--<p>
			Table A.1 provides the short names for entities defined in the MIM of
			this part of ISO 10303. Requirements on the use of the short names are
			found in the implementation methods included in ISO 10303. 
		</p>
		<p class="note">
			<small>
				NOTE&#160;&#160;The EXPRESS entity names are available from
				the following URL:
			</small>
		</p> MWD 2018-01-18 http://wikistep.org/bugzilla/show_bug.cgi?id=6456 -->  
		<!-- <p> -->
		<xsl:call-template name="insertParagraph">
			<xsl:with-param name="text">
				Requirements on the use of the short names are found in the implementation methods included in ISO 10303. EXPRESS entity names and the equivalent short names are available from:
			</xsl:with-param>
		</xsl:call-template>
		<!-- </p> -->
		
		<!-- <p align="center">
			<xsl:variable name="names_url" select="'http://standards.iso.org/iso/10303/tech/short_names/short-names.txt'"/>
			<small>
					&lt;
					<a href="{$names_url}" target="_blank">
						<xsl:value-of select="$names_url"/>
					</a>
					&gt;
			</small>
		</p> -->
		
		<xsl:text>[align=center]</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:variable name="names_url" select="'http://standards.iso.org/iso/10303/tech/short_names/short-names.txt'"/>		
		<xsl:call-template name="insertParagraph">
			<xsl:with-param name="text">
			
				<xsl:call-template name="insertHyperlink">
					<xsl:with-param name="a">
						<a href="{$names_url}" target="_blank">
							<xsl:value-of select="$names_url"/>
						</a>
					</xsl:with-param>
					<xsl:with-param name="asText">true</xsl:with-param>
				</xsl:call-template>
				
			</xsl:with-param>
		</xsl:call-template>

		<!-- output any issues -->
		<!--<xsl:apply-templates select=".." mode="output_clause_issue">
			<xsl:with-param name="clause" select="'shortnames'"/>
		</xsl:apply-templates>
		
		<p align="center">
			<b>
				Table A.1 - Short names of entities 
			</b>
		</p>
		<div align="center">
			<table border="1" cellspacing="0" cellpadding="7" width="537">
				<tr>
					<td>
						<b>Entity data types names</b>
					</td>
					<td>
						<b>Short names</b>
					</td>
				</tr>
				<xsl:apply-templates select="shortname">
					<xsl:sort select="@entity"/>
				</xsl:apply-templates>        
			</table>
		</div> MWD 2018-01-18 http://wikistep.org/bugzilla/show_bug.cgi?id=6456 -->
	</xsl:template>

	<xsl:template match="shortname">
		<!-- <tr>
			<td width="77%" align="left"> -->
				<!-- check that the entity exists well we will do this later -->
<!-- 
				<xsl:variable name="entity" select="@entity"/>

				<xsl:for-each select="../../schema">
					<xsl:variable name="resource_dir">
						<xsl:call-template name="resource_directory">
							<xsl:with-param name="resource" select="./@name"/>            
						</xsl:call-template>
					</xsl:variable>
					<xsl:variable name="express_xml" select="concat($resource_dir,'/',@name,'.xml')"/>  
					<xsl:choose>
						<xsl:when
							test="document($express_xml)/express/schema/entity[@name=$entity]">
							<xsl:value-of select="$entity"/>
						</xsl:when>
					</xsl:choose>
				</xsl:for-each>
			</td>
			<td width="23%" align="left">
				<xsl:choose>
					<xsl:when test="string-length(@name)>0">
						<xsl:value-of select="@name"/>          
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="error_message">
							<xsl:with-param 
								name="message" 
								select="concat('Error sn3: ',@entity,' shortname not declared.')"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</td>
		</tr> -->
		<xsl:text>&#xa;</xsl:text>
		<xsl:variable name="entity" select="@entity"/>
		<xsl:for-each select="../../schema">
			<xsl:variable name="resource_dir">
				<xsl:call-template name="resource_directory">
					<xsl:with-param name="resource" select="./@name"/>            
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="express_xml" select="concat($resource_dir,'/',@name,'.xml')"/>  
			<xsl:choose>
				<xsl:when test="document($express_xml)/express/schema/entity[@name=$entity]">
					<xsl:value-of select="$entity"/>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
		<xsl:text>:: </xsl:text>
		<xsl:choose>
			<xsl:when test="string-length(@name)>0">
				<xsl:value-of select="@name"/>          
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="error_message">
					<xsl:with-param name="message" select="concat('Error sn3: ',@entity,' shortname not declared.')"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>&#xa;&#xa;</xsl:text>
	</xsl:template>
	
</xsl:stylesheet>
