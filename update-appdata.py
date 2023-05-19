import sys
import time
from xml.etree import ElementTree as etree

def update_release(appdata_file,version, date):
    tree = etree.parse(appdata_file)

    releases = tree.find("./releases")
    assert releases

    release = etree.Element("release", attrib={"version": version, "date": date})
    releases.insert(0, release)

    etree.indent(tree)

    tree.write(appdata_file, encoding="utf-8", xml_declaration=True)


if __name__ == "__main__":
    today = time.strftime("%Y-%m-%d")
    update_release("share/org.gaphor.Gaphor.appdata.xml", sys.argv[1], today)