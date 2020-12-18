<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/TR/WD-xsl" version="1.0">

<xsl:template match="/">
<html>
<head>
<style>
td {font-family: Tahoma; font-size: 8pt}
body {font-family: Tahoma; font-size: 8pt}
</style>
</head>
<body>


<xsl:for-each select="BugReport/OSInfo">
	<xsl:apply-templates select="/BugReport/OSInfo"/>
</xsl:for-each>

<xsl:if test="BugReport/UserSystem">
	<xsl:apply-templates select="/BugReport/UserSystem"/>
</xsl:if>

<xsl:if test="BugReport/LocaleInfo">
	<xsl:apply-templates select="/BugReport/LocaleInfo"/>
</xsl:if>

<xsl:for-each select="BugReport/RegKeys">
	<xsl:apply-templates select="/BugReport/RegKeys"/>
</xsl:for-each>

<xsl:for-each select="BugReport/Devices">
	<xsl:apply-templates select="/BugReport/Devices"/>
</xsl:for-each>

</body>
</html>
</xsl:template>


<xsl:template match="OSInfo">
<table border="0" width="100%" cellspacing="1" cellpadding="1">
<tr>
        <td colspan="2" bgcolor="#E0E0FF"><b>User PC Configuration</b></td>
</tr>
<tr>
        <td colspan="2" bgcolor="#F0F0FF"><b>Operating System</b></td>
</tr>
<tr>
        <td width="130" bgcolor="#F0F0F0">Name</td>
        <td bgcolor="#F8F8F8"><xsl:value-of select="OSName"/></td>
</tr>
<tr>
        <td width="130" bgcolor="#F0F0F0">Version</td>
        <td bgcolor="#F8F8F8"><xsl:value-of select="OSVersion"/></td>
</tr>
<tr>
        <td colspan="2" bgcolor="#F0F0FF"><b>Windows Setup</b></td>
</tr>
<tr>
        <td width="130" bgcolor="#F0F0F0">Computer Name</td>
        <td bgcolor="#F8F8F8"><xsl:value-of select="ComputerName"/></td>
</tr>
<tr>
        <td width="130" bgcolor="#F0F0F0">User Name</td>
        <td bgcolor="#F8F8F8"><xsl:value-of select="UserName"/></td>
</tr>
<tr>
        <td width="130" bgcolor="#F0F0F0">Windows Folder</td>
        <td bgcolor="#F8F8F8"><xsl:value-of select="WindowsDirectory"/></td>
</tr>
<tr>
        <td width="130" bgcolor="#F0F0F0">System Folder</td>
        <td bgcolor="#F8F8F8"><xsl:value-of select="SystemDirectory"/></td>
</tr>
<tr>
        <td colspan="2" bgcolor="#F0F0FF"><b>PC Hardware</b></td>
</tr>
<tr>
        <td width="130" bgcolor="#F0F0F0">Processor</td>
        <td bgcolor="#F8F8F8"><xsl:value-of select="Processor"/></td>
</tr>
<tr>
        <td width="130" bgcolor="#F0F0F0">Bios</td>
        <td bgcolor="#F8F8F8"><xsl:value-of select="SystemBiosVersion"/></td>
</tr>
<tr>
        <td width="130" bgcolor="#F0F0F0">OEM Name</td>
        <td bgcolor="#F8F8F8"><xsl:value-of select="OEMName"/></td>
</tr>
<tr>
        <td width="130" bgcolor="#F0F0F0">OEM Product(?)</td>
        <td bgcolor="#F8F8F8"><xsl:value-of select="OEMProduct"/></td>
</tr>
<tr>
        <td width="130" bgcolor="#F0F0F0">Physical Memory</td>
        <td bgcolor="#F8F8F8"><xsl:value-of select="PhysicalMemory"/></td>
</tr>
<tr>
        <td width="130" bgcolor="#F0F0F0">Physical Memory Available</td>
        <td bgcolor="#F8F8F8"><xsl:value-of select="PhysicalMemoryAvailable"/></td>
</tr>
<tr>
        <td width="130" bgcolor="#F0F0F0">Page File Size</td>
        <td bgcolor="#F8F8F8"><xsl:value-of select="PageFile"/></td>
</tr>
<tr>
        <td width="130" bgcolor="#F0F0F0">Page File Available</td>
        <td bgcolor="#F8F8F8"><xsl:value-of select="PageFileAvailable"/></td>
</tr>
<tr>
        <td width="130" bgcolor="#F0F0F0">Virtual Memory</td>
        <td bgcolor="#F8F8F8"><xsl:value-of select="Virtual"/></td>
</tr>
<tr>
        <td width="130" bgcolor="#F0F0F0">Virtual Memory Available</td>
        <td bgcolor="#F8F8F8"><xsl:value-of select="VirtualAvailable"/></td>
</tr>
<tr>
        <td width="130" bgcolor="#F0F0F0">Time difference from GMT</td>
        <td bgcolor="#F8F8F8"><xsl:value-of select="TimeBias"/> mins</td>
</tr>
</table>
</xsl:template>

<xsl:template match="LocaleInfo">
<table border="0" width="100%" cellspacing="1" cellpadding="1">
<tr>
        <td colspan="2" bgcolor="#F0F0FF"><b>Locale Settings</b></td>
</tr>
<tr>
        <td width="130" bgcolor="#F0F0F0">Country</td>
        <td bgcolor="#F8F8F8"><xsl:value-of select="sCountry"/></td>
</tr>
<tr>
        <td width="130" bgcolor="#F0F0F0">Language</td>
        <td bgcolor="#F8F8F8"><xsl:value-of select="sLanguage"/> (<xsl:value-of select="iDefaultLanguage"/>)</td>
</tr>
<tr>
        <td width="130" bgcolor="#F0F0F0">Currency</td>
        <td bgcolor="#F8F8F8"><xsl:value-of select="sEngCurrName"/> (Symbol=<xsl:value-of select="sCurrency"/>)</td>
</tr>
<tr>
        <td width="130" bgcolor="#F0F0F0">Date Format (long)</td>
        <td bgcolor="#F8F8F8"><xsl:value-of select="sLongDate"/></td>
</tr>
<tr>
        <td width="130" bgcolor="#F0F0F0">Date Format (short)</td>
        <td bgcolor="#F8F8F8"><xsl:value-of select="sShortDate"/></td>
</tr>
<tr>
        <td width="130" bgcolor="#F0F0F0">Time Format</td>
        <td bgcolor="#F8F8F8"><xsl:value-of select="sTimeFormat"/></td>
</tr>
<tr>
        <td width="130" bgcolor="#F0F0F0">Default Code Page</td>
        <td bgcolor="#F8F8F8"><xsl:value-of select="iDefaultCodePage"/></td>
</tr>
<tr>
        <td width="130" bgcolor="#F0F0F0">Default ANSI Code Page</td>
        <td bgcolor="#F8F8F8"><xsl:value-of select="iDefaultANSICodePage"/></td>
</tr>
</table>
</xsl:template>

<xsl:template match="Devices">

<table border="0" width="100%" cellspacing="1" cellpadding="1">
<tr>
        <td colspan="3" bgcolor="#F0F0FF"><b>Devices</b></td>
</tr>
<xsl:for-each select="Device">
<tr>
        <td width="130" bgcolor="#F0F0F0"><xsl:value-of select="@Class"/></td>
	<td bgcolor="#f8f8f8"><xsl:value-of select="@Description"/></td>
	<td bgcolor="#f8f8f8"><xsl:value-of select="@FriendlyName"/></td>
</tr>
</xsl:for-each>
</table>

</xsl:template>



<xsl:template match="UserSystem">
<table border="0" width="100%" cellspacing="1" cellpadding="1">
<tr>
        <td bgcolor="#F0F0F0" width="130">Machine type</td>
        <td bgcolor="#F8F8F8"><xsl:value-of select="MachineType"/></td>
</tr>
<tr>
	<td bgcolor="#F0F0F0">Date of recording</td>
	<td bgcolor="#F8F8F8"><xsl:value-of select="DateTime"/></td>
</tr>
<xsl:for-each select="SystemInformation">
	<tr>
		<td bgcolor="#F0F0F0">Number of Processors</td>
		<td bgcolor="#F8F8F8"><xsl:value-of select="@NumberOfProcessors"/></td>
	</tr>

	<xsl:for-each select="SystemMetrics">
	<tr>
		<td bgcolor="#F0F0F0">Number of Monitors</td>
		<td bgcolor="#F8F8F8"><xsl:value-of select="@MonitorsNumber"/></td>
	</tr>
	<tr>
		<td bgcolor="#F0F0F0">Mouse Buttons</td>
		<td bgcolor="#F8F8F8"><xsl:value-of select="@MouseButtons"/></td>
	</tr>
	<tr>
		<td bgcolor="#F0F0F0">Full Screen Size</td>
		<td bgcolor="#F8F8F8"><xsl:value-of select="@FullScreenSize"/></td>
	</tr>
	</xsl:for-each>
</xsl:for-each>

<xsl:for-each select="DiskDrives">
<tr>
        <td bgcolor="#F0F0F0">Disks</td>
	<td bgcolor="#f8f8f8">
	<xsl:for-each select="DiskDrive">
		<xsl:value-of select="@DiskName"/>
	</xsl:for-each>
	</td>
</tr>
</xsl:for-each>

</table>
</xsl:template>


<xsl:template match="RegKeys">

<table border="0" width="100%" cellspacing="1" cellpadding="1">
<tr>
        <td colspan="3" bgcolor="#F0F0FF"><b>Registry keys</b></td>
</tr>
</table>
<xsl:for-each select="Key">
	<xsl:apply-templates select="."/>
</xsl:for-each>

</xsl:template>

<xsl:template match="Key">

<xsl:value-of select="@Name"/>/

<xsl:apply-templates select="Key"/>
<xsl:if test="KeyValue">
<table border="0" width="100%">
	<xsl:for-each select="KeyValue">
		<xsl:apply-templates select="."/>
	</xsl:for-each>
</table>
<br/><br/>
</xsl:if>

</xsl:template>

<xsl:template match="KeyValue">
<tr>
<td bgcolor="#f0f0f0"><xsl:value-of select="@Name"/></td>
<td bgcolor="#f8f8f8"><xsl:value-of select="@Type"/></td>
<td bgcolor="#f8f8f8"><xsl:value-of select="."/></td>
</tr>
</xsl:template>

</xsl:stylesheet>


