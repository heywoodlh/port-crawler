## Port-Crawler

Port-crawler is a wrapper for masscan that can upload the output to Elasticsearch.

### Usage:

Easiest way to use port-crawler is with Docker:

```bash
docker run -it -v /tmp:/tmp --net=host --rm heywoodlh/port-crawler port-crawler --ip "192.168.2.0/24 192.168.1.0/24" --port "22 80 443 8080 32400" --elasticsearch "http://localhost:9200"
```
