# ZoteroEADConverter
An XProc pipeline to download a Zotero library and convert it to EAD 2.

To perform a conversion, run the XProc script `xproc/convert.xpl`, using the XProc interpreter [XMLCalabash](http://xmlcalabash.com/).

You will need to pass three options to the script:

* `library` = a Zotero library URI, relative to the Zotero website, e.g. `groups/99999`
* `output-file` = a file name for the EAD file
* `country-code` = a [country code](http://www.loc.gov/ead/tglib/elements/eadid.html) for the EAD `eadid` element

You will need to pass a parameter called `key`, whose value is a [private key giving access to that Zotero library](https://www.zotero.org/settings/keys). 

e.g.

```
java -Xmx1024m -cp xmlcalabash.jar com.xmlcalabash.drivers.Main --with-param key="XXXXXXXXXXXXXXXX" library="groups/83731" country-code="AU" output-file="ead.xml" ZoteroEADConverter/xproc/convert.xpl
```
