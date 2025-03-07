#!/usr/bin/env python3
# Copyright (C) 2012-2013, The CyanogenMod Project
#           (C) 2017-2018,2020-2021, The LineageOS Project
#           (C) 2023-2024 Blackiron
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from __future__ import print_function

import base64
import glob
import json
import netrc
import os
import re
import sys
import urllib.error
import urllib.parse
import urllib.request

from xml.etree import ElementTree

dryrun = os.getenv('ROOMSERVICE_DRYRUN') == "true"
if dryrun:
    print("Dry run roomservice, no change will be made.")

product = sys.argv[1]

if len(sys.argv) > 2:
    depsonly = sys.argv[2]
else:
    depsonly = None

try:
    device = product[product.index("_") + 1:]
except:
    device = product

if not depsonly:
    print("Device %s not found. Attempting to retrieve device repositories from GitHub (http://github.com/Blackiron-devices)." % device)

repositories = []

try:
    authtuple = netrc.netrc().authenticators("api.github.com")

    if authtuple:
        auth_string = ('%s:%s' % (authtuple[0], authtuple[2])).encode()
        githubauth = base64.encodestring(auth_string).decode().replace('\n', '')
    else:
        githubauth = None
except:
    githubauth = None

def add_auth(githubreq):
    if githubauth:
        githubreq.add_header("Authorization","Basic %s" % githubauth)

if not depsonly:
    githubreq = urllib.request.Request("https://api.github.com/orgs/Blackiron-devices/repos?per_page=100")
    add_auth(githubreq)
    
    try:
        result = json.loads(urllib.request.urlopen(githubreq).read().decode())
    except urllib.error.URLError:
        print("Failed to fetch data from GitHub")
        sys.exit(1)
    except ValueError:
        print("Failed to parse return data from GitHub")
        sys.exit(1)
    
    for repo in result:
        repositories.append(repo['name'])

local_manifests = r'.repo/local_manifests'
if not os.path.exists(local_manifests): os.makedirs(local_manifests)

def exists_in_tree(lm, path):
    for child in lm.getchildren():
        if child.attrib['path'] == path:
            return True
    return False

# in-place prettyprint formatter
def indent(elem, level=0):
    i = "\n" + level*"  "
    if len(elem):
        if not elem.text or not elem.text.strip():
            elem.text = i + "  "
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
        for elem in elem:
            indent(elem, level+1)
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
    else:
        if level and (not elem.tail or not elem.tail.strip()):
            elem.tail = i

def get_manifest_path():
    '''Find the current manifest path
    In old versions of repo this is at .repo/manifest.xml
    In new versions, .repo/manifest.xml includes an include
    to some arbitrary file in .repo/manifests'''

    m = ElementTree.parse(".repo/manifest.xml")
    try:
        m.findall('default')[0]
        return '.repo/manifest.xml'
    except IndexError:
        return ".repo/manifests/{}".format(m.find("include").get("name"))

def get_default_revision():
    m = ElementTree.parse(get_manifest_path())
    d = m.findall('default')[0]
    r = d.get('revision')
    return r.replace('refs/heads/', '').replace('refs/tags/', '')

def get_from_manifest(devicename):
    for path in glob.glob(".repo/local_manifests/*.xml"):
        try:
            lm = ElementTree.parse(path)
            lm = lm.getroot()
        except:
            lm = ElementTree.Element("manifest")

        for localpath in lm.findall("project"):
            if re.search("android_device_.*_%s$" % device, localpath.get("name")):
                return localpath.get("path")

    return None

def is_in_manifest(projectpath):
    for path in glob.glob(".repo/local_manifests/*.xml"):
        try:
            lm = ElementTree.parse(path)
            lm = lm.getroot()
        except:
            lm = ElementTree.Element("manifest")

        for localpath in lm.findall("project"):
            if localpath.get("path") == projectpath:
                return True

    # Search in main manifest, too
    try:
        lm = ElementTree.parse(get_manifest_path())
        lm = lm.getroot()
    except:
        lm = ElementTree.Element("manifest")

    for localpath in lm.findall("project"):
        if localpath.get("path") == projectpath:
            return True

    # ... and don't forget the blackiron snippet
    try:
        lm = ElementTree.parse(".repo/manifests/snippets/blackiron.xml")
        lm = lm.getroot()
    except:
        lm = ElementTree.Element("manifest")

    for localpath in lm.findall("project"):
        if localpath.get("path") == projectpath:
            return True

    return False

def add_to_manifest(repositories):
    if dryrun:
        return

    try:
        lm = ElementTree.parse(".repo/local_manifests/roomservice.xml")
        lm = lm.getroot()
    except:
        lm = ElementTree.Element("manifest")

    for repository in repositories:
        repo_name = repository['repository']
        repo_target = repository['target_path']
        repo_revision = repository['branch']
        print('Checking if %s is fetched from %s' % (repo_target, repo_name))
        if is_in_manifest(repo_target):
            print('Blackiron-devices/%s already fetched to %s' % (repo_name, repo_target))
            continue

        project = ElementTree.Element("project", attrib = {
            "path": repo_target,
            "remote": "github",
            "name": "Blackiron-devices/%s" % repo_name,
            "revision": repo_revision })
        if repo_remote := repository.get("remote", None):
            # aosp- remotes are only used for kernel prebuilts, thus they
            # don't let you customize clone-depth/revision.
            if repo_remote.startswith("aosp-"):
                project.attrib["name"] = repo_name
                project.attrib["remote"] = repo_remote
                project.attrib["clone-depth"] = "1"
                del project.attrib["revision"]
        print("Adding dependency: %s -> %s" % (project.attrib["name"], project.attrib["path"]))
        lm.append(project)

    indent(lm, 0)
    raw_xml = ElementTree.tostring(lm).decode()
    raw_xml = '<?xml version="1.0" encoding="UTF-8"?>\n' + raw_xml

    f = open('.repo/local_manifests/roomservice.xml', 'w')
    f.write(raw_xml)
    f.close()

def fetch_dependencies(repo_path):
    print('Looking for dependencies in %s' % repo_path)
    dependencies_path = repo_path + '/blackiron.dependencies'
    syncable_repos = []
    verify_repos = []

    if os.path.exists(dependencies_path):
        dependencies_file = open(dependencies_path, 'r')
        dependencies = json.loads(dependencies_file.read())
        fetch_list = []

        for dependency in dependencies:
            if not is_in_manifest(dependency['target_path']):
                fetch_list.append(dependency)
                syncable_repos.append(dependency['target_path'])
                if 'branch' not in dependency:
                    if dependency.get('remote', 'github') == 'github':
                        dependency['branch'] = get_default_or_fallback_revision(dependency['repository'])
                    else:
                        dependency['branch'] = None
            verify_repos.append(dependency['target_path'])

            if not os.path.isdir(dependency['target_path']):
                syncable_repos.append(dependency['target_path'])

        dependencies_file.close()

        if len(fetch_list) > 0:
            print('Adding dependencies to manifest')
            add_to_manifest(fetch_list)
    else:
        print('%s has no additional dependencies.' % repo_path)

    if len(syncable_repos) > 0:
        print('Syncing dependencies')
        if not dryrun:
            os.system('repo sync --force-sync %s' % ' '.join(syncable_repos))

    for deprepo in verify_repos:
        fetch_dependencies(deprepo)

def has_branch(branches, revision):
    return revision in [branch['name'] for branch in branches]

def get_default_revision_no_minor():
    return get_default_revision().rsplit('.', 1)[0]

def get_default_or_fallback_revision(repo_name):
    default_revision = get_default_revision()
    print("Default revision: %s" % default_revision)
    print("Checking branch info")

    githubreq = urllib.request.Request("https://api.github.com/repos/Blackiron-devices/" + repo_name + "/branches")
    add_auth(githubreq)
    result = json.loads(urllib.request.urlopen(githubreq).read().decode())

    fallbacks = [ get_default_revision_no_minor(), "fourteen" ]

    if os.getenv('ROOMSERVICE_BRANCHES'):
        fallbacks += list(filter(bool, os.getenv('ROOMSERVICE_BRANCHES').split(' ')))

    for fallback in fallbacks:
        if has_branch(result, fallback):
            print("Using fallback branch: %s" % fallback)
            return fallback

    print("Default and fallback revisions not found in %s. Bailing." % repo_name)
    print("Branches found:")
    for branch in [branch['name'] for branch in result]:
        print(branch)
    sys.exit()

if depsonly:
    repo_path = get_from_manifest(device)
    if repo_path:
        fetch_dependencies(repo_path)
    else:
        print("Trying dependencies-only mode on a non-existing device tree?")

    sys.exit()

else:
    for repo_name in repositories:
        if re.match(r"^android_device_[^_]*_" + device + "$", repo_name):
            print("Found repository: %s" % repo_name)
            
            manufacturer = repo_name.replace("android_device_", "").replace("_" + device, "")
            repo_path = "device/%s/%s" % (manufacturer, device)
            revision = get_default_or_fallback_revision(repo_name)

            device_repository = {'repository':repo_name,'target_path':repo_path,'branch':revision}
            add_to_manifest([device_repository])

            print("Syncing repository to retrieve project.")
            os.system('repo sync --force-sync %s' % repo_path)
            print("Repository synced!")

            fetch_dependencies(repo_path)
            print("Done")
            sys.exit()

print("Repository for %s not found in the Blackiron-devices Github repository list. If this is in error, you may need to manually add it to your local_manifests/roomservice.xml." % device)
