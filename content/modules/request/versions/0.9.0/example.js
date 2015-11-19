hx.request("/file.txt", "text/plain", function(error, data){
  // do something
})
hx.request("/file.txt",{data:11010000}, function(error, data){
  // do something
})


// Load multiple urls with one call to hx.request and one callback
urls = [
  '/file1.txt',
  '/file2.txt'
]
hx.request(urls, function(error, data, source, index){
  if index is -1
    // data is all response data, source is all sources
  else
    // data is single response, index indicates which request
})