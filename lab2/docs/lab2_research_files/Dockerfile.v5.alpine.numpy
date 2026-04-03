FROM python:3.13-alpine

WORKDIR /app

RUN apk add --no-cache \
        build-base \
        openblas-dev \
        lapack-dev \
        gfortran

COPY requirements/backend.txt .

RUN pip install --no-cache-dir -r backend.txt

COPY . .

EXPOSE 8080

CMD ["uvicorn", "spaceship.main:app", "--host=0.0.0.0", "--port=8080"]
