FROM golang:1.24-alpine AS builder

WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download

COPY *.go ./

RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /out/worker ./main.go

FROM gcr.io/distroless/static-debian12

WORKDIR /app

COPY --from=builder /out/worker /app/worker

USER nonroot:nonroot

ENTRYPOINT ["/app/worker"]