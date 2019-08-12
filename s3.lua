function readAll(file)
    local f = assert(io.open(file, "rb"))
    local content = f:read("*all")
    f:close()
    return content
end

function split(inputstr, delimiter)
    local result = { }
    local from  = 1
    local delim_from, delim_to = string.find( inputstr, delimiter, from  )
    while delim_from do
      table.insert( result, string.sub( inputstr, from , delim_from-1 ) )
      from  = delim_to + 1
      delim_from, delim_to = string.find( inputstr, delimiter, from  )
    end
    table.insert( result, string.sub( inputstr, from  ) )
    return result
end

ngx.req.read_body()

local awss3 = require "resty.s3"
local aws_access_key_id = os.getenv('AWS_ACCESS_KEY_ID')
local aws_secret_access_key = os.getenv('AWS_SECRET_ACCESS_KEY')
local bucket = os.getenv('S3_BUCKET_NAME')

local s3 = awss3:new(aws_access_key_id, aws_secret_access_key, bucket, {timeout=1000*10, aws_region='sa-east-1'})

local filename = split(ngx.req.get_headers()['content-disposition'], "filename=")[2]
filename = string.gsub(filename, '"', '')

local data = ngx.req.get_body_file()
local ok, response = s3:put(filename, readAll(data))
