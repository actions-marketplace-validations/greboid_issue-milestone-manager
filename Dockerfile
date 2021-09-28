FROM docker.io/golang:1.17.1@sha256:285cf0cb73ab995caee61b900b2be123cd198f3541ce318c549ea5ff9832bdf0 AS build

# Build the app
WORKDIR /app
COPY . /app
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -gcflags=./dontoptimizeme=-N -ldflags=-s -o /go/bin/app .
RUN mkdir /data

# Generate licence information
RUN go get github.com/google/go-licenses && go-licenses save ./... --save_path=/notices

FROM gcr.io/distroless/static:nonroot@sha256:7cb5539ebb7b99352d736ed97668060cee123285f01705b910891acdf7d945e3
COPY --from=build /notices /notices
COPY --from=build /go/bin/app /issue-tagger
WORKDIR /
CMD ["/issue-tagger"]
