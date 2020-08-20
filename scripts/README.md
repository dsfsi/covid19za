# covid19za scripts

## Mobility Scraper

## GP PDF Scraper
Extracts data from Gauteng Province Health PDF media statements. Extracts Covid-19 data at provincial, district and sub-district level for Gauteng.

### Dependencies
This module requires [pdfplumber](https://github.com/jsvine/pdfplumber). Install using `pip install pdfplumber`.

### Usage
**Import library**:

```
import gp_pdf_extractor
``` 

Note: This assumes you are calling the module from the same directory as the file.

**Extract Data:**

```
gp_pdf_extractor.extract_data("[path_to_pdf]")
```

This will return a '|' delimited string containing all relevant data. 