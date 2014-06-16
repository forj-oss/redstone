# == compiler_tools::params::docs
# Copyright 2013 OpenStack Foundation.
# Copyright 2013 Hewlett-Packard Development Company, L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
#
class compiler_tools::params::docs {
  case $::osfamily {
    'RedHat': {
      $pandoc_package       = 'pandoc'
      $asciidoc_package     = 'asciidoc'
      $docbook_xml_package  = 'docbook-style-xsl'
      $docbook5_xml_package = 'docbook5-schemas'
      $docbook5_xsl_package = 'docbook5-style-xsl'
      $firefox_package      = 'firefox'
      $graphviz_package     = 'graphviz'
      $mod_wsgi_package     = 'mod_wsgi'
      $librrd_dev_package   = 'rrdtool-devel'
      $gnome_doc_package    = 'gnome-doc-utils'
      $libtidy_package      = 'libtidy'
    }
    'Debian': {
      # packages needed by slaves
      $pandoc_package       = 'pandoc'
      $asciidoc_package     = 'asciidoc'
      $docbook_xml_package  = 'docbook-xml'
      $docbook5_xml_package = 'docbook5-xml'
      $docbook5_xsl_package = 'docbook-xsl'
      $firefox_package      = 'firefox'
      $graphviz_package     = 'graphviz'
      $mod_wsgi_package     = 'libapache2-mod-wsgi'
      $librrd_dev_package   = 'librrd-dev'
      $gnome_doc_package    = 'gnome-doc-utils'
      $libtidy_package      = 'libtidy-0.99-0'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} The 'compiler_tools::params::docs' module only supports osfamily Debian or RedHat.")
    }
  }
  # Packages
  $packages = [
    $pandoc_package,         #for docs, markdown->docbook, bug 924507
    $asciidoc_package,       # for building gerrit/building openstack docs
    $docbook_xml_package,    # for building openstack docs
    $docbook5_xml_package,   # for building openstack docs
    $docbook5_xsl_package,   # for building openstack docs
    $firefox_package,        # for selenium tests
    $graphviz_package,       # for generating graphs in docs
    $mod_wsgi_package,
    $librrd_dev_package,     # for python-rrdtool, used by kwapi
    $gnome_doc_package,      # for generating translation files for docs
    $libtidy_package,        # for python-tidy, used by sphinxcontrib-docbookrestapi
  ]
}
