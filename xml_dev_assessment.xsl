<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:wib="https://wibarab.acdh.oeaw.ac.at/langDesc"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    
    <xsl:template match="/">
        <report>
            
            <!-- Creating index of all place names -->
            <xsl:comment>Index of all mentioned places in wib:featureValueObservation/placeName</xsl:comment>
            <placeIndex>
                <xsl:for-each-group select="//wib:featureValueObservation" group-by="tei:placeName/@ref">
                    <xsl:sort select="current-grouping-key()" />
                    <entry>
                        <tei:placeName ref="{current-grouping-key()}"/>
                        <occurrences>
                            <xsl:for-each select="current-group()">
                                <wib:featureValueObservation xml:id="{@xml:id}" />
                            </xsl:for-each>
                        </occurrences>
                    </entry>
                </xsl:for-each-group>
            </placeIndex>
            
            <!-- Counting total number of featureValueObservations per dialect -->
            <xsl:comment>Summary of all number of all feature value observiations associated with each dialect</xsl:comment>
            <observationsByLanguage>
                <xsl:for-each-group select="//wib:featureValueObservation/tei:lang" group-by="@corresp">
                    <dialect>
                        <tei:lang corresp="{current-grouping-key()}"/>
                        <count><xsl:value-of select="count(current-group())"/></count>
                    </dialect>
                </xsl:for-each-group>
            </observationsByLanguage>
            
            <!-- Count per bibliographic item type -->
            <xsl:comment>Most used bibliographic item type and count per type</xsl:comment>
            <bibliographicItems>
                <xsl:variable name="groups" as="element(count)*">
                    <xsl:for-each-group select="//tei:bibl" group-by="@type">
                        <count type="{current-grouping-key()}">
                            <xsl:value-of select="count(current-group())"/>
                        </count>
                    </xsl:for-each-group>
                </xsl:variable>
                <xsl:variable name="maxCount" select="max($groups/number(.))"/>
                <!-- Most used bibliographic item type -->
                <mostUsed>
                    <xsl:copy-of select="$groups[number(.) = $maxCount]"/>
                </mostUsed>
                <xsl:copy-of select="$groups"/>
            </bibliographicItems>
            
            <!-- Check which features are associated with tribes -->
            <xsl:comment>Features associated with tribes</xsl:comment>
            <tribesFeatureList>
                <xsl:for-each-group select="//wib:featureValueObservation[tei:personGrp[@role='tribe']]/tei:name[@type='featureValue']/@ref" group-by=".">
                    <!-- Sort the feature names alphabetically -->
                    <xsl:sort select="current-grouping-key()"/>
                    <name type="featureValue">
                        <xsl:attribute name="ref">
                            <xsl:value-of select="current-grouping-key()"/>
                        </xsl:attribute>
                    </name>
                </xsl:for-each-group>
            </tribesFeatureList>
            
            <!-- Checking for broken pointers -->
            <xsl:comment>Index of broken pointers</xsl:comment>
            <brokenPointers>
                <xsl:variable name="geoData" select="document('featuredb/010_manannot/vicav_geodata.xml')"/>
                <xsl:variable name="biblioData" select="document('featuredb/010_manannot/vicav_biblio_tei_zotero.xml')"/>
                <xsl:variable name="sourceData" select="document('featuredb/010_manannot/wibarab_sources.xml')"/>
                <xsl:variable name="dmpData" select="document('featuredb/010_manannot/wibarab_dmp.xml')"/>
                <xsl:variable name="personGroupData" select="document('featuredb/010_manannot/wibarab_PersonGroup.xml')"/>
                
                <!-- Check for broken placeName refs -->
                <brokenPlaceRefs>
                    <xsl:for-each-group select="//tei:placeName/@ref" group-by=".">
                        <!-- Remove the 'geo:' prefix -->
                        <xsl:variable name="refWithoutPrefix" select="replace(current-grouping-key(), '^geo:', '')"/>
                        <!-- Check if the reference exists in the geodata external file -->
                        <xsl:if test="not($geoData//tei:place[@xml:id=$refWithoutPrefix])">
                            <pointer>
                                <xsl:value-of select="current-grouping-key()"/>
                                <!-- Report the IDs of XML files containing the broken reference -->
                                <xsl:for-each select="distinct-values(current-group()/ancestor::XMLfile/@id)">
                                    <sourceFile xml:id="{.}" />
                                </xsl:for-each>
                            </pointer>
                        </xsl:if>
                    </xsl:for-each-group>
                </brokenPlaceRefs>
                
                <!-- Check for broken bibl refs with 'zot:' prefix -->
                <brokenBiblRefs>
                    <xsl:for-each-group select="//tei:bibl/@corresp[starts-with(., 'zot:')]" group-by=".">
                        <!-- Remove the 'zot:' prefix -->
                        <xsl:variable name="correspWithoutPrefix" select="replace(current-grouping-key(), '^zot:', '')"/>
                        <!-- Check if the reference exists in the biblioData external file -->
                        <xsl:if test="not($biblioData//tei:biblStruct[@xml:id=$correspWithoutPrefix])">
                            <pointer>
                                <xsl:value-of select="current-grouping-key()"/>
                                <!-- Report the IDs of XML files containing the broken reference -->
                                <xsl:for-each select="distinct-values(current-group()/ancestor::XMLfile/@id)">
                                    <sourceFile xml:id="{.}" />
                                </xsl:for-each>
                            </pointer>
                        </xsl:if>
                    </xsl:for-each-group>
                    
                    <!-- Check for broken bibl refs with 'src:' prefix -->
                    <xsl:for-each-group select="//tei:bibl/@corresp[starts-with(., 'src:')]" group-by=".">
                        <!-- Remove the 'src:' prefix -->
                        <xsl:variable name="correspWithoutPrefix" select="replace(current-grouping-key(), '^src:', '')"/>
                        <!-- Check if the reference exists in the sourceData external file -->
                        <xsl:if test="not($sourceData//tei:event[@xml:id=$correspWithoutPrefix])">
                            <brokenBiblRef>
                                <xsl:value-of select="current-grouping-key()"/>
                                <!-- Report the IDs of XML files containing the broken reference -->
                                <xsl:for-each select="distinct-values(current-group()/ancestor::XMLfile/@id)">
                                    <sourceFile xml:id="{.}" />
                                </xsl:for-each>
                            </brokenBiblRef>
                        </xsl:if>
                    </xsl:for-each-group>
                </brokenBiblRefs>
                
                <!-- Check for broken @resp pointers -->
                <brokenRespRefs>
                    <xsl:for-each-group select="//wib:featureValueObservation/@resp" group-by=".">
                        <!-- Remove the 'dmp:' prefix -->
                        <xsl:variable name="respWithoutPrefix" select="replace(current-grouping-key(), '^dmp:', '')"/>
                        <!-- Check if the reference exists in the dmpData external file -->
                        <xsl:if test="not($dmpData//tei:person[@xml:id=$respWithoutPrefix])">
                            <pointer>
                                <xsl:value-of select="current-grouping-key()"/>
                                <!-- Report the IDs of XML files containing the broken reference -->
                                <xsl:for-each select="current-group()">
                                    <sourceFile>
                                        <xsl:value-of select="ancestor::XMLfile/@id"/>
                                    </sourceFile>
                                </xsl:for-each>
                            </pointer>
                        </xsl:if>
                    </xsl:for-each-group>
                </brokenRespRefs>
                
                <!-- Check for broken personGrp refs -->
                <brokenPersonGrpRefs>
                    <xsl:for-each-group select="//tei:personGrp/@corresp" group-by=".">
                        <!-- Remove the 'pgr:' prefix -->
                        <xsl:variable name="correspWithoutPrefix" select="replace(current-grouping-key(), '^pgr:', '')"/>

                        <!-- Check if the reference exists in the personGroupData external file -->
                        <xsl:if test="not($personGroupData//tei:personGrp[@xml:id=$correspWithoutPrefix])">
                            <pointer>
                                <xsl:value-of select="current-grouping-key()"/>
                                <!-- Report the IDs of XML files containing the broken reference, ensure each file is reported only once and is sorted -->
                                <xsl:for-each select="distinct-values(current-group()/ancestor::XMLfile/@id)">
                                    <xsl:sort select="." order="ascending"/>
                                    <sourceFile>
                                        <xsl:value-of select="."/>
                                    </sourceFile>
                                </xsl:for-each>
                            </pointer>
                        </xsl:if>
                    </xsl:for-each-group>
                </brokenPersonGrpRefs>
                
                <!-- Check language profile pointers -->
                <brokenLangRefs>
                    <xsl:for-each-group select="//wib:featureValueObservation/tei:lang/@corresp" group-by=".">
                        <!-- Convert backslashes to forward slashes and adjust relative path -->
                        <xsl:variable name="correctedPath" select="replace(current-grouping-key(), '^\.\.', 'featuredb/010_manannot')"/>
                        <xsl:variable name="finalPath" select="replace($correctedPath, '\\', '/')"/>
                        
                        <!-- Check if the referenced XML exists -->
                        <xsl:if test="not(unparsed-text-available($finalPath))">
                            <pointer>
                                <xsl:value-of select="current-grouping-key()"/>
                                <!-- Report the IDs of XML files containing the missing XML reference -->
                                <xsl:for-each select="distinct-values(current-group()/ancestor::XMLfile/@id)">
                                    <sourceFile xml:id="{.}" />
                                </xsl:for-each>
                            </pointer>
                        </xsl:if>
                    </xsl:for-each-group>
                </brokenLangRefs>
            </brokenPointers>
            
        </report>
    </xsl:template>
</xsl:stylesheet>