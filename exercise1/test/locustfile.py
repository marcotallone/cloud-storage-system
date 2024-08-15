from gevent import monkey

monkey.patch_all()

import os

import numpy as np
import urllib3
from locust import HttpUser, between, task
from requests.auth import HTTPBasicAuth

# Global constants
URL = "https://localhost"
NAME_ROOT = "user"
PASSWORD_ROOT = "PassaparolaSuperSegreta"
FILE = "testfile.txt"

# Disable SSL warnings
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


# User class for the Nextcloud locust test
# NOTE: Depending on your lsp configuration, you might get the error
# 'No parameter named "name"' in the functions below. However, such parameter
# is helpful to name and group the requests in the locust web interface.
class NextcloudUser(HttpUser):
    """User class for the Nextcloud locust test"""

    # Wait time between tasks
    wait_time = between(1, 3)

    # User attributes
    user_id = None
    name = None
    password = None
    auth = None
    counter = 0

    # User selector on start
    def on_start(self):
        self.user_id = np.random.randint(1, 50)
        self.name = f"{NAME_ROOT}{self.user_id}"
        self.password = f"{PASSWORD_ROOT}{self.user_id}"
        self.auth = HTTPBasicAuth(self.name, self.password)
        self.counter = 0

    @task(5)
    def download(self):
        """Download a file from the server"""
        response = self.client.get(
            f"https://localhost/remote.php/dav/files/{self.name}/{FILE}",
            name="Download",
            auth=self.auth,
            allow_redirects=True,
            verify=False,
        )
        if response.status_code == 200:
            with open(
                f"downloads/doenload_{self.name}_{self.counter}.txt", "wb"
            ) as file:
                file.write(response.content)
        self.counter += 1

    @task(10)
    def read(self):
        """Read a file from the server"""
        self.client.get(
            f"/remote.php/dav/files/{self.name}/{FILE}",
            name="Read",
            auth=self.auth,
            verify=False,
        )

    @task(10)
    def upload_one_kb(self):
        """Upload a 1KB file to the server"""
        with open("uploads/1KB.txt", "rb") as file:
            response = self.client.put(
                f"/remote.php/dav/files/{self.name}/1KB_{self.counter}.txt",
                name="Upload 1KB",
                data=file,
                auth=self.auth,
                verify=False,
            )
        if response.status_code == 200:
            self.client.delete(
                f"/remote.php/dav/files/{self.name}/1KB_{self.counter}.txt",
                name="Delete 1KB",
                auth=self.auth,
                verify=False,
            )
            self.counter += 1

    @task(5)
    def upload_one_mb(self):
        """Upload a 1MB file to the server"""
        with open("uploads/1MB.txt", "rb") as file:
            response = self.client.put(
                f"/remote.php/dav/files/{self.name}/1MB_{self.counter}.txt",
                name="Upload 1MB",
                data=file,
                auth=self.auth,
                verify=False,
            )
        if response.status_code == 200:
            self.client.delete(
                f"/remote.php/dav/files/{self.name}/1MB_{self.counter}.txt",
                name="Delete 1MB",
                auth=self.auth,
                verify=False,
            )
            self.counter += 1

    @task(1)
    def upload_one_gb(self):
        """Upload a 1GB file to the server"""
        with open("uploads/1GB.txt", "rb") as file:
            response = self.client.put(
                f"/remote.php/dav/files/{self.name}/1GB_{self.counter}.txt",
                name="Upload 1GB",
                data=file,
                auth=self.auth,
                timeout=600,
                verify=False,
            )
        if response.status_code == 200:
            self.client.delete(
                f"/remote.php/dav/files/{self.name}/1GB_{self.counter}.txt",
                name="Delete 1GB",
                auth=self.auth,
                timeout=600,
                verify=False,
            )
            self.counter += 1


# Perform the test if executed as main
if __name__ == "__main__":
    os.system(f"locust -f locustfile.py --host {URL}")
