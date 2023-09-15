# XML_Dev_Assessment
Assessment Task for the Research Data Engineer position at the ACDH-CH  
Chosen Task: "Task 2: Data Extraction from XML"

## Instructions
### Prerequisites

Before you begin, ensure you have met the following requirements:

- **Python 3.x**: Make sure Python 3 is installed. You can check using `python --version` or `python3 --version`.
- **Git**: Git needs to be installed and accessible from command line. Required for cloning repositories. Verify by running `git --version`.
  **_NOTE:_**  Git is preinstalled on macOS and Linux, but not on Windows computers.

### Setup and Execution

1. **Clone this repository**:
    ```bash
    git clone https://github.com/kisram/XML_Dev_Assessment.git
    ```
2. **Navigate to the project directory**:
    ```bash
    cd XML_Dev_Assessment
    ```
3. **Install Python Dependencies**:
    ```bash
    pip install -r requirements.txt
    ```
4. **Execute the script**:
    ```bash
    python XML_Dev_Assessment.py
    ```
**_NOTE:_** Depending on your setup (e.g. if you have both Python 2 and Python 3 installed), you might need to use 'python3' and 'pip3' instead of 'python' and 'pip'.

### Output

After executing the script, you'll find an XML report of the data in https://github.com/wibarab/featuredb/tree/main/010_manannot/features named `report.xml` in the project directory. It provides the following information:
-  An index of all mentioned places in wib:featureValueObservation/placeName.
-  A summary of all number of all feature value observiations associated with each dialect
(wib:featureValueObservation/lang)
-  Which types of bibliographic items are used most? (type attribute on referenced <bibl>
element)
-  Which features are associated with tribes? (encoded as <personGrp role="tribe">)
-  Do you find documents which cannot be parsed because of well-formedness errors?
-  Do you find broken pointers which cannot be resolved?

## Explanation of Approach and Solution

First, I chose this task because it aligns more with my skills and interests than Task 1. The prerequisites mention:
>Prerequisite: a programming language able to parse XML and aggregate values. Preferably XSLT or XQuery, but Python or Javascript are fine as well.

Given this, I opted for XSLT, supplemented by Python. Some operations were more straightforward with Python or just not doable using only XSLT. Moreover, I needed a mechanism to run the XSLT.

Accessing the `featuredb` repository directly might hit the GitHub rate limit, so my approach starts by cloning it, unless it's already downloaded.

I made a basic assumption that the task requires **one** report for **all** XML files in [this repository](https://github.com/wibarab/featuredb/tree/main/010_manannot/features). In the beginning, I weighed two approaches: merge all XMLs and then process, or transform each XML individually and compile the results. Given that the combined XML size was manageable, the merge-and-process method seemed more efficient and straightforward.

When it came to choosing the XML and XSLT processor, I initially gravitated towards the lxml Python library. But since I intended to use `<xsl:for-each-group>` available in XSLT version 2.0, and lxml only supports 1.0, I chose the saxonche library despite being less familiar with it.

After cloning the repository, every XML file in the directory is parsed. Any XML not well-formed triggers an error message. Successfully parsed XMLs are then merged into a single file. During this, I remove individual XML declarations, adding one global declaration instead. The content of each file is put in an element, labeled with its filename. This is done so I can later identify in which file a broken pointer was found.

Afterwards, the combined XML file is transformed using the XSLT stylesheet. My goal was a straightforward XML report using some custom element names, emphasizing readability. Each sub-task had its designated element (except for 5., that sub-task was achieved in the Python script).

1. **Index of All Mentioned Places**: 
   Using `<xsl:for-each-group>`, I group `wib:featureValueObservation` elements by the `@ref` attribute in `tei:placeName`. This ensures unique indexing. The result is under the `<placeIndex>` element, each entry containing the place, in the same format as in the original XML filesa and a list of all wib:featureValueObservationwhere they occur.

2. **Summary of Feature Value Observations by Dialect**:
   I group `wib:featureValueObservation/tei:lang` elements by their `@corresp` and use the count function. This provides the total number feature value observations for each dialect, listed under the `<observationsByLanguage>` element.

3. **Analysis of Bibliographic Items**:
   The task only asks for the most-used bibliographic item, but I included counts for each type. I group `tei:bibl` elements based on their type attribute and determine the most-used item using the max function. Results can be found under the <bibliographicItems> section.

4. **Features Associated with Tribes**:
   I identified features linked to tribes by targeting `wib:featureValueObservation` elements that have a `tei:personGrp` child with a role attribute labeled "tribe". The associated features are listed under the <tribesFeatureList> section in the report.

5. **Identification of Documents Not Well-Formed**:
   During the XML file processing in the Python script, I use a try-except structure. Parsing each file with Saxon, any ill-formed XML would raise an exception, which is then caught, and the relevant error message, along with the file name, is printed out.

6. **Identification of Broken Pointers**:
   "Broken pointers which cannot be resolved" was a bit ambiguous, so I started with the things that are part of the report: place names, dialects, person groups, and bibliographic references. Later I also included the references from the @resp attribute of each wib:featureValueObservation element, based on the list of prefixes at the beginning of each document The logic for all of these is similar, I check if the value exists in the external documents they reference. For simplicity, links to external documents are hardcoded. For dialects, I verify if the document in the `<lang>` element's `@corresp` attribute exist. Broken pointers, when found, include references to their source document. Both the list of broken pointers and the list of source files is deduplicated. I noticed some `person group references` prefixed with '#' instead of 'prg:'and considered adjusting the script for this but then thought it would be informative to highlight such inconsistencies.

After the XSLT transformation, I refine the XML report for better readability, ensuring proper indentation and removing unnecessary spaces.
