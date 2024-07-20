import os
import numpy as np
from locust import HttpUser, task, between
from requests.auth import HTTPBasicAuth
import urllib3

# Global constants
URL = "https://localhost"
NAME_ROOT = "user"
PASSWORD_ROOT = "PassaparolaSuperSegreta"
FILE = "testfile.txt"
KB = "1KB.txt"
MB = "1MB.txt"
GB = "1GB.txt"
RATIO = {
    "download": 3, 
    "1KB": 3, 
    "1MB": 2, 
    "1GB": 1
}

# Disable SSL warnings
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

class CloudUser(HttpUser):

    # Wait time between tasks
    wait_time = between(1, 1)

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.user_id = None

    # User selector on start
    def on_start(self):
        # Random user selection
        self.user_id = self.environment.runner.user_count
        self.name = f"{NAME_ROOT}{self.user_id}"
        self.password = f"{PASSWORD_ROOT}{self.user_id}"
        self.auth = HTTPBasicAuth(self.name, self.password)
        self.login()

    # Login task
    def login(self):
        self.client.post(
            "/index.php/login",
            data={"user": self.name, "password": self.password},
            name="Login",
            verify=False,
        )

    # Download task
    @task(RATIO["download"])
    def download(self, filename=FILE):
        response = self.client.get(
            f"{URL}/remote.php/dav/files/{self.name}/{filename}",
            name="Download",
            auth=self.auth,
            allow_redirects=True,
            verify=False,
        )
        if response.status_code == 200:
            # Rename the downloaded file and save it
            downloadname = filename.split(".")[0]
            downloadname = f"downloads/{downloadname}{self.user_id}.txt"
            with open(downloadname, "wb") as file:
                file.write(response.content)

    # Upload task
    def upload(self, filename):
        # Upload path
        uploadname = filename.split(".")[0]
        uploadname = f"/remote.php/dav/files/{self.name}/{uploadname}-{np.random.randint(0, 100)}.txt"

        # Upload
        with open(f"uploads/{filename}", "rb") as file:
            self.client.put(
                uploadname,
                data=file,
                name="Upload",
                auth=self.auth,
                verify=False,
            )

        # Delete uploaded file (cleanup)
        self.client.delete(
            uploadname,
            name="Delete",
            auth=self.auth,
            verify=False,
        )

    # Upload 1KB task
    @task(RATIO["1KB"])
    def upload_1KB(self):
        self.upload(KB)

    # Upload 1MB task
    @task(RATIO["1MB"])
    def upload_1MB(self):
        self.upload(MB)

    # Upload 1GB task
    @task(RATIO["1GB"])
    def upload_1GB(self):
        self.upload(GB)

# Perform the test if executed as main
if __name__ == "__main__":
        os.system(f"locust -f locustfile.py --host {URL}")