import re
import ssl
import sys
import textwrap
import time
import urllib.request
from xml.etree import ElementTree as etree


def update_release(appdata_file, version, date, notes):
    tree = etree.parse(appdata_file)

    release = find_release(tree, version, date)
    update_release_details(release, version, notes)

    etree.indent(tree)
    tree.write(appdata_file, encoding="utf-8", xml_declaration=True)


def find_release(tree, version, date):
    if (release := tree.find(f"./releases/release[@version='{version}']")) is None:
        release = etree.Element("release", attrib={"version": version, "date": date})
        tree.find("./releases").insert(0, release)

    return release


def test_find_release():
    tree = etree.parse("share/org.gaphor.Gaphor.appdata.xml")

    release = find_release(tree, "2.17.0", "DATE")

    # Should have found the existing node
    assert release.attrib["date"] != "DATE"


def update_release_details(release, version, notes):
    for node in release.findall("*"):
        release.remove(node)

    description = etree.SubElement(release, "description")
    ul = etree.SubElement(description, "ul")
    for note in notes:
        li = etree.SubElement(ul, "li")
        li.text = note

    url = etree.SubElement(release, "url")
    url.text = f"https://github.com/gaphor/gaphor/releases/tag/{version}"


def download_news_from_github():
    url = "https://raw.githubusercontent.com/gaphor/gaphor/main/CHANGELOG.md"
    with urllib.request.urlopen(url, context=ssl.create_default_context()) as response:
        return response.read().decode(encoding="utf-8")


def test_download_news_from_github():
    news = download_news_from_github()

    assert news
    assert "2.18.0" in news


def parse_news(news_text: str):
    news = {}
    current_version = None
    current_news = None

    for line in news_text.splitlines():
        if re.match("^\d+.\d+.\d+$", line):
            current_news = []
            current_version = line
            news[current_version] = current_news
        elif current_version and re.match("^ *- +", line):
            current_news.append(re.sub("^ *- +", "", line))
        elif current_news and re.match("^ +\w", line):
            current_news[-1] = current_news[-1] + " " + line.strip()
        elif not line:
            current_version = None

    return news


def test_parse_news():
    fragment = textwrap.dedent("""\
        2.1.0
        ------
        - Feature
          three
         - Feature four

        2.0.0
        ------
        - Feature one
        - Feature two
        """)

    news = parse_news(fragment)

    assert "2.0.0" in news
    assert "2.1.0" in news

    assert "Feature one" in news["2.0.0"]
    assert "Feature two" in news["2.0.0"]
    assert "Feature three" in news["2.1.0"]
    assert "Feature four" in news["2.1.0"]


def run_tests():
    for name, maybe_test in list(globals().items()):
        if name.startswith("test_"):
            print(name, "...", end="")
            maybe_test()
            print(" okay")


if __name__ == "__main__":
    if len(sys.argv) > 1:
        version = sys.argv[1]
        today = time.strftime("%Y-%m-%d")
        news = parse_news(download_news_from_github())
        update_release("share/org.gaphor.Gaphor.appdata.xml", version, today, news.get(version, ["Bug fixes."]))
    else:
        run_tests()