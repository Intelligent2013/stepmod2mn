<?xml version="1.0" encoding="utf-8"?>

<!--
This file is a copy of the file data/xsl/sect_g_changes.xsl for application modules, adopted for resources.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"                	
	xmlns:xalan="http://xml.apache.org/xalan" 
	xmlns:java="http://xml.apache.org/xalan/java" 
	version="1.0">
	
	<!-- xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	xmlns:exslt="http://exslt.org/common"
	exclude-result-prefixes="msxsl exslt" -->
	
<!--   <xsl:import href="resource.xsl"/> -->

	<!-- 
			 the stylesheet that allows different stylesheets to be applied 
			 -->
<!--  <xsl:import href="resource_clause.xsl"/>


	<xsl:output method="html"/> -->

	<!-- overwrites the template declared in resource.xsl -->
	<xsl:template match="resource" mode="change_history">
		<xsl:variable name="annex_letter">
			<xsl:choose>
					<xsl:when test="//examples and //tech_discussion">G</xsl:when>
					<xsl:when test="//examples or //tech_discussion">F</xsl:when>
					<xsl:otherwise>E</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:call-template name="annex_header">
			<xsl:with-param name="annex_no" select="$annex_letter"/>
			<xsl:with-param name="heading" select="'Change history'"/>
			<xsl:with-param name="aname" select="'annexg'"/>
		</xsl:call-template>
		
		<xsl:variable name="part_no">
			<xsl:choose>
				<xsl:when test="string-length(@part)>0">
					<xsl:value-of select="concat('ISO/TS 10303-',@part)"/>
				</xsl:when>
				<xsl:otherwise>ISO/TS 10303-XXXX</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:if test="changes">
			<!-- check that the number of change element corresponds to the edition  -->
			<xsl:if test="count(./changes/change_edition)+1 != ./@version"> 
					<xsl:call-template name="error_message">
						<xsl:with-param name="inline" select="'yes'"/>
						<xsl:with-param name="warning_gif" select="'../../../../images/warning.gif'"/>
						<xsl:with-param name="message"
							select="concat('Error F1 Change resource: ',/resource/@name,' The number of change elements do not correspond to the edition')"/>
					</xsl:call-template> 
				</xsl:if>
		</xsl:if>

		<!-- <h2>
			<a name="general">
				<xsl:value-of select="concat($annex_letter,'.1 General')"/>
			</a>
		</h2> -->
		<xsl:call-template name="insertHeaderADOC">
			<xsl:with-param name="id" select="'general'"/>		
			<xsl:with-param name="level" select="2"/>
			<xsl:with-param name="header" select="'General'"/>					
		</xsl:call-template>


		<xsl:choose>
			<xsl:when test="changes">
				<!-- <p> -->
				<xsl:call-template name="insertParagraph">
					<xsl:with-param name="text">
						This annex documents the history of technical modifications made to 
						<xsl:value-of select="concat('ISO/TS 10303-',@part)"/>.
					</xsl:with-param>
				</xsl:call-template>
				<!-- </p> -->
				
				<!-- <p> -->
				<xsl:call-template name="insertParagraph">
					<xsl:with-param name="text">
						Unless otherwise specified all modifications are upwardly compatible to the previous edition.	
						Modifications to EXPRESS specifications are upwardly compatible if:
					</xsl:with-param>
				</xsl:call-template>
				<!-- </p> -->
				
				<!-- <ul>
				<li> -->
				<xsl:call-template name="insertULitem">
					<xsl:with-param name="text">
						instances encoded according to ISO 10303-21, and that conform to an ISO 10303 application
						protocol based on the previous edition of this part of ISO 10303, also conform to a revision of that 
						application protocol based on this edition of this part of ISO 10303;
					</xsl:with-param>
				</xsl:call-template>
			<!-- </li>
			<li> -->
				<xsl:call-template name="insertULitem">
					<xsl:with-param name="text">
						interfaces that conform to ISO 10303-22 and to an ISO 10303 application protocol based on the
						previous edition of this part of ISO 10303, also conform to a revision of that application protocol 
						based on this edition of this part of ISO 10303;
					</xsl:with-param>
				</xsl:call-template>
			<!-- </li>
			<li> -->
				<xsl:call-template name="insertULitem">
					<xsl:with-param name="text">
						the mapping tables of ISO 10303 application protocols based on the previous edition of this 
						part of ISO 10303 remain valid in a revision of that application protocol based on this edition of this part of ISO 10303.
					</xsl:with-param>
				</xsl:call-template>
			<!-- </li>
			</ul> -->
				<xsl:apply-templates select="changes"/>
			</xsl:when>
			<xsl:otherwise>
				<!-- <p> -->
				<xsl:call-template name="insertParagraph">
					<xsl:with-param name="text">
					This is the first edition of the part.
					</xsl:with-param>
				</xsl:call-template>
				<!-- </p> -->
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	

	<xsl:template match="changes">    
		
		<xsl:variable name="annex_letter">
			<xsl:choose>
				<xsl:when test="//examples and //tech_discussion">G</xsl:when>
				<xsl:when test="//examples or //tech_discussion">F</xsl:when>
				<xsl:otherwise>E</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:for-each select="change_edition">
			<xsl:sort data-type="number" select="@version"/>
			<xsl:variable name="aname" select="concat('change_',@version)"/>
			<!-- <h2>
				<a name="{$aname}">
					<xsl:value-of select="concat($annex_letter,'.',position()+1,' Changes made in edition ',@version)"/>
				</a>
			</h2> -->
			
			<xsl:call-template name="insertHeaderADOC">
				<xsl:with-param name="id" select="$aname"/>		
				<xsl:with-param name="level" select="2"/>
				<xsl:with-param name="header" select="concat('Changes made in edition ',@version)"/>					
			</xsl:call-template>
			
			<!-- <h2>
				<a name="summary{@version}">
					<xsl:value-of select="concat($annex_letter,'.',position()+1,'.1 Summary of changes ')"/>
				</a>
			</h2> -->
			
			<xsl:call-template name="insertHeaderADOC">
				<xsl:with-param name="id" select="concat('summary', @version)"/>		
				<xsl:with-param name="level" select="3"/>
				<xsl:with-param name="header" select="'Summary of changes'"/>					
			</xsl:call-template>
			
			<!-- <p> -->
			<xsl:call-template name="insertParagraph">
				<xsl:with-param name="text">
					<xsl:choose>
						<xsl:when test="@version = /resource/@version">This </xsl:when>
						<xsl:otherwise>The </xsl:otherwise>
					</xsl:choose>          
					<xsl:call-template name="number_to_word">
						<xsl:with-param name="number" select="@version"/>
					</xsl:call-template>
					edition of this part of ISO 10303 
					<xsl:choose>
						<xsl:when test="@version = /resource/@version">incorporates</xsl:when>
						<xsl:otherwise>incorporated</xsl:otherwise>
					</xsl:choose>         
					the modifications to the 
					<xsl:call-template name="number_to_word">
						<xsl:with-param name="number" select="string(@version - 1)"/>
					</xsl:call-template>
					edition listed below.
				</xsl:with-param>
			</xsl:call-template>
			<!-- </p> -->
			
			<xsl:apply-templates select="./description"/>
			
			<xsl:for-each select="./schema.changes">
				<xsl:variable name="schema_changes">
					<xsl:apply-templates select=".">
						<xsl:with-param name="annex" select="concat($annex_letter,'.',../@version,'.',position()+1)"/>
					</xsl:apply-templates>
				</xsl:variable>
				<xsl:copy-of select="$schema_changes"/>
				<xsl:if test="not(java:endsWith(java:java.lang.String.new($schema_changes),'&#xa;') or java:endsWith(java:java.lang.String.new($schema_changes),'&#xd;'))">
					<xsl:text>&#xa;&#xa;</xsl:text>
				</xsl:if>
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="description/text()">
		<xsl:value-of select="normalize-space(.)"/>
	</xsl:template>
	
	<xsl:template match="schema.changes">
		<xsl:param name="annex"/>
		<xsl:variable name="_pos"><xsl:number/></xsl:variable>
		<xsl:variable name="pos">
			<xsl:choose>
				<xsl:when test="$_pos = '1'"></xsl:when>
				<xsl:otherwise>_<xsl:value-of select="$_pos"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="aname" select="concat(name(),../@version, $pos)"/>
		<!-- <h2>
			<a name="{$aname}">
				<xsl:value-of select="concat($annex, ' Changes made to schema ', @schema_name)"/>
			</a>
		</h2> -->
		
		<xsl:call-template name="insertHeaderADOC">
			<xsl:with-param name="id" select="$aname"/>		
			<xsl:with-param name="level" select="3"/>
			<xsl:with-param name="header" select="concat('Changes made to schema ',@schema_name)"/>					
		</xsl:call-template>
		
		<xsl:apply-templates select="./description"/>
		<xsl:apply-templates select="./schema.additions"/>
		<xsl:apply-templates select="./schema.modifications"/>
		<xsl:apply-templates select="./schema.deletions"/>
	</xsl:template>
	
	
	<xsl:template match="schema.additions|schema.modifications|schema.deletions" mode="modified.object">
		<xsl:apply-templates select="./modified.object" mode="check_attributes"/>
		
		<xsl:variable name="arm_mim_clause">
			<xsl:choose>
				<xsl:when test="name()='mim.modifications'">5_mim</xsl:when>
				<xsl:when test="name()='mim.deletions'">5_mim</xsl:when>
				<xsl:otherwise>4_info_reqs</xsl:otherwise>
			</xsl:choose>      
		</xsl:variable>
		<xsl:variable name="arm_mim_suffix">
			<xsl:choose>
				<xsl:when test="name()='mim.modifications'">_mim</xsl:when>
				<xsl:when test="name()='mim.deletions'">_mim</xsl:when>
				<xsl:otherwise>_arm</xsl:otherwise>
			</xsl:choose>      
		</xsl:variable>
		
		<xsl:variable name="objects">
			<objects>
				<xsl:for-each select="modified.object[@type='CONSTANT']">
					<xsl:sort select="@name"/>
					<xsl:copy-of select="."/>
				</xsl:for-each>
				<xsl:for-each select="modified.object[@type='USE_FROM']">
					<xsl:sort select="@name"/>
					<xsl:copy-of select="."/>
				</xsl:for-each>
				<xsl:for-each select="modified.object[@type='REFERENCE_FROM']">
					<xsl:sort select="@name"/>
					<xsl:copy-of select="."/>
				</xsl:for-each>
				<xsl:for-each select="modified.object[@type='TYPE']">
					<xsl:sort select="@name"/>
					<xsl:copy-of select="."/>
				</xsl:for-each>
				<xsl:for-each select="modified.object[@type='ENTITY']">
					<xsl:sort select="@name"/>
					<xsl:copy-of select="."/>
				</xsl:for-each>        
				<xsl:for-each select="modified.object[@type='SUBTYPE_CONSTRAINT']">
					<xsl:sort select="@name"/>
					<xsl:copy-of select="."/>
				</xsl:for-each>
				<xsl:for-each select="modified.object[@type='RULE']">
					<xsl:sort select="@name"/>
					<xsl:copy-of select="."/>
				</xsl:for-each>
				<xsl:for-each select="modified.object[@type='FUNCTION']">
					<xsl:sort select="@name"/>
					<xsl:copy-of select="."/>
				</xsl:for-each>
			</objects>
		</xsl:variable>  
		
		<!-- <xsl:choose> -->
			
			<!-- MWD -->
			<!-- <xsl:when test="function-available('msxsl:node-set')">
				<xsl:variable name="objectnodes" select="msxsl:node-set($objects)"/>
				<xsl:for-each select="$objectnodes//modified.object">
					<li>
						<xsl:choose>
							<xsl:when test="./description/ul">
								<xsl:apply-templates select=".">
									<xsl:with-param name="arm_mim_clause" select="$arm_mim_clause"/>
									<xsl:with-param name="arm_mim_suffix" select="$arm_mim_suffix"/>
								</xsl:apply-templates>
							</xsl:when>
							<xsl:when test="position()=last()">
								<xsl:apply-templates select=".">
									<xsl:with-param name="arm_mim_clause" select="$arm_mim_clause"/>
									<xsl:with-param name="arm_mim_suffix" select="$arm_mim_suffix"/>
								</xsl:apply-templates>.</xsl:when>
							<xsl:otherwise><xsl:apply-templates select=".">
								<xsl:with-param name="arm_mim_clause" select="$arm_mim_clause"/>
								<xsl:with-param name="arm_mim_suffix" select="$arm_mim_suffix"/>
							</xsl:apply-templates>;</xsl:otherwise>
						</xsl:choose>
					</li>
				</xsl:for-each>
			</xsl:when> -->
			
			<!-- MWD -->
			<!-- <xsl:when test="function-available('exslt:node-set')">          -->
				<xsl:variable name="objectnodes" select="xalan:nodeset($objects)"/>
				<xsl:for-each select="$objectnodes//modified.object">
					<!-- <li> -->
						<xsl:call-template name="insertULitem">
							<xsl:with-param name="text">
								<xsl:apply-templates select=".">
										<xsl:with-param name="arm_mim_clause" select="$arm_mim_clause"/>
										<xsl:with-param name="arm_mim_suffix" select="$arm_mim_suffix"/>
									</xsl:apply-templates>
									<xsl:choose>
										<xsl:when test="./description/ul"/>
										<xsl:when test="position()=last()">.</xsl:when>
										<xsl:otherwise>;</xsl:otherwise>
									</xsl:choose>										
							</xsl:with-param>
						</xsl:call-template>
									<!-- <xsl:choose>
										<xsl:when test="./description/ul">
											<xsl:apply-templates select=".">
												<xsl:with-param name="arm_mim_clause" select="$arm_mim_clause"/>
												<xsl:with-param name="arm_mim_suffix" select="$arm_mim_suffix"/>
											</xsl:apply-templates>
										</xsl:when>
										<xsl:when test="position()=last()">
											<xsl:apply-templates select=".">
												<xsl:with-param name="arm_mim_clause" select="$arm_mim_clause"/>
												<xsl:with-param name="arm_mim_suffix" select="$arm_mim_suffix"/>
											</xsl:apply-templates>.</xsl:when>
										<xsl:otherwise>
												<xsl:apply-templates select=".">
												<xsl:with-param name="arm_mim_clause" select="$arm_mim_clause"/>
												<xsl:with-param name="arm_mim_suffix" select="$arm_mim_suffix"/>
											</xsl:apply-templates>;</xsl:otherwise>
									</xsl:choose> -->
					<!-- </li> -->
				</xsl:for-each>
			<!-- </xsl:when>    
			
			<xsl:otherwise>BROWSER NOT SUPPORTED</xsl:otherwise>
		</xsl:choose> -->
	</xsl:template>
	
	
	<xsl:template match="modified.object" mode="check_attributes">
		<xsl:if test="@type!='CONSTANT' and
			@type!='USE_FROM' and
			@type!='REFERENCE_FROM' and
			@type!='TYPE' and
			@type!='ENTITY' and
			@type!='SUBTYPE_CONSTRAINT' and
			@type!='RULE' and
			@type!='FUNCTION' or string-length(@type)=0">      
			<xsl:call-template name="error_message">
				<xsl:with-param name="message">
					<xsl:value-of select="concat('Error F4 Change : ',/resource/@name,' 
						The modified.object has @type attribute =',@type,' should have a @type attribute = USE_FROM | REFERENCE_FROM | CONSTANT | TYPE | ENTITY | SUBTYPE_CONSTRAINT | RULE | FUNCTION')"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>    
	</xsl:template>
	
	<xsl:template name="output_interfaced_items">
		<xsl:param name="interface_type"/>
		<xsl:param name="interface_name"/>
		<xsl:param name="interfaced_items"/>
		<xsl:variable name="output2" select="translate(normalize-space(translate($interfaced_items,',()','   ')),' ',', ')"/>
		<xsl:variable name="output1">
			<xsl:call-template name="output_comma_separated_list">
				<xsl:with-param name="string" select="normalize-space(translate($interfaced_items,',()','   '))"/>
				</xsl:call-template>
		</xsl:variable>
		<xsl:value-of select="concat($interface_type,' ',$interface_name,'(',$output1,')')"/>    
	</xsl:template>
	
		
	<xsl:template match="modified.object">
		<xsl:param name="arm_mim_clause"/>
		<xsl:param name="arm_mim_suffix"/>
		<xsl:variable name="object">
			<xsl:choose>
				<xsl:when test="string-length(@interfaced.items)!=0">
					<xsl:call-template name="output_interfaced_items">
						<xsl:with-param name="interface_type" select="@type"/>
						<xsl:with-param name="interface_name" select="@name"/>
						<xsl:with-param name="interfaced_items" select="@interfaced.items"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise><xsl:value-of select="concat(@type,' ',@name)"/></xsl:otherwise>
			</xsl:choose>      
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="@moved-to-resource"><xsl:variable name="resource_ok">
					<xsl:call-template name="check_resource_exists">
						<xsl:with-param name="resource" select="@moved-to-resource"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="$resource_ok='true'">
					 
						<xsl:value-of select="concat($object,' (which has been moved to the resource ',@moved-to-resource, ')')"/><!-- MWD 2017-09-26 -->
						<!--<xsl:value-of select="concat($object,' has been moved to the resource ')"/>
						<xsl:variable name="resource_href"
							select="concat('../../../resources/',@moved-to-resource,'/sys/',$arm_mim_clause,$FILE_EXT,'#',@moved-to-resource,$arm_mim_suffix,'.',@name)"/>
						<a href="{$resource_href}">
							<xsl:value-of select="@moved-to-resource"/>
						</a>-->
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="error_message">
							<xsl:with-param name="message">
								<xsl:value-of select="concat('Error F3 Change : ',/resource/@name,$resource_ok)"/>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="@moved-to-resource">
				<xsl:variable name="resource_ok">
					<xsl:call-template name="check_resource_exists">
						<xsl:with-param name="schema" select="@moved-to-resource"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="$resource_ok='true'">
						
						<xsl:value-of select="concat($object,' (which has been moved to the resource ',@moved-to-resource, ')' )"/><!-- MWD 2017-09-26 -->
						<!--<xsl:variable name="resource_href"
							select="concat('../../../resources/',@moved-to-resource,'/',@moved-to-resource,$FILE_EXT,'#',@name)"/>
						<xsl:value-of select="concat($object,' has been moved to the resource ')"/>
						<a href="{$resource_href}">
							<xsl:value-of select="@moved-to-resource"/>
						</a>-->
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="error_message">
							<xsl:with-param name="message">
								<xsl:value-of select="concat('Error F3 Change : ',/resource/@name,$resource_ok)"/>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$object"/>
				<xsl:apply-templates select="description" mode="modified.object"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="p" mode="position">
		<xsl:value-of select="position()"/>
	</xsl:template>
	
	<!--<xsl:template match="description" mode="modified.object">
		<xsl:if test="string-length(normalize-space(./child::text()[1])!=0)">
				<br/>  
		</xsl:if>    
		<xsl:apply-templates select="."/>
	</xsl:template>-->
	
	<!-- MWD -->
	<xsl:template match="description" mode="modified.object">
	 <xsl:choose>
			<xsl:when test="./ul">
				<!-- <ul> -->
					<xsl:for-each select="./ul/li">
						<!-- <xsl:choose>
							<xsl:when test="position()=last()">
								<li><xsl:apply-templates select="."/>.</li>
							</xsl:when>
							<xsl:otherwise>
								<li><xsl:apply-templates select="."/>;</li>
							</xsl:otherwise>
						</xsl:choose> -->
						
						<xsl:call-template name="insertULitem">
							<xsl:with-param name="text">
								<xsl:apply-templates select="."/>
								<xsl:choose>
									<xsl:when test="position()=last()">.</xsl:when>
									<xsl:otherwise>;</xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
						</xsl:call-template>
						
					</xsl:for-each>
				<!-- </ul> -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="string-length(normalize-space(./child::text()[1])!=0)">
					<!-- <br/>   -->
					<xsl:text> +&#xa;</xsl:text>
				</xsl:if>
				<xsl:apply-templates select="."/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="schema.additions">    
		<!-- <p> -->
		<xsl:call-template name="insertParagraph">
			<xsl:with-param name="text">
				The following EXPRESS declarations and interface specifications have been added: 
			</xsl:with-param>
		</xsl:call-template>
		<!-- </p> -->
		<!-- <ul>   -->
			<xsl:apply-templates select="." mode="modified.object"/>
		<!-- </ul> -->
	</xsl:template>
	
	<xsl:template match="schema.modifications">   
		<!-- <p> -->
		<xsl:call-template name="insertParagraph">
			<xsl:with-param name="text">
				The following EXPRESS declarations and interface specifications have been modified:  
			</xsl:with-param>
		</xsl:call-template>
		<!-- </p> -->
		<!-- <ul>   -->
			<xsl:apply-templates select="." mode="modified.object"/>
		<!-- </ul> -->
	</xsl:template>
	
	<xsl:template match="schema.deletions">   
		<!-- <p> -->
		<xsl:call-template name="insertParagraph">
			<xsl:with-param name="text">
				The following EXPRESS declarations and interface specifications have been removed: 
			</xsl:with-param>
		</xsl:call-template>
		<!-- </p> -->
		<!-- <ul>   -->
			<xsl:apply-templates select="." mode="modified.object"/>
		<!-- </ul> -->
	</xsl:template>
	
</xsl:stylesheet>
