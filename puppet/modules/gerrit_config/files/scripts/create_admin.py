#!/usr/bin/env python
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
# Creates the first Admin Account
# Example of usage: python create_admin.py --username 'Omar Chavez Orozco' --email 'omar.chavez.orozco@gmail.com' --claimed_id 'https://login.launchpad.net/+id/hJTx374'

import argparse
import os.path
import sys
import logging
import json
LOGGER_NAME = 'create_admin'
from gerrit_common import setup_logging
from gerrit_common import throws
from gerrit_common import which
from gerrit_common import get_ux_home
from gerrit_common import exec_cmd
import subprocess
import re


def find_java():
    return which('java')


def find_gerritwar():
    return os.path.join(get_ux_home('gerrit2'), 'review_site', 'bin', 'gerrit.war')


def find_gerritsite():
    return os.path.join(get_ux_home('gerrit2'), 'review_site')


def gsql_exec(sqlcmd):
    logger = logging.getLogger(LOGGER_NAME)
    try:
        try:
            if sqlcmd == None:
                throws("sqlcmd can't be None")
            if not len(sqlcmd) > 0:
                throws("Missing sqlcmd in gsql_exec")
            logger.info("running gerrit sql : " + str(sqlcmd))
            java_bin = find_java()
            logger.debug('using java_bin : %s' % java_bin)
            gerrit_war = find_gerritwar()
            logger.debug('using gerrit_war : %s' % gerrit_war)
            gerrit_site = find_gerritsite()
            logger.debug('using gerrit_site : %s' % gerrit_site)
            # example
            # /usr/bin/java -jar /home/gerrit2/review_site/bin/gerrit.war gsql -d /home/gerrit2/review_site -c 'show tables' --format JSON
            results = exec_cmd(java_bin, ["-jar", gerrit_war, "gsql", "-d", gerrit_site, "-c", "" + sqlcmd + "", "--format", "JSON"])
            if results.upper().find('ERROR') >= 0:
                    throws("gerrit sql command found errors in results : " + results)
            return (0, results)
        except Exception, err:
            banner_log("Script failed to process gsql: " + str(sqlcmd))
            logger.error('failed to run gsql_exec : ' + str(err))
            return (1, str(err))
    finally:
        logger.debug("finished gsql_exec : " + str(sqlcmd))


def getColumnValue(json_input, column):
    # gsql_exec returns two json strings separated by \n
    # Line 0 is the first json string we need
    logger = logging.getLogger(LOGGER_NAME)
    row1 = json_input.split('\n')
    json_input = row1[0]
    logger.info(json_input)
    try:
        decoded = json.loads(json_input)
        logger.info(column + ": " + str(decoded['columns'][column]))
        return (decoded['columns'][column])
    except (ValueError, KeyError, TypeError):
        print "JSON format error"
        return ('')


def banner_log(msg):
    logger = logging.getLogger(LOGGER_NAME)
    logger.info("+" * 20)
    logger.info(msg)
    logger.info("+" * 20)


# Sql injection Protection
# The inclusion of ' character is the only one that can inject sql in our code
# ' character is not allowed in our inputs
def validName(name):
    r = False
    if name != None and len(name) > 0:
            if re.match('^[a-zA-Z0-9_ ]*$', name) is not None:
                r = True
    return r


# Sql injection Protection
def validEmail(email):
    r = False
    if email != None and len(email) > 6:
        if re.match('[\.\w]{1,}[@]\w+[.]\w+', email) is not None:
            r = True
    return r


# Sql injection Protection
def validClaimedId(url):
    r = False
    if url != None and len(url) > 0:
        if url.find('\'') == -1:
            r = True
    return r


def main():
    global LOGGER_NAME
    # http://docs.python.org/2/library/argparse.html
    parser = argparse.ArgumentParser(description='Creates Gerrit Admin Accounts')
    parser.add_argument('--loglevel', help='Specify the default logging level (optional).', choices=['debug', 'info', 'warning', 'error', 'DEBUG', 'INFO', 'WARNING', 'ERROR'], default='info')
    parser.add_argument('--logfile', help='Specify logfile name.', default='/tmp/create_admin.log')
    parser.add_argument('--debug', help='turn on debug output', action='store_true', default=False)
    parser.add_argument('--working_dir', help='working directory.', default='/tmp')
    parser.add_argument('--username', help='change default user name to create as first account.', default='')
    parser.add_argument('--email', help='specify the email address for the user.', default='')
    parser.add_argument('--claimed_id', help='specify the claimed id, example: https://login.launchpad.net/+id/MJA3AHw', default='')
    # parser.add_argument('--ssh_pubkey', help='pupblic key to use. Example, generate with :\n ssh-keygen -t rsa  -f ~/.ssh/gerrit2 -P ""', default='/home/gerrit2/.ssh/gerrit2.pub')
    parser.add_argument('--check_exists', help='checks if the account exists 0 == exists, 1 == not exists', action='store_true', default=False)
    args = parser.parse_args()
    if args.debug:
        args.loglevel = 'debug'
    logger = setup_logging(args.logfile, args.loglevel, LOGGER_NAME)
    banner_log('create_admin.py')

    # Input Validations
    if (validName(args.username) is False):
        banner_log("Script failed")
        logger.error('username is not valid.')
        return 1

    if (validEmail(args.email) is False):
        banner_log("Script failed")
        logger.error('email is not valid.')
        return 1

    if (validClaimedId(args.claimed_id) is False):
        banner_log("Script failed")
        logger.error('claimed_id is not valid.')
        return 1

    exists = False

    # Verifies if an account with the same email exists
    retval = gsql_exec("SELECT count(*) as count FROM accounts WHERE preferred_email='" + args.email + "'")
    count = getColumnValue(retval[1], 'count')
    if not retval[0] == 0:
        return 1

    if int(count) > 0:
        logger.info("An account with email=" + args.email + " already exists.")
        exists = True

    # Verifies if an account with the same name exists
    retval = gsql_exec("SELECT count(*) as count FROM accounts WHERE full_name='" + args.username + "'")
    count = getColumnValue(retval[1], 'count')
    if not retval[0] == 0:
        return 1

    if int(count) > 0:
        logger.info("An account with full_name=" + args.username + " already exists.")
        exists = True

    # Just check if the account already exists...
    if args.check_exists:
        banner_log('Script completed')
        return exists

    if exists is True:
        logger.info("Skipping create.")
    else:
        # Generates new account_id
        sql_command = "SELECT max(account_id) as max_account_id from accounts"
        retval = gsql_exec(sql_command)
        new_account_id = int(getColumnValue(retval[1], 'max_account_id')) + 1
        if not retval[0] == 0:
            return 1

        # Inserts the new account
        sql_command = "INSERT INTO accounts (full_name, preferred_email, maximum_page_size, show_site_header, use_flash_clipboard, account_id) VALUES ('" + args.username + "', '" + args.email + "',25,'Y','Y', " + str(new_account_id) + ")"
        retval = gsql_exec(sql_command)
        # {"type":"error","message":"Duplicate entry '6' for key 'PRIMARY'"}
        if not retval[0] == 0:
            return 1

        # Inserts the new account_id in the Administrator group
        sql_command = "INSERT INTO account_group_members (account_id, group_id)VALUES (" + str(new_account_id) + ",1)"
        retval = gsql_exec(sql_command)
        if not retval[0] == 0:
            return 1

        # Inserts in external accounts
        sql_command = "INSERT INTO `account_external_ids` (account_id, email_address, password, external_id) VALUES (" + str(new_account_id) + ",'" + args.email + "',NULL,'" + args.claimed_id + "')"
        retval = gsql_exec(sql_command)
        if not retval[0] == 0:
            return 1

        subprocess.call('puppet agent --test > /dev/null 2>&1 &', shell=True, stdin=None, stdout=None, stderr=None, close_fds=True)

    banner_log('Script completed')
    return 0


if __name__ == '__main__':
    sys.exit(main())