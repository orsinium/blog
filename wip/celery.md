---
title: "Why celery sucks"
date: 2023-10-13
tags:
  - python
  - misc
---

## How functions work

...

## How distributed systems work

1. Sending request may fail.
1. Sending request may take a long time.
1. Sending request may be impossible.
1. Response may never arrive.
1. Consumer may run a newer version of code.
1. Consumer may run an older version of code.

...

## Meet Celery

```python
from celery import Celery

app = Celery(...)

@app.task
def add(x, y):
    return x + y

def main():
    future = add.apply_async(4, 4)
    result = future.get()
```

```python
async def add(ctx, x, y):
    return x + y

async def main():
    broker = await create_pool(...)
    job = await broker.enqueue_job('add', 3, 4)
    result = await job.result()
```

## Meet walnats

...
