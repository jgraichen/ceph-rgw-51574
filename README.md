# Demonstration for [#51574](https://tracker.ceph.com/issues/51574)

## Usage

```
docker-compose up

gem install aws-sdk-s3
ruby ./script.rb
```

## Description

The `docker-compose.yml` sets up a ceph demo environment based on the `quay.io/ceph/daemon` image. A container image tag can be specified using the `CEPH_TAG` environment variable.

The `./script.rb` ruby script uses the `aws-sdk-s3` client to first set up the S3 policy defined in `policy.yml`, and then tries to upload a file. This will crash the `radosgw` process, and the container will stop.

## CI

See https://github.com/jgraichen/ceph-rgw-51574/actions. If the test is green, `radosgw` likely did crash.
