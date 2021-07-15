import requests
import json
from datetime import datetime
import pandas as pd

headers = {
    "accept": "application/json, text/plain, */*",
    "accept-language": "en-GB,en-US;q=0.9,en;q=0.8,en-ZA;q=0.7",
    "activityid": "cc2d2d94-b0ce-4b98-8b75-cc50f2ca3e18",
    "cache-control": "no-cache",
    "content-type": "application/json;charset=UTF-8",
    "pragma": "no-cache",
    "requestid": "5cbdc7c5-eaf9-3645-2918-50eae987eaac",
    "sec-ch-ua": "\" Not;A Brand\";v=\"99\", \"Google Chrome\";v=\"91\", \"Chromium\";v=\"91\"",
    "sec-ch-ua-mobile": "?0",
    "sec-fetch-dest": "empty",
    "sec-fetch-mode": "cors",
    "sec-fetch-site": "cross-site",
    "x-powerbi-resourcekey": "03e532ee-b92a-44a5-9be9-d28054e54995"
}

def get_prov_filter(prov):
     with open(f'prov_filter.json') as file:
         prov_filter = json.loads(file.read())
         prov_filter['Condition']['In']['Values'][0][0]['Literal']['Value'] = f"'{prov}'"
         return prov_filter

def ensure_cols_numeric(df, cols):
    for col in cols:
        df[col] = pd.to_numeric(df[col], errors='coerce').astype('Int64')

def fetch_source(data_set, label, filter = None):
    with open(f'cumulative.json') as req:
        content = req.read()
        body = json.loads(content)
        if filter:
            body['queries'][0]['Query']['Commands'][0]['SemanticQueryDataShapeCommand']['Query']['Where'] = [filter]

        res = requests.post("https://wabi-west-europe-api.analysis.windows.net/public/reports/querydata?synchronous=true",headers=headers, json=body)
        data = res.json()
        rows = data["results"][0]["result"]["data"]["dsr"]["DS"][0]["PH"][0]["DM0"]

        # print(json.dumps(data, indent=4))

        for r in rows:
            data = r['C']
            date = datetime.fromtimestamp(data[0]/1000)
            date_str = date.strftime("%Y-%m-%d")

            if not date_str in data_set:
                data_set[date_str] = {
                    'date': date_str,
                    'YYYYMMDD': date.strftime("%Y%m%d")
                }

            data_set[date_str][label] =  data[1]
            
data_set = {}

fetch_source(data_set, "GP", get_prov_filter('Gauteng'))
fetch_source(data_set, "WC", get_prov_filter('Western Cape'))
fetch_source(data_set, "EC", get_prov_filter('Eastern Cape'))
fetch_source(data_set, "FS", get_prov_filter('Free State'))
fetch_source(data_set, "KZN", get_prov_filter('KwaZulu-Natal'))
fetch_source(data_set, "LP", get_prov_filter('Limpopo'))
fetch_source(data_set, "MP", get_prov_filter('Mpumalanga'))
fetch_source(data_set, "NW", get_prov_filter('North West'))
fetch_source(data_set, "NC", get_prov_filter('Northern Cape'))
fetch_source(data_set, "total")

df = pd.DataFrame.from_records(list(data_set.values()))
df = df.sort_values(by=['date'])

ensure_cols_numeric(df, ['EC', 'FS', 'GP', 'KZN', 'LP', 'MP', 'NC', 'NW', 'WC', 'total'])

df['source'] = "https://sacoronavirus.co.za/latest-vaccine-statistics/"

df = df[['date', 'YYYYMMDD', 'EC', 'FS', 'GP', 'KZN', 'LP', 'MP', 'NC', 'NW', 'WC', 'total', 'source']]

df.to_csv('../data/covid19za_provincial_cumulative_timeline_vaccination.csv', index=False)
