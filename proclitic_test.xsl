<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:djb="http://www.obdurodon.org" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all" version="2.0">
    <!--
        Filename: proclitic-test.xsl
        Developer: djb 2015-05-14
        Repo: http://github.com/djbpitt/poetry
        Synopsis: Run against itself to merge 'c' with any following string; works recursively
        License: GNU AGPLv3
    -->
    <xsl:output method="xml" indent="yes"/>
    <xsl:variable name="input" select="'a b c c d e f c g c c c h i'" as="xs:string"/>
    <xsl:function name="djb:proclitic" as="xs:string+">
        <xsl:param name="input" as="xs:string" required="yes"/>
        <xsl:param name="pos" as="xs:integer" required="yes"/>
        <!-- Reverse the string so that clitics will be recognizable after merger; needed for clitic sequences -->
        <xsl:variable name="tokenized" select="reverse(tokenize($input, '\s+'))"/>
        <!-- Merge a proclitic with the following (after reversal) string -->
        <xsl:variable name="result" as="xs:string+">
            <xsl:choose>
                <xsl:when test="$tokenized[position() eq $pos] = 'c'">
                    <xsl:sequence select="$tokenized[position() lt $pos - 1]"/>
                    <xsl:sequence
                        select="concat($tokenized[position() eq $pos], $tokenized[position() eq $pos - 1])"/>
                    <xsl:sequence select="$tokenized[position() gt $pos]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$tokenized"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- increment $pos only if we haven't merged (determine from count); otherwise the merger increments automatically -->
        <xsl:variable name="newPos" as="xs:integer"
            select="
                if (count($tokenized) eq count($result)) then
                    $pos + 1
                else
                    $pos"/>
        <xsl:choose>
            <!-- Recurse until we run out of strings -->
            <xsl:when test="$pos lt count($result)">
                <xsl:sequence select="djb:proclitic(string-join(reverse($result), ' '), $newPos)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="string-join(reverse($result), ' ')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:template match="/">
        <root>
            <!-- Process with sibling recursion -->
            <xsl:sequence select="djb:proclitic($input, 1)"/>
        </root>
    </xsl:template>
</xsl:stylesheet>
