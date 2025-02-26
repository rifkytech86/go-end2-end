FROM golang:1.22 AS base

WORKDIR /app
COPY go.mod .
RUN go mod download

# COPY to docker image
COPY . .

# run local
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o main .



#FINAL STAGE
from gcr.io/distroless/base

COPY --from=base /app/main .

COPY  --from=base /app/static ./static

EXPOSE 8080

CMD ["./main"]


