from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
import pandas as pd

SCOPES = ['https://www.googleapis.com/auth/webmasters.readonly']

SITE_URL = 'https://www.farrokhwin.com/'

flow = InstalledAppFlow.from_client_secrets_file(
    '.secrets/credentials.json',
    SCOPES
)

creds = flow.run_local_server(port=0)

service = build('searchconsole', 'v1', credentials=creds)

request = {
    "startDate": "2025-01-01",
    "endDate": "2026-05-18",
    "dimensions": ["date"],
    "rowLimit": 25000
}

response = service.searchanalytics().query(
    siteUrl=SITE_URL,
    body=request
).execute()

rows = response.get('rows', [])

data = []

for row in rows:
    keys = row["keys"]

    data.append({
        "date": keys[0],
        "query": "",
        "page": "",
        "clicks": row["clicks"],
        "impressions": row["impressions"],
        "ctr": row["ctr"],
        "position": row["position"]
    })

df = pd.DataFrame(data)

output_path = 'data/gsc_real.csv'

df.to_csv(output_path, index=False)

print(f'Saved {len(df)} rows to {output_path}')