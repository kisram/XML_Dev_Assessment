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

## Explanation of approach and solution
First of all, I chose this task because it seemed to align more with my skills and interests than task 1.
My approach makes the basic assumption that the task requires **one** report to be created for **all** the xml files in https://github.com/wibarab/featuredb/tree/main/010_manannot/features. Based on the prerequisite
>Prerequisite: a programming language able to parse XML and aggregate values. Preferably XSLT or
XQuery, but Python or Javascript are fine as well.

