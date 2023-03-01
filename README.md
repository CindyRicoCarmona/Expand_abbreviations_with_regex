# Abbreviation expansion with regular expressions.
[![DOI](https://zenodo.org/badge/588171970.svg)](https://zenodo.org/badge/latestdoi/588171970)

Expanding early modern Latin and Spanish abbreviations depending on their word structure. It is a complementary automatic correction, and preparation for a further list based abbreviation expanssion and manual scholarly correction and editing. 

For instance: Most words ending in *ẽdo* should be expanded *endo*:
    
   ``pudiẽdo`` ➡ ``pudiendo``

**Context:** Early Modern Spanish in The School of Salamanca. A Digital Collection of Sources.

For more details about our digital edition see:
* Some preliminary challenges https://github.com/CindyRicoCarmona/Name_Entity_Annotation#preliminary-challenges
* Our text workflow <https://blog.salamanca.school/en/2022/04/27/the-school-of-salamanca-text-workflow-from-the-early-modern-print-to-tei-all/> 
* Our edition guidelines *3.2.4.  Abbreviations and Printing Errors* <https://www.salamanca.school/en/guidelines.html#abbreviationsprinterrors>

**Sample Works:** 

* Early Modern Spanish: León Pinelo, Confirmaciones Reales de Encomiendas (2021 [1630]), in: The School of Salamanca. A Digital Collection of Sources <https://id.salamanca.school/texts/W0061>
* Early Modern Latin: Díaz de Luco, Practica criminalis canonica (2021 [1554]), in: The School of Salamanca. A Digital Collection of Sources <https://id.salamanca.school/texts/W0041>

## Requirements
        
* Input: xml file in TEI-tite format with no special character annotation ``<g>`` elements. It can be addapted to TEI-All texts in similar conditions.
* Missing or double white spaces in the input text should be revised and silently resolved, in order to avoid false positves.

## XSL:Style-sheet Details

* Every template has a specific word structure *case* and a *mode*, so many searches are allowed in the same xsl:style-sheet:
        
* For Spanish was added in every ``xsl:template``, ``not(ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])`` to exclude text marked with different languages.
* For Latin ``not(ancestor::*[@xml:lang = ('es','grc','gr','he','fr','pt','it')])``

        
* Output: Copy of input text plus abbreviations tagged as:

    ``<abbr rend="choice" resp="#auto"><abbr rend="abbr">[abbreviation]</abbr><abbr rend="expan" resp="#CR #auto">[expansion]</abbr></abbr>``
            
* Tilde and Macron characters are taken into account. It means, every case has several possible ocurrencies of composed and precomposed characters e.g ẽ|ẽ|ē

### Case and Mode Example *endo* - ``pudiẽdo`` ➡ ``pudiendo``
    
    <xsl:variable name="endo">
        <xsl:apply-templates select="/" mode="endo"/>
    </xsl:variable>
        
    <!-- Copy of the original text - identity transforms -->
    <xsl:template match="@*|node()" mode="endo">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="endo"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- xsl:template with the regular expression of the specific case and mode. -->
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
    

* The output text can be used for a TEI-tite to TEI-All transformation automatically converteding abbreviations into:
            
    ``<choice resp="#auto"><abbr>[abbreviation]</abbr><expan resp="#CR #auto">[expansion]</expan></choice>``

## How to use it

* With any editor, which suports Saxon. 

Or ...
 
* With Ant and a small pipeline build.xml

See for Spanish ➡ Spanish_W0061\build.xml and for Latin ➡ Latin_W0041\build.xml. 

They show manual and automatic steps to edit the text. For instance:

1) `<target name="patch-000">` manual step. File W0061_001.xml wiht a basic structural annotation.
 
2) `<target name="xslt-000">` automatic step. Input file W0061_001.xml is transformed by style-sheet W0061_001.xsl producing the output file W0061_002.xml annotated with abbreviation and expanssions.

3) `<target name="finalize" depends="xslt-001">` finalizes the process with the last step W0061_001.xsl

This transformation is performed twice in the pipeline, as sometimes two abbreviations on the same line are not resolved in the first go.
Example from file W0061: 

``<lb/>``ay una **peticiõ** **cõ** eſta reſpueſta en aquellas Cortes:

**peticiõ** and **cõ** are two different abbreviations, however, they share a word boundary, namely, the white space between them. Therefore, only the first one is annotated in the first execution.
                        
## Cases

One case and mode for every template. See details in the style-sheets:

* Latin_W0041\xsl\W0041_001.xsl 
* Spanish_W0061\xsl\W0061_001.xsl


### Spanish 

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
22) "đ at the beginning + \w, đspues, đllas (no further special characters like "ā|ẽ|õ|ũ")" mode="dewords"
23) "ꝓ q with tilde inside a word, flaq̃za, riq̃zas (flaqueza, riquezas)" mode="wquew"
24) "ꝓ pro at the beginning + \w, ꝓhibir, ꝓcesso (prohibir, processo)" mode="prow"

Depending on the text and the mixture between latin and spanish.

25) "final ũ", algũ - algun mode="final-un"
26) "q̃" - que,  mode="only-que"
27) "ẽ - en", mode="only-en"
28) "ꝓ q with tilde at the end of a word, porq̃  - porque" mode="wque"
29) "đ| (char0111|charf159)- de" mode="only-de"
30) ⁊ (char204a) ➡ y , mode="only-y"
        
### Latin
        
1) Final ũ|ū - um, legũ, appellatũ", mode="final-um"
2) Final ā|ã - am, primā, verā, mode="final-am"
3) ā + final di|dum|t|ti|tibus|tis|tur, mode="antur"
4) Beginning pro (chara753), ꝓbari probari, mode="pro1"
5) Final - us (chara770), legitimꝰ - legitimus, mode="final-us"
6) õ + c|d|f|s|t ==> on, cōsensu consensu, mode="on-cdfst"
7) õ + final e|es, petitiōe petitione, mode="ones"
8) ũ + t|tur, deducũtur deducuntur, mode="untur"
9) ẽ + da|dam|di|dis|dus|sis|t|te|tia|tiam|tias|tur, legẽdam legendam, mode="entur"
10) ẽ + b|m|p, exẽplo exemplo, mode="em-pmb"
11) ĩ  ==> in, only white spaces as boundaries. 
12) đ ==> de, only white spaces boundaries, mode="de" 

Names are tagged literal:

13) Clemẽ - Clemen + \., mode="Clemen"
14) Innocẽ - Innocen + \., mode="Innocen"
15) Alexā - Alexan + \., mode="Alexan"
16) Alexād - Alexand + \., mode="Alexand"
17) Ioā - Ioan + \. , mode="Ioan"
18) q + ´ + ; ==> que, leuisq́;, mode="qac"
19) q3 + ´ (chare8bf0301) ==> que, Exemplum́, mode="q3accent"
20) q3 (chare8bf), ==> que, mode="q3"
21) ⁊ (char204a) ==> et. , mode="only-et"
            
                
## What is not covered?

Some words might appear separated by ``<pb/>, <cb/>, <lb/>, <note> or <milestone/>``. These cases are not automatically covered yet, and are only manually expanded.

  ``mã-<pb n="[21]v" facs="W0061-0078"/><lb type="nb"/>dando``
    
  ``Encomiẽ<lb type="nb"/>das``

To avoid false positives at the end of `<lb/>(s)`, new lines ``\n`` and tabs ``\t`` are not included as word boundaries. This also means, that words at the end of the lines are not annotated, eventhoug they might follow the pattern. e.g. 

  ``eſtãdo\n``

## Not found, maybe for future works?

Spanish:        
* Words with ĩ and ar, er, ir 
* Words with ã and er, ir
* Words with õ + ir
* Words with ũ + er 
* Words with ũ + ir
* Few cases of "ꝓ" inside a word. e.g. "aꝓuechar" aprouechar 
  
  ``(\s)([aA-zZñſç]+)(ꝓ)([aA-zZñſç]+)([ \.,;\(\)])``
   
## How to add new cases     

This information can be found in the xsl files. Here the Spanish example:
     
1) Test the new pattern in the input text, in this case W0061_001.xml
        Words found should neither yield exceptions, ambiguities nor show conflicts with other cases in this program.
        
2) Write the pattern with examples in the list "cases" above and assign a new mode. It should be different from all modes used before.
     
3) Between the last template and "Logging", write a new variable. Its name is usually the same name as the new mode. In ``<xsl:apply-templates/>`` select the last variable name, and place the new mode: 
     
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

    ``<xsl:template match="text()[not(ancestor::tei:abbr or ancestor::*[@xml:lang = ('la','grc','gr','he','fr','pt','it')])]" mode="ExampleNew">``
    
    Regex-groups must be placed in parenthesis ``()`` and distributed in the new elements. See the templates below.
    
6) For logging purpuses and for keeping track of the new expanssions added, look for the following locations (variable ``$out`` and variable ``$Expansions``) at the very end of the code in the "Logging" section and replace the new variable:
    
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

