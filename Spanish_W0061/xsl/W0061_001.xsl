<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:local="http://salamanca.adwmainz.de"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    xmlns:t="http://www.tei-c.org/ns/tite/1.0"
    version="2.0">
    
    <xsl:output method="xml"/> 
    
    
<!--

Expanding (es) abbreviations depending on word structure with regex.

        ##########
        | CASES: |
        ##########
        
        1) "endo - pudiẽdo", mode="endo"
        2) "ando - dudãdo", mode="ando"
        3) "ente|tes - gẽte", mode="ente"
        4) "ende - entiẽde", mode="ende"
        5) "on - Purificaciõ", mode="cion"
        6) "ento - mandamiẽto", mode="ento"
        7) "encia|cias - differẽcia", mode="encia" 
        8) "ancia - ignorãcia", mode="ancia"
        9) "ẽ and er - entẽder", mode="ener"
        10) "ẽ and ar - encomẽdar", mode="enar"
        11) "ã and ar" - mãdar, mode="anar"
        12) "ẽ - en - puedẽ, quiẽ, deuẽ", mode="final-en"
        13) "ā - an - haziā, siruā, podrā", mode="final-an"
        14) "ũ - un - pregũtar, renũciar", mode="unar" 
        15) "ũ - before (b|p) costũbre, cũplido", mode="umbp"
        16) "õ - before (b|p) hōbres, Cōprar", mode="ombp"
        17) "ō and dad|dades, bōdad, cōformidad", mode="ondad"
        18) "õ and dido|dida|didas|didos, cōcedido, cōcedida" mode="ondido"
        19) "ā and dad|dades, trāquilidad, Hermādad" mode="andad"
        20) "ā and ça|ças, ordenāça, templāça", mode="ança"
        21) "ẽ  and ça|çan|ças, verguẽça, comiẽçan" mode="ença"
        22) "đ at the beginning + \w, đspues,đllas (no further special characters like "ā|ẽ|õ|ũ")" mode="dewords"
        23) "ꝓ q with tilde inside a word, flaq̃za, riq̃zas (flaqueza, riquezas)" mode="wquew"
        24) "ꝓ pro at the beginning + \w, ꝓhibir, ꝓcesso (prohibir, processo)" mode="prow"
          
        Depending on the text and the mixture between latin and spanish, check W0005_Vol01_005.xsl for cases:

        25) "final ũ", algũ - algun mode="final-un"
        26) "q̃" - que,  mode="only-que"
        27) "ẽ - en", mode="only-en"
        28) "ꝓ q with tilde at the end of a word, porq̃  - porque" mode="wque"
        29) "đ| (char0111|charf159)- de" mode="only-de"
        30) ⁊ (char204a) ==> y , mode="only-y"
        
        
     ########################          
    | How to add new cases:  |
     ########################     
     
     1) Test the new pattern in spanisch texts in version 001 (W0005_Vol01, W0017, W0061, W0083 etc.)
        Words found should neither yield exceptions, ambiguities nor show conflicts with other cases in this program.
        
     2) Write the pattern with examples in the list "cases" above and assign a new mode. It should be different from all modes used before.
     
     3) Between the last template and "Logging", write a new variable. Its name is usually the same name as the new mode. 
        And in <xsl:apply-templates/> select the last variable name, and place the new mode: 
     
         <xsl:variable name="ExampleNew">
            <xsl:apply-templates select="$lastTemplateVariableName" mode="ExampleNew"/>
         </xsl:variable>
     
     4) Write a template with a template with the identity transforms using the new mode:
          
            <xsl:template match="@*|node()" mode="ExampleNew">
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()" mode="ExampleNew"/>
                </xsl:copy>
            </xsl:template>
            
     5) Write a template that matches only text in spanisch, which is not tagged as expansion yet and add the new mode:
          
          <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="ExampleNew">
          
          Regex-groups must be placed in () and distributed in the new elements. See the templates below.
    
    6) For logging purpuses and for keeping track of the new expanssions added, look for the following locations (variable $out and variable $Expansions) at the very end of the code in the "logging" section
       and replace the new variable:
    
        <xsl:variable name="out">
            <xsl:copy-of select="$ExampleNew"/>
        </xsl:variable>
        
        Unwanted characters in expansions.
        
        <xsl:variable name="Abbr" as="node()*" select="$ExampleNew//tei:abbr[@rend eq 'abbr' and following-sibling::node()/self::tei:abbr[@rend eq 'expan' and matches(.,'[̃ ãāēẽõōũūꝓđ]+')]]"/>
        <xsl:variable name="WrongExpansions" as="node()*" select="$ExampleNew//tei:abbr[@rend eq 'choice']//tei:abbr[@rend eq 'expan' and matches(.,'[̃ ãāēẽõōũūꝓđ]+')]"/>
        
        Abbr with no special character, check this out.
        $prow//tei:abbr[@rend eq 'abbr' and not(matches(.,'[ãẽõũꝓq̃]+'))]
        
        Update last case variable
        <xsl:variable name="Expansions" as="xs:integer" select="count($ExampleNew//tei:abbr[@rend eq 'choice']//tei:abbr[@rend eq 'expan'])"/>
    

###################################################################################################################################################        
                                         TEMPLATES FOR EACH CASE  
###################################################################################################################################################    
-->
    
<!-- 1) ẽ + "do" e.g. "pudiẽdo"-->
    
    <xsl:variable name="endo">
        <xsl:apply-templates select="/" mode="endo"/>
    </xsl:variable>
        
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="endo">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="endo"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="endo">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZñſç]+)(ẽ|ẽ|ē)(do)([ .,;\(\)])'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3),regex-group(4))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'en',regex-group(4))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(5)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!-- 2) ã + "do" e.g. dudãdo -->
    
    <xsl:variable name="ando">
        <xsl:apply-templates select="$endo" mode="ando"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="ando">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="ando"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="ando">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZſçñ]+)(ã|ã|ā)(do)([ \.,;\(\)])'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3),regex-group(4))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'an',regex-group(4))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(5)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!-- 3) ẽ + "te|tes" e.g. "mortalmẽte", "gẽte"-->
    
    <xsl:variable name="ente">
        <xsl:apply-templates select="$ando" mode="ente"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="ente">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="ente"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="ente">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZſçñ]+)(ẽ|ẽ|ē)(te|tes)([ \.,;\(\)])'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3),regex-group(4))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'en',regex-group(4))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(5)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!-- 4) ẽ + "de" e.g. "entiẽde"-->
    <xsl:variable name="ende">
        <xsl:apply-templates select="$ente" mode="ende"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="ende">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="ende"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="ende">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZſçñ]+)(ẽ|ẽ|ē)(de)([ \.,;\(\)])'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3),regex-group(4))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'en',regex-group(4))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(5)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!--5) "õ-on" at the end e.g. "Purificaciõ"-->
    <xsl:variable name="cion">
        <xsl:apply-templates select="$ende" mode="cion"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="cion">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="cion"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="cion">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZſçñ]+)(õ|õ|ō|ō)([ \.,;\(\)])'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'on')"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(4)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!-- 6) ẽ + "to" e.g. "mandamiẽto"-->
    <xsl:variable name="ento">
        <xsl:apply-templates select="$cion" mode="ento"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="ento">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="ento"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="ento">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZſçñ]+)(ẽ|ẽ|ē)(to)([ \.,;\(\)])'}"><!--(\w+[^ãẽõũ])-->
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3),regex-group(4))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'en',regex-group(4))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(5)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!--7) ẽ + "cia|cias" e.g. "differẽcia"-->
    <xsl:variable name="encia">
        <xsl:apply-templates select="$ento" mode="encia"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="encia">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="encia"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="encia">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZſçñ]+)(ẽ|ẽ|ē)(cia|cias)([ \.,;\(\)])'}"><!--(\w+[^ãẽõũ])-->
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3),regex-group(4))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'en',regex-group(4))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(5)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!--  8) ã + "ancia" e.g. "ignorãcia"-->
    <xsl:variable name="ancia">
        <xsl:apply-templates select="$encia" mode="ancia"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="ancia">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="ancia"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="ancia">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZſçñ]+)(ã|ã|ā)(cia)([ \.,;\(\)])'}"><!--(\w+[^ãẽõũ])-->
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3),regex-group(4))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'an',regex-group(4))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(5)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

<!-- 9) ẽ + "er" e.g. "entẽder"-->
    <xsl:variable name="ener">
        <xsl:apply-templates select="$ancia" mode="ener"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="ener">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="ener"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="ener">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZſçñ]+)(ẽ|ẽ|ē)([aA-zZñſç]?)(er)([ \.,;\(\)])'}"><!--(\w+[^ãẽõũ])-->
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3),regex-group(4),regex-group(5))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'en',regex-group(4),regex-group(5))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(6)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!-- 10) ẽ + "ar" e.g. "encomẽdar"-->
    <xsl:variable name="enar">
        <xsl:apply-templates select="$ener" mode="enar"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="enar">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="enar"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="enar">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZñſç]+)(ẽ|ẽ|ē)([aA-zZñſç]?)(ar)([ \.,;\(\)])'}"><!--(\w+[^ãẽõũ])-->
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3),regex-group(4),regex-group(5))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'en',regex-group(4),regex-group(5))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(6)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!-- 11) ã + "ar" e.g. "mãdar"-->
    <xsl:variable name="anar">
        <xsl:apply-templates select="$enar" mode="anar"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="anar">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="anar"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="anar">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZſçñ]+)(ã|ã|ā)([aA-zZñſç]?)(ar)([\s\.,;\(\)])'}"><!--(\w+[^ãẽõũ])-->
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3),regex-group(4),regex-group(5))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'an',regex-group(4),regex-group(5))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(6)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!-- 12) Words ending with (ẽ-en). e.g. puedẽ, quiẽ, deuẽ-->
    
    <xsl:variable name="final-en">
        <xsl:apply-templates select="$anar" mode="final-en"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="final-en">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="final-en"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="final-en">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZſçñ]+)(ẽ|ẽ|ē)([ \.,;\(\)])'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'en')"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(4)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!-- 13) Words ending in (ā-an). e.g. haziā, siruā, podrā-->
    
    <xsl:variable name="final-an">
        <xsl:apply-templates select="$final-en" mode="final-an"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="final-an">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="final-an"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="final-an">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZſçñ]+)(ã|ã|ā)([ \.,;\(\)])'}"><!--(\w+[^ãẽõũ])-->
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'an')"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(4)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
   
<!-- 14) ũ + ar e.g. pregũtar, renũciar-->
    
    <xsl:variable name="unar">
        <xsl:apply-templates select="$final-en" mode="unar"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="unar">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="unar"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="unar">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZñſç]+)(ũ|ũ|ū|ū)([aA-zZñſç]+)(ar)([ \.,;\(\)])'}"><!--(\w+[^ãẽõũ])-->
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3),regex-group(4),regex-group(5))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'un',regex-group(4),regex-group(5))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(6)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
   
<!-- 15) ũ before (b|p) e.g. cũplido, costũbre-->
    
    <xsl:variable name="umbp">
        <xsl:apply-templates select="$unar" mode="umbp"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="umbp">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="umbp"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="umbp">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZñſç]+)(ũ|ũ|ū|ū)(b|p)([aA-zZñſç]+)([ \.,;\(\)])'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3),regex-group(4),regex-group(5))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'um',regex-group(4),regex-group(5))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(6)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!--16) "õ - before (b|p) e.g. hōbres, Cōprar"-->
    <xsl:variable name="ombp">
        <xsl:apply-templates select="$umbp" mode="ombp"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="ombp">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="ombp"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="ombp">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZñſç]+)(õ|õ|ō|ō)(b|p)([aA-zZñſç]+)([ \.,;\(\)])'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3),regex-group(4),regex-group(5))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'om',regex-group(4),regex-group(5))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(6)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!--17) "ō + dad|dades, bōdad, cōformidad", mode="ondad"-->
    <xsl:variable name="ondad">
        <xsl:apply-templates select="$ombp" mode="ondad"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="ondad">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="ondad"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="ondad">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZñſç]+)(õ|õ|ō|ō)([aA-zZñſç]*)(dad|dades)([ \.,;\(\)])'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3),regex-group(4),regex-group(5))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'on',regex-group(4),regex-group(5))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(6)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!--18) "õ + dido|dida|didas|didos, cōcedido, cōcedida" mode="ondido"-->
    
    <xsl:variable name="ondido">
        <xsl:apply-templates select="$ondad" mode="ondido"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="ondido">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="ondido"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="ondido">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZñſç]+)(õ|õ|ō|ō)([aA-zZñſç]*)(dido|dida|didas|didos)([ \.,;\)])'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3),regex-group(4),regex-group(5))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'on',regex-group(4),regex-group(5))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(6)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!--19) "ā + dad|des, trāquilidad, Hermādad" mode="andad"-->
    
    <xsl:variable name="andad">
        <xsl:apply-templates select="$ondido" mode="andad"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="andad">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="andad"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="andad">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZñſç]+)(āã)([aA-zZñſç]*)(dad|dades)([ \.,;\(\)])'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3),regex-group(4),regex-group(5))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'an',regex-group(4),regex-group(5))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(6)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!--20) "ā + ça|ças, ordenāça, templāça", mode="ança"-->
    <xsl:variable name="ança">
        <xsl:apply-templates select="$andad" mode="ança"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="ança">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="ança"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="ança">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZñſç]+)(ã|ã|ā)([ças]+)([ \.,;\(\)])'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3),regex-group(4))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'an',regex-group(4))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(5)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!--21) "ẽ  and ça|çan|ças, verguẽça, comiẽçan" mode="ença"-->
    <xsl:variable name="ença">
        <xsl:apply-templates select="$ança" mode="ença"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="ença">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="ença"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="ença">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZñſç]+)(ẽ|ẽ|ē)(ça|çan|ças+)([ \.,;\(\)])'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3),regex-group(4))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'en',regex-group(4))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(5)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

<!--22) "đ at the beginning e.g. đspues, đllas (no further special characters like "ā|ẽ|õ|ũ")" mode="dewords"-->
    
    <xsl:variable name="dewords">
        <xsl:apply-templates select="$ença" mode="dewords"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="dewords">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="dewords"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="dewords">
        <xsl:analyze-string select="." regex="{'(\s)(đ)([aA-zZñſç]+)([ \.,;\(\)])'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat('de',regex-group(3))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(4)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!--23) "ꝓ (q with tilde) inside a word, flaq̃za, riq̃zas (flaqueza, riquezas)" mode="wquew"-->
    <xsl:variable name="wquew">
        <xsl:apply-templates select="$dewords" mode="wquew"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="wquew">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="wquew"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="wquew">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZſçñ]+)(q̃)([aA-zZñſç]+)([ \.,;\(\)])'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3),regex-group(4))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'que',regex-group(4))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(5)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!--24) "ꝓ (pro) at the beginning, ꝓhibir, ꝓcesso (prohibir, processo)" mode="prow-->
    
    <xsl:variable name="prow">
        <xsl:apply-templates select="$wquew" mode="prow"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="prow">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="prow"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="prow">
        <xsl:analyze-string select="." regex="{'(\s)(ꝓ)([aA-zZñſç]+)([ \.,;\(\)])'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat('pro',regex-group(3))"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(4)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

<!--25) "final ũ", algũ - algun mode="final-un"-->
    
    <xsl:variable name="final-un">
        <xsl:apply-templates select="$prow" mode="final-un"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="final-un">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="final-un"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="final-un">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZſç]+)(ũ|ũ|ū|ū)([ \.,;\(\)])'}" flags="m">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'un')"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(4)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

<!--26)  "q̃", que - mode="only-que"-->
    
    <xsl:variable name="only-que">
        <xsl:apply-templates select="$final-un" mode="only-que"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="only-que">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="only-que"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="only-que">
        <xsl:analyze-string select="." regex="{'(\s)(q̃)([ \.,;\(\)])'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="regex-group(2)"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="'que'"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(3)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
<!--27) "ẽ", en - algun mode="only-en"-->
    
    <xsl:variable name="only-en">
        <xsl:apply-templates select="$only-que" mode="only-en"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="only-en">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="only-en"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="only-en">
        <xsl:analyze-string select="." regex="{'(\s)(ẽ)([ \.,;\(\)])'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="regex-group(2)"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="'en'"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(3)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!--28) "ꝓ q with tilde at the end of a word, porq̃  - porque"  mode="wque"-->
    <xsl:variable name="wque">
        <xsl:apply-templates select="$only-en" mode="wque"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="wque">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="wque"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="wque">
        <xsl:analyze-string select="." regex="{'(\s)([aA-zZſç]+)(q̃)([ \.,;\(\)])'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="concat(regex-group(2),regex-group(3))"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="concat(regex-group(2),'que')"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(4)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
<!--29) "đ - de" mode="only-de"-->
    
    <xsl:variable name="only-de">
        <xsl:apply-templates select="$wque" mode="only-de"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="only-de">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="only-de"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="only-de">
        <xsl:analyze-string select="." regex="{'(\s)(đ|)([ \.,;\(\)])'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="regex-group(2)"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="'de'"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(3)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

<!--30) ⁊ (char204a) ==> y , mode="only-y"-->
    
    <xsl:variable name="only-y">
        <xsl:apply-templates select="$only-de" mode="only-y"/>
    </xsl:variable>
    
    <!-- identity transforms -->
    <xsl:template match="@*|node()" mode="only-y">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="only-y"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="only-y">
        <xsl:analyze-string select="." regex="{'(\s)(⁊)([ \.,;\(\)])'}">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:element name="abbr">
                    <xsl:attribute name="rend" select="'choice'"/>
                    <xsl:attribute name="resp" select="'#auto'"/>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'abbr'"/>
                        <xsl:value-of select="regex-group(2)"/>
                    </xsl:element>
                    <xsl:element name="abbr">
                        <xsl:attribute name="rend" select="'expan'"/>
                        <xsl:attribute name="resp" select="'#CR #auto'"/>
                        <xsl:value-of select="'y'"/>
                    </xsl:element>
                </xsl:element>
                <xsl:value-of select="regex-group(3)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
<!-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
    
    <!-- LOGGING -->
    <!-- adjust this section in case modifications take place with text nodes or break elements -->
    
    <xsl:variable name="out">
        <xsl:copy-of select="$only-y"/>
    </xsl:variable>
    
    <xsl:template match="/">
        <xsl:copy-of select="$out"/>
        <xsl:variable name="inWhitespace" as="xs:integer" select="string-length(replace(string-join(//tei:text//text(), ''), '\S', ''))"/>
        <xsl:variable name="inChars" as="xs:integer" select="string-length(replace(string-join(//tei:text//text(), ''), '\s', ''))"/>
        <xsl:variable name="outWhitespace" as="xs:integer" select="string-length(replace(string-join($out//tei:text//text(), ''), '\S', ''))"/>
        <xsl:variable name="outChars" as="xs:integer" select="string-length(replace(string-join($out//tei:text//text(), ''), '\s', ''))"/>
        <xsl:variable name="inPb" as="xs:integer" select="count(//tei:pb)"/>
        <xsl:variable name="outPb" as="xs:integer" select="count($out//tei:pb)"/>
        <xsl:variable name="inCb" as="xs:integer" select="count(//tei:cb)"/>
        <xsl:variable name="outCb" as="xs:integer" select="count($out//tei:cb)"/>
        <xsl:variable name="inLb" as="xs:integer" select="count(//tei:lb)"/>
        <xsl:variable name="outLb" as="xs:integer" select="count($out//tei:lb)"/>
        
        <!-- whitespace -->
        <xsl:if test="$inWhitespace ne $outWhitespace">
            <xsl:message select="'ERROR: amount of whitespace characters differs in input and output doc: '"/>
            <xsl:message select="concat('Input whitespace: ', $inWhitespace)"/>
            <xsl:message select="concat('Output whitespace: ', $outWhitespace)"/>
            <xsl:message terminate="yes"/>
        </xsl:if>
        <!-- chars -->
        <xsl:if test="$inChars ne $outChars">
            <xsl:message select="'INFO: amount of non-whitespace characters differs in input and output doc: '"/>
            <xsl:message select="concat('Input characters: ', $inChars)"/>
            <xsl:message select="concat('Output characters: ', $outChars)"/>
            <xsl:message terminate="no"/>
        </xsl:if>
        <!-- breaks -->
        <xsl:if test="$inPb ne $outPb or $inCb ne $outCb or $inLb ne $outLb">
            <xsl:message select="'ERROR: different amount of input and output pb/cb/lb: '"/>
            <xsl:message select="concat('Input pb: ', $inPb, ' | cb: ', $inCb, ' | lb: ', $inLb)"/>
            <xsl:message select="concat('Output pb: ', $outPb, ' | cb: ', $outCb, ' | lb: ', $outLb)"/>
            <xsl:message terminate="yes"/>
        </xsl:if>
        
        <!--
        Unwanted characters in expansions.        
        These characters should not be in an expansion, since they are also to be expandend.  ã ã ā ē ẽ ẽ ĩ õ õ ō ō ũ ũ ū ū đ ꝓ q̃  
        In these program are not taken into account words with multiple charaters to be expanded.
        e.g. (abbr: tãbiẽ => expan: tambien) is a complex case because it hast 2 characters to be expanded namely 'ã' in 'am' and 'ẽ' in 'en'.    
        -->
        <!-- Update last case variable in the following variables: Abbr and WrongExpansions-->
        <xsl:variable name="Abbr" as="node()*" select="$only-y//tei:abbr[@rend eq 'abbr' and following-sibling::node()/self::tei:abbr[@rend eq 'expan' and matches(.,'[̃ ãāēẽõōũūꝓđ]+')]]"/>
        <xsl:variable name="WrongExpansions" as="node()*" select="$only-y//tei:abbr[@rend eq 'choice']//tei:abbr[@rend eq 'expan' and matches(.,'[̃ ãāēẽõōũūꝓđ]+')]"/>
        <xsl:choose>
            <xsl:when test="count($WrongExpansions) gt 1">
                <!--<xsl:for-each select="$WrongExpansions/text()">-->
                <xsl:message select="concat('Error: ', count($WrongExpansions),' unwanted special character(s) in tei:abbr[@rend=expan] detected. Words: abbr => '
                    ,string-join(distinct-values($Abbr),' | '), ' expan => '
                    ,string-join(distinct-values($WrongExpansions),' | '),' - Evaluate the regex patterns/cases and run the program again.')"/>
                <!--</xsl:for-each>-->
            <xsl:message terminate="no"/>
            </xsl:when>
            <xsl:when test="count($WrongExpansions) eq 1">
                <xsl:message select="concat('Error: unwanted special character in expan detected - ',$Abbr,' - ',$WrongExpansions,' - Evaluate the regex patterns/cases and run the program again.')"/>
                <xsl:message terminate="no"/>
            </xsl:when>
            <!--Abbr with no special character, check this out.-->
            <xsl:when test="$only-y//tei:abbr[@rend eq 'abbr' and not(matches(.,'[ãẽõũꝓq̃]+'))]">
                <xsl:message select="concat('An abbr without special character detected: ',string-join(distinct-values(tei:abbr[@rend eq 'abbr' and not(matches(.,'[ãẽõũꝓq̃]+'))]),' | '))"/>
                <xsl:message terminate="no"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- Update last case variable in the following variable: Expansions-->
                <xsl:variable name="Expansions" as="xs:integer" select="count($only-y//tei:abbr[@rend eq 'choice']//tei:abbr[@rend eq 'expan'])"/>
                <xsl:message select="concat('INFO: added ', xs:string($Expansions), ' with regex-based (word structure) abbr. expansion.')"/>
                <xsl:message select="'INFO: quality check successfull.'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>