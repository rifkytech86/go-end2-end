FROM golang:1.24 AS base

WORKDIR /app
COPY go.mod .
RUN go mod download

# COPU to docker image
COPY . .

# run local
RUN go build -o main .



#FINAL STAGE
from gcr.io/distroless/base

COPY --from=base /app/main .

COPY  --from=base /app/static ./static

EXPOSE 8080

CMD ["./main"]


