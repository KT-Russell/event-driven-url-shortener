FROM golang:1.23-alpine AS builder

WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download

COPY *.go ./

RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /out/dashboard ./main.go 

FROM gcr.io/distroless/static-debian12 

WORKDIR /app

COPY --from=builder /out/dashboard /app/dashboard

USER nonroot:nonroot

EXPOSE 8081

CMD ["/app/dashboard"]