import os
import saxonche as saxon
import subprocess
from xml.dom import minidom

def cloneGitHubRepo(repoURL, folderName):
    """
    Clone a GitHub repository if the folder doesn't exist.
    """
    if not os.path.exists(folderName):
        # Use the git command to clone the repo
        subprocess.run(['git', 'clone', repoURL, folderName])
    else:
        print(f"The folder {folderName} already exists.")


def combineXmlFiles(folderPath, processor):
    """
    Combine XML files from a folder into one large XML.
    """
    # Add XML declaration to the combined XML
    combinedXml = "<?xml version='1.0' encoding='UTF-8'?>\n<root>"

    for xmlFile in os.listdir(folderPath):
        fullPath = os.path.join(folderPath, xmlFile)

        if xmlFile.endswith(".xml"):
            try:
                # Trying to parse the XML from the file to test for well-formedness
                processor.parse_xml(xml_file_name=fullPath)
                # Removing individual XML declarations and store each file in an XMLfile element
                with open(fullPath, 'r', encoding='utf-8') as f:
                    content = f.read().replace(
                        '<?xml version="1.0" encoding="UTF-8"?>', '').strip()
                    filenameWithoutExt = os.path.splitext(xmlFile)[0]
                    content = f'<XMLfile id="{filenameWithoutExt}">\n{content}\n</XMLfile>'
                    combinedXml += content

            except Exception as e:
                print(f"File {xmlFile} is not well-formed. Reason: {e}")

    combinedXml += "</root>"
    return combinedXml


def transformXml(parsedXML, compiledStylesheet):
    """
    Transforms a combined XML string using the provided XSLT.
    """
    # Use the compiled stylesheet for transformation
    try:
        transformedResult = compiledStylesheet.transform_to_string(xdm_node=parsedXML)
        return transformedResult
    except Exception as e:
        print(f"Error during transformation. Reason: {e}")
        return None



def cleanWhitespaceNodes(node):
    """
    Removes whitespace-only text nodes from the XML DOM.
    """
    for child in list(node.childNodes):
        if child.nodeType == minidom.Node.TEXT_NODE and child.nodeValue.strip() == '':
            node.removeChild(child)
        else:
            cleanWhitespaceNodes(child)

def prettyPrintXml(xmlString):
    """
    Formats the XML string by removing unnecessary whitespaces and using toprettyxml.
    """
    dom = minidom.parseString(xmlString)
    cleanWhitespaceNodes(dom)
    return dom.toprettyxml(indent="  ")

# Main script execution
if __name__ == '__main__':
    # Clone the original repository
    repoURL = 'https://github.com/wibarab/featuredb.git'
    folderName = 'featuredb'
    cloneGitHubRepo(repoURL, folderName)

    # Initialize necessary processors
    saxonProcessor = saxon.PySaxonProcessor(license=False)
    saxonProcessor.set_configuration_property("xi", "on")
    builder = saxonProcessor.new_document_builder()
    xsltProcessor = saxonProcessor.new_xslt30_processor()

    # Load the XSLT stylesheet
    compiledStylesheet = xsltProcessor.compile_stylesheet(stylesheet_file="xml_dev_assessment.xsl")

    # Combine all XML files
    folderPath = folderName + "/010_manannot/features/"
    combinedXml = combineXmlFiles(folderPath, saxonProcessor)

    # Parse the combined XML
    xmlSource = builder.parse_xml(xml_text=combinedXml)

    # Transform XML
    transformedXml = transformXml(xmlSource, compiledStylesheet)

    # Format the transformed XML for better readability
    formattedXml = prettyPrintXml(transformedXml)

    # Save the formatted XML to a file
    with open("report.xml", "w", encoding="utf-8") as outFile:
        outFile.write(formattedXml)
