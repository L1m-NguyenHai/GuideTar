"""Locust load test for GuideTar Backend API.

Usage:
    pip install locust
    locust -f tests/locustfile.py --host http://127.0.0.1:8000
"""

from locust import HttpUser, task, between, tag


class GuideTarUser(HttpUser):
    wait_time = between(0.5, 3.0)

    def on_start(self):
        self.token = None
        self.headers = {}

    @task(3)
    @tag("fast")
    def health(self):
        self.client.get("/health")

    @task(2)
    @tag("fast")
    def catalog_recommended(self):
        self.client.get("/catalog/recommended")

    @task(2)
    @tag("fast")
    def catalog_artists(self):
        self.client.get("/catalog/artists")

    @task(1)
    @tag("fast")
    def billing_plans(self):
        self.client.get("/billing/plans")

    @task(1)
    @tag("fast")
    def support_categories(self):
        self.client.get("/support/categories")

    @task(1)
    @tag("fast")
    def support_faqs(self):
        self.client.get("/support/faqs")

    @task(1)
    @tag("fast")
    def artists(self):
        self.client.get("/artists/beatles")

    @task(1)
    @tag("auth")
    def users_me(self):
        if not self.token:
            return
        self.client.get("/users/me", headers=self.headers)

    @task(1)
    @tag("auth")
    def dechord_history(self):
        if not self.token:
            return
        self.client.get("/api/analyze/history", headers=self.headers)

    @task(1)
    @tag("auth")
    def favorites_songs(self):
        if not self.token:
            return
        self.client.get("/favorites/songs", headers=self.headers)

    @task(1)
    @tag("auth")
    def favorites_lessons(self):
        if not self.token:
            return
        self.client.get("/favorites/lessons", headers=self.headers)

    @task(1)
    @tag("auth")
    def notes(self):
        if not self.token:
            return
        self.client.get("/notes/", headers=self.headers)
