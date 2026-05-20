from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from pathlib import Path
import pickle

SCOPES = ["https://www.googleapis.com/auth/webmasters.readonly"]

SECRETS_DIR = Path(".secrets")
CREDENTIALS_FILE = SECRETS_DIR / "credentials.json"
TOKEN_FILE = SECRETS_DIR / "token.pickle"

if TOKEN_FILE.exists():
    with open(TOKEN_FILE, "rb") as token:
        creds = pickle.load(token)
else:
    flow = InstalledAppFlow.from_client_secrets_file(
        str(CREDENTIALS_FILE),
        SCOPES
    )
    creds = flow.run_local_server(port=0)
    with open(TOKEN_FILE, "wb") as token:
        pickle.dump(creds, token)

service = build("searchconsole", "v1", credentials=creds)

sites = service.sites().list().execute()

print("\nAvailable Search Console properties:\n")

for site in sites.get("siteEntry", []):
    print(f"- {site.get('siteUrl')} | permission: {site.get('permissionLevel')}")