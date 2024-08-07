#!/usr/bin/python
#
# Copyright 2018 Google LLC
# $HOME/.local/bin
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

import random
from locust import FastHttpUser, TaskSet, User, between, events, LoadTestShape, task, tag, constant_pacing
from typing import Tuple, Optional
from faker import Faker
import logging
import datetime

import locust.stats
locust.stats.CSV_STATS_INTERVAL_SEC = 10

from locust.runners import MasterRunner, LocalRunner
from locust.env import Environment

fake = Faker()

products = [
    '0PUK6V6EV0',
    '1YMWWN1N4O',
    '2ZYFJ3GM2N',
    '66VCHSJNUP',
    '6E92ZMYYFZ',
    '9SIQT8TOJO',
    'L9ECAV7KIM',
    'LS4PSXUNUM',
    'OLJCESPC7Z']


class WebsiteUser(FastHttpUser):

    def on_start(self):
        self.index()

    @task(3)
    def reset_index(self):
        
        self.client.get("/", headers={"Connection": "close"})

    # 1 req
    @task(10)
    def index(self):
        self.client.get("/")

    # 1 req
    @task(20)
    def setCurrency(self):
        currencies = ['EUR', 'USD', 'JPY', 'CAD', 'GBP', 'TRY']
        self.client.post("/setCurrency",
            {'currency_code': random.choice(currencies)})

    # 1 req
    @task(100)
    def browseProduct(self):
        self.client.get("/product/" + random.choice(products))

    # 1 req
    @task(30)
    def viewCart(self):
        self.client.get("/cart")

    # 2 reqs
    @task(30)
    def addToCart(self):
        product = random.choice(products)
        self.client.get("/product/" + product)
        self.client.post("/cart", {
            'product_id': product,
            'quantity': random.randint(1,10)})

    # 1 req
    @task(10)
    def empty_cart(self):
        self.client.post('/cart/empty')

    # 3 reqs
    @task(20)
    def checkout(self):
        self.addToCart()
        current_year = datetime.datetime.now().year+1
        self.client.post("/cart/checkout", {
            'email': fake.email(),
            'street_address': fake.street_address(),
            'zip_code': fake.zipcode(),
            'city': fake.city(),
            'state': fake.state_abbr(),
            'country': fake.country(),
            'credit_card_number': fake.credit_card_number(card_type="visa"),
            'credit_card_expiration_month': random.randint(1, 12),
            'credit_card_expiration_year': random.randint(current_year, current_year + 70),
            'credit_card_cvv': f"{random.randint(100, 999)}",
        })

    # 1 req
    def logout(self):
        self.client.get('/logout')  

    wait_time = between(1, 5)

# class SingleLoad(LoadTestShape):
#     """
#     A load shape that only steps up to a single value, specified by --max-users

#     Keyword arguments:

#         wait_time   -- time to wait after user goal is met

#         spawn_rate  -- users spawned per second while still spawning
    
#     """

#     abstract=True

#     wait_time: int = 15 * 60 
#     spawn_rate: int = 5
#     users: int = 0

#     def __init__(self, *args, **kwargs):
#         self._target_timestamp: float = 0

#         # if self.runner == None or self.runner.environment.parsed_options == None:
#         #     logging.fatal("UH OH! self.runner==None or self.runner.env.parsed_options == None!!")
#         #     exit(4)
        
#         # self.users = self.runner.environment.parsed_options.max_users

#         # self.runner.environment.reset_stats = True
#         self.users = get_max_users()
#         super().__init__(*args, **kwargs)

#     def tick(self):
#         cur_users = self.get_current_user_count()
#         cur_time = self.get_run_time()

#         if cur_users == self.users:
#             if self._target_timestamp == 0:
#                 self._target_timestamp = cur_time

#             elif cur_time - self._target_timestamp >= self.wait_time:
#                 #all done running
#                 return None

#         return self.users, self.spawn_rate


class MultiLoad(LoadTestShape):
    """
    A step load shape

    Keyword arguments:
        
        step_time       -- Time between steps

        step_load       -- User increase amount at each step

        spawn_rate      -- Users to stop/start per second at every step

        num_steps       -- When to terminate
    """
    
    # Time between steps
    step_time = 8 * 60 # 8 minutes
    
    # Users at each step
    # step_load = [1000, 2000, 4000, 6000, 8000, 10000, 12000, 14000, 16000]
    step_load = [1000, 2500, 5000, 7500, 10000, 12500, 15000, 17500]

    # Users to stop/start per second while amount is changing.
    spawn_rate = 4

    abstract=True

    # When to terminate
    num_steps = len(step_load)

    def __init__(self, *args, **kwargs):
        self._step = 0
        self._target_timestamp = 0
        super().__init__(*args, **kwargs)

    def tick(self) -> Optional[Tuple[int, float]]:
        cur_users = self.get_current_user_count()
        cur_time = self.get_run_time()

        target_users = self.step_load[self._step]
        out_str = f"users: {cur_users}/{target_users}"
        
        # if we are done spawning
        if cur_users == target_users:
            

            # if we *just* reached target
            if self._target_timestamp == 0:
                # start timer
                self._target_timestamp = cur_time
            else:
                elapsed = cur_time - self._target_timestamp
                # out_str += f"\t time remaining: {self.step_time[self._step] - elapsed:.2f}"
                out_str += f"\t time remaining: {self.step_time - elapsed:.2f}"
                # logging.info(f"elapsed: {elapsed}\n")
                # if time has gone on long enough
                # if elapsed >= self.step_time[self._step]:

                if elapsed >= self.step_time:
                    # self._check_tail()

                    self._target_timestamp = 0
                    self._step += 1

                    # if we have just completed the last step
                    if self._step == self.num_steps:
                        return None


        logging.info(out_str)
        return target_users, self.spawn_rate