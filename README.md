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

Once aggregated, the combined XML file is transformed using the XSLT stylesheet. My goal was a straightforward XML report using some custom element names, emphasizing readability. Each sub-task had its designated element (except for 5., that sub-task was achieved in the Python script).
