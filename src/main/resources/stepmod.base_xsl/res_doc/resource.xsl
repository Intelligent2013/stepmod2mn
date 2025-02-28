<?xml version="1.0" encoding="utf-8"?>
<!--
$Id: resource.xsl,v 1.115 2018/08/23 11:13:35 mike Exp $
Author:  Rob Bodington, Eurostep Limited
Owner:   Developed by Eurostep and supplied to NIST under contract.
Purpose:

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"		
	xmlns:xalan="http://xml.apache.org/xalan" 
	xmlns:java="http://xml.apache.org/xalan/java" 
	xmlns:str="http://exslt.org/strings"
		version="1.0" extension-element-prefixes="str">
		
		<!-- xmlns:msxsl="urn:schemas-microsoft-com:xslt"
	xmlns:exslt="http://exslt.org/common"
	exclude-result-prefixes="msxsl exslt" -->

	<!-- <xsl:import href="res_toc.xsl"/>

	<xsl:import href="sect_4_express.xsl"/>

	<xsl:import href="../projmg/resource_issues.xsl"/> -->


	<xsl:output 
			method="html"
			doctype-system="http://www.w3.org/TR/html4/loose.dtd"
			doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"
			indent="yes"
			/>


	<xsl:template match="resource">
		<xsl:apply-templates select="." mode="coverpage"/>
		<xsl:apply-templates select="." mode="foreword"/>
		<xsl:apply-templates/>
	</xsl:template>


	<!-- test the WG number. 
			 return a string containing Error if incorrect

	-->
	<xsl:template name="test_wg_number">
		<xsl:param name="wgnumber"/>
		<xsl:variable name="UPPER" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
		<xsl:variable name="LOWER" select="'abcdefghijklmnopqrstuvwxyz'"/>
		<xsl:variable name="ERR" select="'**************************'"/>

		<xsl:variable name="wgnumber_check"
			select="translate(translate($wgnumber,$LOWER,$UPPER),$UPPER,$ERR)"/>

		<xsl:choose>
			<xsl:when test="not($wgnumber)">
	Error WG-1: No WG number provided.
			</xsl:when>

			<xsl:when test="$wgnumber = 00000">
	<!-- the default provided by mkresource -->
	Error WG-2: No WG number provided (0 is invalid).
			</xsl:when>

			<xsl:when test="contains($wgnumber_check,'*')">
	Error WG-3: WG number must be an integer.
			</xsl:when>
			<xsl:otherwise>
	'OK'
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<!-- Outputs the cover page -->
	<xsl:template match="resource" mode="coverpage">

		<!-- output any issues -->
		<xsl:apply-templates select="." mode="output_clause_issue">
			<xsl:with-param name="clause" select="'general'"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="." mode="output_clause_issue">
			<xsl:with-param name="clause" select="'cover'"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="." mode="output_clause_issue">
			<xsl:with-param name="clause" select="'abstract'"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="." mode="output_clause_issue">
			<xsl:with-param name="clause" select="'keywords'"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="." mode="output_clause_issue">
			<xsl:with-param name="clause" select="'contacts'"/>
		</xsl:apply-templates>

		<xsl:variable name="n_number"
			select="concat('ISO/TC 184/SC 4/WG 12 N',./@wg.number)"/>
		<xsl:variable name="date"
			select="translate(
				substring-before(substring-after(@rcs.date,'$Date: '),' '),
				'/','-')"/>

		<table width="624">
			<tr>
	<td><h3><xsl:value-of select="$n_number"/></h3></td>
	<td>&#x20;</td>
	<!-- <td valign="top"><b>Date:&#x20;</b><xsl:value-of select="$date"/></td> -->
	<td valign="top"><xsl:text>*</xsl:text>Date: <xsl:text>* </xsl:text><xsl:value-of select="$date"/></td>
			</tr>    

			<xsl:variable name="test_wg_number">
	<xsl:call-template name="test_wg_number">
		<xsl:with-param name="wgnumber" select="./@wg.number"/>
	</xsl:call-template>
			</xsl:variable>
			<xsl:if test="contains($test_wg_number,'Error')">
	<tr>
		<td>
			<xsl:call-template name="error_message">
				<xsl:with-param name="message">
		<xsl:value-of select="concat('Error in
							resource.xml/resource/@wg.number - ',
							$test_wg_number)"/>
				</xsl:with-param>
			</xsl:call-template>
		</td>
	</tr>
			</xsl:if>


			<xsl:if test="@wg.number.supersedes">      
	<tr>
		<td>
			<h3>              
				Supersedes 
				<xsl:choose>
		<xsl:when test="contains(@wg.number.supersedes, 'ISO')">
			<xsl:value-of select="@wg.number.supersedes"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of 
				select="concat('ISO/TC 184/SC 4/WG 12 N',@wg.number.supersedes)"/>
		</xsl:otherwise>
				</xsl:choose>
			</h3>

			<xsl:variable name="test_wg_number_supersedes">
				<xsl:call-template name="test_wg_number">
		<xsl:with-param name="wgnumber" select="./@wg.number.supersedes"/>
				</xsl:call-template>
			</xsl:variable>
			<xsl:if test="contains($test_wg_number_supersedes,'Error')">
				<tr>
		<td>
			<xsl:call-template name="error_message">
				<xsl:with-param name="message">
					<xsl:value-of 
				select="concat('Error in
					resource.xml/resource/@wg.number.supersedes - ',
					$test_wg_number_supersedes)"/>
				</xsl:with-param>
			</xsl:call-template>
		</td>
				</tr>
			</xsl:if>

			<xsl:if test="@wg.number.supersedes = @wg.number">
				<xsl:call-template name="error_message">
		<xsl:with-param name="message">
			Error in resource.xml/resource/@wg.number.supersedes - 
			Error WG-16: New WG number is the same as superseded WG number.
		</xsl:with-param>
				</xsl:call-template>            
			</xsl:if>
		</td>
	</tr>
			</xsl:if>
		</table>

		<xsl:variable name="resdoc_name">
			<xsl:call-template name="res_display_name">
	<xsl:with-param name="res" select="./@name"/>
			</xsl:call-template>           
		</xsl:variable>

		<xsl:variable name="stdnumber">
			<xsl:call-template name="get_resdoc_pageheader">
	<xsl:with-param name="resdoc" select="."/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="part_no">
			<xsl:call-template name="get_resdoc_iso_number_without_status">
			<xsl:with-param name="resdoc" select="./@name"/>
			</xsl:call-template>
		</xsl:variable>
		
		<!-- <xsl:value-of select="$stdnumber"/><br/> -->
		<!-- <h4 level="4" id="{$stdnumber}">      
			<xsl:choose>			 
				<xsl:when test="string-length($part_no) &lt; 13">
					Product data representation and exchange:  Integrated generic resource:
				</xsl:when>
				<xsl:otherwise>
					Product data representation and exchange:  Integrated application resource:
				</xsl:otherwise>
			</xsl:choose>
			<xsl:value-of select="$resdoc_name"/>
		</h4> -->

		<xsl:variable name="header">
			<xsl:choose>			 
				<xsl:when test="string-length($part_no) &lt; 13"><!-- if it is 100 series, it is 1 number longer and should have a different name -->
					Product data representation and exchange:  Integrated generic resource:
				</xsl:when>
				<xsl:otherwise>
					Product data representation and exchange:  Integrated application resource:
				</xsl:otherwise>
			</xsl:choose>
			<xsl:value-of select="$resdoc_name"/>
		</xsl:variable>
		<xsl:call-template name="insertHeaderADOC">
			<xsl:with-param name="id" select="$stdnumber"/>		
			<xsl:with-param name="level" select="4"/>
			<xsl:with-param name="header" select="normalize-space($header)"/>					
		</xsl:call-template>

		<xsl:variable name="status" select="string(@status)"/>
		<xsl:variable name="status_words">
			<xsl:choose>
	<xsl:when test="$status='CD'">
		Committee Draft
	</xsl:when>
	<xsl:when test="$status='FDIS'">
		Final Draft International Standard
	</xsl:when>
	<xsl:when test="$status='DIS'">
		Draft International Standard
	</xsl:when>
	<xsl:when test="$status='IS'">
		International Standard
	</xsl:when>
	<xsl:when test="$status='CD-TS'">
		draft technical specification 
	</xsl:when>
	<xsl:when test="$status='TS'">
		technical specification 
	</xsl:when>
	<xsl:when test="$status='WD'">
		working draft 
	</xsl:when>
	<xsl:otherwise>
		resource status not set.
	</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<table border="1" cellspacing="1" cellpadding="8" width="624">
			<tr>
	<td valign="TOP" colspan="2" height="26">
		<h3>COPYRIGHT NOTICE:</h3>
		<a name="copyright"/>
		<xsl:choose>
			<xsl:when test="$status='CD'">
				<p>
		This ISO document is a Committee Draft 
		and is copyright protected by ISO. While the reproduction 
		of working drafts or Committee Drafts in any form for use 
		by Participants in the ISO standards development process 
		is permitted without prior permission from ISO, neither 
		this document nor any extract from it may be reproduced, 
		stored or transmitted in any form for any other purpose 
		without prior written permission from ISO.
				</p>
				<p>
		Requests for permission to reproduce this document for 
		the purposes of selling it should be addressed as shown 
		below (via the ISO/TC 184/SC4 Secretariat's member body) 
		or to ISO's member body in the country of the requester.
				</p>
				<div align="center">
		Copyright Manager<br/>
		ANSI<br/>
		11 West 42nd Street<br/>
		New York, New York 10036<br/>
		USA<br/>
		phone: +1-212-642-4900<br/>
		fax: +1-212-398-0023<br/>
				</div>
				<p>
		Reproduction for sales purposes may be subject to royalty
		payments or a licensing agreement. 
				</p>
				<p>
		Violators may be prosecuted.
				</p>

			</xsl:when>

			<xsl:when test="$status='FDIS'">
				<p>
		This document is a Final Draft International Standard  and is
		copyright-protected by ISO. Except as permitted under the
		applicable laws of the user's country, neither this ISO
		document nor any extract from it may be reproduced, stored in
		a retrieval system or transmitted in any form or by 
		any means, electronic, photocopying, recording, or otherwise,
		without prior written permission being secured.  
				</p>
				<p>
		Requests for permission to reproduce should be addressed to
		ISO at the address below or ISO's member body in the 
		country of the requester:
				</p>

				<div align="center">
		<!--
				Copyright Manager, ISO Central Secretariat<br/>
				1 rue de Varembe<br/>
				CH-1211 Geneva 20 Switzerland<br/>
				telephone: +41 22 749 0111<br/>
				telefacsimile: +41 22 734 0179<br/>
				Internet: central@isocs.iso.ch, X.400: c=ch; a=400net; p=iso;
				o=isocs; s=central<br/>
		-->
					ISO Copyright Office<br/>
					CP 401&#160;<span style="font-family:Symbol">&#183;</span>&#160;Ch. de Blandonnet 8<br/>
					CH-1214 Vernier, Geneva<br/>
					Phone: + 41 22 749 01 11<br/>
					Fax: + 41 22 734 10 79<br/>
					Email: copyright@iso.ch<br/>
					Website: https://www.iso.org[www.iso.org] <!-- <a href="https://www.iso.org">www.iso.org</a><br/> -->
					
					<xsl:text>&#xa;</xsl:text>
				</div>

				<p>
		Reproduction for sales purposes may be subject to
		royalty payments or a licensing agreement.
				</p>
				<p>
		Violators may be prosecuted.
				</p>

			</xsl:when>
			<xsl:when test="$status='DIS'">
				<p>
		This document is a Draft International Standard  and is
		copyright-protected by ISO. Except as permitted under the
		applicable laws of the user's country, neither this ISO
		document nor any extract from it may be reproduced, stored in
		a retrieval system or transmitted in any form or by 
		any means, electronic, photocopying, recording, or otherwise,
		without prior written permission being secured.  
				</p>
				<p>
		Requests for permission to reproduce should be addressed to
		ISO at the address below or ISO's member body in the 
		country of the requester:
				</p>

				<div align="center">
		<!--
				Copyright Manager, ISO Central Secretariat<br/>
				1 rue de Varembe<br/>
				CH-1211 Geneva 20 Switzerland<br/>
				telephone: +41 22 749 0111<br/>
				telefacsimile: +41 22 734 0179<br/>
				Internet: central@isocs.iso.ch, X.400: c=ch; a=400net; p=iso;
				o=isocs; s=central<br/>
		-->
					ISO Copyright Office<br/>
					CP 401&#160;<span style="font-family:Symbol">&#183;</span>&#160;Ch. de Blandonnet 8<br/>
					CH-1214 Vernier, Geneva<br/>
					Phone: + 41 22 749 01 11<br/>
					Fax: + 41 22 734 10 79<br/>
					Email: copyright@iso.ch<br/>
					Website: https://www.iso.org[www.iso.org]<!-- <a href="https://www.iso.org">www.iso.org</a><br/> -->
					<xsl:text>&#xa;</xsl:text>
				</div>

				<p>
		Reproduction for sales purposes may be subject to
		royalty payments or a licensing agreement.
				</p>
				<p>
		Violators may be prosecuted.
				</p>

			</xsl:when>
			<xsl:when test="$status='IS'">
				
				All rights reserved. Unless otherwise specified, or required in the context of its implementation, 
				no part of this publication may be reproduced or utilized otherwise in any form or by any means, 
				electronic or mechanical, including photocopying, or posting on the internet or an intranet, 
				without prior written permission. 
				Permission can be requested from either ISO at the address below or ISO's member body in the country of the requester.
				
				<div align="center">
							ISO Copyright Office<br/>
							CP 401&#160;<span style="font-family:Symbol">&#183;</span>&#160;Ch. de Blandonnet 8<br/>
							CH-1214 Vernier, Geneva<br/>
							Phone: + 41 22 749 01 11<br/>
							Fax: + 41 22 734 10 79<br/>
							Email: copyright@iso.ch<br/>
							Website: https://www.iso.org[www.iso.org]<!-- <a href="https://www.iso.org">www.iso.org</a><br/> -->
							<xsl:text>&#xa;</xsl:text>
							Published in Switzerland<br/>                
						</div>
			</xsl:when>
			<xsl:when test="$status='CD-TS'">
				<p>
		This ISO document is a Committee Draft Technical
		Specification and is copyright protected by ISO. While the
		reproduction of working drafts or Committee Drafts in any
		form for use by Participants in the ISO standards development
		process is permitted without prior written permission from
		ISO, neither this document nor any extract from it may be 
		reproduced, stored or transmitted in any form for any other
		purpose without prior written permission from ISO. 
				</p>
				<p>
		Requests for permission to reproduce this document for the
		purposes of selling it should be addressed as shown below
		(via the ISO/TC&#160;184/SC&#160;4 Secretariat's member body) or to the
		ISO's member body in the country of the requestor 
				</p>
				<div align="center">
		Copyright Manager<br/>
		ANSI<br/>
		11 West 42nd Street<br/>
		New York, New York 10036<br/>
		USA<br/>
		phone: +1-212-642-4900<br/>
		fax: +1-212-398-0023<br/>
				</div>
				<p>
		Reproduction for sales purposes may be subject to royalty
		payments or a licensing agreement. 
				</p>
				<p>
		Violators may be prosecuted.
				</p>
			</xsl:when>

			<xsl:when test="$status='TS'">
				<p>
		This document is a Technical Specification and is
		copyright-protected by ISO. Except as permitted under the
		applicable laws of the user's country, neither this ISO
		document nor any extract from it may be reproduced, stored in
		a retrieval system or transmitted in any form or by 
		any means, electronic, photocopying, recording, or otherwise,
		without prior written permission being secured.  
				</p>
				<p>
		Requests for permission to reproduce should be addressed to
		ISO at the address below or ISO's member body in the 
		country of the requester:
				</p>

				<div align="center">
		<!--
				Copyright Manager, ISO Central Secretariat<br/>
				1 rue de Varembe<br/>
				CH-1211 Geneva 20 Switzerland<br/>
				telephone: +41 22 749 0111<br/>
				telefacsimile: +41 22 734 0179<br/>
				Internet: central@isocs.iso.ch, X.400: c=ch; a=400net; p=iso;
				o=isocs; s=central<br/>
		-->
					ISO Copyright Office<br/>
					CP 401&#160;<span style="font-family:Symbol">&#183;</span>&#160;Ch. de Blandonnet 8<br/>
					CH-1214 Vernier, Geneva<br/>
					Phone: + 41 22 749 01 11<br/>
					Fax: + 41 22 734 10 79<br/>
					Email: copyright@iso.ch<br/>
					Website: https://www.iso.org[www.iso.org]<!-- <a href="https://www.iso.org">www.iso.org</a><br/> -->
					<xsl:text>&#xa;</xsl:text>
				</div>

				<p>
		Reproduction for sales purposes may be subject to
		royalty payments or a licensing agreement.
				</p>
				<p>
		Violators may be prosecuted.
				</p>
			</xsl:when>

			<xsl:when test="$status='WD'">
				working draft 
			</xsl:when>
			<xsl:otherwise>
				resource status not set.
			</xsl:otherwise>
		</xsl:choose>
	</td>
			</tr>
			<tr>
	<td valign="TOP" colspan="2" height="88">
		<h3><a name="abstract">
		ABSTRACT:</a></h3>
		<xsl:apply-templates select="." mode="abstract"/>
		<h3>
			<a name="keywords">
				KEYWORDS:
			</a>
		</h3>
		<xsl:apply-templates select="./keywords"/>

		<h3>COMMENTS TO READER:</h3>

		<xsl:if test="$status='CD-TS' or $status='CD'">
			<p>
				Recipients of this draft are invited to submit, with their comments,
				notification of any relevant patent rights of which they are aware and to
				provide supporting documentation.
			</p>
		</xsl:if>


		<xsl:variable name="ballot_cycle_or_pub">
			<xsl:choose>
				<xsl:when test="$status='CD-TS'">
		this ballot cycle
				</xsl:when>
				<xsl:when test="$status='CD'">
		this ballot cycle
				</xsl:when>

				<xsl:when test="$status='TS'">
		publication
				</xsl:when>
				<xsl:when test="$status='FDIS'">
		publication
				</xsl:when>
				<xsl:when test="$status='DIS'">
		publication
				</xsl:when>
				<xsl:when test="$status='IS'">
		publication
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		This document has been reviewed using the internal review checklist 
		(see <xsl:value-of select="concat('WG12&#160;N',@checklist.internal_review)"/>),
		<!-- test the checklist WG number for checklist.internal_review -->
		<xsl:variable name="test_cl_internal_review">
			<xsl:call-template name="test_wg_number">
				<xsl:with-param name="wgnumber" select="./@checklist.internal_review"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="contains($test_cl_internal_review,'Error')">
			<p>
				<xsl:call-template name="error_message">
		<xsl:with-param name="message">
			<xsl:value-of 
					select="concat('Error in
						resource.xml/resource/@checklist.internal_review - ', 
						$test_cl_internal_review)"/>
		</xsl:with-param>
				</xsl:call-template>
			</p>
		</xsl:if>


		the project leader checklist 
		(see <xsl:value-of
		select="concat('WG12&#160;N',@checklist.project_leader)"/>),

		<!-- test the checklist WG number for checklist.project_leader -->
		<xsl:variable name="test_cl_project_leader">
			<xsl:call-template name="test_wg_number">
				<xsl:with-param name="wgnumber" select="./@checklist.project_leader"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="contains($test_cl_project_leader,'Error')">
			<p>
				<xsl:call-template name="error_message">
		<xsl:with-param name="message">
			<xsl:value-of 
					select="concat('Error in
						resource.xml/resource/@checklist.project_leader - ', 
						$test_cl_project_leader)"/>
		</xsl:with-param>
				</xsl:call-template>
			</p>
		</xsl:if>

		and the convener checklist
		(see <xsl:value-of select="concat('WG12&#160;N',@checklist.convener)"/>),

		<!-- test the checklist WG number for checklist.convener -->
		<xsl:variable name="test_cl_convener">
			<xsl:call-template name="test_wg_number">
				<xsl:with-param name="wgnumber" select="./@checklist.convener"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="contains($test_cl_convener,'Error')">
			<p>
				<xsl:call-template name="error_message">
		<xsl:with-param name="message">
			<xsl:value-of 
					select="concat('Error in
						resource.xml/resource/@checklist.convener - ', 
						$test_cl_convener)"/>
		</xsl:with-param>
				</xsl:call-template>
			</p>
		</xsl:if>
		and has been determined to be ready for 
		<xsl:value-of select="$ballot_cycle_or_pub"/>.
	</td>
			</tr>

			<tr>
	<td width="50%" valign="TOP" height="88">
		<a name="contacts"/>
		<xsl:apply-templates select="./contacts/projlead"/>
	</td>
	<td width="50%" valign="TOP" height="88">
		<xsl:apply-templates select="./contacts/editor"/>
	</td>
			</tr>
		</table>

	</xsl:template>

	<xsl:template match="resource" mode="abstract">

		<xsl:variable name="resdoc_name">
			<xsl:call-template name="res_display_name">
				<xsl:with-param name="res" select="./@name"/>
			</xsl:call-template>           
		</xsl:variable>


		<xsl:variable name="resdoc_title">
			<xsl:apply-templates select="resource" mode="title">
				<xsl:with-param name="res" select="./@name"/>
			</xsl:apply-templates>           
		</xsl:variable>

		<xsl:variable name="resdoc_stdnumber">
			<xsl:call-template name="get_resdoc_stdnumber">
				<xsl:with-param name="resdoc" select="."/>
			</xsl:call-template>           
		</xsl:variable>

		<xsl:text>[abstract]</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		
		<!-- THX deleted per ISO review of part 107
				 PS Added back in following review of Part 61 -->
 <!-- <P> -->
		<xsl:call-template name="insertParagraph">
			<xsl:with-param name="text">
				<xsl:value-of select="substring-before($resdoc_stdnumber,'(E)')"/>
				specifies the integrated resource constructs for 
				<xsl:value-of select="$resdoc_name"/>.
			</xsl:with-param>
		</xsl:call-template>
 <!-- </P> -->

		<xsl:choose>
			<xsl:when test="./abstract">
				<xsl:choose>
					<xsl:when  test="./abstract/li">
						<xsl:choose>
							<xsl:when  test="count(./abstract/li)=1">
								<!-- <P> -->
									<xsl:call-template name="insertParagraph">
										<xsl:with-param name="text">The following is within the scope of 
											<xsl:value-of select="substring-before($resdoc_stdnumber,'(E)')"/>:
										</xsl:with-param>
									</xsl:call-template>
								<!-- </P> -->
							</xsl:when>
							<xsl:otherwise>
								<!-- <P> -->
									<xsl:call-template name="insertParagraph">
										<xsl:with-param name="text">The following are within the scope of 
											<xsl:value-of select="substring-before($resdoc_stdnumber,'(E)')"/>:
										</xsl:with-param>
									</xsl:call-template>
								<!-- </P> -->
							</xsl:otherwise>
						</xsl:choose>
						<!-- <ul> -->
							<xsl:text>&#xa;</xsl:text>
							<xsl:apply-templates select="./abstract/*"/>
						<!-- </ul> -->
							<xsl:text>&#xa;&#xa;</xsl:text>							
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="./abstract/*"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<!-- <P> -->
				 <xsl:call-template name="insertParagraph">
					<xsl:with-param name="text">The following are within the scope of 
						<xsl:value-of select="substring-before($resdoc_stdnumber,'(E)')"/>:
					</xsl:with-param>
				</xsl:call-template>
				<!-- </P> -->
				<!-- <UL> -->
					<xsl:text>&#xa;</xsl:text>		
					<xsl:apply-templates select="./inscope/li"/>
					<xsl:text>&#xa;&#xa;</xsl:text>					
				<!-- </UL> -->
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>
	<!--
			<xsl:template match="abstract">


<xsl:variable name="resdoc_name">
<xsl:call-template name="res_display_name">
<xsl:with-param name="res" select="/resource/@name"/>
</xsl:call-template>           
</xsl:variable>


<xsl:variable name="resdoc_stdnumber">
<xsl:call-template name="get_resdoc_stdnumber">
<xsl:with-param name="resdoc" select=".."/>
</xsl:call-template>           
</xsl:variable>

<P>
<xsl:value-of select="$resdoc_stdnumber"/>  specifies the integrated resource 
<xsl:value-of select="$resdoc_name"/>.
</P>

<xsl:apply-templates select="*"/>
</xsl:template>
	-->


	<xsl:template match="keywords">
		<xsl:variable name="keywords1">
			<xsl:if test="not(contains(.,'STEP'))">STEP, </xsl:if>
		</xsl:variable>

		<xsl:variable name="keywords2">
			<xsl:if test="not(contains(.,'10303'))">ISO 10303, </xsl:if>
		</xsl:variable>

		<xsl:variable name="keywords3">
			<xsl:if test="not(contains(.,'integrated resource'))">integrated resource, </xsl:if>
		</xsl:variable>

		<xsl:variable name="keywords4">
			<xsl:value-of select="."/>
		</xsl:variable>

		<xsl:value-of select="normalize-space(concat($keywords1, $keywords2, $keywords3,$keywords4))"/>

	</xsl:template>

	<!-- Outputs the foreword -->
	<!-- MWD 2018-03-02 #6538 replace the template below with this one after DIS -->
	<xsl:template match="resource" mode="foreword">
		<xsl:variable name="status" select="string(@status)"/>
		<xsl:variable name="part_no">
			<xsl:call-template name="get_resdoc_iso_number_without_status">
				<xsl:with-param name="resdoc" select="./@name"/>
			</xsl:call-template>
		</xsl:variable>
		
		<!-- <h2>
			<a name="foreword">
				Foreword
			</a>
		</h2> -->
		
		<xsl:text>.Foreword</xsl:text>
		<xsl:text>&#xa;&#xa;</xsl:text>
	
	
		<!-- <p> -->
		<xsl:call-template name="insertParagraph">
			<xsl:with-param name="text">
			ISO (the International Organization for Standardization) is a worldwide federation of national 
			standards bodies (ISO member bodies). The work of preparing International Standards is normally 
			carried out through ISO technical committees. Each member body interested in a subject for which a 
			technical committee has been established has the right to be represented on that committee. 
			International organizations, governmental and non-governmental, in liaison with ISO, also take part in 
			the work. ISO collaborates closely with the International Electrotechnical Commission (IEC) on all 
			matters of electrotechnical standardization.
			</xsl:with-param>
		</xsl:call-template>
		<!-- </p> -->
		<!-- <p> -->
		<xsl:call-template name="insertParagraph">
			<xsl:with-param name="text">
			The procedures used to develop this document and those intended for its further maintenance are 
			described in the ISO/IEC Directives, Part 1. In particular, the different approval criteria needed for the 
			different types of ISO documents should be noted. This document was drafted in accordance with the 
			editorial rules of the ISO/IEC Directives, Part 2 (see http://www.iso.org/directives[www.iso.org/directives]<!-- <a href="http://www.iso.org/directives" target="_blank">www.iso.org/directives</a> -->).
			</xsl:with-param>
		</xsl:call-template>
		<!-- <p> -->
		<xsl:call-template name="insertParagraph">
			<xsl:with-param name="text">
			Attention is drawn to the possibility that some of the elements of this document may be the subject of 
			patent rights. ISO shall not be held responsible for identifying any or all such patent rights. Details of 
			any patent rights identified during the development of the document will be in the Introduction and/or 
			on the ISO list of patent declarations received (see www.iso.org/patents[http://www.iso.org/patents]<!-- <a href="http://www.iso.org/patents" target="_blank">www.iso.org/patents</a> -->).
			</xsl:with-param>
		</xsl:call-template>
		
		<!-- <p> -->
		<xsl:call-template name="insertParagraph">
			<xsl:with-param name="text">
			Any trade name used in this document is information given for the convenience of users and does not 
			constitute an endorsement.
			</xsl:with-param>
		</xsl:call-template>
		
		<xsl:call-template name="insertParagraph">
			<xsl:with-param name="text">
			For an explanation on the voluntary nature of standards, the meaning of ISO specific terms and 
			expressions related to conformity assessment, as well as information about ISO's adherence to the 
			World Trade Organization (WTO) principles in the Technical Barriers to Trade (TBT) see http://www.iso.org/iso/foreword.html[www.iso.org/iso/foreword.html]<!-- <a href="http://www.iso.org/iso/foreword.html" target="_blank">www.iso.org/iso/foreword.html</a> -->.
			</xsl:with-param>
		</xsl:call-template>
		
		<!-- <p>
			This document was prepared by Technical Committee ISO/TC 184, <i>Automation systems and integration</i>, Subcommittee SC 4,
			<i>Industrial data.</i>
		</p> -->
		<xsl:call-template name="insertParagraph">
			<xsl:with-param name="text">
			This document was prepared by Technical Committee ISO/TC 184, _Automation systems and integration_, Subcommittee SC 4, _Industrial data_.
			</xsl:with-param>
		</xsl:call-template>
		
		<xsl:variable name="text6">
			<xsl:choose>
				<xsl:when test="not(./foreword)">
					<xsl:if test="@version!='1'">
						<xsl:variable name="this_edition">
							<xsl:choose>
								<xsl:when test="@version='2'">
									second
								</xsl:when>
								<xsl:when test="@version='3'">
									third
								</xsl:when>
								<xsl:when test="@version='4'">
									fourth
								</xsl:when>
								<xsl:when test="@version='5'">
									fifth
								</xsl:when>
								<xsl:when test="@version='6'">
									sixth
								</xsl:when>
								<xsl:when test="@version='7'">
									seventh
								</xsl:when>
								<xsl:when test="@version='8'">
									eighth
								</xsl:when>
								<xsl:when test="@version='9'">
									ninth
								</xsl:when>
							</xsl:choose>
						</xsl:variable>
						
						<xsl:variable name="prev_edition">
							<xsl:choose>
								<xsl:when test="@version='2'">
									first
								</xsl:when>
								<xsl:when test="@version='3'">
									second
								</xsl:when>
								<xsl:when test="@version='4'">
									third
								</xsl:when>
								<xsl:when test="@version='5'">
									fourth
								</xsl:when>
								<xsl:when test="@version='6'">
									fifth
								</xsl:when>
								<xsl:when test="@version='7'">
									sixth
								</xsl:when>
								<xsl:when test="@version='8'">
									seventh
								</xsl:when>
								<xsl:when test="@version='9'">
									eighth
								</xsl:when>
							</xsl:choose>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="@previous.revision.cancelled='NO'">
								This <xsl:value-of select="$this_edition"/> edition <!--of
								<xsl:value-of select="$part_no"/>-->
								cancels and replaces the
								<xsl:value-of select="$prev_edition"/> edition  
								(<xsl:value-of
									select="concat($part_no,':',@previous.revision.year)"/>),
								which has been technically revised. 
								
								<xsl:choose>
									<!-- only changed a section of the document -->
									<xsl:when test="@revision.complete='NO'">
										<xsl:value-of select="@revision.scope"/>
										of the <xsl:value-of select="$prev_edition"/> 
										edition  
										<xsl:choose>
											<!-- will be Clauses/Figures/ etc so if contains 'es' 
					 then must be plural-->
											<xsl:when test="contains(@revision.scope,'es')">
												have
											</xsl:when>
											<xsl:otherwise>
												has
											</xsl:otherwise>
										</xsl:choose>
										been technically revised.
									</xsl:when>
									<xsl:otherwise>
										<!-- complete revision so no extra text -->
									</xsl:otherwise>
								</xsl:choose>
								
							</xsl:when>
							
							<xsl:otherwise>
								<!-- cancelled -->
								This <xsl:value-of select="$this_edition"/> edition 
								cancels and replaces the
								<xsl:value-of select="$prev_edition"/> edition
								(<xsl:value-of
									select="concat($part_no,':',@previous.revision.year)"/>), 
								
								<xsl:choose>
									<!-- only changed a section of the document -->
									<xsl:when test="@revision.complete='NO'">
										of which 
										<xsl:value-of select="@revision.scope"/>
										<xsl:choose>
											<!-- will be Clauses/Figures/ etc so if contains 'es' 
					 then must be plural-->
											<xsl:when test="contains(@revision.scope,'es')">
												have
											</xsl:when>
											<xsl:otherwise>
												has
											</xsl:otherwise>
										</xsl:choose>
										been technically revised.
									</xsl:when>
									<xsl:otherwise>
										which has been technically revised.
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="./foreword"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:call-template name="insertParagraph">
			<xsl:with-param name="text"><xsl:value-of select="$text6"/></xsl:with-param>
		</xsl:call-template>
		
		<xsl:if test="./changes">
			<xsl:variable name="annex_letter">
				<xsl:choose>
					<xsl:when test="./examples and ./tech_discussion">G</xsl:when>
					<xsl:when test="./examples or ./tech_discussion">F</xsl:when>
					<xsl:otherwise>E</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<!-- <br/><br/>A detailed description of the changes is provided in Annex <a
				href="g_change{$FILE_EXT}">
				<xsl:value-of select="$annex_letter"/>
			</a>.  -->
			
			<xsl:call-template name="insertParagraph">
			<xsl:with-param name="text">A detailed description of the changes is provided in &lt;&lt;Annex<xsl:value-of select="$annex_letter"/>&gt;&gt;.
				</xsl:with-param>
		</xsl:call-template>
		</xsl:if>
		
		<!-- <p> -->
		<xsl:call-template name="insertParagraph">
			<xsl:with-param name="text">
			A list of all parts in the ISO 10303 series can be found on the http://standards.iso.org/iso/10303/tech/step_titles.htm[ISO website]<!-- <a href="http://standards.iso.org/iso/10303/tech/step_titles.htm" target="_blank">ISO website</a> -->. 
			</xsl:with-param>
		</xsl:call-template>
		
		<!-- <p> -->
		<xsl:call-template name="insertParagraph">
			<xsl:with-param name="text">
			Any feedback or questions on this document should be directed to the user’s national standards body. 
			A complete listing of these bodies can be found at https://www.iso.org/members.html[www.iso.org/members.html]<!-- <a href="https://www.iso.org/members.html">www.iso.org/members.html</a> -->.
			</xsl:with-param>
		</xsl:call-template>
		
	</xsl:template>
	
	<!--<xsl:template match="resource" mode="foreword">
		<xsl:variable name="status" select="string(@status)"/>
		<xsl:variable name="part_no">
			<xsl:call-template name="get_resdoc_iso_number_without_status">
				<xsl:with-param name="resdoc" select="./@name"/>
			</xsl:call-template>
		</xsl:variable>
		
		<h2>
			<a name="foreword">
				Foreword
			</a>
		</h2>
		<p>
			ISO (the International Organization for Standardization) is a worldwide
			federation of national standards bodies (ISO member bodies). The work of
			preparing International Standards is normally carried out through ISO
			technical committees. Each member body interested in a subject for
			which a technical committee has been established has the right to be
			represented on that committee. International organizations,
			governmental and non-governmental, in liaison with ISO, also take
			part in the work. ISO collaborates closely with the International
			Electrotechnical Commission (IEC) on all matters of electrotechnical
			standardization. 
		</p>
		
		<p>
			International Standards are drafted in accordance with the rules given in
			the ISO/IEC Directives, Part 2.
		</p>
		
		<p>
			The main task of technical committees is to prepare International
			Standards. Draft International Standards adopted by the technical
			committees are circulated to the member bodies for voting. Publication as
			an International Standard requires approval by at least 75% of the member
			bodies casting a vote.
		</p>
		<xsl:choose>
			
			
			<xsl:when test="contains($status,'TS') or contains($status,'PAS')">
				<p>
					In other circumstances, particularly when there is an urgent market
					requirement for such documents, a technical committee may decide to
					publish other types of normative document: 
				</p>
				
				<ul>
					<li>
						an ISO Publicly Available Specification (ISO/PAS) represents an
						agreement between technical experts in an ISO working group and  is
						accepted for publication if it is approved by more than 50% 
						of the members of the parent committee casting a vote;
					</li>  
					<li>
						an ISO Technical Specification (ISO/TS) represents an agreement between
						the members of a technical committee and is accepted for
						publication if it is approved by 2/3 of the members of the committee
						casting a vote. 
					</li>
				</ul>
				
				<!-\-<p>
		An ISO/PAS or ISO/TS is reviewed after three years in order to decide whether it will be confirmed for a further three years, revised to become an International Standard, or withdrawn. If the ISO/PAS or ISO/TS is confirmed, it is reviewed again after a further three years, at which time it must either be transformed into an International Standard or be withdrawn.
	</p>-\->
				
				<p>
					An ISO/PAS or ISO/TS is reviewed after three years in order to decide whether
					it will be confirmed for a further three years, revised to become an
					International Standard, or withdrawn. If the ISO/PAS or ISO/TS is confirmed, it
					is reviewed again after a further three years. At that time, an ISO/PAS must
					either be transformed into an International Standard or be withdrawn; an ISO/TS
					may be transformed into an International Standard or be continued as an
					ISO/TS or be withdrawn.
				</p> <!-\- MWD 2017-05-17 -\->
				
			</xsl:when>
		</xsl:choose>
		
		<p>
			Attention is drawn to the possibility that some of the elements of this
			part of ISO 10303 may be the subject of patent rights. ISO shall not be
			held responsible for identifying any or all such patent rights.
		</p>    
		
		<p>  
			<xsl:value-of select="$part_no"/>
			was prepared by Technical Committee ISO/TC 184, 
			<i>Automation systems and integration,</i>
			Subcommittee SC4, <i>Industrial data.</i>
		</p>
		<xsl:choose>
			<xsl:when test="not(./foreword)">
				<xsl:if test="@version!='1'">
					<xsl:variable name="this_edition">
						<xsl:choose>
							<xsl:when test="@version='2'">
								second
							</xsl:when>
							<xsl:when test="@version='3'">
								third
							</xsl:when>
							<xsl:when test="@version='4'">
								fourth
							</xsl:when>
							<xsl:when test="@version='5'">
								fifth
							</xsl:when>
							<xsl:when test="@version='6'">
								sixth
							</xsl:when>
							<xsl:when test="@version='7'">
								seventh
							</xsl:when>
							<xsl:when test="@version='8'">
								eighth
							</xsl:when>
							<xsl:when test="@version='9'">
								ninth
							</xsl:when>
						</xsl:choose>
					</xsl:variable>
					
					<xsl:variable name="prev_edition">
						<xsl:choose>
							<xsl:when test="@version='2'">
								first
							</xsl:when>
							<xsl:when test="@version='3'">
								second
							</xsl:when>
							<xsl:when test="@version='4'">
								third
							</xsl:when>
							<xsl:when test="@version='5'">
								fourth
							</xsl:when>
							<xsl:when test="@version='6'">
								fifth
							</xsl:when>
							<xsl:when test="@version='7'">
								sixth
							</xsl:when>
							<xsl:when test="@version='8'">
								seventh
							</xsl:when>
							<xsl:when test="@version='9'">
								eighth
							</xsl:when>
						</xsl:choose>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="@previous.revision.cancelled='NO'">
							This <xsl:value-of select="$this_edition"/> edition of
							<xsl:value-of select="$part_no"/>
							cancels and replaces the
							<xsl:value-of select="$prev_edition"/> edition  
							(<xsl:value-of
								select="concat($part_no,':',@previous.revision.year)"/>),
							which has been technically revised. 
							
							<xsl:choose>
								<!-\- only changed a section of the document -\->
								<xsl:when test="@revision.complete='NO'">
									<xsl:value-of select="@revision.scope"/>
									of the <xsl:value-of select="$prev_edition"/> 
									edition  
									<xsl:choose>
										<!-\- will be Clauses/Figures/ etc so if contains 'es' 
				 then must be plural-\->
										<xsl:when test="contains(@revision.scope,'es')">
											have
										</xsl:when>
										<xsl:otherwise>
											has
										</xsl:otherwise>
									</xsl:choose>
									been technically revised.
								</xsl:when>
								<xsl:otherwise>
									<!-\- complete revision so no extra text -\->
								</xsl:otherwise>
							</xsl:choose>
							
						</xsl:when>
						
						<xsl:otherwise>
							<!-\- cancelled -\->
							This <xsl:value-of select="$this_edition"/> edition 
							cancels and replaces the
							<xsl:value-of select="$prev_edition"/> edition
							(<xsl:value-of
								select="concat($part_no,':',@previous.revision.year)"/>), 
							
							<xsl:choose>
								<!-\- only changed a section of the document -\->
								<xsl:when test="@revision.complete='NO'">
									of which 
									<xsl:value-of select="@revision.scope"/>
									<xsl:choose>
										<!-\- will be Clauses/Figures/ etc so if contains 'es' 
				 then must be plural-\->
										<xsl:when test="contains(@revision.scope,'es')">
											have
										</xsl:when>
										<xsl:otherwise>
											has
										</xsl:otherwise>
									</xsl:choose>
									been technically revised.
								</xsl:when>
								<xsl:otherwise>
									which has been technically revised.
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="./foreword"/>
			</xsl:otherwise>
		</xsl:choose>
		
		<xsl:if test="./changes">
			<xsl:variable name="annex_letter">
				<xsl:choose>
					<xsl:when test="./examples and ./tech_discussion">G</xsl:when>
					<xsl:when test="./examples or ./tech_discussion">F</xsl:when>
					<xsl:otherwise>E</xsl:otherwise>
				</xsl:choose>
			</xsl:variable> A detailed description of the changes is provided in Annex <a
				href="g_change{$FILE_EXT}">
				<xsl:value-of select="$annex_letter"/>
			</a>. 
		</xsl:if>
		
		<p>
			ISO 10303 is organized as a series of parts, each
			published separately.  The structure of ISO 10303 is
			described in ISO 10303-1.
			<sup><a href="#future">1</a>)</sup>
		</p>
		<p>
			Each part of ISO 10303 is a
			member of one of the following series: description methods, implementation
			methods, conformance testing methodology and framework, integrated generic
			resources, integrated application resources, application protocols,
			abstract test suites, application interpreted constructs, and application
			modules. This part of ISO 10303 is a member of the 
			
			<xsl:choose>
				<xsl:when test="@part &gt; 500"> <!-\- AIC -\->
					application interpreted construct
				</xsl:when>
				<xsl:when test="@part &gt; 100"> <!-\- 100 series -\->
					integrated application resources
				</xsl:when>
				<xsl:otherwise>
					integrated generic resources
				</xsl:otherwise>
			</xsl:choose>
			series. The integrated generic resources, integrated application resources and the application interpreted constructs specify a single conceptual product data model. 
		</p>
		<p>
			A complete list of parts of ISO 10303 is available from the following URL: 
		</p>
		<div align="center">
			<blockquote>
				<A HREF="http://standards.iso.org/iso/10303/tech/step_titles.htm"   target="_blank">
					http://standards.iso.org/iso/10303/tech/step_titles.htm
				</A>
			</blockquote>
		</div>
		<p>
			<a name="future">
				<sup>1)</sup>A future edition of ISO 10303-1 will describe the application modules series. 
			</a>      
		</p>
	</xsl:template>-->

	<xsl:template match="schema_diag">
		<xsl:apply-templates select="express-g" mode="svg"/>  
	</xsl:template>

	<xsl:template match="inscope">
		<!-- <p> -->
			<!-- <a name="inscope"/> -->
			<xsl:text>&#xa;</xsl:text>
			<xsl:text>[[inscope]]</xsl:text>
			<xsl:text>&#xa;</xsl:text>
			<xsl:call-template name="insertParagraph">
			<xsl:with-param name="text">
				The following are within the scope of this part of ISO 10303:
			</xsl:with-param>
		</xsl:call-template>
		<!-- </p> -->
		<!--  output any issues -->
		<xsl:apply-templates select=".." mode="output_clause_issue">
			<xsl:with-param name="clause" select="'inscope'"/>
		</xsl:apply-templates>

		<!-- <ul> -->
		<xsl:text>&#xa;</xsl:text>
			<xsl:apply-templates/>
		<!-- </ul> -->
		<xsl:text>&#xa;&#xa;</xsl:text>
		
	</xsl:template>


	<xsl:template match="outscope">
		<!-- <p> -->
			<!-- <a name="outscope"/> -->
			<xsl:text>[[outscope]]</xsl:text>
			<xsl:text>&#xa;</xsl:text>
			<xsl:call-template name="insertParagraph">
				<xsl:with-param name="text">
					The following are outside the scope of this part of ISO 10303:
				</xsl:with-param>
			</xsl:call-template>
		<!-- </p> -->
		<!-- output any issues -->
		<xsl:apply-templates select=".." mode="output_clause_issue">
			<xsl:with-param name="clause" select="'outscope'"/>
		</xsl:apply-templates>

		<!-- <ul> -->
		<xsl:text>&#xa;</xsl:text>
			<xsl:apply-templates/>
		<!-- </ul> -->
		<xsl:text>&#xa;&#xa;</xsl:text>
	</xsl:template>


	<xsl:template match="resource" mode="annexc">
		<xsl:call-template name="annex_header">
			<xsl:with-param name="annex_no" select="'C'"/>
			<xsl:with-param name="heading" select="'Computer interpretable listings'"/>
			<xsl:with-param name="aname" select="'annexc'"/>
		</xsl:call-template>


		<xsl:variable name="UPPER" select="'ABCDEFGHIEYLMNOPQRSTUVWXYZ'"/>
		<xsl:variable name="LOWER" select="'abcdefghijklmnopqrstuvwxyz'"/>
		<xsl:variable name="mim_schema" select="translate(concat(@name,'_mim'),$LOWER, $UPPER)"/>


		<xsl:variable name="names_url" select="'http://standards.iso.org/iso/10303/tech/short_names/short-names.txt'"/>
		<xsl:variable name="smrl_version_number" select="document(concat($path, '../../../data/library/part.xml'))//part/@version.number"/> <!-- MWD 2018-02-23 -->
		<xsl:variable name="parts_url" select="concat('http://standards.iso.org/iso/10303/smrl/v', $smrl_version_number, '/tech/smrlv', $smrl_version_number, '.zip')"/> <!-- MWD 2018-02-23 -->

		<!-- <p> -->
		<xsl:call-template name="insertParagraph">
			<xsl:with-param name="text">
			This annex references a listing of the EXPRESS entity names and
			corresponding short names as specified or referenced in this part of ISO
			10303. It also provides a listing of each EXPRESS schema specified in this
			part of ISO 10303 without comments or other explanatory text. These
			listings are available in computer-interpretable form in Table C.1 and can
			be found at the following URLs:
			</xsl:with-param>
		</xsl:call-template>
		<!-- </p> -->
		
		
		<!-- <table>
			<tr>
				<td>&#160;&#160;</td>
				<td>Short names:</td>
				<td><a href="{$names_url}"   target="_blank"><xsl:value-of select="$names_url"/></a></td>
						</tr>
						<tr>
				<td>&#160;&#160;</td>
				<td></td>
				<td><a href="{$parts_url}"   target="_blank"><xsl:value-of select="$parts_url"/></a></td>
			</tr>
		</table>
		<p/> -->
		
		<xsl:text>Short names::: </xsl:text>
			<xsl:call-template name="insertHyperlink">
				<xsl:with-param name="a">
					<a href="{$names_url}"   target="_blank"><xsl:value-of select="$names_url"/></a>
				</xsl:with-param>
				<xsl:with-param name="asText">true</xsl:with-param>
			</xsl:call-template>
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>EXPRESS::: </xsl:text>
			<xsl:call-template name="insertHyperlink">
				<xsl:with-param name="a">
					<a href="{$parts_url}"   target="_blank"><xsl:value-of select="$parts_url"/></a>
				</xsl:with-param>
				<xsl:with-param name="asText">true</xsl:with-param>
			</xsl:call-template>		
		<xsl:text>&#xa;&#xa;</xsl:text>
		
		<!-- <div align="center">
			<a name="table_e1">
	<b>
		Table C.1 &#8212; EXPRESS listings
	</b>
			</a>
		</div> -->
		
		
		<xsl:text>[#table_e1]</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>[cols="^,^",options="header"]</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>.EXPRESS listings</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		
		<xsl:text>|===</xsl:text>
		<xsl:text>&#xa;</xsl:text>
			
		<!-- <xsl:text>EXPRESS listings:</xsl:text> -->
			
		<!-- <xsl:text>&#xa;&#xa;</xsl:text> -->
			
		<!-- <br/> -->
		
		<xsl:variable name="FILE_EXT" select="'.htm'"/>
		
		<!-- <div align="center">
			<table border="1" cellspacing="1">
				<tr>
					<xsl:choose>
						<xsl:when test="$FILE_EXT='.xml'">
							<td><b>XML file</b></td>
						</xsl:when>
						<xsl:otherwise>
							<td><b>HTML file</b></td>
						</xsl:otherwise>
					</xsl:choose>
					<td><b>ASCII file</b></td> -->
					<!--<xsl:choose>
						<xsl:when test="$FILE_EXT='.xml'"/>
						<xsl:otherwise>
							<td><b>Combined ASCII file</b></td>
						</xsl:otherwise>
					</xsl:choose> MWD 2017-05-31 -->
				<!-- </tr> -->
				
				<!-- table header -->
				
				<xsl:text>| </xsl:text>
				<xsl:choose>
					<xsl:when test="$FILE_EXT='.xml'">
						<xsl:text>XML file</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>HTML file</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text> | ASCII file</xsl:text>
				<xsl:text>&#xa;&#xa;</xsl:text>
				
				<!-- <xsl:text>| </xsl:text>
				<xsl:text>file</xsl:text>
				<xsl:text>&#xa;&#xa;</xsl:text> -->


			<xsl:variable name="wgnumber" select="./@wg.number.express"/>

			<xsl:for-each select="./schema" >

				<xsl:variable name="resource_dir">
					<!-- <xsl:call-template name="resource_directory">
						<xsl:with-param name="resource" select="@name"/>
					</xsl:call-template> -->
					<xsl:value-of select="concat('/resources/', @name)"/>
				</xsl:variable>

				<xsl:variable name="express_exp" select="concat($resource_dir,'/',@name,'.exp')"/>


				<xsl:variable name="pos" select="position()+3"/>
				<xsl:variable name="schema_file" select="./@name" />
				<xsl:variable name="schema_url">
					<xsl:choose>
						<xsl:when test="$FILE_EXT='.xml'">
							<xsl:value-of select="concat('c_exp_schema_',$pos,'.xml')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat('c_exp_schema_',$pos,'.htm')"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<!-- <tr>
					<td>
						<a href="{$schema_url}">
							<xsl:value-of select="concat($schema_file,$FILE_EXT)"/>
						</a>
					</td>
					<td>
						<a href="../../{$express_exp}"><xsl:value-of select="$schema_file"/>.exp</a>
					</td> -->
					
					
					<xsl:text>| </xsl:text>
					<xsl:call-template name="insertHyperlink">
						<xsl:with-param name="a">
							<a href="{$schema_url}">
								<xsl:value-of select="concat($schema_file,$FILE_EXT)"/>								
							</a>
						</xsl:with-param>
					</xsl:call-template>					
					<xsl:text> | </xsl:text>
					<xsl:call-template name="insertHyperlink">
						<xsl:with-param name="a">
							<a href="{$express_exp}"><xsl:value-of select="$schema_file"/>.exp</a>
						</xsl:with-param>
					</xsl:call-template>					 

					<xsl:text>&#xa;</xsl:text>
					
					<!--<xsl:if test="$FILE_EXT!='.xml'">
						<td>
				<xsl:variable name="test_wg_number">
					<xsl:call-template name="test_wg_number">
						<xsl:with-param name="wgnumber" select="$wgnumber"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="contains($test_wg_number,'Error')">
						<xsl:value-of select="concat('ISO/TC 184/SC 4/WG 12 N',$wgnumber)"/>
					</xsl:when>
					<xsl:otherwise>

						<a href="../wg12n{$wgnumber}.exp">
							<xsl:value-of select="concat('ISO/TC 184/SC 4/WG 12 N',$wgnumber)"/>
						</a>
					</xsl:otherwise>
				</xsl:choose>
						</td>
					</xsl:if>  MWD 2017-05-31 -->
				<!-- </tr> -->
			</xsl:for-each>
			<!-- </table> -->
		<!-- </div> -->
		
		<!-- resource -->
		<!-- <xsl:for-each select="schema">
			<xsl:variable name="schema_pos" select="position()"/>
				<xsl:apply-templates select="../../resource" mode="express_listings">
					<xsl:with-param name="pos" select="$schema_pos"/>
				</xsl:apply-templates>
		</xsl:for-each> -->
		
		
		
		
		<xsl:text>|===</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		
		<!--<p>
		If there is difficulty accessing these sites, contact ISO Central
		Secretariat.
	</p> removed by MWD 2018-08-23 -->
		<!-- <p class="note">
			<small>
				NOTE&#160;&#160;The information provided in computer-interpretable
				form at the 
				above URLs is informative. The information that is contained in the
				body of this part of ISO 10303 is normative. 
			</small>
		</p> -->
		
		<xsl:call-template name="insertNote">		
			<xsl:with-param name="text">
				The information provided in computer-interpretable
				form at the 
				above URLs is informative. The information that is contained in the
				body of this part of ISO 10303 is normative. 
			</xsl:with-param>
		</xsl:call-template>
		
	</xsl:template>


	<xsl:template name="output_express_links">
		<xsl:param name="wgnumber"/>
		<xsl:param name="file"/>
		<xsl:param name="express_exp"/>
		<td>
			<xsl:call-template name="insertHyperlink">
				<xsl:with-param name="a">
					<a href="../../{$express_exp}"><xsl:value-of select="$file"/></a>
				</xsl:with-param>
			</xsl:call-template>			
		</td>
		<td>
			<xsl:variable name="test_wg_number">
	<xsl:call-template name="test_wg_number">
		<xsl:with-param name="wgnumber" select="$wgnumber"/>
	</xsl:call-template>
			</xsl:variable>
			<xsl:choose>
	<xsl:when test="contains($test_wg_number,'Error')">
		<!--
				<xsl:call-template name="error_message">
				<xsl:with-param name="message">
				<xsl:value-of select="concat('(Error in
				resource.xml/resource/@wg.number.',$file,' - ',
				$test_wg_number)"/>
				</xsl:with-param>
				</xsl:call-template>
		-->
		<xsl:value-of select="$wgnumber"/>
	</xsl:when>
	<xsl:otherwise>
		<xsl:value-of select="concat('ISO/TC 184/SC 4/WG 12 N',$wgnumber)"/>
	</xsl:otherwise>
			</xsl:choose>    
		</td>
	</xsl:template>

	<xsl:template match="resource" mode="annexd">
		<xsl:call-template name="annex_header">
			<xsl:with-param name="annex_no" select="'D'"/>
			<xsl:with-param name="annex_id" select="'expg'"/>
			<xsl:with-param name="heading" 
					select="'EXPRESS-G diagrams'"/>
			<xsl:with-param name="aname" select="'annexd'"/>
		</xsl:call-template>

		<!-- <p> -->
		<!-- boilerplate text -->
		<xsl:call-template name="insertParagraph">
			<xsl:with-param name="text">
			The diagrams in this annex correspond to the EXPRESS schemas specified in this part of ISO 10303.
			The diagrams use the EXPRESS-G graphical notation for the EXPRESS language. EXPRESS-G is
			defined in ISO 10303-11.
			</xsl:with-param>
		</xsl:call-template>
		<!-- </p> -->

		<!-- <ul> -->		
					
			<xsl:for-each select="./schema/express-g/imgfile | ./schema/express-g/img" >
				<xsl:variable name="schema">
					<xsl:value-of select="substring-before(@file,'expg')"/>
				</xsl:variable>
				<xsl:variable name="ldiagno">
					<xsl:value-of select="substring-after(@file,'expg')"/>       
				</xsl:variable>
				<xsl:variable name="diagno">
					<xsl:value-of select="substring-before($ldiagno,'.xml')"/>
				</xsl:variable>

				<xsl:variable name="clauseno">
					<xsl:value-of select="position()"/>
				</xsl:variable>

				<xsl:variable name="rel_clauseno">
					<xsl:number/>
				</xsl:variable>

				<xsl:variable name="img_count">
					<xsl:value-of select="count(../imgfile)"/>
				</xsl:variable>

				<xsl:variable name="resource_dir">
					<xsl:call-template name="resource_directory">
						<xsl:with-param name="resource" select="$schema"/>
					</xsl:call-template>
				</xsl:variable>

				<xsl:variable name="expg_path" select="concat('../../',$resource_dir,'/',$schema,'expg',$diagno)"/>

				<xsl:variable name="schema_url">
					<xsl:choose>
						<xsl:when test="$FILE_EXT='.xml'">
							<xsl:value-of select="concat($expg_path,'.xml')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat($expg_path,'.htm')"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<!-- <li> -->
					<!-- <a href="{$schema_url}">
						<xsl:value-of select="concat('Figure D.',$clauseno, ' &#8212; EXPRESS-G diagram of the ', $schema, ' (', $rel_clauseno,' of ', $img_count, ')' )" />
					</a> -->
					<!-- 
					<xsl:text>* &lt;&lt;</xsl:text>
					<xsl:value-of select="concat($schema,'expg',$diagno)"/>
					<xsl:text>,</xsl:text>
					<xsl:value-of select="concat('Figure D.',$clauseno, ' &#8212; EXPRESS-G diagram of the ', $schema, ' (', $rel_clauseno,' of ', $img_count, ')' )" />
					<xsl:text>&gt;&gt;</xsl:text>
					<xsl:choose>
						<xsl:when test="position()!=last()">
							<xsl:value-of select="';'"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="'.'"/>        
						</xsl:otherwise>
					</xsl:choose>
					-->
					<!-- Changed to :  -->
					<!-- for https://github.com/metanorma/stepmod2mn/issues/14 -->
					
					<xsl:variable name="schema_name" select="ancestor::schema/@name"/>
					<xsl:variable name="map_file" select="concat($path, '../../resources/',$schema_name,'/',@file)"/>
					
					
					<!-- -->
					<xsl:call-template name="insertEXPRESSAnnotationStart">
						<xsl:with-param name="name" select="concat($schema_name, '.__expressg')"/>
						<xsl:with-param name="break" select="'false'"/>
					</xsl:call-template>
					
					<xsl:apply-templates select="." mode="svg_start"/> <!-- imgfile | img -->
					
					<!-- for index -->
					<!-- ((({{object.id}},Object EXPRESS-G))) -->
					<!-- <xsl:variable name="index_items">
						<xsl:apply-templates select="document($map_file)//img.area[@href]" mode="svg_index"/>
					</xsl:variable>
					<xsl:for-each select="xalan:nodeset($index_items)//item">
						<xsl:if test="not(preceding-sibling::item[text() = current()/text()])"> exclude duplicates
							<xsl:value-of select="."/>
							<xsl:text>&#xa;</xsl:text>
						</xsl:if>
					</xsl:for-each> -->
					
					<xsl:variable name="filename_no_ext">
						<xsl:value-of select="substring-before(@file,'.xml')"/>
					</xsl:variable>

					<xsl:value-of select="concat('.EXPRESS-G diagram of the ', $schema, ' (', $rel_clauseno,' of ', $img_count, ')' )" />
					<xsl:text>&#xa;</xsl:text>
					<!-- for ../../../../ see https://github.com/metanorma/stepmod2mn/issues/14 -->
					<xsl:value-of select="concat('image::', '../../../../resources/', $schema, '/', $filename_no_ext, '.svg[]')"/>
					
					<!-- </li> -->
					<xsl:text>&#xa;&#xa;</xsl:text>
				
					<xsl:apply-templates select="." mode="svg_end"/> <!-- imgfile | img -->
					
					<xsl:call-template name="insertEXPRESSAnnotationEnd"/>
				
			</xsl:for-each>
		<!-- </ul> -->
		<xsl:text>&#xa;&#xa;</xsl:text>

	</xsl:template>

	<!-- ((({{object.id}},Object EXPRESS-G))) -->
	<xsl:template match="img.area" mode="svg_index">
		<xsl:variable name="curr_file" select="ancestor::imgfile.content/@file"/>
		<xsl:variable name="this-schema">
			<xsl:variable name="part1">
				<xsl:choose>
					<xsl:when test="contains(translate(@href, '1234567890',''), 'expg.xml') and not(contains(@href, $curr_file))">
						<!-- excluding anchors which are in fact pointers to other imagemaps -->
					</xsl:when>
					<xsl:when test="contains(@href, '.xml')">
						<xsl:value-of select="substring-before(@href, '.xml')"/>
					</xsl:when>
					<xsl:when test="contains(@href, '#')">
						<xsl:value-of select="substring-before(@href, '#')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@href"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="contains($part1, '/')">
					<xsl:call-template name="substring-after-last">
						<xsl:with-param name="value" select="$part1"/>
						<xsl:with-param name="delimiter" select="'/'"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$part1"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="normalize-space($this-schema) != ''">
			<item>(((<xsl:value-of select="$this-schema"/>,Object EXPRESS-G)))</item>
		</xsl:if>
	</xsl:template>


	<xsl:template match="schema">
		<xsl:param name="pos"/>
		
		<xsl:variable name="schema_display_name">
			<xsl:call-template name="res_display_name">
				<xsl:with-param name="res" select="@name"/>
			</xsl:call-template>           
		</xsl:variable>

		<xsl:variable name="schema_no" select="$pos"/>

		<xsl:variable name="doctype">
			<xsl:apply-templates select="./ancestor::resource" mode="doctype"/>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="not($doctype='aic')">
				<xsl:call-template name="clause_header">
					<!-- <xsl:with-param name="heading" select="concat((number($schema_no)+3),' ',$schema_display_name)"/> -->
					<xsl:with-param name="heading" select="$schema_display_name"/>
					<xsl:with-param name="level" select="1"/>
					<xsl:with-param name="aname" select="concat('schema',$schema_no+3)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$doctype='aic'">
				<xsl:call-template name="clause_header">
					<!-- <xsl:with-param name="heading" select="concat((number($schema_no)+3),' ','EXPRESS short listing')"/> -->
					<xsl:with-param name="heading" select="'EXPRESS short listing'"/>
					<xsl:with-param name="level" select="1"/>
					<xsl:with-param name="aname" select="concat('schema',$schema_no+3)"/>
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>

		<!-- <xsl:message>
			<xsl:value-of select="'&#010;___________________________________________________________'"/>
			<xsl:value-of select="concat('&#010;Processing: data/resource_docs/',../@name,'/sys/',$schema_no+3,'_schema.xml','&#010;')"/>
		</xsl:message> -->


		<!-- not using -->
		<!-- <xsl:variable name="c_expg"
			select="concat('./c_',($schema_no+3),'schema_expg',$FILE_EXT)"/> -->

		<xsl:variable name="resource_dir">
			<xsl:call-template name="resource_directory">
				<xsl:with-param name="resource" select="@name"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="express_xml" select="document(concat($resource_dir,'/',@name,'.xml'))"/>

		<!-- there is only one schema in a schema clause of an IR -->
		<xsl:variable name="schema_name" select="@name"/>
		
		<xsl:variable name="arm_mim_schema">
			<xsl:choose>
				<xsl:when  test="$doctype='aic'">aic</xsl:when>
				<xsl:otherwise>schema</xsl:otherwise>
			</xsl:choose>
		</xsl:variable> 
		
		<xsl:call-template name="check_schema_name">
			<xsl:with-param name="arm_mim_schema" select="$arm_mim_schema"/>
			<xsl:with-param name="schema_name" select="$schema_name"/>
		</xsl:call-template>

		<xsl:variable name="xref">
			<xsl:call-template name="express_a_name">
				<xsl:with-param name="section1" select="$schema_name"/>
			</xsl:call-template>
		</xsl:variable>

		<!-- output the intro and fundamental contants.! -->
		<xsl:call-template name="clause_header">
			<!-- <xsl:with-param name="heading" select="concat(($schema_no+3),'.1 General')"/> -->
			<xsl:with-param name="heading" select="'General'"/>
			<xsl:with-param name="level" select="2"/>
			<xsl:with-param name="aname" select="concat('gen',$schema_no+3)"/>
		</xsl:call-template>

		<!-- output any issues -->
		<xsl:apply-templates select=".." mode="output_schema_clause_issue">
			<xsl:with-param name="clause" select="'schema_intro'"/>
			<xsl:with-param name="schema" select="$schema_name"/>
		</xsl:apply-templates>

		<xsl:variable name="introduction">
			<xsl:apply-templates select="./introduction"/>
		</xsl:variable>
		<xsl:if test="normalize-space($introduction) != ''">
			<xsl:call-template name="insertEXPRESSAnnotationStart">
				<xsl:with-param name="name" select="$schema_name"/>
			</xsl:call-template>
			<xsl:copy-of select="$introduction"/>
			<xsl:call-template name="insertEXPRESSAnnotationEnd"/>
		</xsl:if>
		
		<!-- <xsl:if test="normalize-space($introduction) != '' and 
		substring($introduction, string-length($introduction)) != '&#xd;' and
		substring($introduction, string-length($introduction)) != '&#xa;'"><xsl:text> </xsl:text></xsl:if> -->
		
		<xsl:variable name="clause_intro_1">This clause defines the information requirements to which implementations shall conform using the EXPRESS language as defined in ISO 10303-11. The following EXPRESS declaration begins the </xsl:variable>
		<xsl:variable name="clause_intro_2"> 
			<xsl:choose>
			<xsl:when  test="$doctype='aic'">
					schema that uses elements from the integrated resources and contains
the types, entity specializations, and functions that are specific to this part of ISO 10303.
			</xsl:when>
			<xsl:otherwise>
					and identifies the necessary external references.
			</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!-- <xsl:value-of select="$clause_intro_1"/>
		<xsl:element name='b'><xsl:value-of select="$schema_name" /></xsl:element>
		<xsl:value-of select="$clause_intro_2"/>
		<p/> -->
		
		<xsl:call-template name="insertParagraph">
			<xsl:with-param name="text">
				<xsl:value-of select="$clause_intro_1"/>
				<b><xsl:value-of select="$schema_name"/></b>
				<xsl:value-of select="$clause_intro_2"/>
				<!-- <xsl:value-of select="concat($clause_intro_1, '*', $schema_name, '*', $clause_intro_2)"/> -->
			</xsl:with-param>
		</xsl:call-template>
		
		
		<!-- <p> -->
		<xsl:call-template name="insertParagraph">
			<xsl:with-param name="text">
			Short names of entities defined in this schema are described in Annex A. Unambiguous identification of this schema is defined in Annex B.
			</xsl:with-param>
		</xsl:call-template>
		<!-- </p> -->
		
		<!-- <u>EXPRESS specification: </u> -->
		<xsl:call-template name="insertParagraph">
			<xsl:with-param name="text">
				[.underline]#EXPRESS specification:#
			</xsl:with-param>
		</xsl:call-template>
		
		<!-- <code>

			<br/>    <br/>
			*)<br/>
			<a name="{$xref}">
	SCHEMA <xsl:value-of select="concat($schema_name,';')"/>
			</a>
		</code> -->
		<xsl:if test="$xref != ''">
			<xsl:text>[[</xsl:text><xsl:value-of select="$xref"/><xsl:text>]]&#xa;</xsl:text>
		</xsl:if>
		<code>
		<xsl:call-template name="insertLutaMLCodeStart"/>
			<!-- <xsl:text>*)&#xa;</xsl:text>		 -->
			<xsl:text>SCHEMA </xsl:text><xsl:value-of select="concat($schema_name,';')"/>
		<xsl:call-template name="insertCodeEnd"/>
		</code>

		<!-- output all the EXPRESS specifications -->
		<!-- display the EXPRESS for the interfaces in the ARM.
	 The template is in sect4_express.xsl -->
		<xsl:if test="$express_xml/express/schema/interface">
			<!-- <a name="interfaces"/> -->
			<xsl:text>[[interfaces_</xsl:text><xsl:value-of select="$schema_name"/><xsl:text>]]</xsl:text>
			<xsl:text>&#xa;</xsl:text>
		</xsl:if>
		<!-- start
		express_xml=<xsl:value-of select="concat($resource_dir,'/',@name,'.xml')"/> -->
		<xsl:apply-templates select="$express_xml/express/schema/interface">
			<xsl:with-param name="doctype" select="$doctype"/>
		</xsl:apply-templates>
<!-- end -->


		<!--	<a name="funcon{$schema_no+3}" />  -->

		<xsl:call-template name="clause_header">
			<!-- <xsl:with-param name="heading" select="concat(($schema_no+3),'.2 Fundamental concepts and assumptions')"/> -->
			<xsl:with-param name="heading_num" select="concat(($schema_no+3),'.2')"/>
			<xsl:with-param name="heading" select="'Fundamental concepts and assumptions'"/>
			<xsl:with-param name="level" select="2"/>
			<!--    <xsl:with-param name="aname" select="concat('schema','position()')"/> -->
			<xsl:with-param name="aname" select="concat('funcon', $schema_no+3)"/>
		</xsl:call-template>

		<!-- output any issues -->
		<xsl:apply-templates select=".." mode="output_schema_clause_issue">
			<xsl:with-param name="clause" select="'fund_cons'"/>
			<xsl:with-param name="schema" select="$schema_name"/>
		</xsl:apply-templates>

		<xsl:variable name="fund_cons">
			<xsl:apply-templates select="./fund_cons"/>
		</xsl:variable>
		
		<xsl:call-template name="insertEXPRESSAnnotationStart">
			<xsl:with-param name="name" select="concat($schema_name, '.__fund_cons')"/>
		</xsl:call-template>
		<xsl:copy-of select="$fund_cons"/>
		<xsl:if test="not(java:endsWith(java:java.lang.String.new($fund_cons),'&#xa;') or java:endsWith(java:java.lang.String.new($fund_cons),'&#xd;'))">
			<xsl:text>&#xa;</xsl:text> <!-- &#xa; -->
		</xsl:if>
		<xsl:call-template name="insertEXPRESSAnnotationEnd"/>

		<!-- Move all EXPRESS-G diagrams (`[.svgmap]`) to Annex D https://github.com/metanorma/stepmod2mn/issues/20 -->
		<!-- <xsl:apply-templates select="./express-g" mode="svg"/> -->
	
		<!-- display the constant EXPRESS. The template is in sect4_express.xsl -->
		<xsl:apply-templates select="$express_xml/express/schema/constant">
			<xsl:with-param name="main_clause" select="($schema_no+3)" />
		</xsl:apply-templates>

		<!-- display the EXPRESS for the types in the schema.
	 The template is in sect4_express.xsl -->
		<xsl:apply-templates select="$express_xml/express/schema/type">
			<xsl:with-param name="main_clause" select="($schema_no+3)" />
		</xsl:apply-templates>

		<!-- display the EXPRESS for the entities in the schema.
	 The template is in sect4_express.xsl -->
		<xsl:apply-templates select="$express_xml/express/schema/entity">
			<xsl:with-param name="main_clause" select="$schema_no+3" />
		</xsl:apply-templates>

		<!-- display the EXPRESS for the subtype.contraints in the schema.
	 The template is in sect4_express.xsl -->
		<xsl:apply-templates select="$express_xml/express/schema/subtype.constraint">
			<xsl:with-param name="main_clause" select="$schema_no+3" />
		</xsl:apply-templates>

		<!-- display the EXPRESS for the functions in the schema
	 The template is in sect4_express.xsl -->
		<xsl:apply-templates select="$express_xml/express/schema/function">
			<xsl:with-param name="main_clause" select="($schema_no+3)" />
		</xsl:apply-templates>
		
		<!-- display the EXPRESS for the rules in the schema. 
	 The template is in sect4_express.xsl -->
		<xsl:apply-templates select="$express_xml/express/schema/rule">
			<xsl:with-param name="main_clause" select="$schema_no+3" />
		</xsl:apply-templates>

		<!-- display the EXPRESS for the procedures in the schema. 
	 The template is in sect4_express.xsl -->
		<xsl:apply-templates select="$express_xml/express/schema/procedure">
			<xsl:with-param name="main_clause" select="$schema_no+3" />
		</xsl:apply-templates>
		<!-- <code>
			<br/>    <br/>
			*)<br/>
			END_SCHEMA;&#160;&#160;- - &#160;<xsl:value-of select="$express_xml/express/schema/@name"/>
			<br/>(*
		</code> -->
		<code>
		<xsl:call-template name="insertLutaMLCodeStart"/>
			<!-- <xsl:text>*)&#xa;</xsl:text>					 -->
			<xsl:text>END_SCHEMA;  -- </xsl:text><xsl:value-of select="$express_xml/express/schema/@name"/>
			<!-- <xsl:text>&#xa;</xsl:text>
			<xsl:text>(*</xsl:text> -->
		<xsl:call-template name="insertCodeEnd"/>
		</code>

		<!-- <xsl:message>
			<xsl:value-of select="'&#010;___________________________________________________________'"/>
			<xsl:value-of select="concat('&#010;EndProcessing: data/resource_docs/',../@name,'/sys/',$schema_no+3,'_schema.xml','&#010;')"/>
		</xsl:message> -->

	</xsl:template>

	<xsl:template match="uof" mode="toc">
		<xsl:variable name="href" select="concat('#uof',@name)"/>
		<!-- <li>
			<a href="{$href}">
				<xsl:choose>
					<xsl:when test="position()!=last()">
						<xsl:value-of select="concat(@name,';')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat(@name,'.')"/>        
					</xsl:otherwise>
				</xsl:choose>
			</a>
		</li> -->
		
		<xsl:call-template name="insertParagraph">
			<xsl:with-param name="text">
					* &lt;&lt;
					<xsl:choose>
						<xsl:when test="position()!=last()">
							<xsl:value-of select="concat(@name,';')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat(@name,'.')"/>        
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text>, </xsl:text>
					<xsl:value-of select="$href"/>
				
					<xsl:text>&gt;&gt;</xsl:text>
				</xsl:with-param>
		</xsl:call-template>
		
	</xsl:template>

	<xsl:template match="uoflink" mode="toc">
		<xsl:variable name="resource" select="@resource"/>
		<xsl:variable name="uof" select="@uof"/>
		<xsl:variable name="xref" select="concat('#uof',$uof)"/>
		<!-- <li>
			<xsl:choose>
				<xsl:when test="position()!=last()">
					<a href="{$xref}">
						<xsl:value-of select="concat($uof,';')"/>
					</a>
				</xsl:when>
				<xsl:otherwise>
					<a href="{$xref}">
						<xsl:value-of select="concat($uof,'.')"/>        
					</a>
				</xsl:otherwise>
			</xsl:choose>
		</li> -->
		<xsl:call-template name="insertParagraph">
			<xsl:with-param name="text">
					* &lt;&lt;
				<xsl:choose>
					<xsl:when test="position()!=last()">					
						<xsl:value-of select="concat($uof,';')"/>					
					</xsl:when>
					<xsl:otherwise>					
						<xsl:value-of select="concat($uof,'.')"/>
					</xsl:otherwise>
				</xsl:choose>		
				<xsl:text>, </xsl:text>
				<xsl:value-of select="$xref"/>
				<xsl:text>&gt;&gt;</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>


	<!-- build a list of normrefs that are used by the resource.
			 The list comprises:
			 All normrefs explicitly included in the resource by normref.inc
			 All default normrefs that define terms for which abbreviations are provided and listed in ../data/basic/abbreviations_default.xml
			 All resources referenced by a USE FROM in any schema
	-->
	<xsl:template name="normrefs_list">
		<xsl:param name="current_resource"/>

		<xsl:variable name="doctype">
			<xsl:apply-templates select="$current_resource" mode="doctype"/>
		</xsl:variable>

		<!-- get all default normrefs listed in ../../data/basic/normrefs_resdoc_default.xml -->
		<xsl:variable name="normref_list1">
			<xsl:choose>
	<xsl:when test="not($doctype='aic')">
		<xsl:call-template name="get_normref">
			<xsl:with-param 
		name="normref_nodes" 
		select="document(concat($path, '../../../data/basic/normrefs_resdoc_default.xml'))/normrefs/normref.inc"/>
			<xsl:with-param 
		name="normref_list" 
		select="''"/>
		</xsl:call-template> 
	</xsl:when>
	<xsl:when test="$doctype='aic'">
		<xsl:call-template name="get_normref">
			<xsl:with-param 
		name="normref_nodes" 
		select="document(concat($path, '../../../data/basic/normrefs_aic_default.xml'))/normrefs/normref.inc"/>
			<xsl:with-param 
		name="normref_list" 
		select="''"/>
		</xsl:call-template> 
	</xsl:when>
			</xsl:choose>   
		</xsl:variable>

		<!--
	<xsl:message>
	l1:<xsl:value-of select="$normref_list1"/>:l1
	</xsl:message>
		-->


		<!-- get all normrefs explicitly included in the resource by normref.inc -->
		<xsl:variable name="normref_list2">
			<xsl:call-template name="get_normref">
	<xsl:with-param 
			name="normref_nodes" 
			select="/resource/normrefs/normref.inc"/>
	<xsl:with-param 
			name="normref_list" 
			select="$normref_list1"/>
			</xsl:call-template>    
		</xsl:variable>
		<!--
	<xsl:message>
	l2:<xsl:value-of select="$normref_list2"/>:l2
	</xsl:message>
		-->

		<!-- get all normrefs that define terms for which abbreviations are
	 provided.
	 Get the abbreviation.inc from abbreviations_default.xml, 
	 get the referenced abbreviation from abbreviations.xml
	 then get the normref in which the term is defined
		-->
		<xsl:variable name="normref_list3">
			<xsl:choose>
	<xsl:when test="not($doctype='aic')">
		<xsl:call-template name="get_normrefs_from_abbr">
			<xsl:with-param 
		name="abbrvinc_nodes" 
		select="document(concat($path, '../../../data/basic/abbreviations_resdoc_default.xml'))/abbreviations/abbreviation.inc"/>
			<xsl:with-param 
		name="normref_list" 
		select="$normref_list2"/>
		</xsl:call-template>
	</xsl:when>
	<xsl:when test="$doctype='aic'">
		<xsl:call-template name="get_normrefs_from_abbr">
			<xsl:with-param 
		name="abbrvinc_nodes" 
		select="document(concat($path, '../../../data/basic/abbreviations_aic_default.xml'))/abbreviations/abbreviation.inc"/>
			<xsl:with-param 
		name="normref_list" 
		select="$normref_list2"/>
		</xsl:call-template>
	</xsl:when>
			</xsl:choose>    

		</xsl:variable>
		<!--
	<xsl:message>
	l3:<xsl:value-of select="$normref_list3"/>:l3
	</xsl:message>
		-->

		<!-- get all resources referenced by a USE FROM 
	 - need to get this working -->
		<xsl:variable name="resource_dir">
			<xsl:call-template name="resource_directory">
	<xsl:with-param name="resource" select="/resource/@name"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="schema_xml" 
			select="concat($resource_dir,'/resource.xml')"/>
		<!-- for now hard code as normref_list3
	 <xsl:variable name="normref_list4">
	 
	 <xsl:call-template name="get_normrefs_from_schema">
	 <xsl:with-param 
	 name="interface_nodes" 
	 select="document($schema_xml)/express/schema/interface"/>
	 <xsl:with-param 
	 name="normref_list" 
	 select="$normref_list3"/>
	 </xsl:call-template>
	 </xsl:variable>
		-->

		<xsl:variable name="normref_list4" 
			select="$normref_list3"/>
		<!--
	<xsl:message>
	l4:<xsl:value-of select="$normref_list4"/>:l4
	</xsl:message>
		-->
		<xsl:value-of select="$normref_list4"/>
	</xsl:template>

	<!-- given a list of normref nodes, add the ids of the normrefs to the
			 normref_list, if not already a member. ids in normref_list are
			 separated by a , -->
	<xsl:template name="get_normref">
		<xsl:param name="normref_nodes"/>
		<xsl:param name="normref_list"/>
		
		<xsl:variable name="normref_list_ret">
			<xsl:choose>
	<xsl:when test="$normref_nodes">

		<xsl:variable name="first">
			<xsl:choose>
				<xsl:when test="$normref_nodes[1]/@normref">
		<xsl:value-of 
				select="concat('normref:',$normref_nodes[1]/@normref)"/>
				</xsl:when>
				<xsl:when test="$normref_nodes[1]/@resource.name">
		<xsl:value-of 
				select="concat('resource:',$normref_nodes[1]/@resource.name)"/>
				</xsl:when>            
				<xsl:when test="$normref_nodes[1]/@resource.name">
		<xsl:value-of 
				select="concat('resource:',$normref_nodes[1]/@resource.name)"/>
				</xsl:when>            
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="normref_list1">
			<xsl:call-template name="add_normref">
				<xsl:with-param name="normref" select="$first"/>
				<xsl:with-param name="normref_list" select="$normref_list"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:call-template name="get_normref">
			<xsl:with-param 
		name="normref_nodes" 
		select="$normref_nodes[position()!=1]"/>
			<xsl:with-param 
		name="normref_list" 
		select="$normref_list1"/>
		</xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
		<!-- end of recursion -->
		<xsl:value-of select="$normref_list"/>
	</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="$normref_list_ret"/>
	</xsl:template>

	<!-- given a list of abbreviation.inc nodes, add the ids of the normrefs to the
			 normref_list, if not already a member. ids in normref_list are
			 separated by a , -->
	<xsl:template name="get_normrefs_from_abbr">
		<xsl:param name="abbrvinc_nodes"/>
		<xsl:param name="normref_list"/>
		
		<xsl:variable name="normref_list_ret">
			<xsl:choose>
	<xsl:when test="$abbrvinc_nodes">
		<xsl:variable name="abbr.inc" select="$abbrvinc_nodes[1]/@linkend"/>

		<xsl:variable name="abbr" 
			select="document(concat($path, '../../../data/basic/abbreviations.xml'))/abbreviation.list/abbreviation[@id=$abbr.inc]"/>

		<xsl:variable name="first">
			<xsl:choose>
				<xsl:when test="$abbr/term.ref/@normref">
		<xsl:value-of 
				select="concat('normref:',$abbr/term.ref/@normref)"/>
				</xsl:when>
				<xsl:when test="$abbr/term.ref/@resource.name">
		<xsl:value-of 
				select="concat('resource:',$abbr/term.ref/@resource.name)"/>
				</xsl:when>            
				<xsl:when test="$abbr/term.ref/@resource.name">
		<xsl:value-of 
				select="concat('resource:',$abbr/term.ref/@resource.name)"/>
				</xsl:when>            
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="normref_list1">
			<xsl:call-template name="add_normref">
				<xsl:with-param name="normref" select="$first"/>
				<xsl:with-param name="normref_list" select="$normref_list"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:call-template name="get_normrefs_from_abbr">
			<xsl:with-param 
		name="abbrvinc_nodes" 
		select="$abbrvinc_nodes[position()!=1]"/>
			<xsl:with-param 
		name="normref_list" 
		select="$normref_list1"/>
		</xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
		<!-- end of recursion -->
		<xsl:value-of select="$normref_list"/>
	</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:value-of select="$normref_list_ret"/>

	</xsl:template>


	<!-- 
			 given a list of interface nodes defined in an express schema,
			 add the names of the modules referenced by the interface to the list
			 of normative references.
	-->
	<xsl:template name="get_normrefs_from_schema">
		<xsl:param name="interface_nodes"/>
		<xsl:param name="normref_list"/>

		<xsl:variable name="normref_list_ret">
			<xsl:choose>
	<xsl:when test="$interface_nodes">
		<xsl:variable name="schema" select="$interface_nodes[1]/@schema"/>
		<xsl:variable name="UPPER">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
		<xsl:variable name="LOWER">abcdefghijklmnopqrstuvwxyz</xsl:variable>
		<xsl:variable name="schema_lcase"
			select="translate($schema,$UPPER, $LOWER)"/>
		
		<xsl:variable name="resource_name">
			<xsl:choose>
				<xsl:when test="contains($schema_lcase,'_arm')">
		<xsl:value-of 
				select="concat('resource:',substring-before($schema_lcase,'_arm'))"/>
				</xsl:when>
				<xsl:when test="contains($schema_lcase,'_mim')">
		<xsl:value-of 
				select="concat('resource:',substring-before($schema_lcase,'_mim'))"/>
				</xsl:when>
				<xsl:otherwise>
		<xsl:value-of 
				select="concat('resource:',$schema_lcase)"/>          
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="normref_list1">
			<xsl:call-template name="add_normref">
				<xsl:with-param name="normref" select="$resource_name"/>
				<xsl:with-param name="normref_list" select="$normref_list"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:call-template name="get_normrefs_from_schema">
			<xsl:with-param 
		name="interface_nodes" 
		select="$interface_nodes[position()!=1]"/>
			<xsl:with-param 
		name="normref_list" 
		select="$normref_list1"/>
		</xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
		<!-- end of recursion -->
		<xsl:value-of select="$normref_list"/>
	</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="$normref_list_ret"/>
	</xsl:template>


	<!-- add a normref id to the set of normref ids. -->
	<xsl:template name="add_normref">
		<xsl:param name="normref"/>
		<xsl:param name="normref_list"/>
		<!-- end the list with a , -->
		<xsl:variable name="normref_list_term"
			select="concat($normref_list,',')"/>
		<xsl:variable name="normref_list1">
			<xsl:choose>
	<xsl:when test="contains($normref_list_term, concat(',',$normref,','))">
		<xsl:value-of select="$normref_list"/>
	</xsl:when>
	<xsl:otherwise>
		<xsl:value-of select="concat($normref_list,',',$normref,',')"/>      
	</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="$normref_list1"/>
	</xsl:template>
	

	<xsl:template name="prune_normrefs_list">
		<xsl:param name="normrefs_list"/>
		<xsl:param name="pruned_normrefs_list" select="''"/>
		<xsl:param name="pruned_normrefs_ids" select="''"/>
		<xsl:choose>
			<xsl:when test="$normrefs_list">
	<xsl:variable 
			name="first"
			select="substring-before(substring-after($normrefs_list,','),',')"/>
	<xsl:variable 
			name="rest"
			select="substring-after(substring-after($normrefs_list,','),',')"/>

	<xsl:variable name="add_to_pruned_normrefs_ids">
		<xsl:choose>
			<xsl:when test="contains($first,'normref:')">
				<!--  The default or explicit deal normrefs have
			 already been pruned so just add -->
				<xsl:variable 
			name="id" 
			select="substring-after($first,'normref:')"/>
			
				<xsl:variable name="normref_xml" select="document(concat($path, '../../../data/basic/normrefs.xml'))"/>
				<xsl:variable name="normref_node" select="$normref_xml/normref.list/normref[@id=$id]"/>
				<xsl:choose>
					<xsl:when test="$normref_node">
					
						<xsl:variable name="normref">
							<xsl:apply-templates select="$normref_xml/normref.list/normref[@id=$id]" mode="prune_normrefs_list"/>
						</xsl:variable>
						<!-- return the normref to be added to the list -->
						<xsl:value-of select="$normref"/>
						
					</xsl:when>
					
					<xsl:otherwise>
						<xsl:call-template name="error_message">
							<xsl:with-param name="message">
								<xsl:value-of select="concat('Error 7: reference with id ', $id, ' not found')"/>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:otherwise>
					
				</xsl:choose>
			</xsl:when>

			<xsl:when test="contains($first,'resource:')">
				<xsl:variable 
			name="resource" 
			select="substring-after($first,'resource:')"/>
				
				<xsl:variable name="resource_dir">
		<xsl:call-template name="resource_directory">
			<xsl:with-param name="resource" select="$resource"/>
		</xsl:call-template>
				</xsl:variable>
				
				<xsl:variable name="resource_ok">
		<xsl:call-template name="check_resource_exists">
			<xsl:with-param name="schema" select="$resource"/>
		</xsl:call-template>
				</xsl:variable>
				
				<xsl:variable name="resource_xml" 
					select="document(concat($resource_dir,'/resource.xml'))"/>

				
				<!-- output the normative reference derived from the resource -->
				<xsl:variable name="normref">
					<xsl:if test="$resource_ok='true'">
						<xsl:apply-templates 
								select="$resource_xml/resource"
								mode="prune_normrefs_list"/>
					</xsl:if>
				</xsl:variable>
				
				<!-- if the normref for the resource has been already been added,
			 ignore -->
				<xsl:if test="not(contains($pruned_normrefs_ids,$normref))">
		<!-- return the normref to be added to the list -->
		<xsl:value-of select="$normref"/>
				</xsl:if>
			</xsl:when>
			<xsl:when test="contains($first,'resource:')">
				<!-- 
			 NO PRUNING TAKING PLACE - JUST MAKING SURE THAT THE
			 RESOURCE STAY IN THE LIST -->
				<xsl:variable 
			name="resource" 
			select="substring-after($first,'resource:')"/>
				<xsl:value-of select="$resource"/>
			</xsl:when>
			<xsl:otherwise/>
			
		</xsl:choose>
	</xsl:variable> <!-- add_to_pruned_normrefs_ids -->
	
	<xsl:variable name="new_pruned_normrefs_ids">
		<xsl:choose>
			<xsl:when test="string-length($add_to_pruned_normrefs_ids)>0">
				<xsl:value-of 
			select="concat($pruned_normrefs_ids,',',$add_to_pruned_normrefs_ids,',')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$pruned_normrefs_ids"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="new_pruned_normrefs_list">
		<xsl:choose>
			<xsl:when test="string-length($add_to_pruned_normrefs_ids)>0">
				<xsl:value-of 
			select="concat($pruned_normrefs_list,',',$first,',')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$pruned_normrefs_list"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:call-template name="prune_normrefs_list">
		<xsl:with-param name="normrefs_list" select="$rest"/>
		<xsl:with-param name="pruned_normrefs_list" 
				select="$new_pruned_normrefs_list"/>
		<xsl:with-param name="pruned_normrefs_ids" 
				select="$new_pruned_normrefs_ids"/>
	</xsl:call-template>  

			</xsl:when>
			<xsl:otherwise>
	<!-- end of recursion -->
	<xsl:value-of select="$pruned_normrefs_list"/>
			</xsl:otherwise>
		</xsl:choose>   
	</xsl:template>

	<xsl:template match="normref" mode="prune_normrefs_list">
		<xsl:value-of select="concat(./stdref/stdnumber,./stdref/pubdate)"/>
	</xsl:template>


	<xsl:template match="resource" mode="prune_normrefs_list">
		<xsl:value-of select="concat('10303-',./@part,./@publication.year)"/>
	</xsl:template>


	<!-- Output the standard set of normative references and then any added by
			 the resource
			 This is the main template for outputting normrefs. It is called from
			 the sect_2_refs.xsl
	-->
	<xsl:template name="output_normrefs">
		<xsl:param name="resource_number"/>
		<xsl:param name="current_resource"/>

		<!-- <h2>Normative references</h2> --> <!-- 2 Normative references -->
		
		<xsl:text>[bibliography]</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>== </xsl:text>
		<xsl:text>Normative references</xsl:text>
		<xsl:text>&#xa;&#xa;</xsl:text>
		
		
		<!--<p>
			The following referenced documents are indispensable for the application of
			this document. For dated references, only the edition cited applies. For
			undated references, the latest edition of the referenced document
			(including any amendments) applies.
		</p>--> 
		
		<!-- MWD 2018-07-04 6538 the above paragraph replaced with this one -->
		<!-- <p> -->	
		<xsl:call-template name="insertParagraph">
			<xsl:with-param name="text">
			The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. 
			For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.
			</xsl:with-param>
		</xsl:call-template>
		<!-- </p> -->		
		
		<!-- output any issues -->
		<xsl:apply-templates select="." mode="output_clause_issue">
			<xsl:with-param name="clause" select="'normrefs'"/>
		</xsl:apply-templates>  


		<!-- output the normative references explicitly defined in the resource -->
		<xsl:apply-templates select="/resources/normrefs/normref">
			<xsl:with-param name="current_resource" select="$current_resource"/>
		</xsl:apply-templates>


		<!-- output the default normative references 
		-->

		<xsl:call-template name="output_default_normrefs">
			<xsl:with-param name="resource_number" select="$resource_number"/>
			<xsl:with-param name="current_resource" select="$current_resource"/>
		</xsl:call-template>

	</xsl:template>

	<!-- output the default normative reference -->
	<xsl:template name="output_default_normrefs">
		<xsl:param name="resource_number"/>
		<xsl:param name="current_resource"/>

		<xsl:variable name="normrefs">
			<xsl:call-template name="normrefs_list">
				<xsl:with-param name="current_resource" select="$current_resource"/>
			</xsl:call-template>
		</xsl:variable>
		<!--
	<xsl:message>
	normrefs:<xsl:value-of select="$normrefs"/>:normrefs
	</xsl:message> 
		-->

		<xsl:variable name="pruned_normrefs">
			<xsl:call-template name="prune_normrefs_list">
				<xsl:with-param name="normrefs_list" select="$normrefs"/>
			</xsl:call-template>  
		</xsl:variable>

		<!--
	<xsl:message>
	pruned_normrefs:<xsl:value-of select="$pruned_normrefs"/>:pruned_normrefs
	</xsl:message>
		-->

	<xsl:variable name="normrefs_to_be_sorted">
		<xsl:call-template name="output_normrefs_rec">
			<xsl:with-param name="normrefs" select="$pruned_normrefs"/>
			<xsl:with-param name="resource_number" select="$resource_number"/>
		</xsl:call-template>  
	</xsl:variable>

	<xsl:for-each select="xalan:nodeset($normrefs_to_be_sorted)/normref">
		
		<!-- sorting basis is special normalized string, consisting of organization, series and part number all of equal lengths per each element -->
		<xsl:sort select='part'/>
		
		<xsl:for-each select="string"> <!-- /* -->
			<!-- <xsl:copy-of select="."/>			 -->
			<xsl:value-of select="."/>			
		</xsl:for-each>
		
		<!-- <xsl:for-each select="string">
				<xsl:text>* </xsl:text><xsl:value-of select="normalize-space(.)"/>
				<xsl:text>&#xa;&#xa;</xsl:text>				
			</xsl:for-each> -->
		
	</xsl:for-each>

	<!-- <xsl:choose>
		<xsl:when test="function-available('msxsl:node-set')">
			<xsl:variable name="normrefs_to_be_sorted_set" select="msxsl:node-set($normrefs_to_be_sorted)"/>
			<xsl:for-each select="$normrefs_to_be_sorted_set/normref">
				
				<xsl:sort select='part'/>
				
				<xsl:for-each select="string/*">
					<xsl:copy-of select="."/>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:when>
		<xsl:when test="function-available('exslt:node-set')">    
			<xsl:variable name="normrefs_to_be_sorted_set" select="exslt:node-set($normrefs_to_be_sorted)"/>
			<xsl:for-each select="$normrefs_to_be_sorted_set/normref">
				
				<xsl:sort select='part'/>
				
				<xsl:for-each select="string/*">
					<xsl:copy-of select="."/>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:when>
	</xsl:choose> -->

		<!-- output a footnote to say that the normative reference has not been
	 published -->

		<xsl:call-template name="output_unpublished_normrefs">
			<xsl:with-param name="normrefs" select="$normrefs"/>
		</xsl:call-template>

		<!-- output a footnote to say that the normative reference has not been
	 published -->
		<xsl:call-template name="output_derogated_normrefs">
			<xsl:with-param name="normrefs" select="$normrefs"/>
			<xsl:with-param name="current_resource" select="$current_resource"/>
		</xsl:call-template>
		
	</xsl:template>

	<xsl:template name="output_normrefs_rec">
		<xsl:param name="resource_number"/>
		<xsl:param name="normrefs"/>

		<xsl:choose>
			<xsl:when test="$normrefs">
	<xsl:variable 
			name="first"
			select="substring-before(substring-after($normrefs,','),',')"/>
	<xsl:variable 
			name="rest"
			select="substring-after(substring-after($normrefs,','),',')"/>      

	<xsl:choose>
		<xsl:when test="contains($first,'normref:')">
			<xsl:variable 
		name="normref" 
		select="substring-after($first,'normref:')"/>

			<xsl:variable name="normref_xml" select="document(concat($path, '../../../data/basic/normrefs.xml'))"/>

			<xsl:variable 
		name="normref_node"
		select="$normref_xml/normref.list/normref[@id=$normref]"/>
			
			<xsl:choose>
				<xsl:when test="$normref_node">   
		<!-- don't output the normref if referring to current resource
		-->
		<!-- normref stdnumber are 10303-1107 whereas resource numbers are
				 1107, so remove the 10303- -->
		<xsl:variable name="part_no" 
						select="substring-after($normref_node/stdref/stdnumber,'-')"/>
						<xsl:element name="normref">
							 <xsl:element name="string">
								<xsl:if test="$resource_number!=$part_no">
									<!-- OOUTPUT from normative references -->
										<xsl:apply-templates select="$normref_xml/normref.list/normref[@id=$normref]"/>
								</xsl:if>
							</xsl:element>
							<xsl:variable name="part">
								<xsl:value-of select="$normref_xml/normref.list/normref[@id=$normref]/stdref/stdnumber"/>
							</xsl:variable>
							<xsl:variable name="orgname">
								<xsl:value-of select="$normref_xml/normref.list/normref[@id=$normref]/stdref/orgname"/>
							</xsl:variable>
							<!-- eliminate status info like TS, CD-TS, etc -->
							<xsl:variable name="orgname_cleaned">
								<xsl:choose>
									<xsl:when test="$orgname='ISO'">AISO</xsl:when>
									<xsl:when test="$orgname='ISO/TS'">AISO</xsl:when>
									<xsl:when test="$orgname='ISO/IEC'">BIEC</xsl:when>
									<xsl:when test="$orgname='IEC'">CIEC</xsl:when>
									<xsl:otherwise>D<xsl:value-of select="$orgname"/></xsl:otherwise>
								</xsl:choose>   
							</xsl:variable>
							
							
							
							<!-- Try to 'normalize' part and subpart numbers -->
								<!--<xsl:variable name="series" select="substring-before($part,'-')"/>-->
							
							<xsl:variable name="series">
								<xsl:choose>
									<xsl:when test="contains($part, '-')">
										<xsl:value-of select="substring-before($part,'-')"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="$part"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							
							
							
							
								<!-- normalize with longest possible series (10303) -->                    
								<xsl:variable name="series_norm">
								<xsl:choose>
									<xsl:when test="string-length($series)=1">0000<xsl:value-of select="$series"/></xsl:when>
									<xsl:when test="string-length($series)=2">000<xsl:value-of select="$series"/></xsl:when>
									<xsl:when test="string-length($series)=3">00<xsl:value-of select="$series"/></xsl:when>
									<xsl:when test="string-length($series)=4">0<xsl:value-of select="$series"/></xsl:when>
									<xsl:when test="string-length($series)=5"><xsl:value-of select="$series"/></xsl:when>
									<xsl:otherwise>00000</xsl:otherwise>
<!--                    <xsl:call-template name="error_message">
											<xsl:with-param name="message">
												<xsl:value-of select="concat('Unsupported length of series number: ', $series, 'length: ', string-length($series))"/>
											</xsl:with-param>
										</xsl:call-template> -->
								</xsl:choose>
								</xsl:variable>
								<!-- normalize with longest possible part (4 digits) -->                    
								<xsl:variable name="part_norm">
								<xsl:choose>
									<xsl:when test="string-length($part_no)=1">-000<xsl:value-of select="$part_no"/></xsl:when> 
									<xsl:when test="string-length($part_no)=2">-00<xsl:value-of select="$part_no"/></xsl:when>
									<xsl:when test="string-length($part_no)=3">-0<xsl:value-of select="$part_no"/></xsl:when>
									<xsl:when test="string-length($part_no)=4">-<xsl:value-of select="$part_no"/></xsl:when>
									<xsl:otherwise>-0000</xsl:otherwise>
<!--                    <xsl:call-template name="error_message">
											<xsl:with-param name="message">
												<xsl:value-of select="concat('Unsupported length of part number: ', $part_no, 'length: ', string-length($part_no))"/>
											</xsl:with-param>
										</xsl:call-template> -->
								</xsl:choose>
								</xsl:variable>
								<xsl:element name="part">
								<!-- Organization name -->
									<xsl:value-of select="$orgname_cleaned"/>-<xsl:value-of select="$series_norm"/><xsl:value-of select="$part_norm"/>
								</xsl:element>
						</xsl:element>

				</xsl:when>
				<xsl:otherwise>
		<xsl:call-template name="error_message">
			<xsl:with-param name="message">
				<xsl:value-of select="concat('Error 7: ', $normref, 'not found')"/>
			</xsl:with-param>
		</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>

		<xsl:when test="contains($first,'resource:')">
			<xsl:variable 
		name="resource" 
		select="substring-after($first,'resource:')"/>
			
			<xsl:variable name="resource_dir">
				<xsl:call-template name="resource_directory">
		<xsl:with-param name="resource" select="$resource"/>
				</xsl:call-template>
			</xsl:variable>
			
			<xsl:variable name="resource_xml" 
				select="document(concat($resource_dir,'/resource.xml'))"/>
			
			<!-- output the normative reference derived from the resource -->
				<xsl:element name="normref">
				<xsl:apply-templates 
				select="$resource_xml/resource" mode="normref">
				</xsl:apply-templates>
		</xsl:element>
			
		</xsl:when>
		
		<xsl:when test="contains($first,'resource:')">
			<xsl:variable 
		name="resource" 
		select="substring-after($first,'resource:')"/>
			<xsl:call-template name="output_resource_normref">
				<xsl:with-param name="resource_schema" select="$resource"/>
			</xsl:call-template>          
		</xsl:when>
	</xsl:choose>
	
	<xsl:call-template name="output_normrefs_rec">
		<xsl:with-param name="normrefs" select="$rest"/>
		<xsl:with-param name="resource_number" select="$resource_number"/>
	</xsl:call-template>
	
			</xsl:when>
			<xsl:otherwise/>
			<!-- end of recursion -->
		</xsl:choose>
	</xsl:template>
	

	<!-- output a footnote to say that the normative reference has not been
			 published 
			 Check the normative references in the nodule, then all the auto
			 generated normrefs. These should be passed as a parameter the value of
			 which is deduced by: template name="normrefs_list"
	-->
	<xsl:template name="output_unpublished_normrefs">
		<xsl:param name="normrefs"/>

		<xsl:variable name="footnote">
			<xsl:choose>
				<xsl:when test="/resource/normrefs/normref/stdref[@published='n']">
					<xsl:value-of select="'y'"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="output_unpublished_normrefs_rec">
						<xsl:with-param name="normrefs" select="$normrefs"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:if test="$footnote='y'">
			<!-- <p>
	<a name="tobepub">
		<sup>1)</sup> To be published.
	</a>      
			</p> -->
		</xsl:if>
	</xsl:template>

	<xsl:template name="output_unpublished_normrefs_rec">
		<xsl:param name="normrefs"/>

		<xsl:choose>
			<xsl:when test="$normrefs">
				<xsl:variable 
						name="first"
						select="substring-before(substring-after($normrefs,','),',')"/>
				<xsl:variable 
						name="rest"
						select="substring-after(substring-after($normrefs,','),',')"/>      
				
				<xsl:variable name="footnote">
					<xsl:choose>
						<xsl:when test="contains($first,'normref:')">
							<xsl:variable name="normref" select="substring-after($first,'normref:')"/>
							<xsl:choose>
								<xsl:when test="document(concat($path, '../../../data/basic/normrefs.xml'))/normref.list/normref[@id=$normref]/stdref[@published='n']">
									<xsl:value-of select="'y'"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="'n'"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>

						<xsl:when test="contains($first,'resource:')">
							<xsl:variable name="resource" select="substring-after($first,'resource:')"/>
							
							<xsl:variable name="resource_dir">
								<xsl:call-template name="resource_directory">
									<xsl:with-param name="resource" select="$resource"/>
								</xsl:call-template>
							</xsl:variable>

							<xsl:variable name="resource_xml" select="concat($resource_dir,'/resource.xml')"/>

							<xsl:choose>
								<xsl:when test="document($resource_xml)/resource[@published='n']">
									<xsl:value-of select="'y'"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="'n'"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>

						<xsl:otherwise>
							<xsl:value-of select="'n'"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:choose>
					<xsl:when test="$footnote='n'">
						<!-- only recurse if no unpublished standard found -->      
						<xsl:call-template name="output_unpublished_normrefs_rec">
							<xsl:with-param name="normrefs" select="$rest"/>
						</xsl:call-template>        
					</xsl:when>
					<xsl:otherwise>
						<!-- footnote found so stop -->
						<xsl:value-of select="'y'"/>
					</xsl:otherwise>
				</xsl:choose>
	
			</xsl:when>
			<xsl:otherwise>
			<!-- end of recursion -->
			<!-- <xsl:value-of select="$footnote"/> -->
				<xsl:value-of select="'n'"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- output a footnote to say that the normative reference has been
			 derogated 
			 Check the normative references in the nodule, then all the auto
			 generated normrefs. These should be passed as a parameter the value of
			 which is deduced by: template name="normrefs_list"
	-->
	<xsl:template name="output_derogated_normrefs">
		<xsl:param name="current_resource"/>
		<xsl:param name="normrefs"/>

		<xsl:variable name="footnote">
			<xsl:choose>
	<xsl:when 
			test="( string($current_resource/@status)='TS' or 
			string($current_resource/@status)='IS') and
			( string(./@status)='CD' or string(./@status)='CD-TS')">
		<xsl:value-of select="'y'"/>
	</xsl:when>
	<xsl:otherwise>
		<xsl:if test="( string($current_resource/@status)='TS' or 
			string($current_resource/@status)='IS')">
			<xsl:call-template name="output_derogated_normrefs_rec">
				<xsl:with-param name="normrefs" select="$normrefs"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:if test="$footnote='y'">
			<!-- <p>
	<a name="derogation">
		2) Reference applicable during ballot or review period.
	</a>      
			</p> -->
		</xsl:if>
	</xsl:template>

	<xsl:template name="output_derogated_normrefs_rec">
		<xsl:param name="normrefs"/>

		<xsl:choose>
			<xsl:when test="$normrefs">
	<xsl:variable 
			name="first"
			select="substring-before(substring-after($normrefs,','),',')"/>
	<xsl:variable 
			name="rest"
			select="substring-after(substring-after($normrefs,','),',')"/>      
	
	<xsl:variable name="footnote">
		<xsl:choose>
			<!-- ASSUMING THAT ALL NORMREFS IN normrefs.xml ARE
		 PUBLISHED THERE FORE CANNOT BE DEROGATED 

<xsl:when test="contains($first,'normref:')">
<xsl:variable 
name="normref" 
select="substring-after($first,'normref:')"/>
<xsl:choose>
<xsl:when
test="document('../../data/basic/normrefs.xml')/normref.list/normref[@id=$normref]/stdref[@published='n']">
<xsl:value-of select="'y'"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="'n'"/>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
			-->

			<xsl:when test="contains($first,'resource:')">
				<xsl:variable 
			name="resource" 
			select="substring-after($first,'resource:')"/>
				
				<xsl:variable name="resource_dir">
		<xsl:call-template name="resource_directory">
			<xsl:with-param name="resource" select="$resource"/>
		</xsl:call-template>
				</xsl:variable>

				<xsl:variable name="resource_xml" 
					select="concat($resource_dir,'/resource.xml')"/>

				<xsl:variable name="resource_status" 
					select="string(document($resource_xml)/resource/@status)"/>
				<xsl:choose>
		<xsl:when test="$resource_status='CD-TS' or $resource_status='CD'">
			<xsl:value-of select="'y'"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="'n'"/>
		</xsl:otherwise>
				</xsl:choose>
			</xsl:when>

			<xsl:otherwise>
				<xsl:value-of select="'n'"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:choose>
		<xsl:when test="$footnote='n'">
			<!-- only recurse if no unpublished standard found -->      
			<xsl:call-template name="output_derogated_normrefs_rec">
				<xsl:with-param name="normrefs" select="$rest"/>
			</xsl:call-template>        
		</xsl:when>
		<xsl:otherwise>
			<!-- footnote found so stop -->
			<xsl:value-of select="'y'"/>
		</xsl:otherwise>
	</xsl:choose>
	
			</xsl:when>
			<xsl:otherwise>
	<!-- end of recursion -->
	<!-- <xsl:value-of select="$footnote"/> -->
	<xsl:value-of select="'n'"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>



	<!-- get the normrefs out of the normrefs.xml database -->
	<xsl:template match="normref.inc">
		<xsl:param name="current_resource"/>

		<xsl:variable name="ref" select="@ref"/>
		
		<xsl:variable name="normref_xml" select="document(concat($path, '../../../data/basic/normrefs.xml'))"/>
		<xsl:variable name="normref_node" select="$normref_xml/normref.list/normref[@id=$ref]"/>

		<xsl:if test="$normref_node">
			<xsl:apply-templates select="$normref_xml/normref.list/normref[@id=$ref]">
				<xsl:with-param name="current_resource" select="$current_resource"/>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>

	<xsl:template name="output_resource_normref">
		<xsl:param name="resource_schema"/>
		<xsl:variable name="ir_ok">
			<xsl:call-template name="check_resource_exists">
	<xsl:with-param name="schema" select="$resource_schema"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="ir_ref">
			<xsl:if test="$ir_ok='true'">
	<xsl:value-of 
			select="document(concat('../../data/resources/',
				$resource_schema,'/',$resource_schema,'.xml'))/express/@reference"/>
			</xsl:if>
		</xsl:variable>

		<p>
			<xsl:call-template name="error_message">
	<xsl:with-param name="message">
		<xsl:value-of 
				select="concat('Warning 8: MIM uses schema ', 
					$resource_schema, 
					'Make sure you include Integrated resource (',
					$ir_ref,
					') that defines it as a normative reference. ',
					'Use: normref.inc')"/>
	</xsl:with-param>
	<xsl:with-param name="inline" select="'no'"/>
			</xsl:call-template>
		</p>
	</xsl:template>

	<xsl:template match="resource" mode="normref">
	<xsl:element name="string">
	<p>
		<xsl:variable name="part">
			<xsl:choose>
				<xsl:when test="string-length(@part)>0">
					<xsl:value-of select="@part"/>
				</xsl:when>
				<xsl:otherwise>
					&lt;part&gt;
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="stdnumber">
			<xsl:call-template name="get_module_stdnumber_undated">
				<xsl:with-param name="module" select="."/>
			</xsl:call-template>
		</xsl:variable>

		
		<xsl:variable name="stdtitle"
			select="concat('Industrial automation systems and integration ',
							'&#8212; Product data representation and exchange ')"/>

		<xsl:variable name="module_name">
			<xsl:call-template name="module_display_name">
				<xsl:with-param name="module" select="@name"/>
			</xsl:call-template>
		</xsl:variable>

		<!--<xsl:variable name="subtitle"
			select="concat('&#8212; Part ',$part,': Application module: ', $module_name,'.')"/>-->
		<xsl:variable name="subtitle"
			select="concat('&#8212; Part ',$part,': Application module: ', $module_name)"/><!-- 2018-08-22 MAW full-stop removed -->
		
		<!-- Printing of standard line starts here -->
		<xsl:value-of select="$stdnumber"/>
		<xsl:choose><!-- if the module is a TS or IS module and is referring to a CD or CD-TS module -->
			<xsl:when 
				test="( string(./@status)='TS' or 
							string(./@status)='IS') and
							( string(./@status)='CD' or string(./@status)='CD-TS')">
						<xsl:text> footnote:[Reference applicable during ballot or review period.]</xsl:text>
				<!-- &#160;<sup><a href="#derogation">2</a>)</sup> -->
			</xsl:when>
			<xsl:when test="@published='n'"><xsl:text> footnote:[To be published.]</xsl:text><!-- &#160;<sup><a href="#tobepub">1</a>)</sup> -->
			</xsl:when>
		</xsl:choose>, 
		<!-- <i>
			<xsl:value-of select="$stdtitle"/>
			<xsl:value-of select="$subtitle"/>
		</i> -->
		<xsl:text> _</xsl:text>
			<xsl:value-of select="$stdtitle"/>
			<xsl:value-of select="$subtitle"/>
		<xsl:text>_</xsl:text>
	</p>
	</xsl:element>    
	<xsl:element name="part">
	<!-- Need to 'normalize' the length so that we can easier sort it -->
		<xsl:choose>
			<xsl:when test="string-length(@part)=1">ISO-10303-000<xsl:value-of select="@part"/></xsl:when>
			<xsl:when test="string-length(@part)=2">ISO-10303-00<xsl:value-of select="@part"/></xsl:when>
			<xsl:when test="string-length(@part)=3">ISO-10303-0<xsl:value-of select="@part"/></xsl:when>
			<xsl:when test="string-length(@part)=4">ISO-10303-<xsl:value-of select="@part"/></xsl:when>      
			<xsl:otherwise>
						<xsl:call-template name="error_message">
							<xsl:with-param name="message">
								<xsl:value-of select="concat('Unsupported length of part number: ', @part, 'length: ', string-length(@part))"/>
							</xsl:with-param>
						</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:element>
	</xsl:template>

	<!-- Output the normative reference -->
	<xsl:template match="normref">
	<xsl:variable name="stdnumber">
<!--    <xsl:choose>
			<xsl:when test="stdref/pubdate">
				<xsl:value-of select="concat(stdref/orgname,'&#160;',stdref/stdnumber,':',stdref/pubdate)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat(stdref/orgname,'&#160;',stdref/stdnumber,':&#8212;&#160;')"/>
			</xsl:otherwise>
		</xsl:choose> -->
		<xsl:value-of 
			select="concat(stdref/orgname,' ',stdref/stdnumber)"/>
	</xsl:variable>
	<!-- <li> -->
		
		<xsl:text>* [[[</xsl:text>
			<xsl:value-of select="@id"/>
			<xsl:text>,</xsl:text>
			<xsl:value-of select="$stdnumber"/>
		<xsl:text>]]]</xsl:text>
	
		<!-- <xsl:value-of select="$stdnumber"/> -->
		
		<xsl:if test="stdref[@published='n']">
			<xsl:text> footnote:[To be published.]</xsl:text><!-- <sup><a href="#tobepub">1</a>)</sup> -->
		</xsl:if><xsl:text>, </xsl:text>
		
		<!-- <i> -->
		<xsl:text>_</xsl:text><xsl:value-of select="normalize-space(stdref/stdtitle)"/>
			<xsl:variable name="subtitle" select="normalize-space(stdref/subtitle)"/>
			<!-- 2018-08-22 MAW full-stop not added and removed if it already exists -->
			<!--<xsl:choose>
				<xsl:when test="substring($subtitle, string-length($subtitle)) != '.'">
					<xsl:value-of select="concat($subtitle,'.')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$subtitle"/>
				</xsl:otherwise>
			</xsl:choose>-->
			<xsl:choose>
				<xsl:when test="substring($subtitle, string-length($subtitle)) = '.'">
					<xsl:value-of select="substring($subtitle, 1, (string-length($subtitle)-1))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$subtitle"/>
				</xsl:otherwise>
			</xsl:choose>
		<!-- </i> -->
		<xsl:text>_</xsl:text>
		<xsl:text>&#xa;&#xa;</xsl:text>
	<!-- </li> -->
	</xsl:template>


	<!-- Output the standard set of abbreviations and then any added by
			 the resource
	-->
	<xsl:template name="output_abbreviations">
		<xsl:param name="section"/>
		
		<!-- <a name="abbrv">3.2 Abbreviated terms</a> -->
		<!-- <h2 level="2">      
			<a name="abbrv">Abbreviated terms</a>
		</h2> -->
	<xsl:call-template name="insertHeaderADOC">
		<xsl:with-param name="id" select="'abbrv'"/>		
		<xsl:with-param name="level" select="2"/>
		<xsl:with-param name="header" select="'Abbreviated terms'"/>		
	</xsl:call-template>


		<!-- output any issues -->
		<xsl:apply-templates select="." mode="output_clause_issue">
			<xsl:with-param name="clause" select="'abbreviations'"/>
		</xsl:apply-templates>


		<!-- <p> -->
			<!-- RBN Changed due to request from ISO
		 For the purposes of this part of ISO 10303, -->
		 <xsl:call-template name="insertParagraph">
			<xsl:with-param name="text">
				For the purposes of this document, 
				the following abbreviated terms apply:
			</xsl:with-param>
		</xsl:call-template>
		<!-- </p> -->
		<!-- <table width="80%" type="abbreviations"> -->
			<!-- get the default abbreviations out of the abbreviations_resdoc_defaultxml
		 database -->
			<xsl:variable name="abbreviations_resdoc_default_xml" select="document(concat($path, '../../../data/basic/abbreviations_resdoc_default.xml'))"/>
			<xsl:apply-templates select="$abbreviations_resdoc_default_xml/abbreviations/abbreviation.inc"/>
			
			<xsl:apply-templates select="/resource/abbreviations" mode="output"/>    
			<xsl:text>&#xa;</xsl:text>
		<!-- </table> -->
	</xsl:template>
	

	<!-- Output the standard set of abbreviations and then any added by
			 the resource
	-->
	<xsl:template match="abbreviations" mode="output">
		<!-- output any abbreviations defined in the resource-->
		<xsl:apply-templates select="/resource/abbreviations/abbreviation"/>

		<!-- output any abbreviations defined in the resource-->
		<xsl:apply-templates select="/resource/abbreviations/abbreviation.inc"/>
	</xsl:template>

	<!-- get the abbreviations out of the abbreviations.xml database -->
	<xsl:template match="abbreviation.inc">
		<xsl:variable name="ref" select="@linkend"/>
		<xsl:variable name="abbrev" select="document(concat($path, '../../../data/basic/abbreviations.xml'))/abbreviation.list/abbreviation[@id=$ref]"/>
		<xsl:choose>
			<xsl:when test="$abbrev">
				<xsl:apply-templates select="$abbrev"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="error_message">
					<xsl:with-param name="message">
						<xsl:value-of select="concat('Error 9: abbreviation.inc ',$ref, 'not found: ')"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>


	<!-- output the abbreviation. The term is defined in the normative
			 references -->
	<xsl:template match="abbreviation">
		<!-- <tr>
			<td>
					<xsl:value-of select="acronym"/>
			</td>
			<td>
				<xsl:apply-templates select="./term" mode="abbreviation"/>
				<xsl:apply-templates select="term.ref" mode="abbreviation"/>
			</td>
		</tr> -->
		
		<xsl:value-of select="acronym"/>
		<xsl:text>:: </xsl:text>
		<xsl:apply-templates select="./term" mode="abbreviation"/>
		<xsl:apply-templates select="term.ref" mode="abbreviation"/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>

	<xsl:template match="term.ref" mode="abbreviation">
		<xsl:variable name="termref" select="./@linkend"/>
		<xsl:variable name="normref" select="./@normref"/>
		<xsl:variable name="term" select="document(concat($path, '../../../data/basic/normrefs.xml'))/normref.list/normref/term[@id=$termref]"/>
		<xsl:choose>
			<xsl:when test="$term">
				<xsl:value-of select="normalize-space($term)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="error_message">
					<xsl:with-param name="message">
						<xsl:value-of select="concat('Error 10: term.ref ',$termref, 'not found: ')"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="term" mode="abbreviation">
		<xsl:value-of select="normalize-space(.)"/>
	</xsl:template>


	<xsl:template match="term">
		<xsl:param name="show_id" select="'true'"/>
		<xsl:variable name="nterm" select="normalize-space(.)"/>
		<!-- <a name="term-{$nterm}">
			<xsl:value-of select="$nterm"/>
		</a> -->
		<xsl:if test="$show_id = 'true'">
		<xsl:text>[[</xsl:text>
		<xsl:value-of select="concat('term-', translate($nterm, ' ', '_'))"/>
		<xsl:text>]]</xsl:text>
		</xsl:if>
		<xsl:value-of select="$nterm"/>
		<xsl:apply-templates select="../synonym"/>
	</xsl:template>

	<xsl:template match="synonym">
		<!-- <br/> -->
		<xsl:text> +&#xa;</xsl:text>
		<xsl:value-of select="normalize-space(.)"/>
	</xsl:template>


	<!-- output the normative references, terms, definitions and abbreviated terms -->
	<xsl:template name="output_terms">
		<xsl:param name="resource_number"/>
		<xsl:param name="current_resource"/>


		<!-- output any issues -->
		<xsl:apply-templates select="." mode="output_clause_issue">
			<xsl:with-param name="clause" select="'definition'"/>
		</xsl:apply-templates>

		<!-- get a list of normative references that have terms defined -->
		<xsl:variable name="normrefs">
			<xsl:call-template name="normrefs_terms_list">
				<xsl:with-param name="current_resource" select="$current_resource"/>
			</xsl:call-template>
		</xsl:variable>

		<!-- output the included terms -->
		<xsl:call-template name="output_normrefs_terms_rec">
			<xsl:with-param name="normrefs" select="$normrefs"/>
			<xsl:with-param name="normref_ids" select="$normrefs"/>
			<xsl:with-param name="section" select="0"/>
			<xsl:with-param name="resource_number" select="$resource_number"/>
			<xsl:with-param name="current_resource" select="$current_resource"/>
		</xsl:call-template>

		<xsl:variable name="def_section">
			<xsl:call-template name="length_normrefs_list">
				<xsl:with-param name="resource_number" select="$resource_number"/>
				<xsl:with-param name="normrefs_list" select="$normrefs"/>
			</xsl:call-template>
		</xsl:variable>

		<!-- output any definitions defined in this resource -->
		<xsl:if test="/resource/definition">
			<!-- output the section head first -->
			<xsl:call-template name="output_resource_term_section">
				<xsl:with-param name="resource" select="/resource"/>
				<xsl:with-param name="section" select="concat('3.1.',$def_section+1)"/>
			</xsl:call-template>
			<!-- RBN Changed due to request from ISO
		 For the purposes of this part of ISO 10303, -->              
			<!-- <p> -->
			<xsl:call-template name="insertParagraph">
				<xsl:with-param name="text">
					For the purposes of this document, 
					the following terms and definitions apply:
				</xsl:with-param>
			</xsl:call-template>
				<!-- </p> -->			
			
		</xsl:if>

		<!-- increment the section number depending on whether a definition
	 section has been output -->
		<xsl:variable name="def_section1">
			<xsl:choose>
				<xsl:when test="/resource/definition">
					<xsl:value-of select="$def_section+1"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$def_section"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:apply-templates select="/resource/definition">
			<xsl:with-param name="section" select="concat('3.1.',$def_section1)"/>
			<xsl:sort select="term"/>
		</xsl:apply-templates>

		<xsl:call-template name="output_abbreviations">
			<xsl:with-param name="section" select="$def_section1+1"/>
		</xsl:call-template>
	</xsl:template>


	<!-- Given a list of normative references, output any terms from them -->
	<xsl:template name="output_normrefs_terms_rec">
		<xsl:param name="normrefs"/>
		<xsl:param name="normref_ids"/>
		<xsl:param name="section"/>
		<xsl:param name="resource_number"/>
		<xsl:param name="current_resource"/>

		<xsl:variable name="doctype">
			<xsl:apply-templates select="$current_resource" mode="doctype"/>
		</xsl:variable>


		<xsl:choose>
			<xsl:when test="$normrefs">

				<xsl:variable name="first" select="substring-before(substring-after($normrefs,','),',')"/>
				<xsl:variable name="section_no" select="$section+1"/>
				<xsl:variable name="rest" select="substring-after(substring-after($normrefs,','),',')"/>      

				<xsl:choose>
					<xsl:when test="contains($first,'normref:')">
						<xsl:variable name="ref" select="substring-after($first,'normref:')"/>
						<xsl:variable name="normref" select="document(concat($path, '../../../data/basic/normrefs.xml'))/normref.list/normref[@id=$ref]"/>

						<!-- get the number of the standard -->      
						<xsl:variable name="stdnumber" select="concat($normref/stdref/orgname, ' ',$normref/stdref/stdnumber)"/>

						<!-- output the section header for the normative reference that is
					 defining terms 
					 IGNORE if the normative ref is referring to this resource
						-->
						<!-- normref stdnumber are 10303-1107 whereas resource numbers are
					 1107, so remove the 10303- -->
						<xsl:variable name="part_no" select="substring-after($normref/stdref/stdnumber,'-')"/>
						<xsl:if test="$resource_number!=$part_no">
							<!-- <xsl:value-of select="concat('3.1.',$section_no, ' Terms defined in ',$stdnumber)"/> -->
							<!-- <h2 level="3" id="{concat('3.1.',$section_no)}">					
								<xsl:value-of select="concat('Terms defined in ',$stdnumber)"/>
							</h2> -->				
							<xsl:call-template name="insertHeaderADOC">
								<xsl:with-param name="id" select="concat('sec_3.1.',$section_no)"/>		
								<xsl:with-param name="attributes" select="'.nonterm'"/>
								<xsl:with-param name="level" select="2"/> <!-- 3 -->
								<xsl:with-param name="header" select="concat('Terms defined in ',$stdnumber)"/>					
							</xsl:call-template>
							
							<!-- RBN Changed due to request from ISO
						 For the purposes of this part of ISO 10303, -->              
						 <xsl:call-template name="insertParagraph">
								<xsl:with-param name="text">
									For the purposes of this document, 
									the following terms defined in 
									<xsl:value-of select="$stdnumber"/>
									<xsl:text> apply:</xsl:text>
								</xsl:with-param>
							</xsl:call-template>
							<!-- <ul> -->							
							
					<!-- now output the terms -->
						<xsl:variable name="moreNormRefs" select="string-length(/resource/normrefs/normref.inc[@normref=$ref]/term.ref)+string-length(/resource/normrefs/normref.inc)+1"/>
								<xsl:choose>
									<xsl:when test="not($doctype='aic')">
									
										<xsl:variable name="normrefs_resdoc_default_xml" select="document(concat($path, '../../../data/basic/normrefs_resdoc_default.xml'))"/>
										
										<xsl:variable name="normrefs_resdoc_default_node" select="$normrefs_resdoc_default_xml/normrefs/normref.inc[@normref=$ref]"/>
										
										<xsl:choose>
											<xsl:when test="$normrefs_resdoc_default_node">
												<xsl:apply-templates select="$normrefs_resdoc_default_xml/normrefs/normref.inc[@normref=$ref]/term.ref" mode="normref">
													<xsl:with-param name="current_resource" select="$current_resource"/>
													<xsl:with-param name="moreNormRefs" select="$moreNormRefs"/>
												</xsl:apply-templates>
											</xsl:when>
											
											<xsl:otherwise>
												<xsl:call-template name="error_message">
													<xsl:with-param name="message">
														<xsl:value-of select="concat('Error 7: reference with id ', $ref, ' not found')"/>
													</xsl:with-param>
												</xsl:call-template>
											</xsl:otherwise>
											
										</xsl:choose>
										
									</xsl:when>
									<xsl:when test="$doctype='aic'">
									
									
										<xsl:variable name="normrefs_aic_default_xml" select="document(concat($path, '../../../data/basic/normrefs_aic_default.xml'))"/>
										
										<xsl:variable name="normrefs_aic_default_node" select="$normrefs_aic_default_xml/normrefs/normref.inc[@normref=$ref]"/>
										
										<xsl:choose>
											<xsl:when test="$normrefs_aic_default_node">
												<xsl:apply-templates select="$normrefs_aic_default_xml/normrefs/normref.inc[@normref=$ref]/term.ref" mode="normref">
													<xsl:with-param name="current_resource" select="$current_resource"/>
													<xsl:with-param name="moreNormRefs" select="$moreNormRefs"/>
												</xsl:apply-templates>
											</xsl:when>
											
											<xsl:otherwise>
												<xsl:call-template name="error_message">
													<xsl:with-param name="message">
														<xsl:value-of select="concat('Error 7: reference with id ', $ref, ' not found')"/>
													</xsl:with-param>
												</xsl:call-template>
											</xsl:otherwise>
											
										</xsl:choose>
										
									</xsl:when>
								</xsl:choose>
								<!-- check to see if any terms from the same normref are 
										 identified in resource -->
								<xsl:apply-templates select="/resource/normrefs/normref.inc[@normref=$ref]/term.ref" mode="normref"/>
								<xsl:apply-templates select="/resource/normrefs/normref.inc" mode="normref_check">
									<xsl:with-param name="resource_number" select="$part_no"/>
									<xsl:with-param name="current_resource" select="$current_resource"/>
								</xsl:apply-templates>

							<!-- </ul> -->
							<xsl:text>&#xa;&#xa;</xsl:text>
						</xsl:if>
					</xsl:when>
					
					<!-- a term defined in another resource -->
					<xsl:when test="contains($first,'resource:')">
						<xsl:variable name="resource" select="substring-after($first,'resource:')"/>

						<xsl:variable name="resource_dir">
							<xsl:call-template name="resource_directory">
								<xsl:with-param name="resource" select="$resource"/>
							</xsl:call-template>
						</xsl:variable>


						<xsl:variable name="resource_ok">
							<xsl:call-template name="check_resource_exists">
								<xsl:with-param name="schema" select="$resource"/>
							</xsl:call-template>
						</xsl:variable>

						<xsl:choose>
							<xsl:when test="$resource_ok='true'">
								<xsl:variable name="resource_xml" select="concat($resource_dir,'/resource.xml')"/>
								<xsl:variable name="normrefid" select="concat('10303-',document($resource_xml)/resource/@part)"/>
					
								<!-- check to see if the terms for the resource have been output
										 as part of normative references -->
								<xsl:if test="not(contains($normref_ids,$normrefid))">
									<xsl:variable name="resource_node" select="document($resource_xml)/resource"/>
									<xsl:variable name="stdnumber" select="concat('ISO/',$resource_node/@status,' 10303-',$resource_node/@part)"/>

						
						<!-- output the section header for the normative reference
								 that is defining terms -->              
						<!-- <xsl:value-of select="concat('3.',$section_no, ' Terms defined in ', $stdnumber)"/> -->
						<!-- <h2 level="2" id="{concat('3.',$section_no)}">		    
							<xsl:value-of select="concat('Terms defined in ', $stdnumber)"/>
						</h2> -->			
						<xsl:call-template name="insertHeaderADOC">
							<xsl:with-param name="id" select="concat('sec_3.',$section_no)"/>		
							<xsl:with-param name="level" select="2"/>
							<xsl:with-param name="header" select="concat('Terms defined in ', $stdnumber)"/>					
						</xsl:call-template>
						
						<!-- RBN Changed due to request from ISO
								 For the purposes of this part of ISO 10303,-->              
						<xsl:call-template name="insertParagraph">
							<xsl:with-param name="text">
								For the purposes of this document, 
								the following terms defined in 
								<xsl:value-of select="$stdnumber"/>
								 apply:
							 </xsl:with-param>
						</xsl:call-template>
						<!-- <ul> -->
						
							<!-- now output the terms -->
							<xsl:apply-templates 
						select="/resource/normrefs/normref.inc[@resource.name=$resource]/term.ref" 
						mode="resource"/>
						<xsl:text>&#xa;&#xa;</xsl:text>
					 <!--  </ul> -->
					</xsl:if>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="error_message">
									<xsl:with-param name="message">
										<xsl:value-of select="concat('Error ref 2: ',
												$resource_ok,' Check the normatives references')"/>
									</xsl:with-param>
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>

					<xsl:when test="contains($first,'resource:')">
						<xsl:variable name="resource" select="substring-after($first,'resource:')"/>
						<!-- should never get here -->
					</xsl:when>
				</xsl:choose>

				<xsl:call-template name="output_normrefs_terms_rec">
					<xsl:with-param name="normrefs" select="$rest"/>
					<xsl:with-param name="normref_ids" select="$normref_ids"/>
					<xsl:with-param name="section" select="$section_no"/>
					<xsl:with-param name="resource_number" select="$resource_number"/>
					<xsl:with-param name="current_resource" select="$current_resource"/>
				</xsl:call-template>

			</xsl:when>
			<xsl:otherwise>
	<!-- end of recursion -->
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>

	<!--
		build a list of normrefs that are used by the resource and have terms
		defined in them The list comprises: All default normrefs listed in
		../data/basic/normrefs.xml All normrefs explicitly included in the
		resource by normref.inc
	-->
	<xsl:template name="normrefs_terms_list">
		<xsl:param name="current_resource" />

		<xsl:variable name="doctype">
			<xsl:apply-templates select="$current_resource"
				mode="doctype" />
		</xsl:variable>

		<!-- get all normrefs explicitly included in the resource by normref.inc -->
		<xsl:variable name="normref_list1">
			<xsl:call-template name="get_normref_term">
				<xsl:with-param name="normref_nodes" select="/resource/normrefs/normref.inc" />
				<xsl:with-param name="normref_list" select="''" />
			</xsl:call-template>
		</xsl:variable>

		<!-- get all default normrefs listed in ../data/basic/normrefs.xml -->
		<xsl:variable name="normref_list2">
			<xsl:choose>
				<xsl:when test="not($doctype='aic')">
					<xsl:call-template name="get_normref_term">
						<xsl:with-param name="normref_nodes"
							select="document(concat($path, '../../../data/basic/normrefs_resdoc_default.xml'))/normrefs/normref.inc" />
						<xsl:with-param name="normref_list" select="$normref_list1" />
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$doctype='aic'">
					<xsl:call-template name="get_normref_term">
						<xsl:with-param name="normref_nodes"
							select="document(concat($path, '../../../data/basic/normrefs_aic_default.xml'))/normrefs/normref.inc" />
						<xsl:with-param name="normref_list" select="$normref_list1" />
					</xsl:call-template>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:value-of select="concat($normref_list2,',')" />

	</xsl:template>


	<!-- given a list of normref nodes, add the ids of the normrefs to the
			 normref_list, if not already a member. ids in normref_list are
			 separated by a , -->
	<xsl:template name="get_normref_term">
		<xsl:param name="normref_nodes"/>
		<xsl:param name="normref_list"/>
		
		<xsl:variable name="normref_list_ret">
			<xsl:choose>
	<xsl:when test="$normref_nodes">
		<xsl:choose>
			<xsl:when test="$normref_nodes[1]/term.ref">
				<!-- only add the normref if it is defining terms -->
				<xsl:variable name="first">
					<xsl:choose>
						<xsl:when test="$normref_nodes[1]/@normref">
							<xsl:value-of select="concat('normref:',$normref_nodes[1]/@normref)"/>
						</xsl:when>
						<xsl:when test="$normref_nodes[1]/@resource.name">
							<xsl:value-of select="concat('resource:',$normref_nodes[1]/@resource.name)"/>
						</xsl:when>            
						<xsl:when test="$normref_nodes[1]/@resource.name">
							<xsl:value-of select="concat('resource:',$normref_nodes[1]/@resource.name)"/>
						</xsl:when>            
					</xsl:choose>
				</xsl:variable>
				
				<xsl:variable name="normref_list1">
					<xsl:call-template name="add_normref">
						<xsl:with-param name="normref" select="$first"/>
						<xsl:with-param name="normref_list" select="$normref_list"/>
					</xsl:call-template>
				</xsl:variable>
				
				<xsl:call-template name="get_normref_term">
				<xsl:with-param name="normref_nodes" select="$normref_nodes[position()!=1]"/>
				<xsl:with-param name="normref_list" select="$normref_list1"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="get_normref_term">
					<xsl:with-param name="normref_nodes" select="$normref_nodes[position()!=1]"/>
					<xsl:with-param name="normref_list" select="$normref_list"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:when>
	<xsl:otherwise>
		<!-- end of recursion -->
		<xsl:value-of select="$normref_list"/>
	</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="$normref_list_ret"/>
	</xsl:template>


	<!-- Given the name of a resource, check if there is a corresponding
			 normative reference there. If so, remove it. -->
	<xsl:template name="remove_resource_from_normrefs_list">
		<xsl:param name="normrefs_list"/>
		<xsl:param name="resource_number"/>

		<xsl:variable name="nref" 
			select="concat(',normref:ref10303-',$resource_number)"/>

		<xsl:variable name="pruned_normrefs_list">
			<xsl:choose>
	<xsl:when test="contains($normrefs_list,$nref)">
		<xsl:variable 
				name="before" 
				select="substring-before($normrefs_list,$nref)"/>
		<xsl:variable 
				name="after" 
				select="substring-after(substring-after($normrefs_list,$nref),',')"/>
		<xsl:value-of select="concat($before,$after)"/>
	</xsl:when>
	<xsl:otherwise>
		<xsl:value-of select="$normrefs_list"/>
	</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="$pruned_normrefs_list"/>
	</xsl:template>

	<!-- return the number of normrefs in the list -->
	<xsl:template name="length_normrefs_list">
		<xsl:param name="normrefs_list"/>
		<xsl:param name="resource_number"/>
		<!-- check if the current resource is included.
	 If so, remove the reference -->
		<xsl:variable name="pruned_normrefs_list">
			<xsl:call-template name="remove_resource_from_normrefs_list">
				<xsl:with-param name="normrefs_list" select="$normrefs_list"/>
				<xsl:with-param name="resource_number" select="$resource_number"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="section1">
			<xsl:call-template name="count_substring">
				<xsl:with-param name="substring" select="','"/>
				<xsl:with-param name="string" select="$pruned_normrefs_list"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:value-of select="floor($section1 div 2)"/>
	</xsl:template>


	<!-- output the section header for terms defined in a resource -->
	<xsl:template name="output_resource_term_section">
		<xsl:param name="resource"/>
		<xsl:param name="section"/>
		
		<xsl:variable name="stdnumber" select="concat('ISO/',$resource/@status,' 10303-',$resource/@part)"/>

		<!-- <xsl:value-of select="concat($section,' Other terms and definitions')"/> -->
			<!--
		<xsl:value-of select="concat($section,' Terms defined in',$stdnumber)"/>
			-->
		<!-- <h2 level="3" id="{$section}">
			<xsl:value-of select="'Other terms and definitions'"/>
		</h2> -->
		<xsl:call-template name="insertHeaderADOC">
			<xsl:with-param name="id" select="concat('sec_',$section)"/>
			<xsl:with-param name="level" select="2"/> <!-- 3 -->
			<xsl:with-param name="header" select="'Other terms and definitions'"/>					
		</xsl:call-template>
	</xsl:template>


	<xsl:template match="term.ref" mode="resource">
		<xsl:variable name="resource" select="../@resource.name"/>

		<xsl:variable name="resource_dir">
			<xsl:call-template name="resource_directory">
	<xsl:with-param name="resource" select="$resource"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="resource_ok">
			<xsl:call-template name="check_resource_exists">
	<xsl:with-param name="schema" select="$resource"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="resource_xml" 
			select="concat($resource_dir,'/resource.xml')"/>

		<xsl:choose>
			<xsl:when test="$resource_ok='true'">
				<xsl:variable name="ref" select="@linkend"/>
				<xsl:variable name="term" select="document($resource_xml)/resource/definition/term[@id=$ref]"/>
	
				<xsl:choose>
					<xsl:when test="$term">		
						<!-- <xsl:choose>
							<xsl:when test="position()=last()">
								<li><xsl:apply-templates select="$term"/>.</li>
							</xsl:when>
							<xsl:otherwise>
								<li><xsl:apply-templates select="$term"/>;</li>
							</xsl:otherwise>
						</xsl:choose> -->
						<xsl:call-template name="insertParagraph">
							<xsl:with-param name="text">
								<xsl:text>* </xsl:text>
								<xsl:apply-templates select="$term"/>
								<xsl:choose>
									<xsl:when test="position()=last()">.</xsl:when>
									<xsl:otherwise>;</xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:when>
					
					<xsl:otherwise>
						<!-- <li> -->
							<xsl:call-template name="insertParagraph">
								<xsl:with-param name="text">
									<xsl:variable name="text">
										<xsl:call-template name="error_message">
											<xsl:with-param name="message" select="concat('Error 11: Can not find term referenced by: ',$ref)"/>
										</xsl:call-template>
									</xsl:variable>
									<xsl:text>* </xsl:text>
									<xsl:value-of select="$text"/>
								</xsl:with-param>
							</xsl:call-template>
						<!-- </li> -->
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="error_message">
					<xsl:with-param name="message">
						<xsl:value-of select="concat('Error ref1: ', $resource_ok)"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- output any terms that are defined in normref.inc that is referring
			 to a resource through @resource.name where the resource has the same
			 number as resource_number -->
	<xsl:template match="normref.inc"  mode="normref_check">
		<xsl:param name="resource_number"/>
		<xsl:variable name="resource" select="@resource.name"/>

		<xsl:if test="string-length($resource)>0">
			<xsl:variable name="resource_ok">
	<xsl:call-template name="check_resource_exists">
		<xsl:with-param name="schema" select="$resource"/>
	</xsl:call-template>
			</xsl:variable>
			
			<xsl:choose>
	<xsl:when test="$resource_ok='true'">
		<xsl:variable name="resource_dir">
			<xsl:call-template name="resource_directory">
				<xsl:with-param name="resource" select="$resource"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="resource_xml" 
			select="concat($resource_dir,'/resource.xml')"/>
		<xsl:variable name="part"
			select="document($resource_xml)/resource/@part"/>
		<xsl:if test="$part=$resource_number">
			<xsl:apply-templates select="term.ref" mode="resource"/>
		</xsl:if>
	</xsl:when>
	<xsl:otherwise>
		<xsl:call-template name="error_message">
			<xsl:with-param name="message">
				<xsl:value-of select="concat('Error ref 3: ', $resource_ok,
						'Check the normatives references: ')"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template match="term.ref"  mode="normref">
		<xsl:param name="current_resource"/>
		<xsl:param name="moreNormRefs"/>    
		<xsl:variable  name="ref" select="@linkend"/>
		<xsl:variable name="term" select="document(concat($path, '../../../data/basic/normrefs.xml'))/normref.list/normref/term[@id=$ref]"/>
		<xsl:variable name="term_ref_text">
			<xsl:choose>
				<xsl:when test="$term">
					<xsl:choose>
						<xsl:when test="position()=last()">		
							<!-- <xsl:choose>
								<xsl:when test="$moreNormRefs > 0">
									<li><xsl:apply-templates select="$term"/>;</li>					
								</xsl:when>
								<xsl:otherwise>
									<li><xsl:apply-templates select="$term"/>.</li>
								</xsl:otherwise>
							</xsl:choose> -->			
							<!-- <xsl:call-template name="insertParagraph">
								<xsl:with-param name="text"> -->
									<xsl:text>* </xsl:text>
									<xsl:apply-templates select="$term">
										<xsl:with-param name="show_id">false</xsl:with-param>
									</xsl:apply-templates>
									<xsl:choose>
										<xsl:when test="$moreNormRefs > 0">;</xsl:when>
										<xsl:otherwise>.</xsl:otherwise>
									</xsl:choose>
								<!-- </xsl:with-param>
							</xsl:call-template> -->
						</xsl:when>
						<xsl:otherwise>
							<!-- <li><xsl:apply-templates select="$term"/>;</li> -->
							<!-- <xsl:call-template name="insertParagraph">
								<xsl:with-param name="text"> -->
									<xsl:text>* </xsl:text>
									<xsl:apply-templates select="$term">
										<xsl:with-param name="show_id">false</xsl:with-param>
									</xsl:apply-templates>
									<xsl:text>;</xsl:text>
								<!-- </xsl:with-param>
						</xsl:call-template> -->
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<!-- <li><xsl:call-template name="error_message">
						<xsl:with-param 
								name="message"
								select="concat('Error 12: Can not find term referenced by: ',$ref)"/>
					</xsl:call-template>
					</li> -->
					<!-- <xsl:call-template name="insertParagraph">
						<xsl:with-param name="text"> -->
							<xsl:text>* </xsl:text>
							<xsl:variable name="text">
								<xsl:call-template name="error_message">
									<xsl:with-param 
											name="message"
											select="concat('Error 12: Can not find term referenced by: ',$ref)"/>
								</xsl:call-template>
							</xsl:variable>
							<xsl:value-of select="$text"/>
						<!-- </xsl:with-param>
					</xsl:call-template> -->
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:copy-of select="$term_ref_text"/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>


	<xsl:template match="definition">
		<xsl:param name="section"/>
		
		<!-- <xsl:value-of select="$section"/>.<xsl:number/><br/> -->
		<!-- <xsl:value-of select="concat($section,'.',position())"/><br/>  -->
		<!-- <h4 level="4" id="{concat($section,'.',position())}">      
			<xsl:apply-templates select="term"/>
		</h4> -->
		
		<xsl:variable name="header">
			<xsl:apply-templates select="term"/>
		</xsl:variable>
		<xsl:call-template name="insertHeaderADOC">
			<xsl:with-param name="id" select="concat('sec_', $section,'.',position())"/>		
			<xsl:with-param name="level" select="3"/> <!-- 4 -->
			<xsl:with-param name="header" select="normalize-space($header)"/>					
		</xsl:call-template>
		
		<!-- <p> -->		
		<xsl:call-template name="insertParagraph">
			<xsl:with-param name="text">
				<xsl:apply-templates select="def"/>
			</xsl:with-param>
		</xsl:call-template>
		<!-- </p> -->		
	</xsl:template>
	
	<xsl:template match="def">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="tech_discussion">
		<!-- output any issues -->
		<xsl:apply-templates select=".." mode="output_clause_issue">
			<xsl:with-param name="clause" select="'tech_discussion'"/>
		</xsl:apply-templates>
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="*[local-name() = 'tech_discussion' or local-name() = 'examples']/*[local-name() = 'b' or local-name() = 'b2'][*[local-name() = 'i' or local-name() = 'i2']]" priority="2">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="*[local-name() = 'examples']/*[local-name() = 'b' or local-name() = 'b2']" priority="2">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="*[local-name() = 'tech_discussion' or local-name() = 'examples']/p[count(*) = 1 and normalize-space(text()) = '']/*[local-name() = 'b' or local-name() = 'b2']" priority="2">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="*[local-name() = 'tech_discussion' or local-name() = 'examples']/*[local-name() = 'b' or local-name() = 'b2']/*[local-name() = 'i' or local-name() = 'i2']" priority="2">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="*[local-name() = 'tech_discussion' or local-name() = 'examples']/p[count(*) = 1 and normalize-space(text()) = '']/*[local-name() = 'b' or local-name() = 'b2']/*[local-name() = 'i' or local-name() = 'i2']" priority="2">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="*[local-name() = 'tech_discussion' or local-name() = 'examples']/*[local-name() = 'b' or local-name() = 'b2']/*[local-name() = 'i' or local-name() = 'i2']/text() |
												*[local-name() = 'tech_discussion' or local-name() = 'examples']/p[count(*) = 1 and  normalize-space(text()) = '']/*[local-name() = 'b' or local-name() = 'b2']/text() |
												*[local-name() = 'examples']/*[local-name() = 'b' or local-name() = 'b2']/text()" priority="2">
		<xsl:variable name="section_number" select="substring-before(., ' ')"/>
		<xsl:variable name="section_number_parts" select="str:split($section_number, '.')"/>
		<xsl:choose>
			<xsl:when test="string-length($section_number_parts[1]) = 1 and string-length($section_number_parts[2]) &gt;= 1">
				<xsl:variable name="header" select="substring-after(., ' ')"/>
				<xsl:call-template name="insertHeaderADOC">
					<xsl:with-param name="level"><xsl:value-of select="count($section_number_parts)"/></xsl:with-param>
					<xsl:with-param name="header" select="$header"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="{local-name(..)}">
					<xsl:value-of select="."/>
				</xsl:element>
				<xsl:if test="ancestor::examples and not(ancestor::p)">
					<xsl:text>&#xa;&#xa;</xsl:text>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>


	
	<!-- MWD -->
	<xsl:template match="annex_clause">
		<xsl:variable name="title" select="@title"/>
		<xsl:variable name="sect_no">
			<xsl:apply-templates select="." mode="number"/>
		</xsl:variable>
		<xsl:variable name="annex">
			<xsl:choose>
				<xsl:when test="ancestor::*[name()='tech_discussion']">tech_discussion</xsl:when>
				<xsl:otherwise>ERROR</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:if test="$annex='ERROR'">
			<xsl:call-template name="error_message">
				<xsl:with-param
					name="message"
					select="'ERROR annex_clause: You can only use annex_clause in tech_disc and usage_guide and change_detail'"/>
			</xsl:call-template>      
		</xsl:if>
		
		<xsl:variable name="annex_list">
			<xsl:apply-templates select="//application_protocol" mode="annex_list"/>
		</xsl:variable>
		
		<xsl:variable name="annex_letter" select="'E'"/>
					
		<!-- <h2>
			<a name="{$title}">
				<xsl:value-of select="concat($annex_letter,'.',$sect_no,' ',$title)"/>
			</a>
		</h2> -->		
		<xsl:call-template name="insertHeaderADOC">
			<xsl:with-param name="id" select="$title"/>		
			<xsl:with-param name="level" select="2"/>
			<xsl:with-param name="header" select="concat($annex_letter,'.',$sect_no,' ',$title)"/>					
			<xsl:with-param name="annex_no" select="$annex_letter"/>
		</xsl:call-template>
		
		<xsl:apply-templates/>
	</xsl:template>
	
	
	<xsl:template match="annex_clause" mode="number">
		<xsl:param name="sect_no" select="''"/>
		
		<xsl:variable name="current_sect_no">
			<xsl:number/>
		</xsl:variable>
		<xsl:variable name="sect_no_string">
			<xsl:choose>
				<xsl:when test="$sect_no=''">
					<xsl:value-of select="$current_sect_no"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($current_sect_no,'.',$sect_no)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="parent::*[name()='annex_clause']">
				<xsl:apply-templates select="parent::*[name()='annex_clause']" mode="number">
					<xsl:with-param name="sect_no" select="$sect_no_string"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$sect_no_string"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="examples">
		<!-- output any issues -->
		<xsl:apply-templates select=".." mode="output_clause_issue">
			<xsl:with-param name="clause" select="'examples'"/>
		</xsl:apply-templates>
		<xsl:apply-templates/>
	</xsl:template>


	<xsl:template match="add_scope">
		<!-- output any issues -->
		<xsl:apply-templates select=".." mode="output_clause_issue">
			<xsl:with-param name="clause" select="'add_scope'"/>
		</xsl:apply-templates>

		<xsl:apply-templates/>
	</xsl:template>


	<xsl:template match="express-g">
		<!-- <ul> -->
		<xsl:text>&#xa;</xsl:text>
			<xsl:apply-templates select="imgfile|img" mode="expressg"/>
		<xsl:text>&#xa;&#xa;</xsl:text>
		<!-- </ul> -->
	</xsl:template>

	<xsl:template match="imgfile" mode="expressg">
		<xsl:variable name="file">
			<xsl:call-template name="set_file_ext">
				<xsl:with-param name="filename" select="@file"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="href" select="concat('../',$file)"/>
		<!-- <li>
			<a href="{$href}">
				<xsl:apply-templates select="." mode="title"/>
			</a>
		</li> -->
		<xsl:call-template name="insertParagraph">
			<xsl:with-param name="text">
				<xsl:text>* </xsl:text>
				<xsl:text>&lt;&lt;</xsl:text>
				<xsl:apply-templates select="." mode="title"/>
				<xsl:text>, </xsl:text>
				<xsl:value-of select="$href"/>
				<xsl:text>&gt;&gt;</xsl:text>
			</xsl:with-param>
		</xsl:call-template>		
	</xsl:template>

	<xsl:template match="imgfile" mode="title">
		<xsl:variable name="number">
			<xsl:number/>
		</xsl:variable>
		<xsl:variable name="fig_no">
			<xsl:choose>
				<xsl:when test="name(../..)='arm'">
					<xsl:choose>
						<xsl:when test="$number=1">
							<xsl:value-of 
						select="concat('Figure C.',$number, 
							' &#8212; ARM schema level EXPRESS-G diagram ',$number)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of 
						select="concat('Figure C.',$number, 
							' &#8212; ARM entity level EXPRESS-G diagram ',($number - 1))"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="name(../..)='mim'">
					<xsl:choose>
						<xsl:when test="$number=1">
							<xsl:value-of 
						select="concat('Figure D.',$number, 
							' &#8212; MIM schema level EXPRESS-G diagram ',$number)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of 
						select="concat('Figure D.',$number, 
							' &#8212; MIM entity level EXPRESS-G diagram ',($number - 1))"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise >
					<xsl:if test="string-length(@title) > 3" >
						<xsl:value-of 
					select="concat('Figure ',$number, 
						' &#8212; ',@title)" />
					</xsl:if>       
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="$fig_no"/>
	</xsl:template>


	<xsl:template match="express-g" mode="svg">
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>.The schemas of this part of ISO 10303</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:apply-templates select="imgfile | img" mode="svg"/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>

	<xsl:template match="imgfile | img" mode="svg">
		<xsl:text>[.svgmap]</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>====</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		
		<xsl:variable name="svg_filename" select="concat(substring-before(@file, '.xml'), '.svg')"/>
		<!-- image::basic_attribute_schemaexpg1.svg[] -->
		<xsl:text>image::../</xsl:text><xsl:value-of select="$svg_filename"/><xsl:text>[]</xsl:text>
		<xsl:text>&#xa;&#xa;</xsl:text>

		
		<!-- unordered list example -->
		<!-- * <<express:basic_attribute_schema>>; 1
					* <<express:action_schema>>; 2
					* <<express:support_resource_schema>>; 3
		-->
		<xsl:variable name="map_file">
		<xsl:choose>
			<xsl:when test="ancestor::schema_diag"><!-- for introduction section file placed in current folder -->
				<xsl:value-of select="concat($path, @file)"/>				
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="schema_name" select="ancestor::schema/@name"/>
				<xsl:value-of select="concat($path, '../../resources/',$schema_name,'/',@file)"/>
			</xsl:otherwise>
		</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="map_file_xml" select="document($map_file)"/>
		<xsl:variable name="map_file_node" select="$map_file_xml//img.area[@href]"/>
		<xsl:choose>
			<xsl:when test="$map_file_node">
				<xsl:apply-templates select="$map_file_xml//img.area[@href]" mode="svg"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('ERROR: Image map file ', @file, '(', $map_file, ') does not exist or empty!')"/>
			</xsl:otherwise>
		</xsl:choose>
		
		<xsl:text>====</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>

	<xsl:template match="imgfile | img" mode="svg_start">
		<xsl:text>[.svgmap]</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		<xsl:text>====</xsl:text>
		<xsl:text>&#xa;</xsl:text>
		
		<xsl:variable name="schema_full" select="substring-before(@file, '.xml')"/>
		<xsl:variable name="expg_n" select="substring-after($schema_full, 'expg')"/>
		<xsl:variable name="schema" select="substring-before($schema_full, 'expg')"/>
		<xsl:variable name="id">
			<xsl:choose>
				<xsl:when test="$schema != ''">
					<xsl:value-of select="concat('expg-', $schema, '-', $expg_n)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$schema_full"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<!-- image::basic_attribute_schemaexpg1.svg[] -->
		<xsl:text>[[</xsl:text><xsl:value-of select="$id"/><xsl:text>]]</xsl:text>
		<xsl:text>&#xa;</xsl:text>

		
	</xsl:template>


	<xsl:template match="imgfile | img" mode="svg_end">
		
		<!-- * <<express:basic_attribute_schema>>; 1
					* <<express:action_schema>>; 2
					* <<express:support_resource_schema>>; 3
		-->
		<xsl:variable name="map_file">
		<xsl:choose>
			<xsl:when test="ancestor::schema_diag"><!-- for introduction section file placed in current folder -->
				<xsl:value-of select="concat($path, @file)"/>				
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="schema_name" select="ancestor::schema/@name"/>
				<xsl:value-of select="concat($path, '../../resources/',$schema_name,'/',@file)"/>
			</xsl:otherwise>
		</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="map_file_xml" select="document($map_file)"/>
		
		<xsl:variable name="map_file_node" select="$map_file_xml//img.area[@href]"/>
		
		<xsl:choose>
			<xsl:when test="$map_file_node">
				<xsl:apply-templates select="$map_file_xml//img.area[@href]" mode="svg"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('ERROR: Image map file ', @file, '(', $map_file, ') does not exist or empty!')"/>
			</xsl:otherwise>
		</xsl:choose>
		
		<xsl:text>====</xsl:text>
		<!-- <xsl:text>&#xa;&#xa;</xsl:text> -->
	</xsl:template>

	
	
	<!-- * <<express:basic_attribute_schema>>; number -->
	<xsl:template match="img.area" mode="svg">
		<!-- <xsl:variable name="this-schema" select="substring-after(@href,'#')" /> -->
		<xsl:variable name="this-schema">
			<xsl:variable name="part1">
				<xsl:choose>
					<xsl:when test="contains(@href, '.xml')">
						<xsl:value-of select="substring-before(@href, '.xml')"/>
					</xsl:when>
					<xsl:when test="contains(@href, '#')">
						<xsl:value-of select="substring-before(@href, '#')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@href"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="contains($part1, '/')">
					<xsl:call-template name="substring-after-last">
						<xsl:with-param name="value" select="$part1"/>
						<xsl:with-param name="delimiter" select="'/'"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$part1"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:text>* &lt;&lt;express:</xsl:text><xsl:value-of select="$this-schema"/><xsl:text>&gt;&gt;; </xsl:text><xsl:number/>
		<xsl:text>&#xa;</xsl:text>
	</xsl:template>

	<xsl:template match="bibliography">
		<!-- 
	 count how many bitiem.incs are in the current document add that to
	 the default bibitem.inc and bibitem in current document and start
	 counting from there
		-->
		<xsl:variable name="bibitem_cnt" select="count(./bibitem)"/>

		<xsl:apply-templates select="./bibitem.inc">
			<xsl:with-param name="number_start" select="$bibitem_cnt"/>
		</xsl:apply-templates>
	</xsl:template>


	<xsl:template match="bibitem">
		<!-- the value from which to start the counting. -->
		<xsl:param name="number_start" select="0"/>

		<!-- 
	 the value to be used for the number. This is used if the bibitem
	 is being displayed from a bibitem.inc
		-->
		<xsl:param name="number_inc" select="0"/>

		<xsl:param name="ref"/>

		<xsl:variable name="number">
			<!-- if the number is provided, use it, else count -->
			<xsl:choose>
				<xsl:when test="$number_inc>0">
					<xsl:value-of select="$number_inc"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:number count="bibitem"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!-- <p>
			[<xsl:value-of select="$number_start+$number"/>]  -->
			<!--	<xsl:apply-templates select="orgname"/> 
		<xsl:apply-templates select="orgname"/>   -->
			<!-- <xsl:apply-templates select="stdnumber"/>				
			<xsl:apply-templates select="stdtitle"/>
			<xsl:apply-templates select="subtitle"/>
			<xsl:apply-templates select="pubdate"/>
			<xsl:apply-templates select="ulink"/> -->
		<!-- </p> -->
		
		<xsl:call-template name="insertParagraph">
			<xsl:with-param name="text">
				<xsl:text>* </xsl:text>
				<xsl:apply-templates select="stdnumber">
					<xsl:with-param name="ref" select="$ref"/>
				</xsl:apply-templates>
				<xsl:apply-templates select="stdtitle"/>
				<xsl:apply-templates select="subtitle"/>
				<xsl:apply-templates select="pubdate"/>
				<xsl:apply-templates select="ulink"/>
			</xsl:with-param>
		</xsl:call-template>
		
	</xsl:template>


	<xsl:template match="bibitem.inc">
		<!-- the value from which to start the counting. -->
		<xsl:param name="number_start" select="0"/>

		<xsl:variable name="ref" select="@ref"/>
		<xsl:variable name="bibitem" select="document(concat($path, '../../../data/basic/bibliography.xml'))/bibitem.list/bibitem[@id=$ref]"/>
		
		<xsl:choose>
			<xsl:when test="$bibitem">
				<xsl:apply-templates select="$bibitem">
					<xsl:with-param name="number_start" select="$number_start"/>
					<xsl:with-param name="number_inc" select="position()"/>
					<xsl:with-param name="ref" select="$ref"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="error_message">
					<xsl:with-param 
							name="message" select="concat('Error 13: Can not find bibitem referenced by: ',$ref, 'in ../data/basic/bibliography.xml')"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="orgname">
		<xsl:value-of select="."/>
		<xsl:text>, </xsl:text>
	</xsl:template>

	<xsl:template match="stdnumber">
		<xsl:param name="ref"/>		
		<!-- <xsl:value-of select="."/>
		<xsl:text>, </xsl:text> -->		
		<xsl:text>[[[</xsl:text>
		<xsl:value-of select="$ref"/>
		<xsl:text>,</xsl:text>
		<xsl:value-of select="."/>
		<xsl:text>]]], </xsl:text>		
	</xsl:template>

	<xsl:template match="stdtitle">
		<!-- <i>
			<xsl:value-of select="."/>
		</i> -->
		<xsl:text> _</xsl:text>		
		<xsl:value-of select="normalize-space(java:replaceAll(java:java.lang.String.new(.),'&#x2014;','--'))"/>
		<xsl:text>_ </xsl:text>
	</xsl:template>

	<xsl:template match="subtitle">
		<xsl:text>, </xsl:text>
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="pubdate">
		<xsl:text>, </xsl:text>
		<xsl:value-of select="."/>
		<xsl:text>.</xsl:text>
	</xsl:template>

<!-- moved to 
	stepmod/xsl/common.xsl
	<xsl:template match="ulink">
		<xsl:text>Available from the World Wide Web: </xsl:text>
		<xsl:variable name="href" select="."/>
		<br/><a href="{$href}"><xsl:value-of select="$href"/></a>
	</xsl:template>-->

	<xsl:template match="resource" mode="annex_list" >
		<!-- returns a list of annexes with content as a string with each annex name as a single word(no spaces)
	 separated by spaces -->
		<xsl:if test="string-length(./tech_discussion) > 10">
			Technicaldiscussion
		</xsl:if>
		<xsl:if test="string-length(./examples) > 10">
			Examples 
		</xsl:if>
		<xsl:if test="string-length(./add_scope) > 10">
			Additionalscope
		</xsl:if>

	</xsl:template>

	<xsl:template name="annex_position" >
		<xsl:param name="annex_name" />
		<xsl:param name="annex_list" />
		<!-- returns integer count of position of named annex in list of annexes -->
		<xsl:variable name="UPPER" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
		<xsl:variable name="LOWER" select="'abcdefghijklmnopqrstuvwxyz'"/>

		<xsl:variable name="annex" select="concat(translate($annex_name,' ',''),' ')" />

		<xsl:value-of select="string-length(
				translate(
				substring-before(
				concat(' ',normalize-space($annex_list),' '),
				$annex
				),
				concat($UPPER,$LOWER),
				'')
				)" />
	</xsl:template>

	<xsl:template name="annex_count" >
		<xsl:if test="string-length(./tech_discussion) > 10">T</xsl:if>
		<xsl:if test="string-length(./examples) > 10">E</xsl:if>
		<xsl:if test="string-length(./add_scope) > 10">A</xsl:if>
	</xsl:template>
</xsl:stylesheet>

