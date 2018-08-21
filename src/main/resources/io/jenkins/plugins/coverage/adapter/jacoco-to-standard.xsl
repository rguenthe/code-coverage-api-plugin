<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method="xml"/>

    <xsl:key name="classname" match="class" use="substring-before(concat(@name, '$'), '$')"/>
    <xsl:key name="sourcefilename" match="class" use="@sourcefilename"/>

    <xsl:template match="/">
        <xsl:if test="/report">
            <report>
                <xsl:attribute name="name">jacoco</xsl:attribute>
                <xsl:choose>
                    <xsl:when test="/report/group">
                        <xsl:apply-templates select="report/group"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <group>
                            <xsl:attribute name="name">project</xsl:attribute>
                            <xsl:apply-templates select="report/package"/>
                        </group>
                    </xsl:otherwise>
                </xsl:choose>
            </report>
        </xsl:if>
    </xsl:template>

    <xsl:template match="/report/group">
        <group>
            <xsl:attribute name="name">
                <xsl:value-of select="@name"/>
            </xsl:attribute>
            <xsl:apply-templates select="package"/>
        </group>
    </xsl:template>

    <xsl:template match="package">
        <package>
            <xsl:attribute name="name">
                <xsl:value-of select="@name"/>
            </xsl:attribute>

            <xsl:attribute name="attr-mode">true</xsl:attribute>
            <xsl:attribute name="instruction-covered">
                <xsl:value-of select="counter[@type = 'INSTRUCTION']/@covered"/>
            </xsl:attribute>
            <xsl:attribute name="instruction-missed">
                <xsl:value-of select="counter[@type = 'INSTRUCTION']/@missed"/>
            </xsl:attribute>
            <xsl:attribute name="line-covered">
                <xsl:value-of select="counter[@type = 'LINE']/@covered"/>
            </xsl:attribute>
            <xsl:attribute name="line-missed">
                <xsl:value-of select="counter[@type = 'LINE']/@missed"/>
            </xsl:attribute>
            <xsl:if test="counter[@type = 'BRANCH']">
                <xsl:attribute name="br-covered">
                    <xsl:value-of select="counter[@type = 'BRANCH']/@covered"/>
                </xsl:attribute>
                <xsl:attribute name="br-missed">
                    <xsl:value-of select="counter[@type = 'BRANCH']/@missed"/>
                </xsl:attribute>
            </xsl:if>

            <xsl:apply-templates
                    select="class[generate-id(.)=generate-id(key('classname',substring-before(concat(@name, '$'), '$'))[1])]"/>
        </package>
    </xsl:template>


    <xsl:template match="class">
        <xsl:choose>
            <xsl:when test="@sourcefilename">
                <xsl:variable name="sourcefilename" select="@sourcefilename"/>

                <file name="{$sourcefilename}">
                    <xsl:for-each select="key('sourcefilename', $sourcefilename)">
                        <class>
                            <xsl:attribute name="name">
                                <xsl:value-of select="@name"/>
                            </xsl:attribute>

                            <xsl:attribute name="attr-mode">true</xsl:attribute>
                            <xsl:attribute name="instruction-covered">
                                <xsl:value-of select="counter[@type = 'INSTRUCTION']/@covered"/>
                            </xsl:attribute>
                            <xsl:attribute name="instruction-missed">
                                <xsl:value-of select="counter[@type = 'INSTRUCTION']/@missed"/>
                            </xsl:attribute>
                            <xsl:attribute name="line-covered">
                                <xsl:value-of select="counter[@type = 'LINE']/@covered"/>
                            </xsl:attribute>
                            <xsl:attribute name="line-missed">
                                <xsl:value-of select="counter[@type = 'LINE']/@missed"/>
                            </xsl:attribute>
                            <xsl:if test="counter[@type = 'BRANCH']">
                                <xsl:attribute name="br-covered">
                                    <xsl:value-of select="counter[@type = 'BRANCH']/@covered"/>
                                </xsl:attribute>
                                <xsl:attribute name="br-missed">
                                    <xsl:value-of select="counter[@type = 'BRANCH']/@missed"/>
                                </xsl:attribute>
                            </xsl:if>

                            <xsl:apply-templates select="method"/>

                        </class>
                    </xsl:for-each>

                    <xsl:copy-of select="../sourcefile[@name = $sourcefilename]/line"/>
                </file>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="classname"
                              select="substring-after(substring-before(concat(@name, '$'), '$'), concat(../@name, '/'))"/>

                <xsl:variable name="sourcefile" select="../sourcefile[starts-with(@name, concat($classname, '.'))]"/>
                <xsl:choose>
                    <xsl:when test="$sourcefile">
                        <file name="{substring-before(concat(@name, '$'), '$')}.java">
                            <xsl:attribute name="name">
                                <xsl:value-of select="$sourcefile/@name"/>
                            </xsl:attribute>

                            <xsl:for-each select="key('classname',substring-before(concat(@name, '$'), '$'))">
                                <class>
                                    <xsl:attribute name="name">
                                        <xsl:value-of select="@name"/>
                                    </xsl:attribute>

                                    <xsl:attribute name="attr-mode">true</xsl:attribute>
                                    <xsl:attribute name="instruction-covered">
                                        <xsl:value-of select="counter[@type = 'INSTRUCTION']/@covered"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="instruction-missed">
                                        <xsl:value-of select="counter[@type = 'INSTRUCTION']/@missed"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="line-covered">
                                        <xsl:value-of select="counter[@type = 'LINE']/@covered"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="line-missed">
                                        <xsl:value-of select="counter[@type = 'LINE']/@missed"/>
                                    </xsl:attribute>
                                    <xsl:if test="counter[@type = 'BRANCH']">
                                        <xsl:attribute name="br-covered">
                                            <xsl:value-of select="counter[@type = 'BRANCH']/@covered"/>
                                        </xsl:attribute>
                                        <xsl:attribute name="br-missed">
                                            <xsl:value-of select="counter[@type = 'BRANCH']/@missed"/>
                                        </xsl:attribute>
                                    </xsl:if>

                                    <xsl:apply-templates select="method"/>
                                </class>
                            </xsl:for-each>

                            <xsl:copy-of select="$sourcefile/line"/>
                        </file>
                    </xsl:when>
                    <xsl:otherwise>
                        <file name="{$classname}.java">
                            <xsl:for-each select="key('classname',substring-before(concat(@name, '$'), '$'))">
                                <class>
                                    <xsl:attribute name="name">
                                        <xsl:value-of select="@name"/>
                                    </xsl:attribute>

                                    <xsl:attribute name="attr-mode">true</xsl:attribute>
                                    <xsl:attribute name="instruction-covered">
                                        <xsl:value-of select="counter[@type = 'INSTRUCTION']/@covered"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="instruction-missed">
                                        <xsl:value-of select="counter[@type = 'INSTRUCTION']/@missed"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="line-covered">
                                        <xsl:value-of select="counter[@type = 'LINE']/@covered"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="line-missed">
                                        <xsl:value-of select="counter[@type = 'LINE']/@missed"/>
                                    </xsl:attribute>
                                    <xsl:if test="counter[@type = 'BRANCH']">
                                        <xsl:attribute name="br-covered">
                                            <xsl:value-of select="counter[@type = 'BRANCH']/@covered"/>
                                        </xsl:attribute>
                                        <xsl:attribute name="br-missed">
                                            <xsl:value-of select="counter[@type = 'BRANCH']/@missed"/>
                                        </xsl:attribute>
                                    </xsl:if>

                                    <xsl:apply-templates select="method"/>
                                </class>
                            </xsl:for-each>
                        </file>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="method">
        <method>
            <xsl:attribute name="name">
                <xsl:value-of select="@name"/>
            </xsl:attribute>
            <xsl:attribute name="signature">
                <xsl:value-of select="@desc"/>
            </xsl:attribute>
            <xsl:attribute name="attr-mode">true</xsl:attribute>
            <xsl:attribute name="instruction-covered">
                <xsl:value-of select="counter[@type = 'INSTRUCTION']/@covered"/>
            </xsl:attribute>
            <xsl:attribute name="instruction-missed">
                <xsl:value-of select="counter[@type = 'INSTRUCTION']/@missed"/>
            </xsl:attribute>
            <xsl:attribute name="line-covered">
                <xsl:value-of select="counter[@type = 'LINE']/@covered"/>
            </xsl:attribute>
            <xsl:attribute name="line-missed">
                <xsl:value-of select="counter[@type = 'LINE']/@missed"/>
            </xsl:attribute>
            <xsl:if test="counter[@type = 'BRANCH']">
                <xsl:attribute name="br-covered">
                    <xsl:value-of select="counter[@type = 'BRANCH']/@covered"/>
                </xsl:attribute>
                <xsl:attribute name="br-missed">
                    <xsl:value-of select="counter[@type = 'BRANCH']/@missed"/>
                </xsl:attribute>
            </xsl:if>

        </method>
    </xsl:template>

</xsl:stylesheet>