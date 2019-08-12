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

function new()
  local awss3 = require "resty.s3"
  local aws_access_key_id = os.getenv('AWS_ACCESS_KEY_ID')
  local aws_secret_access_key = os.getenv('AWS_SECRET_ACCESS_KEY')
  local bucket = os.getenv('S3_BUCKET_NAME')

  return awss3:new(aws_access_key_id, aws_secret_access_key, bucket, {timeout=1000*10, aws_region='sa-east-1'})
end

function put()
  ngx.req.read_body()

  local s3 = new()

  local filename = split(ngx.req.get_headers()['content-disposition'], "filename=")[2]
  filename = string.gsub(filename, '"', '')

  local data = ngx.req.get_body_file()
  local ok, response, status = s3:put(filename, readAll(data))

  if not ok then
    ngx.status = status
    ngx.say(response)
    return
  end
end

function list()
  local s3 = new()

  local ok, doc, status = s3:list('')
  if not ok then
    ngx.status = status
    ngx.say(doc)
    return
  end

  if not doc.ListBucketResult.Contents then
    ngx.status = ngx.HTTP_NO_CONTENT
    return
  end

  local result = ""
  local contents = doc.ListBucketResult.Contents

  -- There is only 1 file
  if contents.Key then
    result = result..contents.LastModified..'\t'..contents.Size..'\t'..contents.Key
  else
    -- More than 1 file
    for k, v in pairs(doc.ListBucketResult.Contents) do
      result = result..v.LastModified..'\t'..v.Size..'\t'..v.Key
      result = result..'\n'
    end
  end
  -- Remove leading line break
  if result ~= "" then
    result = result:sub(1, result:len()-1)
  end

  ngx.say(result)
end

local method = ngx.var.request_method
if method == 'PUT' then
  put()
elseif method == 'GET' then
  list()
end
