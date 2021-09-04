FROM docker.io/golang:1.17.0@sha256:7dbfeb9d51c049e8bfe36cf1a4217c7b1ba304bf0eb72d57d0c04f405589f122 AS build

# Build the app
WORKDIR /app
COPY . /app
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -gcflags=./dontoptimizeme=-N -ldflags=-s -o /go/bin/app .
RUN mkdir /data

# Generate licence information
RUN go get github.com/google/go-licenses && go-licenses save ./... --save_path=/notices

FROM gcr.io/distroless/static:nonroot@sha256:be5d77c62dbe7fedfb0a4e5ec2f91078080800ab1f18358e5f31fcc8faa023c4
COPY --from=build /notices /notices
COPY --from=build /go/bin/app /issue-tagger
WORKDIR /
CMD ["/issue-tagger"]
