# Nginx S3 File Upload Proxy
S3 file upload proxy using Nginx, complete with AWS authentication.

## Installation

Create a `.env` file to hold your environment variables for Nginx. You can base on the `.env.example` file contained in root folder.

Using Docker, build the image.
```bash
docker build -t nginx-s3-upload .
```

After the image is built, create a container.
```bash
docker run -d -p 8080:80 --env-file=.env nginx-s3-upload
```

## Usage

### Upload file

```bash
curl -v \
-T /path/to/file/to/upload \
-H 'Content-Disposition: filename="file to upload.ext"' \
localhost:8080/upload
```

### List files

```bash
curl http://localhost:8080
```

## Contributing

Issue a pull request and I will love you forever.

## License

nginx-s3-upload is released under the MIT license.
