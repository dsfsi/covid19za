import os
import datetime

import requests
import urllib.request
import time
from bs4 import BeautifulSoup
import re
import json

import pandas as pd


def get_google_link():
    '''Get link of Google Community Mobility report file
       Returns:
           link (str): link of Google Community report file
    '''
    # get webpage source
    url = 'https://www.google.com/covid19/mobility/'
    response = requests.get(url)
    soup = BeautifulSoup(response.text, "html.parser")
    csv_tag = soup.find('a', {"class": "icon-link"})
    link = csv_tag['href']
    return link

def download_google_report(directory="../data/mobility/google_mobility"):
    '''Download Google Community Mobility report in CSV format
        Args:
            directory: directory to which CSV report will be downloaded
        Returns:
            new_files (bool): flag indicating whether or not new files have been downloaded
    '''
    new_files = False

    # create directory if it don't exist
    if not os.path.exists(directory):
        os.makedirs(directory)

    # download CSV file
    link = get_google_link()
    file_name = "Global_Mobility_Report.csv"
    path = os.path.join(directory, file_name)
    if not os.path.isfile(path):
        new_files = True
        urllib.request.urlretrieve(link, path)
    else:
        path_new = os.path.join(directory, file_name + "_new")
        urllib.request.urlretrieve(link, path_new)
        if os.path.getsize(path) == os.path.getsize(path_new):
            os.remove(path_new)
        else:
            new_files = True
            os.remove(path)
            os.rename(path_new, path)

    if not new_files:
        print('Google: No updates')
    else:
        print('Google: Update available')

    return new_files


def build_google_report(
        source=os.path.join("../data/mobility/google_mobility/", "Global_Mobility_Report.csv"),
        report_type="regions"):
    '''Build cleaned Google report for the worldwide or for some country (currently only for the US)
        Args:
            source: location of the raw Google CSV report
            report_type: two options available: "regions" - report for the worldwide, "US" - report for the US
        Returns:
           google (DataFrame): generated Google report
    '''
    google = pd.read_csv(source, low_memory=False)
    google.columns = google.columns.str.replace(
        r'_percent_change_from_baseline', '')
    google.columns = google.columns.str.replace(r'_', ' ')
    google = google.rename(columns={'country region': 'country'})
    if report_type == "regions":
        google = google[google['sub region 2'].isnull()]
        google = google.rename(columns={'sub region 1': 'region'})
        google = google.loc[:,
                            ['country',
                             'region',
                             'date',
                             'retail and recreation',
                             'grocery and pharmacy',
                             'parks',
                             'transit stations',
                             'workplaces',
                             'residential']]
        google['region'].fillna('Total', inplace=True)
    elif report_type == "ZA":
        google = google[(google['country'] == "South Africa")]
        google = google.rename(
            columns={'sub region 1': 'province'})
        google = google.loc[:,
                            ['province',
                             'date',
                             'retail and recreation',
                             'grocery and pharmacy',
                             'parks',
                             'transit stations',
                             'workplaces',
                             'residential']]
        google['province'].fillna('Total', inplace=True)
    return google

def run():
    new_files_status_google = download_google_report()
    google_za = build_google_report(report_type="ZA")
    google_za.to_csv(os.path.join("../data/mobility/google_mobility/", "mobility_report_ZA.csv"), index=False)

if __name__ == '__main__':
    run()
